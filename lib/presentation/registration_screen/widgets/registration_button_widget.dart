import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RegistrationButtonWidget extends StatelessWidget {
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onPressed;

  const RegistrationButtonWidget({
    super.key,
    required this.isLoading,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppTheme.lightTheme.primaryColor
              : AppTheme.getTextColor(context, secondary: true)
              .withValues(alpha: 0.3),
          foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
          elevation: isEnabled ? 2 : 0,
          shadowColor: AppTheme.shadowLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
        ),
        child: isLoading
            ? SizedBox(
          height: 5.w,
          width: 5.w,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.onPrimary,
            ),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tạo tài khoản',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onPrimary,
              ),
            ),
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: 'arrow_forward',
              size: 5.w,
              color: AppTheme.lightTheme.colorScheme.onPrimary,
            ),
          ],
        ),
      ),
    );
  }
}
