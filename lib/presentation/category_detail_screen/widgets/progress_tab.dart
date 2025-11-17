// Dán toàn bộ code này vào file: lib/presentation/category_detail_screen/widgets/progress_tab.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    if (userProgress.isEmpty) {
      return _buildNotEnrolledState();
    }

    final double progress = (userProgress["progress"] ?? 0.0).toDouble();
    final int completionPercentage = (progress * 100).toInt();
    final int timeSpent = (userProgress["timeSpent"] ?? 0);
    // Lấy điểm trung bình
    final double averageScore = (userProgress["averageScore"] ?? 0.0).toDouble();

    final scoreHistoryData = userProgress["scoreHistory"];
    List<Map<String, dynamic>> scoreHistory = [];
    if (scoreHistoryData is List) {
      scoreHistory = scoreHistoryData.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        }
        return <String, dynamic>{};
      }).where((item) => item.isNotEmpty).toList();
    }

    final achievements = (userProgress["achievements"] as List?)?.cast<String>() ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Tổng quan tiến độ"),
          SizedBox(height: 2.h),
          // Truyền điểm trung bình vào widget overview
          _buildProgressOverview(completionPercentage, timeSpent, averageScore.round()),
          SizedBox(height: 4.h),
          _buildSectionTitle("Xu hướng điểm số"),
          SizedBox(height: 2.h),
          _buildScoreTrendsChart(context, scoreHistory),
          SizedBox(height: 4.h),
          _buildSectionTitle("Thành tích đạt được"),
          SizedBox(height: 2.h),
          _buildAchievements(achievements),
        ],
      ),
    );
  }

  // --- Các hàm build widget ---

  Widget _buildProgressOverview(int completionPercentage, int timeSpentInSeconds, int averageScore) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2)),
          boxShadow: [ BoxShadow( color: AppTheme.shadowLight.withOpacity(0.5), blurRadius: 10, offset: Offset(0, 4)) ]
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
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: completionPercentage / 100),
                    duration: const Duration(milliseconds: 1500),
                    builder: (context, value, child) => CircularProgressIndicator(
                      value: value,
                      strokeWidth: 10,
                      strokeCap: StrokeCap.round,
                      backgroundColor: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        value >= 0.8 ? AppTheme.success : (value >= 0.5 ? AppTheme.warning : AppTheme.primary),
                      ),
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
          // Hiển thị thêm các thông tin phụ
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItemOverview(Icons.stars_outlined, "Điểm TB", "$averageScore"),
              _buildInfoItemOverview(Icons.access_time_filled, "Thời gian học", _formatTime(timeSpentInSeconds)),
            ],
          ),
        ],
      ),
    );
  }

  // Widget con để hiển thị thông tin trong overview
  Widget _buildInfoItemOverview(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 20),
        SizedBox(height: 0.5.h),
        Text(value, style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 0.2.h),
        Text(label, style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
      ],
    );
  }

  // --- Các hàm còn lại giữ nguyên không đổi ---
  String _formatTime(int totalSeconds) { if (totalSeconds < 60) { return "$totalSeconds giây"; } final int minutes = totalSeconds ~/ 60; return "$minutes phút"; }
  Widget _buildScoreTrendsChart(BuildContext context, List<Map<String, dynamic>> scoreHistory) { if (scoreHistory.isEmpty) { return _buildEmptyDataState("Chưa có dữ liệu điểm số", Icons.show_chart_rounded); } scoreHistory.sort((a, b) { Timestamp timeA = a['timestamp'] ?? Timestamp.now(); Timestamp timeB = b['timestamp'] ?? Timestamp.now(); return timeA.compareTo(timeB); }); List<FlSpot> spots = scoreHistory.asMap().entries.map((entry) { int index = entry.key; double score = (entry.value['score'] ?? 0.0).toDouble(); return FlSpot(index.toDouble(), score); }).toList(); if (spots.length == 1) { spots.add(FlSpot(1, spots.first.y)); } return Container( height: 35.h, padding: EdgeInsets.only(top: 4.h, right: 4.w, left: 1.w, bottom: 1.h), decoration: BoxDecoration( color: AppTheme.lightTheme.colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2)), boxShadow: [ BoxShadow( color: AppTheme.shadowLight.withOpacity(0.5), blurRadius: 10, offset: Offset(0, 4) ) ] ), child: LineChart( LineChartData( lineTouchData: LineTouchData( handleBuiltInTouches: true, touchTooltipData: LineTouchTooltipData( tooltipBgColor: AppTheme.primary.withOpacity(0.9), getTooltipItems: (List<LineBarSpot> touchedBarSpots) { return touchedBarSpots.map((barSpot) { final flSpot = barSpot; final int index = flSpot.x.toInt(); if (index >= scoreHistory.length) return null; final String difficulty = scoreHistory[index]['difficulty'] ?? ''; final String score = flSpot.y.toStringAsFixed(0); return LineTooltipItem( '${score} điểm\n', TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.sp), children: [ TextSpan( text: 'Mức: $difficulty', style: TextStyle(color: Colors.white.withOpacity(0.8), fontWeight: FontWeight.normal, fontSize: 10.sp), ), ], ); }).toList(); }, ), ), gridData: FlGridData( show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) { return FlLine( color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.1), strokeWidth: 1, ); }, ), titlesData: FlTitlesData( leftTitles: AxisTitles( sideTitles: SideTitles( showTitles: true, reservedSize: 35, interval: 25, getTitlesWidget: (value, meta) { return SideTitleWidget( axisSide: meta.axisSide, space: 10, child: Text( value.toInt().toString(), style: TextStyle(color: AppTheme.textSecondary, fontSize: 10.sp) ), ); }, ), ), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), bottomTitles: AxisTitles( sideTitles: SideTitles( showTitles: true, reservedSize: 30, interval: 1, getTitlesWidget: (value, meta) { int index = value.toInt(); if (scoreHistory.length == 1 && index == 1) { return SideTitleWidget(axisSide: meta.axisSide, child: const Text('')); } if (index >= 0 && index < scoreHistory.length) { Timestamp timestamp = scoreHistory[index]['timestamp']; return SideTitleWidget( axisSide: meta.axisSide, child: Text( DateFormat('dd/MM').format(timestamp.toDate()), style: TextStyle(color: AppTheme.textSecondary, fontSize: 10.sp), ), ); } return const Text(''); }, ), ), ), borderData: FlBorderData( show: true, border: Border( bottom: BorderSide(color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2), width: 1.5), left: BorderSide(color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2), width: 1.5), ) ), minX: 0, maxX: spots.length.toDouble() - (spots.length > 1 ? 0.9 : 0), minY: 0, maxY: 110, lineBarsData: [ LineChartBarData( spots: spots, isCurved: true, color: AppTheme.primary, barWidth: 4, isStrokeCapRound: true, dotData: FlDotData( show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter( radius: 5, color: Colors.white, strokeWidth: 2, strokeColor: AppTheme.primary, ), ), belowBarData: BarAreaData( show: true, gradient: LinearGradient( colors: [AppTheme.primary.withOpacity(0.3), AppTheme.primary.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter, ), ), ), ], ), ), ); }
  Widget _buildAchievements(List<String> achievements) { if (achievements.isEmpty) { return _buildEmptyDataState("Chưa có thành tích nào", Icons.emoji_events_outlined, subtitle: "Hoàn thành các quiz để mở khóa thành tích!"); } final Map<String, IconData> achievementIcons = { 'first_step': Icons.directions_walk, 'high_scorer': Icons.star, 'master': Icons.workspace_premium, }; return GridView.builder( shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount( crossAxisCount: 4, crossAxisSpacing: 2.w, mainAxisSpacing: 2.w, ), itemCount: achievements.length, itemBuilder: (context, index) { final achievement = achievements[index]; return Card( elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ Icon(achievementIcons[achievement] ?? Icons.help_outline, color: AppTheme.warning, size: 32), SizedBox(height: 1.h), Text( achievement.replaceAll('_', ' ').replaceFirst(achievement[0], achievement[0].toUpperCase()), textAlign: TextAlign.center, style: TextStyle(fontSize: 10.sp), overflow: TextOverflow.ellipsis, ), ], ), ); }, ); }
  Widget _buildEmptyDataState(String title, IconData icon, {String? subtitle}) { return Container( width: double.infinity, padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w), decoration: BoxDecoration( color: AppTheme.lightTheme.colorScheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.lightTheme.colorScheme.outline.withOpacity(0.2)), ), child: Column( children: [ Icon(icon, color: AppTheme.textSecondary.withOpacity(0.5), size: 48), SizedBox(height: 2.h), Text(title, style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: AppTheme.textSecondary)), if (subtitle != null) ...[ SizedBox(height: 1.h), Padding( padding: EdgeInsets.symmetric(horizontal: 4.w), child: Text(subtitle, style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary), textAlign: TextAlign.center), ) ] ], ), ); }
  Widget _buildNotEnrolledState() { return Center( child: Padding( padding: EdgeInsets.all(8.w), child: Column( mainAxisAlignment: MainAxisAlignment.center, children: [ Icon(Icons.lock_outline, size: 48.sp, color: AppTheme.textSecondary), SizedBox(height: 2.h), Text( 'Xem tiến độ học tập', style: AppTheme.lightTheme.textTheme.titleLarge, textAlign: TextAlign.center, ), SizedBox(height: 1.h), Text( 'Hãy nhấn nút "Đăng ký ngay" ở bên dưới để tham gia và bắt đầu theo dõi tiến độ của bạn!', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp), textAlign: TextAlign.center, ), ], ), ), ); }
  Widget _buildSectionTitle(String title) { return Text(title, style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)); }
}
