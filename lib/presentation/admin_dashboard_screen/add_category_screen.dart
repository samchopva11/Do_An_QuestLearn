
import 'dart:convert'; // Thêm thư viện để dùng Base64
import 'dart:io';     // Cần để làm việc với File
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart'; // Thư viện chọn ảnh
import 'package:cloud_firestore/cloud_firestore.dart'; // Thư viện Firestore
import '../../core/app_export.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _imageFile; // Biến để lưu file ảnh đã chọn
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // HÀM CHỌN ẢNH (Giữ nguyên)
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Giảm chất lượng ảnh để file nhẹ hơn
      maxWidth: 800,   // Giảm chiều rộng ảnh
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // HÀM LƯU DỮ LIỆU (ĐÃ SỬA ĐỂ DÙNG BASE64)
  Future<void> _handleSaveCategory() async {
    // 1. Kiểm tra tính hợp lệ của form và việc chọn ảnh
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_imageFile == null) {
      Fluttertoast.showToast(
          msg: "Vui lòng chọn ảnh bìa cho chủ đề",
          backgroundColor: AppTheme.error);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Đọc file ảnh dưới dạng một chuỗi các byte
      print("Bắt đầu đọc file ảnh...");
      List<int> imageBytes = await _imageFile!.readAsBytes();

      // KIỂM TRA KÍCH THƯỚC FILE (Rất quan trọng để không vượt quá giới hạn 1MB của Firestore)
      // Giới hạn ở đây là 700KB (700 * 1024 bytes)
      if (imageBytes.length > 700 * 1024) {
        Fluttertoast.showToast(
          msg: "Ảnh quá lớn. Vui lòng chọn ảnh dưới 700KB.",
          backgroundColor: AppTheme.error,
          toastLength: Toast.LENGTH_LONG, // Hiển thị lâu hơn
        );
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return; // Dừng lại nếu ảnh quá lớn
      }

      // 3. Mã hóa chuỗi byte đó thành một chuỗi văn bản Base64
      print("Đang chuyển đổi ảnh sang Base64...");
      String base64Image = base64Encode(imageBytes);

      // 4. Lưu dữ liệu vào Firestore
      print("Bắt đầu lưu dữ liệu vào Firestore...");
      await FirebaseFirestore.instance.collection('categories').add({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'imageUrl': '', // Để trống vì chúng ta không dùng Storage URL nữa
        // Thêm trường mới để lưu ảnh Base64
        'imageBase64': 'data:image/png;base64,$base64Image',
        'questionCount': 0, // Mặc định ban đầu
        'createdAt': Timestamp.now(), // Lưu thời gian tạo
      });
      print("✅ Lưu dữ liệu vào Firestore thành công!");

      Fluttertoast.showToast(msg: "Thêm chủ đề mới thành công!");

      if (mounted) {
        Navigator.pop(context, true); // Quay về màn hình dashboard
      }
    } catch (e) {
      print("🔥 Lỗi khi lưu chủ đề: $e");
      Fluttertoast.showToast(
          msg: "Đã có lỗi xảy ra. Vui lòng thử lại.",
          backgroundColor: AppTheme.error);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Thêm Chủ Đề Mới',
          style: AppTheme.lightTheme.textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- PHẦN CHỌN ẢNH BÌA ---
                Text('Ảnh bìa chủ đề',
                    style: AppTheme.lightTheme.textTheme.titleMedium),
                SizedBox(height: 1.h),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 25.h,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border, width: 1),
                      // Hiển thị ảnh đã chọn hoặc khung chọn ảnh
                      image: _imageFile != null
                          ? DecorationImage(
                        image: FileImage(_imageFile!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: _imageFile == null
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              size: 12.w, color: AppTheme.textSecondary),
                          SizedBox(height: 1.h),
                          Text('Nhấn để chọn ảnh (dưới 700KB)',
                              style: TextStyle(
                                  color: AppTheme.textSecondary)),
                        ],
                      ),
                    )
                        : null,
                  ),
                ),

                SizedBox(height: 4.h),

                // --- Phần Tên Chủ Đề ---
                Text('Tên chủ đề',
                    style: AppTheme.lightTheme.textTheme.titleMedium),
                SizedBox(height: 1.h),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'Ví dụ: Lịch sử thế giới hiện đại',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tên chủ đề';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 4.h),

                // --- Phần Mô Tả ---
                Text('Mô tả chi tiết',
                    style: AppTheme.lightTheme.textTheme.titleMedium),
                SizedBox(height: 1.h),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    hintText: 'Giới thiệu về nội dung, mục tiêu của chủ đề...',
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập mô tả';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 6.h),

                // --- Nút Lưu ---
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSaveCategory,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Lưu Chủ Đề'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
