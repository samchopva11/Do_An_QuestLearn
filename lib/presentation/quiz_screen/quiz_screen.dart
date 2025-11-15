// Dán toàn bộ code này vào file: lib/presentation/quiz_screen/quiz_screen.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <<<< THÊM MỚI: Import Firebase Auth
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

  const QuizScreen({
    Key? key,
    required this.categoryId,
    required this.difficulty,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  // <<<< THÊM MỚI: Khai báo các instance của Firebase
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Biến mới để lưu câu hỏi từ Firestore
  List<QueryDocumentSnapshot> _realQuestions = [];
  late Future<void> _loadQuestionsFuture;

  // Quiz state
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  List<int?> _userAnswers = [];
  Timer? _timer;
  int _timeRemaining = 300;
  bool _isQuizCompleted = false;
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadQuestionsFuture = _fetchQuestions();
    _setupAnimations();
  }

  Future<void> _fetchQuestions() async {
    try {
      final querySnapshot = await _firestore
          .collection('categories')
          .doc(widget.categoryId)
          .collection('questions')
          .where('difficulty', isEqualTo: widget.difficulty)
          .get();

      _realQuestions = querySnapshot.docs;
      _realQuestions.shuffle();

      _initializeQuizState();
    } catch (e) {
      throw Exception('Lỗi tải câu hỏi: $e');
    }
  }

  void _initializeQuizState() {
    _userAnswers = List.filled(_realQuestions.length, null);
    _startTimer();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
    _slideController.forward();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeRemaining > 0) {
            _timeRemaining--;
          } else {
            _handleTimeUp();
          }
        });
      }
    });
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

  // <<<< THÊM MỚI: Hàm để cập nhật tiến độ lên Firestore
  Future<void> _updateProgress(int finalScore, int totalQuestions) async {
    final user = _auth.currentUser;
    // Nếu người dùng chưa đăng nhập hoặc không có câu hỏi thì không làm gì cả
    if (user == null || totalQuestions == 0) {
      return;
    }

    // Tính toán tiến độ dưới dạng số thập phân (ví dụ: 0.5 cho 50%)
    final double newProgress = finalScore / totalQuestions;

    try {
      final progressRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('enrolledCourses')
          .doc(widget.categoryId);

      // Dùng 'update' để chỉ cập nhật các trường cần thiết
      // và không ghi đè các trường khác như 'enrolledAt'
      await progressRef.update({
        'progress': newProgress,
        'lastStudied': FieldValue.serverTimestamp(), // Cập nhật thời điểm học gần nhất
      });

      print("Cập nhật tiến độ thành công!");

    } catch (e) {
      print("Đã có lỗi khi cập nhật tiến độ: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: Không thể cập nhật tiến độ.")),
        );
      }
    }
  }

  // <<<< CHỈNH SỬA: Thay đổi hàm _finishQuiz để gọi hàm cập nhật
  void _finishQuiz() {
    if (_isQuizCompleted) return; // Tránh gọi hàm này nhiều lần

    _timer?.cancel();
    setState(() {
      _isQuizCompleted = true;
    });

    int correctAnswers = 0;
    for (int i = 0; i < _realQuestions.length; i++) {
      final questionData = _realQuestions[i].data() as Map<String, dynamic>;
      if (_userAnswers[i] != null &&
          _userAnswers[i] == questionData['correctAnswerIndex']) {
        correctAnswers++;
      }
    }

    // <<<< CHỈNH SỬA: Gọi hàm cập nhật tiến độ ngay sau khi tính điểm
    if (_realQuestions.isNotEmpty) {
      _updateProgress(correctAnswers, _realQuestions.length);
    }

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Hoàn thành!'),
          content: Text('Bạn đã trả lời đúng $correctAnswers / ${_realQuestions.length} câu.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if(mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ExitConfirmationDialog(
          onConfirmExit: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            _timer?.cancel();
          },
          onContinueQuiz: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadQuestionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Đang chuẩn bị câu hỏi..."),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text("Lỗi")),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Không thể tải được câu hỏi. Vui lòng thử lại.\nChi tiết: ${snapshot.error}"),
              ),
            ),
          );
        }

        if (_realQuestions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text("Không có câu hỏi")),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Rất tiếc, chưa có câu hỏi nào cho độ khó \"${widget.difficulty}\" trong chủ đề này."),
              ),
            ),
          );
        }

        final currentQuestionData =
        _realQuestions[_currentQuestionIndex].data() as Map<String, dynamic>;
        final isLastQuestion =
            _currentQuestionIndex == _realQuestions.length - 1;
        final canGoNext = _selectedOptionIndex != null;
        final canGoPrevious = _currentQuestionIndex > 0;

        return WillPopScope(
          onWillPop: () async {
            _showExitConfirmation();
            return false;
          },
          child: Scaffold(
            backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
            body: Column(
              children: [
                QuizHeaderWidget(
                  currentQuestion: _currentQuestionIndex + 1,
                  totalQuestions: _realQuestions.length,
                  timeRemaining: _timeRemaining,
                  onExitPressed: _showExitConfirmation,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: QuestionContentWidget(
                        questionText: currentQuestionData["content"] ?? "Nội dung câu hỏi bị thiếu",
                        options: (currentQuestionData["options"] as List).cast<String>(),
                        selectedOptionIndex: _selectedOptionIndex,
                        onOptionSelected: _selectOption,
                      ),
                    ),
                  ),
                ),
                QuizNavigationWidget(
                  canGoNext: canGoNext,
                  canGoPrevious: canGoPrevious,
                  isLastQuestion: isLastQuestion,
                  onNextPressed: canGoNext ? _goToNextQuestion : null,
                  onPreviousPressed: canGoPrevious ? _goToPreviousQuestion : null,
                  onFinishPressed: canGoNext ? _finishQuiz : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

