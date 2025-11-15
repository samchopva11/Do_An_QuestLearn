// Dán toàn bộ code này vào file: lib/presentation/registration_screen/registration_screen.dart

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/registration_button_widget.dart';
import './widgets/registration_form_widget.dart';
import './widgets/registration_header_widget.dart';
import './widgets/terms_modal_widget.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== BƯỚC 1: LOẠI BỎ BIẾN `_selectedRole` =====
  // String _selectedRole = 'Student'; // DÒNG NÀY ĐÃ ĐƯỢC XÓA

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isTermsAccepted = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _nameController.text.trim().length >= 2 &&
        _emailController.text.trim().isNotEmpty &&
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
            .hasMatch(_emailController.text.trim()) &&
        _passwordController.text.length >= 6 &&
        _confirmPasswordController.text == _passwordController.text &&
        _isTermsAccepted;
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!_isTermsAccepted) {
      _showErrorToast('Vui lòng đồng ý với điều khoản sử dụng');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? newUser = userCredential.user;

      if (newUser != null) {
        await newUser.updateDisplayName(_nameController.text.trim());

        // ===== BƯỚC 2: GÁN CỨNG VAI TRÒ LÀ 'student' =====
        await _firestore.collection('users').doc(newUser.uid).set({
          'uid': newUser.uid,
          'displayName': _nameController.text.trim(),
          'email': newUser.email,
          'role': 'student', // GÁN CỨNG VAI TRÒ, KHÔNG DÙNG BIẾN
          'createdAt': FieldValue.serverTimestamp(),
          'photoURL': '', // Thêm trường này cho nhất quán
          'disabled': false, // Thêm trường này cho nhất quán
          'dateOfBirth': null,
        });

        _showSuccessToast('Tạo tài khoản thành công!');

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.mainScreen, (route) => false);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        _showErrorToast('Email này đã được sử dụng. Vui lòng chọn email khác.');
      } else if (e.code == 'weak-password') {
        _showErrorToast('Mật khẩu quá yếu. Vui lòng chọn mật khẩu khác.');
      } else {
        _showErrorToast('Đã xảy ra lỗi. Vui lòng thử lại.');
      }
    } catch (e) {
      _showErrorToast('Đã xảy ra lỗi không xác định. Vui lòng thử lại.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.error,
      textColor: AppTheme.lightTheme.colorScheme.onError,
      fontSize: 14.sp,
    );
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.success,
      textColor: AppTheme.lightTheme.colorScheme.onPrimary,
      fontSize: 14.sp,
    );
  }

  void _showTermsModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TermsModalWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            RegistrationHeaderWidget(
              onBackPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 2.h),
                    Text(
                      'Chào mừng bạn!',
                      style: AppTheme.lightTheme.textTheme.headlineMedium
                          ?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.getTextColor(context),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Tạo tài khoản để bắt đầu hành trình học tập của bạn với Quiz Learning',
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.getTextColor(context, secondary: true),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 4.h),

                    // ===== BƯỚC 3: LOẠI BỎ CÁC THAM SỐ LIÊN QUAN ĐẾN VAI TRÒ =====
                    RegistrationFormWidget(
                      formKey: _formKey,
                      nameController: _nameController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      confirmPasswordController: _confirmPasswordController,
                      // selectedRole: _selectedRole, // DÒNG NÀY ĐÃ ĐƯỢC XÓA
                      isPasswordVisible: _isPasswordVisible,
                      isConfirmPasswordVisible: _isConfirmPasswordVisible,
                      isTermsAccepted: _isTermsAccepted,
                      // onRoleChanged: (role) { // KHỐI NÀY ĐÃ ĐƯỢC XÓA
                      //   setState(() {
                      //     _selectedRole = role;
                      //   });
                      // },
                      onPasswordVisibilityToggle: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      onConfirmPasswordVisibilityToggle: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                          !_isConfirmPasswordVisible;
                        });
                      },
                      onTermsChanged: (value) {
                        setState(() {
                          _isTermsAccepted = value ?? false;
                        });
                      },
                      onTermsPressed: _showTermsModal,
                    ),

                    SizedBox(height: 4.h),
                    RegistrationButtonWidget(
                      isLoading: _isLoading,
                      isEnabled: _isFormValid,
                      onPressed: _handleRegistration,
                    ),
                    SizedBox(height: 3.h),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(
                            context, AppRoutes.loginScreen),
                        child: RichText(
                          text: TextSpan(
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.getTextColor(context,
                                  secondary: true),
                            ),
                            children: [
                              const TextSpan(text: 'Đã có tài khoản? '),
                              TextSpan(
                                text: 'Đăng nhập ngay',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
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

