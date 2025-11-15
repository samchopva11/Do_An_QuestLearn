// Dán toàn bộ code này vào file: lib/presentation/auth_wrapper/auth_wrapper.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_demo/presentation/login_screen/login_screen.dart';
import 'package:app_demo/presentation/main_screen/main_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

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
        if (snapshot.hasData) {
          // Chuyển đến màn hình chính có BottomNavBar
          return const MainScreen();
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
