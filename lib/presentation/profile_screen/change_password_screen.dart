// Dán toàn bộ code này vào file: lib/presentation/profile_screen/change_password_screen.dart

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- LOGIC XỬ LÝ ĐỔI MẬT KHẨU (ĐÃ CẬP NHẬT HOÀN CHỈNH) ---
  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("Không có người dùng nào đang đăng nhập.");
      }
      final String email = user.email!;

      print("Đang tái xác thực người dùng...");
      AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: _oldPasswordController.text.trim(),
      );
      await user.reauthenticateWithCredential(credential);
      print("✅ Tái xác thực thành công!");

      print("Đang cập nhật mật khẩu mới...");
      await user.updatePassword(_newPasswordController.text.trim());
      print("✅ Đổi mật khẩu thành công trên server!");

      await _handleSuccess();

    } on FirebaseAuthException catch (e) {
      print("🔥 Lỗi đổi mật khẩu: ${e.code}");

      // ===== BẮT ĐẦU PHẦN SỬA LỖI QUAN TRỌNG =====
      if (e.code == 'requires-recent-login') {
        // Xử lý riêng cho trường hợp phiên đăng nhập đã quá cũ
        await _handleRequiresRecentLogin();
      } else {
        // Xử lý các lỗi Firebase khác
        String errorMessage = "Đã xảy ra lỗi. Vui lòng thử lại.";
        if (e.code == 'wrong-password') {
          errorMessage = "Mật khẩu cũ không chính xác.";
        } else if (e.code == 'weak-password') {
          errorMessage = "Mật khẩu mới quá yếu. Vui lòng chọn mật khẩu mạnh hơn.";
        }
        Fluttertoast.showToast(msg: errorMessage, backgroundColor: AppTheme.error, toastLength: Toast.LENGTH_LONG);
      }
      // ===== KẾT THÚC PHẦN SỬA LỖI QUAN TRỌNG =====

    } catch (e) {
      print("🔥 Lỗi không xác định: $e");
      Fluttertoast.showToast(msg: "Đã xảy ra lỗi không mong muốn.", backgroundColor: AppTheme.error);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Hàm xử lý khi đổi mật khẩu thành công
  Future<void> _handleSuccess() async {
    Fluttertoast.showToast(
      msg: "Đổi mật khẩu thành công! Vui lòng đăng nhập lại.",
      backgroundColor: AppTheme.success,
      toastLength: Toast.LENGTH_LONG,
    );
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.loginScreen,
            (route) => false,
      );
    }
  }

  // Hàm xử lý khi gặp lỗi requires-recent-login
  Future<void> _handleRequiresRecentLogin() async {
    Fluttertoast.showToast(
      msg: "Phiên đăng nhập đã cũ để đảm bảo an toàn, vui lòng đăng nhập lại.",
      backgroundColor: AppTheme.error,
      toastLength: Toast.LENGTH_LONG,
    );
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.loginScreen,
            (route) => false,
      );
    }
  }

  // Hàm để điều hướng đến màn hình Quên Mật Khẩu
  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, AppRoutes.forgotPassword);
  }

  // --- GIAO DIỆN CỦA MÀN HÌNH (giữ nguyên) ---
  @override
  Widget build(BuildContext context) {
    // ... (Toàn bộ phần build không thay đổi, giữ nguyên như cũ) ...
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      appBar: AppBar(
        title: Text('Đổi Mật Khẩu', style: TextStyle(color: AppTheme.getTextColor(context))),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.getTextColor(context)),
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
                SizedBox(height: 4.h),
                _buildPasswordField(
                  controller: _oldPasswordController,
                  label: 'Mật khẩu cũ',
                  hint: 'Nhập mật khẩu hiện tại của bạn',
                  isVisible: _isOldPasswordVisible,
                  onVisibilityToggle: () => setState(() => _isOldPasswordVisible = !_isOldPasswordVisible),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu cũ';
                    }
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _navigateToForgotPassword,
                    child: Text(
                      'Quên mật khẩu?',
                      style: TextStyle(color: AppTheme.primary, fontSize: 12.sp),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                _buildPasswordField(
                  controller: _newPasswordController,
                  label: 'Mật khẩu mới',
                  hint: 'Nhập mật khẩu mới (ít nhất 6 ký tự)',
                  isVisible: _isNewPasswordVisible,
                  onVisibilityToggle: () => setState(() => _isNewPasswordVisible = !_isNewPasswordVisible),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Mật khẩu mới phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 3.h),
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  label: 'Xác nhận mật khẩu mới',
                  hint: 'Nhập lại mật khẩu mới',
                  isVisible: _isConfirmPasswordVisible,
                  onVisibilityToggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return 'Mật khẩu xác nhận không khớp';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 5.h),
                SizedBox(
                  width: double.infinity,
                  height: 7.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleChangePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                      'Xác Nhận Đổi Mật Khẩu',
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget con để xây dựng các ô nhập mật khẩu
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    String? Function(String?)? validator,
  }) {
    // ... (Giữ nguyên) ...
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.getTextColor(context),
          ),
        ),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          obscureText: !isVisible,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'lock',
                size: 5.w,
                color: AppTheme.getTextColor(context, secondary: true),
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: AppTheme.getTextColor(context, secondary: true),
              ),
              onPressed: onVisibilityToggle,
            ),
          ),
        ),
      ],
    );
  }
}
