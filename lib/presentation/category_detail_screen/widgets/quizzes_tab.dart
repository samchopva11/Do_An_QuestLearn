// Dán vào file: lib/presentation/category_detail_screen/widgets/quizzes_tab.dart

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class QuizzesTab extends StatelessWidget {
  final Map<String, dynamic> category;
  final Function(String difficulty) onStartQuiz;
  final Function(String difficulty) onReviewResults;

  const QuizzesTab({
    Key? key,
    required this.category,
    required this.onStartQuiz,
    required this.onReviewResults,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lấy số lượng câu hỏi
    final int easyCount = category["easyCount"] ?? 0;
    final int mediumCount = category["mediumCount"] ?? 0;
    final int hardCount = category["hardCount"] ?? 0;

    // ==========================================================
    // =====       SỬA LỖI: LẤY THỜI GIAN TỪ CATEGORY        =====
    // ==========================================================
    // Lấy thời gian làm bài (tính bằng phút) từ dữ liệu category
    // và cung cấp giá trị mặc định nếu không có
    final int easyDuration = category['easyDuration'] ?? 20;
    final int mediumDuration = category['mediumDuration'] ?? 45;
    final int hardDuration = category['hardDuration'] ?? 60;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: [
          // Truyền thời gian tương ứng vào mỗi card
          _buildDifficultyCard(
            context: context,
            title: "Dễ",
            difficulty: "Dễ",
            questionCount: easyCount,
            durationInMinutes: easyDuration, // << TRUYỀN THỜI GIAN DỄ
            bestScore: 0,
            color: AppTheme.success,
            iconName: 'lightbulb_outline',
          ),
          SizedBox(height: 3.h),
          _buildDifficultyCard(
            context: context,
            title: "Trung bình",
            difficulty: "Trung bình",
            questionCount: mediumCount,
            durationInMinutes: mediumDuration, // << TRUYỀN THỜI GIAN TRUNG BÌNH
            bestScore: 0,
            color: AppTheme.warning,
            iconName: 'psychology_alt',
          ),
          SizedBox(height: 3.h),
          _buildDifficultyCard(
            context: context,
            title: "Khó",
            difficulty: "Khó",
            questionCount: hardCount,
            durationInMinutes: hardDuration, // << TRUYỀN THỜI GIAN KHÓ
            bestScore: 0,
            color: AppTheme.error,
            iconName: 'local_fire_department',
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard({
    required BuildContext context,
    required String title,
    required String difficulty,
    required int questionCount,
    required int durationInMinutes, // << THÊM THAM SỐ NHẬN THỜI GIAN
    required int bestScore,
    required Color color,
    required String iconName,
  }) {
    final bool hasAttempted = bestScore > 0;
    final bool hasQuestions = questionCount > 0;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            iconName == 'lightbulb_outline'
                ? Icons.lightbulb_outline
                : iconName == 'psychology_alt'
                ? Icons.psychology_alt
                : Icons.local_fire_department,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          "$questionCount câu hỏi",
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: hasAttempted
            ? Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "Điểm cao nhất: $bestScore%",
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        )
            : null,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        "Số câu hỏi",
                        questionCount.toString(),
                        Icons.quiz_outlined,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    // ==========================================================
                    // =====         SỬA LỖI: HIỂN THỊ ĐÚNG THỜI GIAN      =====
                    // ==========================================================
                    Expanded(
                      child: _buildInfoItem(
                        "Thời gian", // Bỏ chữ "ước tính"
                        "$durationInMinutes phút", // Hiển thị thời gian đã nhận
                        Icons.access_time,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                if (hasQuestions) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton.icon(
                      onPressed: () => onStartQuiz(difficulty),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow, size: 20),
                      label: Text(
                        hasAttempted ? "Làm lại bài quiz" : "Bắt đầu quiz",
                        style: AppTheme.lightTheme.textTheme.titleSmall
                            ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (hasAttempted) ...[
                    SizedBox(height: 2.h),
                    SizedBox(
                      width: double.infinity,
                      height: 6.h,
                      child: OutlinedButton.icon(
                        onPressed: () => onReviewResults(difficulty),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: color,
                          side: BorderSide(color: color, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.visibility_outlined, size: 20),
                        label: Text(
                          "Xem lại kết quả",
                          style: AppTheme.lightTheme.textTheme.titleSmall
                              ?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme
                          .lightTheme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color:
                          AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          size: 32,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          "Chưa có câu hỏi cho độ khó này",
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    // Giữ nguyên widget này
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
