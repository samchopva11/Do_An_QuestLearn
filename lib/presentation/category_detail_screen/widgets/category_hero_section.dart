// Dán vào file: lib/presentation/category_detail_screen/widgets/category_hero_section.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class CategoryHeroSection extends StatelessWidget {
  final Map<String, dynamic> category;
  final bool isEnrolled;
  final VoidCallback onEnrollmentToggle;

  const CategoryHeroSection({
    Key? key,
    required this.category,
    required this.isEnrolled,
    required this.onEnrollmentToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ==========================================================
    // =====        SỬA LỖI: LẤY DỮ LIỆU AN TOÀN             =====
    // ==========================================================
    final String name = category["name"] ?? "Chủ đề không tên";
    final String imageBase64 = category["imageBase64"] ?? "";
    Uint8List? imageBytes;
    if (imageBase64.isNotEmpty) {
      try {
        imageBytes = base64Decode(imageBase64.split(',').last);
      } catch (e) {
        print("Lỗi giải mã ảnh trong HeroSection: $e");
      }
    }

    return SizedBox(
      height: 35.h,
      child: Stack(
        children: [
          // Hero Image with Parallax Effect
          Positioned.fill(
            // ==========================================================
            // =====    SỬA LỖI: DÙNG IMAGE.MEMORY THAY VÌ CUSTOM    =====
            // ==========================================================
            child: imageBytes != null
                ? Image.memory(
              imageBytes,
              width: double.infinity,
              height: 35.h,
              fit: BoxFit.cover,
            )
                : Container(
              color: AppTheme.border.withOpacity(0.1),
              child: Icon(
                Icons.image_not_supported_outlined,
                color: AppTheme.textSecondary,
                size: 48.sp,
              ),
            ),
          ),

          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: 6.h,
            left: 4.w,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface
                    .withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, size: 24),
              ),
            ),
          ),

          // Category Info
          Positioned(
            bottom: 4.h,
            left: 4.w,
            right: 4.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Name
                Text(
                  name, // Dùng biến name đã được xử lý an toàn
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 1.h),

                // Enrollment Status Badge
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: isEnrolled
                        ? AppTheme.success.withOpacity(0.9)
                        : AppTheme.warning.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isEnrolled ? Icons.check_circle : Icons.schedule,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        isEnrolled ? "Đã đăng ký" : "Chưa đăng ký",
                        style:
                        AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
