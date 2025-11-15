// Dán toàn bộ code này vào file: lib/presentation/main_screen/main_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <<<< THÊM MỚI: Import Provider
import 'package:app_demo/presentation/home_screen/home_screen.dart';
import 'package:app_demo/presentation/progress_screen/progress_screen.dart';
import 'package:app_demo/presentation/profile_screen/profile_screen.dart';
import 'package:app_demo/core/app_export.dart';
import 'package:app_demo/presentation/all_topics_screen/all_topics_screen.dart';

// Class Provider để quản lý trạng thái của MainScreen
class MainScreenStateProvider with ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void goToTab(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners(); // Thông báo cho các widget đang lắng nghe về sự thay đổi
    }
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // <<<< CHỈNH SỬA: Bỏ state cục bộ đi, chúng ta sẽ dùng Provider >>>>
  // int _currentIndex = 0;
  // void _onTap(int index) { ... }

  // Danh sách màn hình không đổi
  final List<Widget> _screens = [
    const HomeScreen(),
    const AllTopicsScreen(),
    const ProgressScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // <<<< CHỈNH SỬA: Lấy state từ Provider >>>>
    final mainScreenState = Provider.of<MainScreenStateProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        // <<<< CHỈNH SỬA: Dùng Provider để điều khiển >>>>
        if (mainScreenState.currentIndex != 0) {
          // Yêu cầu provider chuyển về tab 0
          context.read<MainScreenStateProvider>().goToTab(0);
          return false; // Ngăn không cho pop màn hình
        }
        return true; // Cho phép pop (thoát app) nếu đang ở tab Home
      },
      child: Scaffold(
        body: IndexedStack(
          // <<<< CHỈNH SỬA: Dùng currentIndex từ Provider >>>>
          index: mainScreenState.currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          // <<<< CHỈNH SỬA: Dùng currentIndex từ Provider >>>>
          currentIndex: mainScreenState.currentIndex,
          // <<<< CHỈNH SỬA: Dùng Provider để xử lý sự kiện onTap >>>>
          onTap: (index) => context.read<MainScreenStateProvider>().goToTab(index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.background,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textSecondary,
          selectedFontSize: 12.0,
          unselectedFontSize: 12.0,
          items: [
            // <<<< CHỈNH SỬA: Cập nhật điều kiện màu sắc theo Provider >>>>
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'home',
                size: 24,
                color: mainScreenState.currentIndex == 0 ? AppTheme.primary : AppTheme.textSecondary,
              ),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'list_alt',
                size: 24,
                color: mainScreenState.currentIndex == 1 ? AppTheme.primary : AppTheme.textSecondary,
              ),
              label: 'Danh sách',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'trending_up',
                size: 24,
                color: mainScreenState.currentIndex == 2 ? AppTheme.primary : AppTheme.textSecondary,
              ),
              label: 'Tiến độ',
            ),
            BottomNavigationBarItem(
              icon: CustomIconWidget(
                iconName: 'person',
                size: 24,
                color: mainScreenState.currentIndex == 3 ? AppTheme.primary : AppTheme.textSecondary,
              ),
              label: 'Tài khoản',
            ),
          ],
        ),
      ),
    );
  }
}
