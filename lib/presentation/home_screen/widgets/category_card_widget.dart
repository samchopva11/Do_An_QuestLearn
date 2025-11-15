// Dán toàn bộ code này vào file: lib/presentation/home_screen/widgets/category_card_widget.dart

import 'dart:typed_data'; // Import để dùng Uint8List
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class CategoryCardWidget extends StatelessWidget {
  final String title;
  // THÊM CÁC BỘ ĐẾM ĐỘ KHÓ
  final int easyCount;
  final int mediumCount;
  final int hardCount;
  final Uint8List? imageBytes;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const CategoryCardWidget({
    Key? key,
    required this.title,
    // YÊU CẦU CÁC THAM SỐ MỚI
    required this.easyCount,
    required this.mediumCount,
    required this.hardCount,
    this.imageBytes,
    required this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 3,
        shadowColor: AppTheme.shadowLight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: _buildImage(),
            ),
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 11.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.h),
                  // GỌI HÀM HIỂN THỊ CHIP ĐỘ KHÓ MỚI
                  _buildDifficultyChips(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageBytes != null) {
      return Image.memory(
        imageBytes!,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        color: AppTheme.border.withOpacity(0.1),
        child: Icon(
          Icons.image_not_supported_outlined,
          color: AppTheme.textSecondary,
          size: 24.sp,
        ),
      );
    }
  }

  // HÀM MỚI: Hiển thị các chip độ khó
  Widget _buildDifficultyChips() {
    return Wrap(
      spacing: 1.5.w,
      runSpacing: 0.5.h,
      children: [
        // Chỉ hiển thị chip nếu số lượng > 0
        if (easyCount > 0)
          _buildChip('$easyCount Dễ', AppTheme.success),
        if (mediumCount > 0)
          _buildChip('$mediumCount TB', AppTheme.warning),
        if (hardCount > 0)
          _buildChip('$hardCount Khó', AppTheme.error),
      ],
    );
  }

  // Widget con để vẽ chip (giữ nguyên nhưng dùng màu từ theme)
  Widget _buildChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 7.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
