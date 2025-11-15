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

  // ==========================================================
  // =====        SỬA LỖI 1: THÊM BIẾN TRẠNG THÁI           =====
  // ==========================================================
  bool _isEnrolling = false;

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

  void _handleStartQuiz(String difficulty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          categoryId: widget.categoryId,
          difficulty: difficulty,
        ),
      ),
    );
  }

  // ==========================================================
  // =====        SỬA LỖI 1: CẬP NHẬT HÀM ENROLLMENT       =====
  // ==========================================================
  Future<void> _handleEnrollment(bool isEnrolled) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Báo cho giao diện biết là đang bắt đầu xử lý
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
      // Xử lý nếu có lỗi xảy ra
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã có lỗi xảy ra: $e')),
        );
      }
    } finally {
      // Bất kể thành công hay thất bại, báo cho giao diện là đã xử lý xong
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
          // Chỉ hiển thị loading toàn màn hình khi stream chưa có dữ liệu lần đầu
          return _buildLoadingState();
        }

        if (combinedSnapshot.hasError) {
          // SỬA LỖI 2: Dùng widget hiển thị lỗi riêng
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

        final categoryData = categorySnapshot.data() as Map<String, dynamic>;

        final bool isEnrolled = progressSnapshot != null && progressSnapshot.exists;

        final Map<String, dynamic> userProgressData =
        isEnrolled ? progressSnapshot.data() as Map<String, dynamic> : {};

        return Scaffold(
          backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
          body: Column(
            children: [
              CategoryHeroSection(
                category: categoryData,
                isEnrolled: isEnrolled,
                // Chức năng enroll trong hero section tạm thời vô hiệu hoá để tập trung vào nút chính
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
                    OverviewTab(category: categoryData),
                    QuizzesTab(
                      category: categoryData,
                      onStartQuiz: _handleStartQuiz,
                      onReviewResults: (difficulty) {},
                    ),
                    ProgressTab(
                      category: categoryData,
                      userProgress: userProgressData,
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: EnrollmentActionButton(
            isEnrolled: isEnrolled,
            // SỬA LỖI 1: Kết hợp trạng thái loading của Stream và của nút bấm
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
    // ... Giữ nguyên không đổi
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

  // ==========================================================
  // =====        SỬA LỖI 2: SỬA LẠI WIDGET LOADING       =====
  // ==========================================================
  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.primary, // Đổi màu cho đẹp hơn
            ),
            SizedBox(height: 3.h),
            Text(
              "Đang tải chi tiết chủ đề...",
              // Chỉnh lại style cho nhỏ và màu dễ nhìn
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // =====        SỬA LỖI 2: TẠO WIDGET HIỂN THỊ LỖI       =====
  // ==========================================================
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
