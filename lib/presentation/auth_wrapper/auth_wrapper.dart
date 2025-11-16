// Dán toàn bộ code này vào file: lib/presentation/auth_wrapper/auth_wrapper.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // << THÊM MỚI
import 'package:flutter/material.dart';

import 'package:app_demo/presentation/login_screen/login_screen.dart';
import 'package:app_demo/presentation/main_screen/main_screen.dart';
import 'package:app_demo/presentation/admin_dashboard_screen/admin_dashboard_screen.dart'; // << THÊM MỚI

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  // << THÊM MỚI: Widget riêng để kiểm tra vai trò người dùng >>
  Widget _checkRole(User user) {
    // Sử dụng FutureBuilder để đọc dữ liệu một lần từ Firestore
    return FutureBuilder<DocumentSnapshot>(
      // Lấy thông tin user từ collection 'users' bằng user.uid
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        // 1. Trong khi đang chờ dữ liệu từ Firestore
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                backgroundColor: Colors.blueAccent,
              ),
            ),
          );
        }

        // 2. Nếu có lỗi khi đọc dữ liệu (ví dụ: mất mạng)
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text("Đã có lỗi xảy ra. Vui lòng thử lại."),
            ),
          );
        }

        // 3. Nếu đọc dữ liệu thành công
        if (snapshot.hasData && snapshot.data!.exists) {
          // Lấy dữ liệu của user
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final String role = data['role'] ?? 'user'; // Lấy vai trò, mặc định là 'user'

          // Kiểm tra vai trò và điều hướng
          if (role == 'admin') {
            return const AdminDashboardScreen(); // Đến màn hình Admin
          } else {
            return const MainScreen(); // Đến màn hình User
          }
        }

        // 4. Trường hợp không tìm thấy document của user (hiếm gặp)
        // Cứ cho về màn hình user bình thường
        return const MainScreen();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Lắng nghe sự thay đổi trạng thái đăng nhập từ Firebase
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Trạng thái đang chờ kết nối
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Nếu có dữ liệu người dùng (đã đăng nhập)
        if (snapshot.hasData && snapshot.data != null) {
          // << THAY ĐỔI: Không vào MainScreen ngay >>
          // << Thay vào đó, gọi hàm _checkRole để kiểm tra vai trò >>
          return _checkRole(snapshot.data!);
        }

        // Nếu không có dữ liệu (chưa đăng nhập)
        else {
          // Chuyển đến màn hình đăng nhập
          return const LoginScreen();
        }
      },
    );
  }
}
