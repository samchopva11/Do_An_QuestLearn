// Dán toàn bộ code này vào file: lib/presentation/admin_category_management_screen/admin_category_management_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:convert';
import '../../core/app_export.dart';
import '../add_edit_question_screen/add_edit_question_screen.dart';

class AdminCategoryManagementScreen extends StatefulWidget {
  final String categoryId;

  const AdminCategoryManagementScreen({Key? key, required this.categoryId})
      : super(key: key);

  @override
  State<AdminCategoryManagementScreen> createState() =>
      _AdminCategoryManagementScreenState();
}

class _AdminCategoryManagementScreenState
    extends State<AdminCategoryManagementScreen> {

  String _getDifficultyField(String difficulty) {
    switch (difficulty) {
      case 'Dễ':
        return 'easyCount';
      case 'Trung bình':
        return 'mediumCount';
      case 'Khó':
        return 'hardCount';
      default:
        return '';
    }
  }

  Future<void> _showDeleteConfirmationDialog(
      String questionId, String difficulty) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Bạn có chắc chắn muốn xóa câu hỏi này không?'),
                Text('Hành động này không thể hoàn tác.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child:
              const Text('Xóa', style: TextStyle(color: AppTheme.error)),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  final categoryRef = FirebaseFirestore.instance
                      .collection('categories')
                      .doc(widget.categoryId);
                  final questionRef =
                  categoryRef.collection('questions').doc(questionId);

                  // ==========================================================
                  // =====    SỬA LỖI LOGIC XÓA: DÙNG TRANSACTION         =====
                  // ==========================================================
                  await FirebaseFirestore.instance.runTransaction((transaction) async {
                    // Đọc giá trị hiện tại của category để kiểm tra bộ đếm
                    DocumentSnapshot categorySnapshot = await transaction.get(categoryRef);
                    if (!categorySnapshot.exists) {
                      throw Exception("Chủ đề không tồn tại!");
                    }

                    // 1. Xóa document câu hỏi
                    transaction.delete(questionRef);

                    // 2. Cập nhật các bộ đếm trong document category cha
                    final difficultyField = _getDifficultyField(difficulty);
                    if (difficultyField.isNotEmpty) {
                      final currentCount = (categorySnapshot.data() as Map<String, dynamic>)[difficultyField] ?? 0;

                      // Chỉ giảm nếu bộ đếm lớn hơn 0 để tránh số âm
                      if (currentCount > 0) {
                        transaction.update(categoryRef, {
                          'questionCount': FieldValue.increment(-1),
                          difficultyField: FieldValue.increment(-1),
                        });
                      } else {
                        // Nếu bộ đếm đã là 0 (trường hợp hiếm), chỉ giảm questionCount
                        transaction.update(categoryRef, {
                          'questionCount': FieldValue.increment(-1),
                        });
                      }
                    } else {
                      // Nếu không xác định được độ khó, chỉ giảm questionCount
                      transaction.update(categoryRef, {'questionCount': FieldValue.increment(-1)});
                    }
                  });


                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Đã xóa câu hỏi thành công')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Lỗi khi xóa câu hỏi: $e'),
                          backgroundColor: AppTheme.error),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Color _getColorForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'Dễ':
        return AppTheme.success;
      case 'Trung bình':
        return AppTheme.warning;
      case 'Khó':
        return AppTheme.error;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ...Phần còn lại của file giữ nguyên, không có gì thay đổi...
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('categories')
            .doc(widget.categoryId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Không tìm thấy chủ đề."));
          }

          final categoryData =
          snapshot.data!.data() as Map<String, dynamic>;
          final String categoryName =
              categoryData['name'] ?? 'Chủ đề không tên';
          final String base64Image = categoryData['imageBase64'] ?? '';

          Widget imageWidget;
          if (base64Image.isNotEmpty) {
            try {
              final pureBase64 = base64Image.split(',').last;
              final imageBytes = base64Decode(pureBase64);
              imageWidget = Image.memory(imageBytes, fit: BoxFit.cover);
            } catch(e) {
              imageWidget = Container(
                color: AppTheme.surface,
                child: Icon(Icons.broken_image, color: AppTheme.error),
              );
            }
          } else {
            imageWidget = Container(
              color: AppTheme.surface,
              child:
              Icon(Icons.image_not_supported,
                  color: AppTheme.textSecondary),
            );
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
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.3),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // TODO: Điều hướng đến màn hình Sửa thông tin chủ đề
                    },
                    color: Colors.white,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.3),
                    ),
                  )
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    categoryName,
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        const Shadow(blurRadius: 4, color: Colors.black54)
                      ],
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(4.w, 4.w, 4.w, 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Quản lý Câu Hỏi",
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        "Thêm, sửa, xóa các câu hỏi cho chủ đề này.",
                        style: AppTheme.lightTheme.textTheme.bodyMedium
                            ?.copyWith(color: AppTheme.textSecondary),
                      ),
                      SizedBox(height: 3.h),
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('categories')
                            .doc(widget.categoryId)
                            .collection('questions')
                            .orderBy('createdAt',
                            descending: true)
                            .snapshots(),
                        builder: (context, questionSnapshot) {
                          if (questionSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (questionSnapshot.hasError) {
                            return Center(
                                child: Text(
                                    'Lỗi tải câu hỏi: ${questionSnapshot.error}'));
                          }
                          if (!questionSnapshot.hasData ||
                              questionSnapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text('Chưa có câu hỏi nào trong chủ đề này.'),
                            );
                          }

                          final questions = questionSnapshot.data!.docs;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: questions.length,
                            itemBuilder: (context, index) {
                              final questionDoc = questions[index];
                              final questionData =
                              questionDoc.data() as Map<String, dynamic>;
                              final String difficulty =
                                  questionData['difficulty'] ?? 'Không rõ';

                              return Card(
                                margin: EdgeInsets.only(bottom: 2.h),
                                elevation: 2,
                                shadowColor: AppTheme.shadowLight,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text('${index + 1}'),
                                    backgroundColor: AppTheme.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                  title: Text(
                                    questionData['content'] ??
                                        'Nội dung câu hỏi bị thiếu',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme
                                        .lightTheme.textTheme.titleSmall
                                        ?.copyWith(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Chip(
                                      label: Text(difficulty,
                                          style: TextStyle(color: Colors.white)),
                                      backgroundColor:
                                      _getColorForDifficulty(difficulty),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 2.w, vertical: 0),
                                      labelStyle: AppTheme
                                          .lightTheme.textTheme.labelSmall
                                          ?.copyWith(color: Colors.white),
                                      materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete_outline, color: AppTheme.error),
                                    onPressed: () {
                                      _showDeleteConfirmationDialog(
                                          questionDoc.id, difficulty);
                                    },
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddEditQuestionScreen(
                                              categoryId: widget.categoryId,
                                              questionId: questionDoc.id,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditQuestionScreen(
                categoryId: widget.categoryId,
              ),
            ),
          );
        },
        label: const Text("Thêm Câu Hỏi"),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primary,
      ),
    );
  }
}
