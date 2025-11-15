// Dán toàn bộ code này vào file: lib/presentation/registration_screen/widgets/registration_form_widget.dart

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RegistrationFormWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isPasswordVisible;
  final bool isConfirmPasswordVisible;
  final bool isTermsAccepted;
  final VoidCallback onPasswordVisibilityToggle;
  final VoidCallback onConfirmPasswordVisibilityToggle;
  final Function(bool?) onTermsChanged;
  final VoidCallback onTermsPressed;

  const RegistrationFormWidget({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isPasswordVisible,
    required this.isConfirmPasswordVisible,
    required this.isTermsAccepted,
    required this.onPasswordVisibilityToggle,
    required this.onConfirmPasswordVisibilityToggle,
    required this.onTermsChanged,
    required this.onTermsPressed,
  });

  @override
  State<RegistrationFormWidget> createState() => _RegistrationFormWidgetState();
}

class _RegistrationFormWidgetState extends State<RegistrationFormWidget> {
  String _passwordStrength = '';
  Color _passwordStrengthColor = AppTheme.lightTheme.colorScheme.error;
  bool _isEmailValid = false;
  bool _isNameValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;

  @override
  void initState() {
    super.initState();
    widget.nameController.addListener(_validateName);
    widget.emailController.addListener(_validateEmail);
    widget.passwordController.addListener(_validatePassword);
    widget.confirmPasswordController.addListener(_validateConfirmPassword);
  }

  @override
  void dispose() {
    widget.nameController.removeListener(_validateName);
    widget.emailController.removeListener(_validateEmail);
    widget.passwordController.removeListener(_validatePassword);
    widget.confirmPasswordController.removeListener(_validateConfirmPassword);
    super.dispose();
  }

  void _validateName() {
    setState(() {
      _isNameValid = widget.nameController.text.trim().length >= 2;
    });
  }

  void _validateEmail() {
    final email = widget.emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    setState(() {
      _isEmailValid = emailRegex.hasMatch(email);
    });
  }

  void _validatePassword() {
    final password = widget.passwordController.text;
    setState(() {
      _isPasswordValid = password.length >= 6;
      _updatePasswordStrength(password);
    });
  }

  void _validateConfirmPassword() {
    setState(() {
      _isConfirmPasswordValid = widget.confirmPasswordController.text ==
          widget.passwordController.text &&
          widget.confirmPasswordController.text.isNotEmpty;
    });
  }

  void _updatePasswordStrength(String password) {
    if (password.isEmpty) {
      _passwordStrength = '';
      _passwordStrengthColor = AppTheme.lightTheme.colorScheme.error;
      return;
    }

    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[a-z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;

    switch (score) {
      case 0:
      case 1:
        _passwordStrength = 'Yếu';
        _passwordStrengthColor = AppTheme.lightTheme.colorScheme.error;
        break;
      case 2:
      case 3:
        _passwordStrength = 'Trung bình';
        _passwordStrengthColor = AppTheme.warning;
        break;
      case 4:
      case 5:
        _passwordStrength = 'Mạnh';
        _passwordStrengthColor = AppTheme.success;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Name Field
          _buildInputField(
            controller: widget.nameController,
            label: 'Họ và tên',
            hint: 'Nhập họ và tên của bạn',
            prefixIcon: 'person',
            isValid: _isNameValid,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập họ và tên';
              }
              if (value.trim().length < 2) {
                return 'Họ và tên phải có ít nhất 2 ký tự';
              }
              return null;
            },
          ),
          SizedBox(height: 2.h),

          // Email Field
          _buildInputField(
            controller: widget.emailController,
            label: 'Email',
            hint: 'Nhập địa chỉ email của bạn',
            prefixIcon: 'email',
            keyboardType: TextInputType.emailAddress,
            isValid: _isEmailValid,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập email';
              }
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value.trim())) {
                return 'Email không hợp lệ';
              }
              return null;
            },
          ),
          SizedBox(height: 2.h),

          // Password Field
          _buildPasswordField(
            controller: widget.passwordController,
            label: 'Mật khẩu',
            hint: 'Nhập mật khẩu của bạn',
            isVisible: widget.isPasswordVisible,
            onVisibilityToggle: widget.onPasswordVisibilityToggle,
            isValid: _isPasswordValid,
            showStrengthIndicator: true,
          ),
          SizedBox(height: 2.h),

          // Confirm Password Field
          _buildPasswordField(
            controller: widget.confirmPasswordController,
            label: 'Xác nhận mật khẩu',
            hint: 'Nhập lại mật khẩu của bạn',
            isVisible: widget.isConfirmPasswordVisible,
            onVisibilityToggle: widget.onConfirmPasswordVisibilityToggle,
            isValid: _isConfirmPasswordValid,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng xác nhận mật khẩu';
              }
              if (value != widget.passwordController.text) {
                return 'Mật khẩu không khớp';
              }
              return null;
            },
          ),
          SizedBox(height: 3.h),

          // Terms and Conditions
          _buildTermsCheckbox(),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String prefixIcon,
    TextInputType? keyboardType,
    bool isValid = false,
    String? Function(String?)? validator,
  }) {
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
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: prefixIcon,
                size: 5.w,
                color: AppTheme.getTextColor(context, secondary: true),
              ),
            ),
            suffixIcon: controller.text.isNotEmpty
                ? Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: isValid ? 'check_circle' : 'error',
                size: 5.w,
                color: isValid ? AppTheme.success : AppTheme.error,
              ),
            )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    bool isValid = false,
    bool showStrengthIndicator = false,
    String? Function(String?)? validator,
  }) {
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
          validator: validator ??
                  (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu';
                }
                if (value.length < 6) {
                  return 'Mật khẩu phải có ít nhất 6 ký tự';
                }
                return null;
              },
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
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.text.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(right: 2.w),
                    child: CustomIconWidget(
                      iconName: isValid ? 'check_circle' : 'error',
                      size: 5.w,
                      color: isValid ? AppTheme.success : AppTheme.error,
                    ),
                  ),
                GestureDetector(
                  onTap: onVisibilityToggle,
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: isVisible ? 'visibility' : 'visibility_off',
                      size: 5.w,
                      color: AppTheme.getTextColor(context, secondary: true),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showStrengthIndicator && _passwordStrength.isNotEmpty) ...[
          SizedBox(height: 1.h),
          Row(
            children: [
              Text(
                'Độ mạnh: ',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.getTextColor(context, secondary: true),
                ),
              ),
              Text(
                _passwordStrength,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: _passwordStrengthColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }


  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: widget.isTermsAccepted,
          onChanged: widget.onTermsChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => widget.onTermsChanged(!widget.isTermsAccepted),
            child: Padding(
              padding: EdgeInsets.only(top: 2.w),
              child: RichText(
                text: TextSpan(
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.getTextColor(context, secondary: true),
                  ),
                  children: [
                    TextSpan(text: 'Tôi đồng ý với '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: widget.onTermsPressed,
                        child: Text(
                          'Điều khoản sử dụng',
                          style:
                          AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    TextSpan(text: ' và '),
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: widget.onTermsPressed,
                        child: Text(
                          'Chính sách bảo mật',
                          style:
                          AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

