// Dán toàn bộ code này vào file: lib/presentation/profile_screen/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../core/app_export.dart';

// Phần EditProfileScreen và StreamBuilder giữ nguyên
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return _EditProfileView(user: snapshot.data!);
        }
        return const Scaffold(
          body: Center(child: Text("Bạn chưa đăng nhập. Đang điều hướng...")),
        );
      },
    );
  }
}

class _EditProfileView extends StatefulWidget {
  final User user;
  const _EditProfileView({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  late TextEditingController _displayNameController;
  late TextEditingController _dobController;

  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _displayNameController =
        TextEditingController(text: widget.user.displayName);
    _dobController = TextEditingController();
    _loadUserFromFirestore();
  }

  Future<void> _loadUserFromFirestore() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();
      if (userDoc.exists && mounted) {
        final data = userDoc.data();
        if (data != null && data.containsKey('dateOfBirth')) {
          final dobTimestamp = data['dateOfBirth'] as Timestamp;
          _selectedDate = dobTimestamp.toDate();
          _dobController.text = DateFormat('dd/MM/yyyy').format(_selectedDate!);
        }
      }
    } catch (e) {
      print("Không thể tải ngày sinh từ Firestore: $e");
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      final newDisplayName = _displayNameController.text.trim();
      Map<String, dynamic> firestoreUpdateData = {};
      bool hasChanges = false;

      // So sánh tên
      if (newDisplayName != (currentUser.displayName ?? '')) {
        await currentUser.updateDisplayName(newDisplayName);
        firestoreUpdateData['displayName'] = newDisplayName;
        hasChanges = true;
      }

      // So sánh ngày sinh
      if (_selectedDate != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
        final data = doc.data();
        DateTime? currentDob;
        if (data != null && data.containsKey('dateOfBirth')) {
          currentDob = (data['dateOfBirth'] as Timestamp).toDate();
        }
        // Chỉ cập nhật nếu ngày sinh mới khác ngày sinh cũ
        if (currentDob == null || !_selectedDate!.isAtSameMomentAs(currentDob)) {
          firestoreUpdateData['dateOfBirth'] = Timestamp.fromDate(_selectedDate!);
          hasChanges = true;
        }
      }

      if (firestoreUpdateData.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update(firestoreUpdateData);
      }

      if (hasChanges) {
        await currentUser.reload();
        Fluttertoast.showToast(msg: "Cập nhật thông tin thành công!");
      } else {
        Fluttertoast.showToast(msg: "Không có thông tin nào thay đổi.");
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Lỗi: ${e.toString()}", backgroundColor: Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ========================================================
  // =====     PHẦN BUILD ĐÃ ĐƯỢC CẬP NHẬT              =====
  // ========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Chỉnh sửa thông tin'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        // << THAY ĐỔI 1: Không cần nút lưu ở đây nữa >>
        // actions: [
        //   ...
        // ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: 'Họ và tên',
                  prefixIcon: Icon(Icons.person_outline),
                  border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              SizedBox(height: 3.h),
              TextFormField(
                initialValue: widget.user.email,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 3.h),
              TextFormField(
                controller: _dobController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Ngày sinh',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onTap: () => _selectDate(context),
              ),

              // << THAY ĐỔI 2: THÊM NÚT CẬP NHẬT MỚI >>
              SizedBox(height: 6.h),
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Cập Nhật'),
                  style: ElevatedButton.styleFrom(
                    textStyle: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                "Lưu ý: Để thay đổi mật khẩu, vui lòng quay lại màn hình Tài khoản và chọn 'Đổi mật khẩu'.",
                style: AppTheme.lightTheme.textTheme.bodySmall
                    ?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
