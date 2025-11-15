
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AdminUserDetailScreen extends StatefulWidget {
  final String userId;

  const AdminUserDetailScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  // DANH SÁCH CÁC VAI TRÒ CÓ THỂ CÓ
  final List<String> _roles = ['student', 'teacher', 'admin'];

  // HÀM VÔ HIỆU HÓA/KÍCH HOẠT TÀI KHOẢN (Giữ nguyên)
  Future<void> _toggleAccountStatus(bool currentStatus) async {
    // ... code giữ nguyên, không thay đổi ...
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'disabled': !currentStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(currentStatus ? 'Đã kích hoạt lại tài khoản.' : 'Đã vô hiệu hóa tài khoản.'),
          backgroundColor: AppTheme.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  // ===================== HÀM MỚI ĐỂ THAY ĐỔI VAI TRÒ =====================
  Future<void> _showChangeRoleDialog(String currentRole) async {
    String? selectedRole = currentRole; // Giá trị ban đầu của dialog

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thay đổi vai trò người dùng'),
          content: StatefulBuilder( // Dùng StatefulBuilder để Radio button có thể cập nhật
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: _roles.map((role) {
                  return RadioListTile<String>(
                    title: Text(role[0].toUpperCase() + role.substring(1)), // Viết hoa chữ cái đầu
                    value: role,
                    groupValue: selectedRole,
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value;
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Lưu'),
              onPressed: () async {
                if (selectedRole != null && selectedRole != currentRole) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.userId)
                        .update({'role': selectedRole});

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã cập nhật vai trò thành công!'),
                        backgroundColor: AppTheme.success,
                      ),
                    );
                  } catch (e) {
                    // Xử lý lỗi
                  }
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Người Dùng'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(widget.userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Không tìm thấy thông tin người dùng."));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final String fullName = userData['displayName'] ?? 'N/A'; // Đã sửa ở bước trước
          final String email = userData['email'] ?? 'N/A';
          final String photoURL = userData['photoURL'] ?? '';
          final Timestamp? createdAt = userData['createdAt'];
          final bool isDisabled = userData['disabled'] ?? false;
          final String currentRole = userData['role'] ?? 'student'; // Lấy vai trò hiện tại

          return SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Phần thông tin cơ bản ---
                _buildInfoSection(photoURL, fullName, email, createdAt),
                SizedBox(height: 4.h),

                // --- Phần quản lý tài khoản ---
                _buildSectionTitle("Quản lý tài khoản"),
                _buildStatusCard(isDisabled),
                SizedBox(height: 2.h),

                // ===================== WIDGET MỚI ĐỂ QUẢN LÝ VAI TRÒ =====================
                _buildRoleCard(currentRole),
                SizedBox(height: 2.h),

                // Nút Vô hiệu hóa / Kích hoạt (Giữ nguyên)
                _buildActionButton(
                  title: isDisabled ? 'Kích hoạt lại tài khoản' : 'Vô hiệu hóa tài khoản',
                  icon: isDisabled ? Icons.check_circle : Icons.block,
                  color: isDisabled ? AppTheme.success : AppTheme.error,
                  onTap: () => _toggleAccountStatus(isDisabled),
                ),
                SizedBox(height: 2.h),

                // --- ĐÃ LOẠI BỎ NÚT RESET PASSWORD ---

                // --- Phần thống kê học tập (Giữ nguyên) ---
                _buildSectionTitle("Thống kê học tập"),
                const Text("Các thông tin về tiến độ học tập sẽ được hiển thị ở đây."),
              ],
            ),
          );
        },
      ),
    );
  }

  // CÁC HÀM BUILD KHÁC (Giữ nguyên)
  Widget _buildInfoSection(String photoURL, String fullName, String email, Timestamp? createdAt) {
    //... code giữ nguyên
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 12.w,
            backgroundImage: photoURL.isNotEmpty ? NetworkImage(photoURL) : null,
            child: photoURL.isEmpty ? Icon(Icons.person, size: 12.w) : null,
          ),
          SizedBox(height: 2.h),
          Text(
            fullName,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 1.h),
          Text(
            email,
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
          ),
          if (createdAt != null) ...[
            SizedBox(height: 1.h),
            Text(
              'Tham gia ngày: ${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    //... code giữ nguyên
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Text(
        title,
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatusCard(bool isDisabled) {
    //... code giữ nguyên
    return Card(
      color: isDisabled ? AppTheme.error.withOpacity(0.1) : AppTheme.success.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          children: [
            Icon(
              isDisabled ? Icons.no_accounts : Icons.verified_user,
              color: isDisabled ? AppTheme.error : AppTheme.success,
            ),
            SizedBox(width: 4.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trạng thái',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                ),
                Text(
                  isDisabled ? 'Đã bị vô hiệu hóa' : 'Đang hoạt động',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDisabled ? AppTheme.error : AppTheme.success,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // ===================== WIDGET MỚI ĐỂ HIỂN THỊ VAI TRÒ =====================
  Widget _buildRoleCard(String currentRole) {
    IconData roleIcon;
    Color roleColor;

    switch (currentRole) {
      case 'admin':
        roleIcon = Icons.shield;
        roleColor = AppTheme.primary;
        break;
      case 'teacher':
        roleIcon = Icons.school;
        roleColor = AppTheme.secondary;
        break;
      default: // student
        roleIcon = Icons.person;
        roleColor = AppTheme.textSecondary;
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(roleIcon, color: roleColor),
                SizedBox(width: 4.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vai trò',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                    ),
                    Text(
                      currentRole[0].toUpperCase() + currentRole.substring(1), // Viết hoa chữ cái đầu
                      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: roleColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            TextButton(
              onPressed: () => _showChangeRoleDialog(currentRole),
              child: const Text('Thay đổi'),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildActionButton({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    //... code giữ nguyên
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 2.h),
        ),
      ),
    );
  }
}
