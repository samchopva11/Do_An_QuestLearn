// Dán toàn bộ code này vào file: lib/presentation/login_screen/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_export.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberEmail = false;
  String? _emailError;
  String? _passwordError;

  // Các hàm initState, dispose, load/save email, và validate không đổi
  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loadRememberedEmail() {}

  void _saveEmailPreference() {}

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  // =======================================================================
  // THAY THẾ TOÀN BỘ HÀM _handleLogin BẰNG PHIÊN BẢN NÂNG CẤP NÀY
  // =======================================================================
  Future<void> _handleLogin() async {
    setState(() {
      _emailError = _validateEmail(_emailController.text);
      _passwordError = _validatePassword(_passwordController.text);
    });

    if (_emailError != null || _passwordError != null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _passwordError = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // 1. Xác thực thông tin đăng nhập với Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // 2. Lấy thông tin chi tiết người dùng từ Firestore
        final doc = await _firestore.collection('users').doc(user.uid).get();

        if (doc.exists) {
          final userData = doc.data()!;
          final bool isDisabled = userData['disabled'] ?? false;

          // 3. KIỂM TRA TRẠNG THÁI TÀI KHOẢN
          if (isDisabled) {
            // 3A. Nếu tài khoản bị vô hiệu hóa
            HapticFeedback.heavyImpact();
            // Đăng xuất người dùng ngay lập tức
            await _auth.signOut();
            // Hiển thị thông báo lỗi
            setState(() {
              _passwordError = 'Tài khoản của bạn đã bị quản trị viên khóa.';
            });
          } else {
            // 3B. Nếu tài khoản hoạt động bình thường
            HapticFeedback.lightImpact();

            if (_rememberEmail) {
              _saveEmailPreference();
            }

            // Điều hướng dựa trên vai trò (role)
            final role = userData['role'] ?? 'student';
            if (role == 'admin' || role == 'teacher') {
              Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.mainScreen);
            }
          }
        } else {
          // Trường hợp hiếm: Auth thành công nhưng không có document trong Firestore
          HapticFeedback.heavyImpact();
          await _auth.signOut();
          setState(() {
            _passwordError = 'Không tìm thấy hồ sơ người dùng. Vui lòng liên hệ hỗ trợ.';
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      HapticFeedback.heavyImpact();
      String errorMessage = 'Email hoặc mật khẩu không chính xác.';
      // Giữ nguyên logic bắt lỗi của bạn
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = 'Email hoặc mật khẩu không chính xác.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Email không hợp lệ.';
      }
      setState(() {
        _passwordError = errorMessage;
      });
    } catch (e) {
      HapticFeedback.heavyImpact();
      setState(() {
        _passwordError = 'Đã xảy ra lỗi không mong muốn.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleForgotPassword() {
    Navigator.pushNamed(context, AppRoutes.forgotPassword);
  }

  // PHẦN GIAO DIỆN (build method) KHÔNG THAY ĐỔI
  @override
  Widget build(BuildContext context) {
    // ... (toàn bộ code trong hàm build của bạn được giữ nguyên)
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 8.h),
                // App Logo
                Container(
                  width: 25.w,
                  height: 25.w,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: CustomIconWidget(
                    iconName: 'quiz',
                    color: AppTheme.surface,
                    size: 12.w,
                  ),
                ),
                SizedBox(height: 4.h),
                // Welcome Text
                Text(
                  'Chào mừng trở lại!',
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Đăng nhập để tiếp tục học tập',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 6.h),
                // Email Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _emailError != null
                              ? AppTheme.error
                              : AppTheme.border,
                          width: _emailError != null ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.shadowLight,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        enabled: !_isLoading,
                        decoration: InputDecoration(
                          hintText: 'Nhập email của bạn',
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(3.w),
                            child: CustomIconWidget(
                              iconName: 'email',
                              color: _emailError != null
                                  ? AppTheme.error
                                  : AppTheme.textSecondary,
                              size: 6.w,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 4.w,
                          ),
                        ),
                        onChanged: (value) {
                          if (_emailError != null) {
                            setState(() {
                              _emailError = null;
                            });
                          }
                        },
                      ),
                    ),
                    if (_emailError != null) ...[
                      SizedBox(height: 1.h),
                      Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: Text(
                          _emailError!,
                          style:
                          AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 3.h),
                // Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _passwordError != null
                              ? AppTheme.error
                              : AppTheme.border,
                          width: _passwordError != null ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.shadowLight,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        textInputAction: TextInputAction.done,
                        enabled: !_isLoading,
                        onFieldSubmitted: (_) => _handleLogin(),
                        decoration: InputDecoration(
                          hintText: 'Nhập mật khẩu',
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(3.w),
                            child: CustomIconWidget(
                              iconName: 'lock',
                              color: _passwordError != null
                                  ? AppTheme.error
                                  : AppTheme.textSecondary,
                              size: 6.w,
                            ),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.all(3.w),
                              child: CustomIconWidget(
                                iconName: _isPasswordVisible
                                    ? 'visibility_off'
                                    : 'visibility',
                                color: AppTheme.textSecondary,
                                size: 6.w,
                              ),
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 4.w,
                          ),
                        ),
                        onChanged: (value) {
                          if (_passwordError != null) {
                            setState(() {
                              _passwordError = null;
                            });
                          }
                        },
                      ),
                    ),
                    if (_passwordError != null) ...[
                      SizedBox(height: 1.h),
                      Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: Text(
                          _passwordError!,
                          style:
                          AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                // Remember Email & Forgot Password Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 6.w,
                          height: 6.w,
                          child: Checkbox(
                            value: _rememberEmail,
                            onChanged: _isLoading
                                ? null
                                : (value) {
                              setState(() {
                                _rememberEmail = value ?? false;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Nhớ email',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _isLoading ? null : _handleForgotPassword,
                      child: Text(
                        'Quên mật khẩu?',
                        style:
                        AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.surface,
                      elevation: _isLoading ? 0 : 4,
                      shadowColor: AppTheme.primary.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      width: 6.w,
                      height: 6.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.surface),
                      ),
                    )
                        : Text(
                      'Đăng nhập',
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(
                        color: AppTheme.surface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Người dùng mới? ',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {
                        Navigator.pushNamed(
                            context, AppRoutes.registration);
                      },
                      child: Text(
                        'Đăng ký tại đây',
                        style:
                        AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
