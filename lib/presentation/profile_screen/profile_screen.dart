// Dán toàn bộ code này vào file: lib/presentation/profile_screen/profile_screen.dart

import 'package:flutter/material.dart';import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
// THÊM IMPORT NÀY ĐỂ DÙNG FIRESTORE
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_export.dart';
import 'package:app_demo/presentation/profile_screen/change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Thay vì lưu cả User object, chúng ta sẽ lưu các thông tin cần thiết
  String? _displayName;
  String? _email;
  String? _photoURL;
  bool _isLoading = true; // Thêm biến cờ để báo đang tải dữ liệu

  @override
  void initState() {
    super.initState();
    // Lấy dữ liệu người dùng ngay khi màn hình khởi tạo
    _fetchUserData();
  }

  // =======================================================================
  // THAY THẾ TOÀN BỘ HÀM _fetchUserData BẰNG PHIÊN BẢN NÂNG CẤP NÀY
  // =======================================================================
  Future<void> _fetchUserData() async {
    // Lấy người dùng hiện tại từ Authentication để có uid và email
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        // Dùng uid để lấy document tương ứng trong collection 'users'
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && mounted) {
          // Lấy dữ liệu từ Firestore và cập nhật state
          final userData = userDoc.data()!;
          setState(() {
            _displayName = userData['displayName']; // LẤY TÊN TỪ FIRESTORE
            _email = user.email; // Email có thể lấy trực tiếp từ Auth
            _photoURL = userData['photoURL']; // Ảnh cũng nên lấy từ Firestore
            _isLoading = false; // Tải xong
          });
        } else {
          // Nếu không có document, hiển thị dữ liệu mặc định từ Auth
          setState(() {
            _displayName = user.displayName;
            _email = user.email;
            _photoURL = user.photoURL;
            _isLoading = false;
          });
        }
      } catch (e) {
        // Xử lý lỗi nếu có
        print("Lỗi khi lấy dữ liệu từ Firestore: $e");
        if(mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Hàm xử lý đăng xuất không đổi
  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.loginScreen,
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Lỗi khi đăng xuất: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Đăng xuất không thành công. Vui lòng thử lại.')),
      );
    }
  }

  // Hàm điều hướng không đổi, chỉ cần reload dữ liệu
  Future<void> _navigateToEditProfile() async {
    final result =
    await Navigator.pushNamed(context, AppRoutes.editProfileScreen);

    // Nếu màn hình edit trả về true (nghĩa là đã có thay đổi),
    // gọi lại _fetchUserData để làm mới dữ liệu
    if (result == true && mounted) {
      _fetchUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Nếu đang tải, hiển thị vòng xoay
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tài khoản')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Tài khoản',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30.sp,
                  backgroundColor: AppTheme.primary.withOpacity(0.1),
                  // SỬA LẠI ĐỂ DÙNG BIẾN STATE MỚI
                  backgroundImage:
                  _photoURL != null && _photoURL!.isNotEmpty
                      ? NetworkImage(_photoURL!)
                      : null,
                  child: _photoURL == null || _photoURL!.isEmpty
                      ? CustomIconWidget(
                    iconName: 'person',
                    size: 30.sp,
                    color: AppTheme.primary,
                  )
                      : null,
                ),
                SizedBox(width: 4.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // SỬA LẠI ĐỂ DÙNG BIẾN STATE MỚI
                      _displayName ?? 'Người dùng mới',
                      style: AppTheme.lightTheme.textTheme.titleLarge,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      // SỬA LẠI ĐỂ DÙNG BIẾN STATE MỚI
                      _email ?? 'Không có email',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 4.h),
            _buildProfileOptionTile(
              icon: 'edit',
              title: 'Chỉnh sửa thông tin',
              onTap: _navigateToEditProfile,
            ),
            _buildProfileOptionTile(
              icon: 'lock_reset',
              title: 'Đổi mật khẩu',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ChangePasswordScreen()),
                );
              },
            ),
            const Spacer(),
            // --- Nút Đăng xuất ---
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton.icon(
                onPressed: () => _handleLogout(context),
                icon: CustomIconWidget(
                  iconName: 'logout',
                  size: 22,
                  color: Colors.white,
                ),
                label: Text(
                  'Đăng xuất',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  // Hàm build option không đổi
  Widget _buildProfileOptionTile({
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  })
  {
    {
      final color = isLogout ? Colors.red : AppTheme.textPrimary;
      return ListTile(
        leading: CustomIconWidget(
          iconName: icon,
          size: 24,
          color: color,
        ),
        title: Text(
          title,
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(color: color),
        ),
        trailing: isLogout
            ? null
            : CustomIconWidget(
          iconName: 'chevron_right',
          size: 24,
          color: AppTheme.textSecondary,
        ),
        onTap: onTap,
      );
    }
  }
}





