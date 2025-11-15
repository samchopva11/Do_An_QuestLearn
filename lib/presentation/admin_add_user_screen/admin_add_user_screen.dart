// Dán toàn bộ code này vào file: lib/presentation/admin_add_user_screen/admin_add_user_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
// THÊM IMPORT NÀY
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class AdminAddUserScreen extends StatefulWidget {
  const AdminAddUserScreen({Key? key}) : super(key: key);

  @override
  State<AdminAddUserScreen> createState() => _AdminAddUserScreenState();
}

class _AdminAddUserScreenState extends State<AdminAddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final List<String> _roles = ['student', 'teacher', 'admin'];
  String _selectedRole = 'student';
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAddNewUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // ===== SỬA LỖI TRIỆT ĐỂ: SỬ DỤNG INSTANCE FIREBASE PHỤ =====
      // Lấy instance của FirebaseAuth từ app phụ 'AdminAuth' đã khởi tạo trong main.dart
      FirebaseAuth adminAuth = FirebaseAuth.instanceFor(app: Firebase.app('AdminAuth'));

      UserCredential userCredential = await adminAuth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // ==========================================================

      User? newUser = userCredential.user;

      if (newUser != null) {
        // Lưu thông tin chi tiết vào Firestore (dùng instance mặc định)
        await FirebaseFirestore.instance.collection('users').doc(newUser.uid).set({
          'uid': newUser.uid,
          'displayName': _fullNameController.text.trim(),
          'email': newUser.email,
          'role': _selectedRole,
          'createdAt': FieldValue.serverTimestamp(),
          'photoURL': '',
          'disabled': false,
        });

        // Đăng xuất người dùng vừa tạo ra khỏi instance phụ để dọn dẹp
        await adminAuth.signOut();

        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo người dùng mới thành công!'),
              backgroundColor: AppTheme.success,
            ),
          );
          Navigator.pop(context, true); // Trả về true để báo hiệu thành công
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Đã có lỗi xảy ra.';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'Email này đã tồn tại trên hệ thống.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'Mật khẩu phải có ít nhất 6 ký tự.';
      }
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: AppTheme.error),
        );
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi không xác định: $e'), backgroundColor: AppTheme.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ...Phần build UI không thay đổi, bạn có thể giữ nguyên hoặc dán đè...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Người Dùng Mới'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Vui lòng nhập họ và tên' : null,
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Vui lòng nhập email';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) return 'Email không hợp lệ';
                  return null;
                },
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mật khẩu tạm thời'),
                obscureText: true,
                validator: (value) => value == null || value.length < 6 ? 'Mật khẩu phải có ít nhất 6 ký tự' : null,
              ),
              SizedBox(height: 4.h),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Vai trò'),
                items: _roles.map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role[0].toUpperCase() + role.substring(1)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedRole = newValue!;
                  });
                },
              ),
              SizedBox(height: 6.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleAddNewUser,
                  icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.save),
                  label: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Lưu Người Dùng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

