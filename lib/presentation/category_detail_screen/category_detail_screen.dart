// Dán toàn bộ code này vào file: lib/presentation/category_detail_screen/category_detail_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_demo/presentation/quiz_screen/quiz_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:rxdart/rxdart.dart';

import '../../core/app_export.dart';
import './widgets/category_hero_section.dart';
import './widgets/enrollment_action_button.dart';
import './widgets/overview_tab.dart';
import './widgets/progress_tab.dart';
import './widgets/quizzes_tab.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String categoryId;

  const CategoryDetailScreen({
    Key? key,
    required this.categoryId,
  }) : super(key: key);

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool _isEnrolling = false;

  // << THÊM BIẾN ĐỂ LƯU DỮ LIỆU CATEGORY >>
  Map<String, dynamic>? _categoryData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ==========================================================
  // =====        SỬA LỖI: CẬP NHẬT HÀM START QUIZ        =====
  // ==========================================================
  void _handleStartQuiz(String difficulty) {
    if (_categoryData == null) return; // Kiểm tra an toàn

    // Lấy thông tin thời gian từ _categoryData
    // Ví dụ: easyDuration, mediumDuration, hardDuration (tính bằng phút)
    int durationInMinutes = 30; // Mặc định là 30 phút nếu không có dữ liệu
    if (difficulty == 'Dễ') {
      durationInMinutes = _categoryData!['easyDuration'] ?? 30;
    } else if (difficulty == 'Trung bình') {
      durationInMinutes = _categoryData!['mediumDuration'] ?? 45;
    } else if (difficulty == 'Khó') {
      durationInMinutes = _categoryData!['hardDuration'] ?? 60;
    }

    // Chuyển đổi phút sang giây
    final int durationInSeconds = durationInMinutes * 60;

    // Điều hướng và truyền tham số mới
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          categoryId: widget.categoryId,
          difficulty: difficulty,
          durationInSeconds: durationInSeconds, // << TRUYỀN THỜI GIAN VÀO ĐÂY
        ),
      ),
    );
  }

  Future<void> _handleEnrollment(bool isEnrolled) async {
    final user = _auth.currentUser;
    if (user == null) return;

    setState(() {
      _isEnrolling = true;
    });

    try {
      final courseRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('enrolledCourses')
          .doc(widget.categoryId);

      if (isEnrolled) {
        await courseRef.delete();
      } else {
        await courseRef.set({
          'progress': 0.0,
          'enrolledAt': FieldValue.serverTimestamp(),
          'lastStudied': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã có lỗi xảy ra: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isEnrolling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return StreamBuilder<List<DocumentSnapshot>>(
      stream: _combineStreams(user),
      builder: (context, combinedSnapshot) {
        if (combinedSnapshot.connectionState == ConnectionState.waiting && !combinedSnapshot.hasData) {
          return _buildLoadingState();
        }

        if (combinedSnapshot.hasError) {
          return _buildErrorState(combinedSnapshot.error.toString());
        }

        if (!combinedSnapshot.hasData || combinedSnapshot.data!.isEmpty) {
          return _buildErrorState("Không tìm thấy dữ liệu chủ đề.");
        }

        final categorySnapshot = combinedSnapshot.data![0];
        final progressSnapshot = combinedSnapshot.data!.length > 1 ? combinedSnapshot.data![1] : null;

        if (!categorySnapshot.exists) {
          return _buildErrorState("Không tìm thấy chủ đề với ID này.");
        }

        // << LƯU DỮ LIỆU VÀO BIẾN STATE >>
        _categoryData = categorySnapshot.data() as Map<String, dynamic>;

        final bool isEnrolled = progressSnapshot != null && progressSnapshot.exists;

        final Map<String, dynamic> userProgressData =
        isEnrolled ? progressSnapshot.data() as Map<String, dynamic> : {};

        return Scaffold(
          backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
          body: Column(
            children: [
              CategoryHeroSection(
                category: _categoryData!,
                isEnrolled: isEnrolled,
                onEnrollmentToggle: () {},
              ),
              Container(
                color: AppTheme.lightTheme.colorScheme.surface,
                child: TabBar(
                  controller: _tabController,
                  tabs: [
                    _buildTab('info_outline', "Tổng quan", 0),
                    _buildTab('quiz', "Bài quiz", 1),
                    _buildTab('trending_up', "Tiến độ", 2),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    OverviewTab(category: _categoryData!),
                    QuizzesTab(
                      category: _categoryData!,
                      onStartQuiz: _handleStartQuiz,
                      onReviewResults: (difficulty) {},
                    ),
                    ProgressTab(
                      category: _categoryData!,
                      userProgress: userProgressData,
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: EnrollmentActionButton(
            isEnrolled: isEnrolled,
            isLoading: (combinedSnapshot.connectionState == ConnectionState.waiting) || _isEnrolling,
            onEnroll: () => _handleEnrollment(false),
            onUnenroll: () => _handleEnrollment(true),
            onContinue: () => _tabController.animateTo(1),
          ),
        );
      },
    );
  }

  Stream<List<DocumentSnapshot>>? _combineStreams(User? user) {
    Stream<DocumentSnapshot> categoryStream =
    _firestore.collection('categories').doc(widget.categoryId).snapshots();

    if (user == null) {
      return categoryStream.map((categoryDoc) => [categoryDoc]);
    } else {
      Stream<DocumentSnapshot> progressStream = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('enrolledCourses')
          .doc(widget.categoryId)
          .snapshots();

      return Rx.zip2(categoryStream, progressStream, (a, b) => [a, b]);
    }
  }

  Widget _buildTab(String iconName, String text, int index) {
    return AnimatedBuilder(
      animation: _tabController.animation!,
      builder: (BuildContext context, Widget? child) {
        final bool isSelected = _tabController.index == index;
        return Tab(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                iconName == 'info_outline'
                    ? Icons.info_outline
                    : iconName == 'quiz'
                    ? Icons.quiz_outlined
                    : Icons.trending_up,
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
              SizedBox(width: 1.w),
              Text(text),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.primary,
            ),
            SizedBox(height: 3.h),
            Text(
              "Đang tải chi tiết chủ đề...",
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(backgroundColor: AppTheme.background, elevation: 0),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off,
                size: 60.sp,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
              SizedBox(height: 3.h),
              Text(
                "Đã có lỗi xảy ra",
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                error,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
