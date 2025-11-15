import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterChipWidget extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterChipWidget({
    Key? key,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        margin: EdgeInsets.only(right: 2.w),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withValues(alpha: 0.1)
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 1.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.2.h),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.surface,
                ),
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: 1.w),
              CustomIconWidget(
                iconName: 'close',
                size: 16,
                color: AppTheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
