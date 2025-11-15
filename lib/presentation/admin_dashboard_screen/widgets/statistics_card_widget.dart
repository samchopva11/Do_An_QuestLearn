import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StatisticsCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String changePercentage;
  final bool isPositive;
  final String iconName;

  const StatisticsCardWidget({
    Key? key,
    required this.title,
    required this.value,
    required this.changePercentage,
    required this.isPositive,
    required this.iconName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.w,
      height: 20.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 10.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: iconName,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                  ),
                ),
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? AppTheme.success.withValues(alpha: 0.1)
                        : AppTheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: isPositive ? 'trending_up' : 'trending_down',
                        color: isPositive ? AppTheme.success : AppTheme.error,
                        size: 12,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        changePercentage,
                        style:
                        AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: isPositive ? AppTheme.success : AppTheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
