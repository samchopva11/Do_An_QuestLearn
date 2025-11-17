// Dán toàn bộ code này vào file: lib/presentation/quiz_screen/quiz_screen.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/exit_confirmation_dialog.dart';
import './widgets/question_content_widget.dart';
import './widgets/quiz_header_widget.dart';
import './widgets/quiz_navigation_widget.dart';

class QuizScreen extends StatefulWidget {
  final String categoryId;
  final String difficulty;
  final int durationInSeconds;

  const QuizScreen({
    Key? key,
    required this.categoryId,
    required this.difficulty,
    required this.durationInSeconds,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<QueryDocumentSnapshot> _realQuestions = [];
  late Future<void> _loadQuestionsFuture;

  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  List<int?> _userAnswers = [];
  Timer? _timer;
  int _timeRemaining = 0;
  bool _isQuizCompleted = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.durationInSeconds;
    _loadQuestionsFuture = _fetchQuestions();
    _setupAnimations();
  }

  // =================================================================
  // =====        SỬA LỖI 2: SỬA HÀM CẬP NHẬT TIẾN ĐỘ             =====
  // =================================================================
  Future<void> _updateProgress(int finalScore, int totalQuestions) async {
    final user = _auth.currentUser;
    if (user == null || totalQuestions == 0) return;

    final int scorePercentage = (finalScore * 100 / totalQuestions).round();
    final bool passedThisQuiz = scorePercentage >= 50;

    final int timeSpentInSeconds = widget.durationInSeconds - _timeRemaining;

    try {
      final progressRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('enrolledCourses')
          .doc(widget.categoryId);

      // 1. Dùng transaction để đảm bảo dữ liệu đọc và ghi là nhất quán
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(progressRef);
        final data = doc.data() as Map<String, dynamic>? ?? {};

        // 2. Cập nhật trạng thái "đã qua"
        Map<String, dynamic> updates = {};
        if (passedThisQuiz) {
          if (widget.difficulty == 'Dễ' && !(data['passedEasy'] ?? false)) {
            updates['passedEasy'] = true;
          } else if (widget.difficulty == 'Trung bình' && !(data['passedMedium'] ?? false)) {
            updates['passedMedium'] = true;
          } else if (widget.difficulty == 'Khó' && !(data['passedHard'] ?? false)) {
            updates['passedHard'] = true;
          }
        }

        // 3. Tính toán lại % tiến độ tổng
        int passedLevels = 0;
        if (data['passedEasy'] == true || updates['passedEasy'] == true) passedLevels++;
        if (data['passedMedium'] == true || updates['passedMedium'] == true) passedLevels++;
        if (data['passedHard'] == true || updates['passedHard'] == true) passedLevels++;
        double newTotalProgress = passedLevels / 3.0;

        // 4. Tính toán điểm trung bình mới
        List<dynamic> scoreHistory = List.from(data['scoreHistory'] ?? []);
        scoreHistory.add({'score': scorePercentage}); // Thêm điểm của lần này vào
        double totalScore = scoreHistory.fold(0, (sum, item) => sum + (item['score'] ?? 0));
        double newAverageScore = totalScore / scoreHistory.length;

        // 5. Gộp tất cả cập nhật và ghi vào transaction
        updates.addAll({
          'lastStudied': FieldValue.serverTimestamp(),
          'scoreHistory': FieldValue.arrayUnion([
            {
              'score': scorePercentage,
              'timestamp': Timestamp.now(),
              'difficulty': widget.difficulty
            }
          ]),
          'timeSpent': FieldValue.increment(timeSpentInSeconds),
          'progress': newTotalProgress,
          'averageScore': newAverageScore, // << THÊM TRƯỜNG MỚI
        });

        if (doc.exists) {
          transaction.update(progressRef, updates);
        } else {
          // Trường hợp này hiếm khi xảy ra nếu logic enroll đúng
          transaction.set(progressRef, updates);
        }
      });
    } catch (e) {
      print("Lỗi transaction khi cập nhật tiến độ: $e");
    }
  }

  // --- Các hàm còn lại giữ nguyên hoặc không có thay đổi logic lớn ---

  Future<void> _fetchQuestions() async { try { final querySnapshot = await _firestore .collection('categories') .doc(widget.categoryId) .collection('questions') .where('difficulty', isEqualTo: widget.difficulty) .get(); _realQuestions = querySnapshot.docs; _realQuestions.shuffle(); _initializeQuizState(); } catch (e) { throw Exception('Lỗi tải câu hỏi: $e'); } }
  void _initializeQuizState() {
    _userAnswers = List.filled(_realQuestions.length, null);
    _startTimer();
  }
  void _setupAnimations() {
    _slideController = AnimationController( duration: const Duration(milliseconds: 300), vsync: this, );
    _slideAnimation = Tween<Offset>( begin: const Offset(1.0, 0.0), end: Offset.zero, ).animate(CurvedAnimation( parent: _slideController, curve: Curves.easeInOut, ));
    _slideController.forward();
  }
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) { if (mounted) { setState(() { if (_timeRemaining > 0) { _timeRemaining--; } else { _handleTimeUp(); } }); } });
  }
  void _handleTimeUp() {
    _timer?.cancel();
    if (!_isQuizCompleted) {
      _finishQuiz();
    }
  }
  void _selectOption(int optionIndex) {
    if (!_isQuizCompleted) {
      HapticFeedback.selectionClick();
      setState(() {
        _selectedOptionIndex = optionIndex;
        _userAnswers[_currentQuestionIndex] = optionIndex;
      });
    }
  }
  void _goToNextQuestion() {
    if (_currentQuestionIndex < _realQuestions.length - 1) {
      _slideController.reset();
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = _userAnswers[_currentQuestionIndex];
      });
      _slideController.forward();
    }
  }
  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      _slideController.reset();
      setState(() {
        _currentQuestionIndex--;
        _selectedOptionIndex = _userAnswers[_currentQuestionIndex];
      });
      _slideController.forward();
    }
  }
  void _finishQuiz() {
    if (_isQuizCompleted) return;
    _timer?.cancel();
    setState(() { _isQuizCompleted = true; });
    int correctAnswers = 0;
    for (int i = 0; i < _realQuestions.length; i++) {
      final questionData = _realQuestions[i].data() as Map<String, dynamic>;
      if (_userAnswers[i] != null && _userAnswers[i] == questionData['correctAnswerIndex']) {
        correctAnswers++;
      }
    }
    if (_realQuestions.isNotEmpty) {
      _updateProgress(correctAnswers, _realQuestions.length);
    }
    Future.delayed(const Duration(milliseconds: 500), () { if (!mounted) return; showDialog( context: context, barrierDismissible: false, builder: (dialogContext) => AlertDialog( title: const Text('Hoàn thành!'), content: Text('Bạn đã trả lời đúng $correctAnswers / ${_realQuestions.length} câu.'), actions: [ TextButton( onPressed: () { Navigator.of(dialogContext).pop(); if (mounted) { Navigator.of(context).pop(true); } }, child: const Text('OK'), ), ], ), ); }); }
  void _showExitConfirmation() { showDialog ( context: context, barrierDismissible: false, builder: (BuildContext context) { return ExitConfirmationDialog( onConfirmExit: () { Navigator.of(context).pop(); Navigator.of(context).pop(); _timer?. cancel(); }, onContinueQuiz: () { Navigator.of(context).pop(); }, ); }, ); }
  @override void dispose() { _timer?.cancel(); _slideController.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) { return FutureBuilder( future: _loadQuestionsFuture, builder: (context, snapshot) { if (snapshot.connectionState == ConnectionState.waiting) { return const Scaffold( body: Center( child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ CircularProgressIndicator(), SizedBox(height: 16), Text("Đang chuẩn bị câu hỏi..."), ], ), ), ); } if (snapshot.hasError) { return Scaffold( appBar: AppBar(title: Text("Lỗi")), body: Center( child: Padding( padding: const EdgeInsets.all(16.0), child: Text("Không thể tải được câu hỏi. Vui lòng thử lại.\nChi tiết: ${snapshot.error}"), ), ), ); } if (_realQuestions.isEmpty) { return Scaffold( appBar: AppBar(title: Text("Không có câu hỏi")), body: Center( child: Padding( padding: const EdgeInsets.all(16.0), child: Text("Rất tiếc, chưa có câu hỏi nào cho độ khó \"${widget.difficulty}\" trong chủ đề này."), ), ), ); } final currentQuestionData = _realQuestions[_currentQuestionIndex].data() as Map<String, dynamic>; final isLastQuestion = _currentQuestionIndex == _realQuestions.length - 1; final canGoNext = _selectedOptionIndex != null; final canGoPrevious = _currentQuestionIndex > 0; return WillPopScope( onWillPop: () async { _showExitConfirmation(); return false; }, child: Scaffold( backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor, body: Column( children: [ QuizHeaderWidget( currentQuestion: _currentQuestionIndex + 1, totalQuestions: _realQuestions.length, timeRemaining: _timeRemaining, onExitPressed: _showExitConfirmation, ), Expanded( child: SingleChildScrollView( child: SlideTransition( position: _slideAnimation, child: QuestionContentWidget( questionText: currentQuestionData["content"] ?? "Nội dung câu hỏi bị thiếu", options: (currentQuestionData["options"] as List).cast<String>(), selectedOptionIndex: _selectedOptionIndex, onOptionSelected: _selectOption, ), ), ), ), QuizNavigationWidget( canGoNext: canGoNext, canGoPrevious: canGoPrevious, isLastQuestion: isLastQuestion, onNextPressed: canGoNext ? _goToNextQuestion : null, onPreviousPressed: canGoPrevious ? _goToPreviousQuestion : null, onFinishPressed: canGoNext ? _finishQuiz : null, ), ], ), ), ); }, ); }
}

