// Dán toàn bộ code này vào file: lib/presentation/admin_category_management_screen/admin_category_management_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/app_export.dart';
import '../add_edit_question_screen/add_edit_question_screen.dart';
import '../admin_edit_category_screen/edit_category_screen.dart';
// << 1. IMPORT MÀN HÌNH MỚI >>
import '../admin_question_list_screen/admin_question_list_screen.dart';

class AdminCategoryManagementScreen extends StatefulWidget {
  final String categoryId;

  const AdminCategoryManagementScreen({Key? key, required this.categoryId})
      : super(key: key);

  @override
  State<AdminCategoryManagementScreen> createState() =>
      _AdminCategoryManagementScreenState();
}

class _AdminCategoryManagementScreenState extends State<AdminCategoryManagementScreen> {
  // Các hàm xử lý xóa và điều hướng (giữ nguyên không đổi)
  Future<void> _showDeleteCategoryConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Xác Nhận Xóa Chủ Đề'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bạn có chắc chắn muốn xóa toàn bộ chủ đề này?'),
                Text(
                  'TẤT CẢ câu hỏi bên trong cũng sẽ bị xóa vĩnh viễn. Hành động này không thể hoàn tác.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('Xóa Vĩnh Viễn', style: TextStyle(color: AppTheme.error)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _handleDeleteCategory();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleDeleteCategory() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final categoryRef = FirebaseFirestore.instance.collection('categories').doc(widget.categoryId);
      final questionsQuery = categoryRef.collection('questions');
      final questionSnapshot = await questionsQuery.get();
      final batch = FirebaseFirestore.instance.batch();
      for (final doc in questionSnapshot.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(categoryRef);
      await batch.commit();
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      Fluttertoast.showToast(msg: "Đã xóa chủ đề thành công!");
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      Fluttertoast.showToast(msg: "Lỗi khi xóa chủ đề: $e", backgroundColor: AppTheme.error);
    }
  }

  Future<void> _navigateToEditScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCategoryScreen(categoryId: widget.categoryId),
      ),
    );
    if (result == true && mounted) {
      setState(() {});
    }
  }

  // Hàm lấy màu (giữ nguyên)
  Color _getColorForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'Dễ': return AppTheme.success;
      case 'Trung bình': return AppTheme.warning;
      case 'Khó': return AppTheme.error;
      default: return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // << 2. THAY FUTUREBUILDER BẰNG STREAMBUILDER ĐỂ SỐ LƯỢNG CÂU HỎI CẬP NHẬT TỨC THÌ >>
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .doc(widget.categoryId)
            .snapshots(), // Dùng snapshots()
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            // Xử lý trường hợp chủ đề đã bị xóa
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(context).pop();
              }
            });
            return const Center(child: Text("Chủ đề đã bị xóa. Đang quay lại..."));
          }

          final categoryData = snapshot.data!.data() as Map<String, dynamic>;
          final String categoryName = categoryData['name'] ?? 'Chủ đề không tên';
          final String base64Image = categoryData['imageBase64'] ?? '';

          // Lấy số lượng câu hỏi từ categoryData
          final int easyCount = categoryData['easyCount'] ?? 0;
          final int mediumCount = categoryData['mediumCount'] ?? 0;
          final int hardCount = categoryData['hardCount'] ?? 0;

          Widget imageWidget;
          if (base64Image.isNotEmpty) {
            try {
              final pureBase64 = base64Image.split(',').last;
              final imageBytes = base64Decode(pureBase64);
              imageWidget = Image.memory(imageBytes, fit: BoxFit.cover);
            } catch(e) {
              imageWidget = Container(color: AppTheme.surface, child: Icon(Icons.broken_image, color: AppTheme.error));
            }
          } else {
            imageWidget = Container(color: AppTheme.surface, child: Icon(Icons.image_not_supported, color: AppTheme.textSecondary));
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 30.h,
                pinned: true,
                stretch: true,
                backgroundColor: AppTheme.background,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () => Navigator.pop(context),
                  color: Colors.white,
                  style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.3)),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _navigateToEditScreen,
                    tooltip: 'Sửa thông tin chủ đề',
                    color: Colors.white,
                    style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.3)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_forever),
                    onPressed: _showDeleteCategoryConfirmationDialog,
                    tooltip: 'Xóa toàn bộ chủ đề',
                    color: Colors.white,
                    style: IconButton.styleFrom(backgroundColor: AppTheme.error.withOpacity(0.5)),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    categoryName,
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [const Shadow(blurRadius: 4, color: Colors.black54)],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      imageWidget,
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black87],
                            stops: [0.5, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                  stretchModes: const [StretchMode.zoomBackground],
                ),
              ),
              // << 3. PHẦN BODY MỚI VỚI CÁC THẺ NHÓM CÂU HỎI >>
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 4.w, 4.w, 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Quản lý Câu Hỏi", style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      SizedBox(height: 1.h),
                      Text("Chọn một mức độ để xem hoặc thêm câu hỏi mới.", style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
                      SizedBox(height: 4.h),

                      // Thẻ nhóm Dễ
                      _buildDifficultyCard(
                          title: 'Dễ',
                          count: easyCount,
                          color: AppTheme.success,
                          icon: Icons.sentiment_very_satisfied,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AdminQuestionListScreen(categoryId: widget.categoryId, difficulty: 'Dễ')));
                          }
                      ),
                      SizedBox(height: 2.h),

                      // Thẻ nhóm Trung bình
                      _buildDifficultyCard(
                          title: 'Trung bình',
                          count: mediumCount,
                          color: AppTheme.warning,
                          icon: Icons.sentiment_neutral,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AdminQuestionListScreen(categoryId: widget.categoryId, difficulty: 'Trung bình')));
                          }
                      ),
                      SizedBox(height: 2.h),

                      // Thẻ nhóm Khó
                      _buildDifficultyCard(
                          title: 'Khó',
                          count: hardCount,
                          color: AppTheme.error,
                          icon: Icons.sentiment_very_dissatisfied,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AdminQuestionListScreen(categoryId: widget.categoryId, difficulty: 'Khó')));
                          }
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      // << 4. BỎ FLOATINGACTIONBUTTON Ở ĐÂY >>
      // floatingActionButton: ...
    );
  }

  // << 5. WIDGET HELPER ĐỂ TẠO THẺ NHÓM ĐẸP HƠN >>
  Widget _buildDifficultyCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    required VoidCallback onTap
  }) {
    return Card(
      elevation: 4,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      clipBehavior: Clip.antiAlias, // Để hiệu ứng ripple không bị tràn ra ngoài
      child: InkWell(
        onTap: onTap,
        splashColor: color.withOpacity(0.2),
        highlightColor: color.withOpacity(0.1),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 8)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 40),
                  SizedBox(width: 4.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      Text('$count câu hỏi', style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
