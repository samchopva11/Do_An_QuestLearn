import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class TermsModalWidget extends StatelessWidget {
  const TermsModalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.getTextColor(context, secondary: true)
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Điều khoản sử dụng & Chính sách bảo mật',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.getTextColor(context),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.getTextColor(context, secondary: true)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'close',
                      size: 5.w,
                      color: AppTheme.getTextColor(context, secondary: true),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(
            color: AppTheme.border.withValues(alpha: 0.5),
            height: 1,
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    context,
                    'Điều khoản sử dụng',
                    [
                      'Bằng việc sử dụng ứng dụng Quiz Learning, bạn đồng ý tuân thủ các điều khoản và điều kiện được quy định dưới đây.',
                      'Ứng dụng được thiết kế để hỗ trợ việc học tập thông qua các bài kiểm tra trắc nghiệm tương tác.',
                      'Người dùng có trách nhiệm bảo mật thông tin tài khoản và không chia sẻ cho bên thứ ba.',
                      'Nghiêm cấm việc sử dụng ứng dụng cho các mục đích bất hợp pháp hoặc vi phạm quyền sở hữu trí tuệ.',
                      'Chúng tôi có quyền tạm ngừng hoặc chấm dứt tài khoản nếu phát hiện vi phạm điều khoản sử dụng.',
                    ],
                  ),
                  SizedBox(height: 3.h),
                  _buildSection(
                    context,
                    'Chính sách bảo mật',
                    [
                      'Chúng tôi cam kết bảo vệ thông tin cá nhân của người dùng theo các tiêu chuẩn bảo mật cao nhất.',
                      'Thông tin thu thập bao gồm: họ tên, email, tiến độ học tập và kết quả bài kiểm tra.',
                      'Dữ liệu được mã hóa và lưu trữ an toàn trên hệ thống Firebase của Google.',
                      'Chúng tôi không chia sẻ thông tin cá nhân với bên thứ ba mà không có sự đồng ý của bạn.',
                      'Bạn có quyền yêu cầu xóa dữ liệu cá nhân bất kỳ lúc nào bằng cách liên hệ với chúng tôi.',
                      'Cookies và dữ liệu phiên được sử dụng để cải thiện trải nghiệm người dùng.',
                    ],
                  ),
                  SizedBox(height: 3.h),
                  _buildSection(
                    context,
                    'Quyền và trách nhiệm',
                    [
                      'Người dùng có quyền truy cập, chỉnh sửa và xóa thông tin cá nhân của mình.',
                      'Chúng tôi có trách nhiệm thông báo kịp thời nếu có thay đổi về chính sách bảo mật.',
                      'Trong trường hợp xảy ra sự cố bảo mật, chúng tôi sẽ thông báo cho người dùng trong vòng 72 giờ.',
                      'Người dùng có trách nhiệm cập nhật thông tin liên lạc để nhận được các thông báo quan trọng.',
                    ],
                  ),
                  SizedBox(height: 3.h),
                  _buildSection(
                    context,
                    'Liên hệ',
                    [
                      'Nếu bạn có bất kỳ câu hỏi nào về điều khoản sử dụng hoặc chính sách bảo mật, vui lòng liên hệ với chúng tôi qua email: support@quizlearning.vn',
                      'Địa chỉ: 123 Đường ABC, Quận 1, TP. Hồ Chí Minh, Việt Nam',
                      'Điện thoại: +84 123 456 789',
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.primaryColor
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'info',
                          size: 5.w,
                          color: AppTheme.lightTheme.primaryColor,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            'Điều khoản này có hiệu lực từ ngày 11/11/2025 và có thể được cập nhật định kỳ.',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<String> content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.getTextColor(context),
          ),
        ),
        SizedBox(height: 1.h),
        ...content
            .map((text) => Padding(
          padding: EdgeInsets.only(bottom: 1.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 1.w, right: 2.w),
                width: 1.w,
                height: 1.w,
                decoration: BoxDecoration(
                  color:
                  AppTheme.getTextColor(context, secondary: true),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  text,
                  style: AppTheme.lightTheme.textTheme.bodyMedium
                      ?.copyWith(
                    color:
                    AppTheme.getTextColor(context, secondary: true),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ))
            .toList(),
      ],
    );
  }
}
