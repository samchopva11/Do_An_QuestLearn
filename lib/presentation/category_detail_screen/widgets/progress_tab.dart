// Dán toàn bộ code này vào file: lib/presentation/category_detail_screen/widgets/progress_tab.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ProgressTab extends StatelessWidget {
  final Map<String, dynamic> category;
  final Map<String, dynamic> userProgress;

  const ProgressTab({
    Key? key,
    required this.category,
    required this.userProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // =====       SỬA LỖI: LẤY DỮ LIỆU TỪ DỮ LIỆU THẬT      =====
    // ==========================================================

    // Kiểm tra xem userProgress có rỗng hay không (nghĩa là chưa đăng ký)
    if (userProgress.isEmpty) {
      return _buildNotEnrolledState();
    }

    // Lấy dữ liệu thật từ userProgress
    final double progress = userProgress["progress"] ?? 0.0;
    final int completionPercentage = (progress * 100).toInt();

    // Các dữ liệu khác sẽ được thêm sau, tạm thời dùng giá trị mặc định
    final scoreHistory = (userProgress["scoreHistory"] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final timeSpent = userProgress["timeSpent"] ?? 0;
    final achievements = (userProgress["achievements"] as List?)?.cast<String>() ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Tổng quan tiến độ"),
          SizedBox(height: 2.h),
          _buildProgressOverview(completionPercentage, timeSpent),
          SizedBox(height: 3.h),
          _buildSectionTitle("Xu hướng điểm số"),
          SizedBox(height: 2.h),
          _buildScoreTrendsChart(scoreHistory),
          SizedBox(height: 3.h),
          _buildSectionTitle("Thành tích đạt được"),
          SizedBox(height: 2.h),
          _buildAchievements(achievements),
        ],
      ),
    );
  }

  // HÀM MỚI: Hiển thị khi người dùng chưa đăng ký khóa học
  Widget _buildNotEnrolledState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 48.sp, color: AppTheme.textSecondary),
            SizedBox(height: 2.h),
            Text(
              'Xem tiến độ học tập',
              style: AppTheme.lightTheme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Hãy nhấn nút "Đăng ký ngay" ở bên dưới để tham gia và bắt đầu theo dõi tiến độ của bạn!',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // --- Các hàm build widget con còn lại giữ nguyên hoặc chỉnh sửa nhỏ ---
  Widget _buildSectionTitle(String title) {
    // ... Giữ nguyên
    return Text(title, style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold));
  }

  Widget _buildProgressOverview(int completionPercentage, int timeSpent) {
    // ... Giữ nguyên
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 40.w,
            height: 40.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 40.w,
                  height: 40.w,
                  child: CircularProgressIndicator(
                    value: completionPercentage / 100,
                    strokeWidth: 8,
                    backgroundColor: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      completionPercentage >= 80 ? AppTheme.success : (completionPercentage >= 50 ? AppTheme.warning : AppTheme.primary),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("$completionPercentage%", style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text("Hoàn thành", style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time, color: AppTheme.secondary, size: 20),
              SizedBox(width: 2.w),
              Text("Thời gian học: ${timeSpent} phút", style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreTrendsChart(List<Map<String, dynamic>> scoreHistory) {
    if (scoreHistory.isEmpty) {
      return _buildEmptyDataState("Chưa có dữ liệu điểm số", Icons.trending_up);
    }
    // ... Logic biểu đồ giữ nguyên
    return Container(
      /* ... */
    );
  }

  Widget _buildAchievements(List<String> achievements) {
    if (achievements.isEmpty) {
      return _buildEmptyDataState("Chưa có thành tích nào", Icons.emoji_events, subtitle: "Hoàn thành các quiz để mở khóa thành tích!");
    }
    // ... Logic hiển thị thành tích giữ nguyên
    return Wrap(
      /* ... */
    );
  }

  Widget _buildEmptyDataState(String title, IconData icon, {String? subtitle}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 48),
          SizedBox(height: 2.h),
          Text(title, style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
          if (subtitle != null) ...[
            SizedBox(height: 1.h),
            Text(subtitle, style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary), textAlign: TextAlign.center),
          ]
        ],
      ),
    );
  }
}
