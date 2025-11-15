// Dán toàn bộ code này vào file: lib/presentation/home_screen/widgets/category_grid_widget.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import './category_card_widget.dart';
import './empty_state_widget.dart';

class CategoryGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final bool isLoading;
  final Function(Map<String, dynamic>) onCategoryTap;
  final Function(Map<String, dynamic>)? onCategoryLongPress;

  const CategoryGridWidget({
    Key? key,
    required this.categories,
    required this.isLoading,
    required this.onCategoryTap,
    this.onCategoryLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingGrid(context);
    }

    if (categories.isEmpty) {
      return EmptyStateWidget(
        title: 'Không tìm thấy chủ đề nào',
        subtitle: 'Hãy thử tìm kiếm với từ khóa khác.',
        buttonText: '',
        onButtonPressed: () {},
      );
    }

    return GridView.builder(
      padding: kIsWeb
          ? EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h)
          : EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        childAspectRatio: 0.65,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 3.h,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];

        // Lấy dữ liệu một cách an toàn
        final String name = category['name'] ?? 'Không có tên';
        final bool isEnrolled = category['isEnrolled'] as bool? ?? false;
        final double progress = (category['progress'] as num? ?? 0.0).toDouble();
        final String imageBase64 = category['imageBase64'] ?? '';

        // ==========================================================
        // =====    SỬA LỖI: LẤY CÁC BỘ ĐẾM ĐỘ KHÓ TỪ DỮ LIỆU    =====
        // ==========================================================
        final int easyCount = category['easyCount'] ?? 0;
        final int mediumCount = category['mediumCount'] ?? 0;
        final int hardCount = category['hardCount'] ?? 0;

        Uint8List? imageBytes;
        if (imageBase64.isNotEmpty) {
          try {
            final String pureBase64 = imageBase64.split(',').last;
            imageBytes = base64Decode(pureBase64);
          } catch (e) {
            print('Lỗi giải mã ảnh Base64 cho chủ đề "$name": $e');
          }
        }

        return Column(
          children: [
            Expanded(
              child: CategoryCardWidget(
                title: name,
                // =======================================================
                // ===== SỬA LỖI: TRUYỀN CÁC THAM SỐ BẮT BUỘC VÀO CARD =====
                // =======================================================
                easyCount: easyCount,
                mediumCount: mediumCount,
                hardCount: hardCount,
                imageBytes: imageBytes,
                onTap: () => onCategoryTap(category),
                onLongPress: onCategoryLongPress != null
                    ? () => onCategoryLongPress!(category)
                    : null,
              ),
            ),
            if (isEnrolled) _buildProgressIndicator(progress),
          ],
        );
      },
    );
  }

  // Các hàm helper giữ nguyên
  Widget _buildProgressIndicator(double progress) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.5.w),
      child: Column(
        children: [
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppTheme.border.withOpacity(0.5),
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 9.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
        ],
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 4;
    if (screenWidth > 600) return 3;
    return 2;
  }

  Widget _buildLoadingGrid(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(context),
        childAspectRatio: 0.65,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 3.h,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    final skeletonColor = AppTheme.border.withOpacity(0.3);
    return Column(
      children: [
        Expanded(
          child: Container(
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
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 5, child: Container(color: skeletonColor)),
                Padding(
                  padding: EdgeInsets.all(3.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 2.h,
                        width: 25.w,
                        decoration: BoxDecoration(color: skeletonColor, borderRadius: BorderRadius.circular(4)),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        height: 2.h,
                        width: 30.w,
                        decoration: BoxDecoration(color: skeletonColor, borderRadius: BorderRadius.circular(4)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.5.w),
          child: Column(
            children: [
              SizedBox(height: 1.h),
              Container(
                height: 1.2.h,
                decoration: BoxDecoration(color: skeletonColor, borderRadius: BorderRadius.circular(5)),
              ),
              SizedBox(height: 0.5.h),
            ],
          ),
        ),
      ],
    );
  }
}
