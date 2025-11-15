// Dán toàn bộ code này vào file: lib/presentation/forgot_password_screen/forgot_password_screen.dart

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';import 'package:fluttertoast/fluttertoast.dart';

import '../../core/app_export.dart'; // Import này chứa các file cần thiết khác của bạn
import '../../theme/app_theme.dart';
// KHÔNG CẦN import custom_button_widget.dart
import '../../widgets/custom_icon_widget.dart';   // Widget icon tùy chỉnh

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // --- LOGIC XỬ LÝ GỬI EMAIL KHÔI PHỤC MẬT KHẨU ---
  Future<void> _handlePasswordReset() async {
    // Kiểm tra xem form có hợp lệ không
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Bật vòng xoay loading
    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      print("Đang gửi email reset mật khẩu tới: $email");

      // Gọi hàm của Firebase để gửi email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      print("✅ Gửi email thành công!");

      Fluttertoast.showToast(
        msg: "Email khôi phục đã được gửi. Vui lòng kiểm tra hộp thư của bạn (kể cả mục Spam).",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.success,
        textColor: Colors.white,
        fontSize: 14.sp,
      );

      // Sau khi gửi thành công, đợi 1 giây rồi quay lại màn hình trước đó
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      print("🔥 Lỗi gửi email: ${e.code} - ${e.message}");
      String errorMessage = "Đã xảy ra lỗi. Vui lòng thử lại.";
      if (e.code == 'user-not-found') {
        errorMessage = "Không tìm thấy người dùng với email này.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Địa chỉ email không hợp lệ.";
      }

      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.error,
        textColor: Colors.white,
        fontSize: 14.sp,
      );
    } catch (e) {
      // Xử lý các lỗi không xác định khác
      print("🔥 Lỗi không xác định: $e");
      Fluttertoast.showToast(
        msg: "Đã xảy ra một lỗi không mong muốn.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.error,
        textColor: Colors.white,
        fontSize: 14.sp,
      );
    } finally {
      // Luôn tắt vòng xoay loading sau khi hoàn tất
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- GIAO DIỆN CỦA MÀN HÌNH ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      // App Bar với nút quay lại
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.getTextColor(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 2.h),

                // Tiêu đề
                Text(
                  'Quên mật khẩu?',
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                SizedBox(height: 1.5.h),
                Text(
                  'Đừng lo lắng! Vui lòng nhập địa chỉ email đã đăng ký của bạn. Chúng tôi sẽ gửi một liên kết để bạn đặt lại mật khẩu.',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.getTextColor(context, secondary: true),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 5.h),

                // Ô nhập Email
                Text(
                  'Email',
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.getTextColor(context),
                  ),
                ),
                SizedBox(height: 1.h),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    final emailRegex =
                    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value.trim())) {
                      return 'Email không hợp lệ';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'Nhập địa chỉ email của bạn',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'email',
                        size: 5.w,
                        color: AppTheme.getTextColor(context, secondary: true),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5.h),

                // ===============================================================
                //       THAY THẾ CustomButtonWidget BẰNG ElevatedButton
                // ===============================================================
                SizedBox(
                  width: double.infinity,
                  height: 7.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handlePasswordReset, // Gắn hàm xử lý vào đây
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary, // Lấy màu chính từ theme của bạn
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : Text(
                      'Gửi Email',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // ===============================================================

              ],
            ),
          ),
        ),
      ),
    );
  }
}
