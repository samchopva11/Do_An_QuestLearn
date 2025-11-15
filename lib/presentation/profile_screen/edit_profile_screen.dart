import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../core/app_export.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // SỬA LỖI 1: Dùng StreamBuilder để lắng nghe trạng thái đăng nhập
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Trường hợp 1: Đang chờ hoặc chưa có dữ liệu user
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Trường hợp 2: Có dữ liệu user
        if (snapshot.hasData && snapshot.data != null) {
          // Trả về widget chứa logic chính, truyền user vào
          return _EditProfileView(user: snapshot.data!);
        }

        // Trường hợp 3: Không có user (đã bị đăng xuất) -> quay về login
        // Đây là một biện pháp an toàn
        return const Scaffold(
          body: Center(child: Text("Bạn chưa đăng nhập. Đang điều hướng...")),
        );
      },
    );
  }
}

// SỬA LỖI 2: Tách logic giao diện ra một Widget riêng
class _EditProfileView extends StatefulWidget {
  final User user; // Nhận user từ StreamBuilder
  const _EditProfileView({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  // Controllers
  late TextEditingController _displayNameController;
  late TextEditingController _dobController;

  // Biến trạng thái
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Bây giờ chúng ta có thể chắc chắn widget.user không null
    _displayNameController = TextEditingController(text: widget.user.displayName);
    _dobController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // Hàm chọn ngày tháng (không đổi)
  Future<void> _selectDate(BuildContext context) async {
    // ... (code không đổi)
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // Hàm xử lý lưu thay đổi
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        User? currentUser = _auth.currentUser;
        if (currentUser == null) return; // Kiểm tra an toàn

        // 1. Cập nhật Display Name
        if (_displayNameController.text != currentUser.displayName) {
          await currentUser.updateDisplayName(_displayNameController.text);
        }

        // 2. Cập nhật ngày sinh (logic vẫn như cũ)
        // ...

        await currentUser.reload();
        Fluttertoast.showToast(msg: "Cập nhật thông tin thành công!");

        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Lỗi: ${e.toString()}", backgroundColor: Colors.red);
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Phần giao diện chính không có thay đổi lớn
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Chỉnh sửa thông tin'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.white))
                : IconButton(
              icon: Icon(Icons.save),
              onPressed: _saveProfile,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Trường Họ và Tên
              TextFormField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: 'Họ và tên',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              SizedBox(height: 3.h),

              // Trường Email (dùng widget.user.email)
              TextFormField(
                initialValue: widget.user.email,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 3.h),

              // Trường Ngày tháng năm sinh
              TextFormField(
                controller: _dobController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Ngày sinh',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onTap: () => _selectDate(context),
              ),

              SizedBox(height: 5.h),
              Text(
                "Lưu ý: Để thay đổi mật khẩu, vui lòng quay lại màn hình Tài khoản và chọn 'Đổi mật khẩu'.",
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
