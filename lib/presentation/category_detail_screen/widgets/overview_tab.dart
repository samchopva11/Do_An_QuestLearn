// Dán vào file: lib/presentation/category_detail_screen/widgets/overview_tab.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class OverviewTab extends StatelessWidget {
  final Map<String, dynamic> category;

  const OverviewTab({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // =====        SỬA LỖI: LẤY DỮ LIỆU ĐÚNG TRƯỜNG        =====
    // ==========================================================
    final int easyCount = category["easyCount"] ?? 0;
    final int mediumCount = category["mediumCount"] ?? 0;
    final int hardCount = category["hardCount"] ?? 0;
    final int totalQuestions = category["questionCount"] ?? (easyCount + mediumCount + hardCount);
    // Lấy mô tả, nếu không có thì hiển thị mặc định
    final String description = category["description"] ?? "Chủ đề này hiện chưa có mô tả chi tiết. Hãy bắt đầu khám phá các câu hỏi ngay nhé!";


    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description Section
          _buildSectionTitle("Mô tả"),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withOpacity(0.2),
              ),
            ),
            child: Text(
              description, // Dùng biến description đã xử lý
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
          ),

          SizedBox(height: 3.h),

          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Tổng câu hỏi",
                  totalQuestions.toString(),
                  const Icon(Icons.quiz_outlined, color: AppTheme.primary, size: 24),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildStatCard(
                  "Thời gian ước tính",
                  "${(totalQuestions * 1.5).round()} phút",
                  const Icon(Icons.access_time, color: AppTheme.secondary, size: 24),
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Difficulty Distribution Chart
          _buildSectionTitle("Phân bố độ khó"),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            height: 30.h,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withOpacity(0.2),
              ),
            ),
            child: totalQuestions > 0
                ? _buildDifficultyChart(easyCount, mediumCount, hardCount)
                : _buildEmptyChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.lightTheme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Widget icon) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          icon,
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
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

  Widget _buildDifficultyChart(int easy, int medium, int hard) {
    // Giữ nguyên logic biểu đồ, nó đã dùng đúng easy/medium/hard
    return Semantics(
      label: "Biểu đồ phân bố độ khó câu hỏi",
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY:
          [easy, medium, hard].reduce((a, b) => a > b ? a : b).toDouble() *
              1.2,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const titles = ['Dễ', 'Trung bình', 'Khó'];
                  return Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Text(
                      titles[value.toInt()],
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 8.w,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return Text(
                    value.toInt().toString(),
                    style: AppTheme.lightTheme.textTheme.bodySmall,
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: easy.toDouble(),
                  color: AppTheme.success,
                  width: 12.w,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: medium.toDouble(),
                  color: AppTheme.warning,
                  width: 12.w,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: hard.toDouble(),
                  color: AppTheme.error,
                  width: 12.w,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bar_chart, size: 48),
          SizedBox(height: 2.h),
          Text(
            "Chưa có dữ liệu câu hỏi",
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
