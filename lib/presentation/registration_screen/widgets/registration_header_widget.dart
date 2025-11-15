import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RegistrationHeaderWidget extends StatelessWidget {
  final VoidCallback onBackPressed;

  const RegistrationHeaderWidget({
    super.key,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackPressed,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.border.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: CustomIconWidget(
                iconName: 'arrow_back_ios',
                size: 5.w,
                color: AppTheme.getTextColor(context),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Tạo tài khoản',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getTextColor(context),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w), // Balance the back button
        ],
      ),
    );
  }
}
