// Dán toàn bộ code này vào file: lib/presentation/admin_edit_category_screen/edit_category_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_export.dart';

class EditCategoryScreen extends StatefulWidget {
  final String categoryId;

  const EditCategoryScreen({super.key, required this.categoryId});

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _newImageFile; // Ảnh mới được chọn (nếu có)
  String? _currentImageBase64; // Ảnh hiện tại dạng Base64
  bool _isLoading = false;
  bool _isFetchingData = true;

  @override
  void initState() {
    super.initState();
    _fetchCategoryData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Lấy dữ liệu cũ của chủ đề để điền vào form
  Future<void> _fetchCategoryData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryId)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data() as Map<String, dynamic>;
        _nameController.text = data['name'] ?? '';
        _descriptionController.text = data['description'] ?? '';
        setState(() {
          _currentImageBase64 = data['imageBase64'];
          _isFetchingData = false;
        });
      }
    } catch (e) {
      if(mounted) {
        Fluttertoast.showToast(msg: "Lỗi tải dữ liệu chủ đề: $e", backgroundColor: AppTheme.error);
        setState(() {
          _isFetchingData = false;
        });
      }
    }
  }

  // Hàm chọn ảnh mới
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
    );
    if (pickedFile != null) {
      setState(() {
        _newImageFile = File(pickedFile.path);
      });
    }
  }

  // Hàm cập nhật chủ đề
  Future<void> _handleUpdateCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() { _isLoading = true; });

    try {
      String? imageToUpdate;
      // Nếu người dùng chọn ảnh mới, xử lý ảnh mới
      if (_newImageFile != null) {
        List<int> imageBytes = await _newImageFile!.readAsBytes();
        if (imageBytes.length > 700 * 1024) {
          Fluttertoast.showToast(msg: "Ảnh mới quá lớn (dưới 700KB)", backgroundColor: AppTheme.error);
          setState(() { _isLoading = false; });
          return;
        }
        String base64Image = base64Encode(imageBytes);
        imageToUpdate = 'data:image/png;base64,$base64Image';
      }

      final categoryName = _nameController.text.trim();
      final updateData = {
        'name': categoryName,
        'description': _descriptionController.text.trim(),
        'name_lowercase': categoryName.toLowerCase(), // CẬP NHẬT TRƯỜNG TÌM KIẾM
        // Nếu có ảnh mới thì cập nhật, không thì giữ nguyên
        if (imageToUpdate != null) 'imageBase64': imageToUpdate,
      };

      await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryId)
          .update(updateData);

      Fluttertoast.showToast(msg: "Cập nhật chủ đề thành công!");
      if (mounted) {
        // Trả về true để màn hình trước có thể làm mới
        Navigator.pop(context, true);
      }

    } catch (e) {
      Fluttertoast.showToast(msg: "Lỗi khi cập nhật: $e", backgroundColor: AppTheme.error);
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  // Widget để hiển thị ảnh (ảnh mới hoặc ảnh cũ)
  Widget _buildImagePreview() {
    // Ưu tiên hiển thị ảnh mới chọn
    if (_newImageFile != null) {
      return Image.file(_newImageFile!, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    }
    // Nếu không có ảnh mới, hiển thị ảnh cũ từ Base64
    if (_currentImageBase64 != null && _currentImageBase64!.isNotEmpty) {
      try {
        final pureBase64 = _currentImageBase64!.split(',').last;
        final imageBytes = base64Decode(pureBase64);
        return Image.memory(imageBytes, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
      } catch (e) {
        // Xử lý lỗi nếu Base64 không hợp lệ
      }
    }
    // Fallback nếu không có ảnh nào
    return Icon(Icons.add_photo_alternate_outlined, size: 12.w, color: AppTheme.textSecondary);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Sửa Thông Tin Chủ Đề', style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isFetchingData
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ảnh bìa chủ đề', style: AppTheme.lightTheme.textTheme.titleMedium),
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
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11), // trừ 1px của border
                      child: _buildImagePreview(),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Text('Tên chủ đề', style: AppTheme.lightTheme.textTheme.titleMedium),
                SizedBox(height: 1.h),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(hintText: 'Nhập tên chủ đề mới...'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Vui lòng nhập tên chủ đề' : null,
                ),
                SizedBox(height: 4.h),
                Text('Mô tả chi tiết', style: AppTheme.lightTheme.textTheme.titleMedium),
                SizedBox(height: 1.h),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(hintText: 'Nhập mô tả mới...'),
                  maxLines: 5,
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Vui lòng nhập mô tả' : null,
                ),
                SizedBox(height: 6.h),
                SizedBox(
                  width: double.infinity,
                  height: 6.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleUpdateCategory,
                    child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Lưu Thay Đổi'),
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
