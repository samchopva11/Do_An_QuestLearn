import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuizNavigationWidget extends StatelessWidget {
  final bool canGoNext;
  final bool canGoPrevious;
  final bool isLastQuestion;
  final VoidCallback? onNextPressed;
  final VoidCallback? onPreviousPressed;
  final VoidCallback? onFinishPressed;

  const QuizNavigationWidget({
    Key? key,
    required this.canGoNext,
    required this.canGoPrevious,
    required this.isLastQuestion,
    this.onNextPressed,
    this.onPreviousPressed,
    this.onFinishPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color:
            AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (canGoPrevious) ...[
              Expanded(
                flex: 1,
                child: OutlinedButton.icon(
                  onPressed: onPreviousPressed,
                  icon: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                  label: Text(
                    'Previous',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
            ],
            Expanded(
              flex: canGoPrevious ? 2 : 1,
              child: ElevatedButton(
                onPressed: isLastQuestion
                    ? (canGoNext ? onFinishPressed : null)
                    : (canGoNext ? onNextPressed : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: canGoNext
                      ? (isLastQuestion
                      ? AppTheme.success
                      : AppTheme.lightTheme.colorScheme.primary)
                      : AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                  foregroundColor: canGoNext
                      ? AppTheme.lightTheme.colorScheme.surface
                      : AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.5),
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: canGoNext ? 2 : 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLastQuestion ? 'Finish Quiz' : 'Next Question',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: canGoNext
                            ? AppTheme.lightTheme.colorScheme.surface
                            : AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!isLastQuestion) ...[
                      SizedBox(width: 2.w),
                      CustomIconWidget(
                        iconName: 'arrow_forward',
                        color: canGoNext
                            ? AppTheme.lightTheme.colorScheme.surface
                            : AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                        size: 20,
                      ),
                    ],
                    if (isLastQuestion) ...[
                      SizedBox(width: 2.w),
                      CustomIconWidget(
                        iconName: 'check_circle',
                        color: canGoNext
                            ? AppTheme.lightTheme.colorScheme.surface
                            : AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                        size: 20,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
