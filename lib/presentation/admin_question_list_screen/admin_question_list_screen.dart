// Dán toàn bộ code này vào file: lib/presentation/admin_question_list_screen/admin_question_list_screen.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../add_edit_question_screen/add_edit_question_screen.dart';

class AdminQuestionListScreen extends StatefulWidget {
  final String categoryId;
  final String difficulty;

  const AdminQuestionListScreen({
    Key? key,
    required this.categoryId,
    required this.difficulty,
  }) : super(key: key);

  @override
  State<AdminQuestionListScreen> createState() =>
      _AdminQuestionListScreenState();
}

class _AdminQuestionListScreenState extends State<AdminQuestionListScreen> {
  bool _isImporting = false;

  // ==========================================================
  // =====         BẮT ĐẦU LOGIC IMPORT EXCEL             =====
  // ==========================================================

  Future<void> _importFromExcel() async {
    // 1. Chọn file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null) {
      Fluttertoast.showToast(msg: "Đã hủy chọn file.");
      return;
    }

    setState(() => _isImporting = true);

    try {
      File file = File(result.files.single.path!);
      var bytes = await file.readAsBytes();
      var excel = Excel.decodeBytes(bytes);

      var sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null) {
        throw Exception("Không tìm thấy sheet nào trong file Excel.");
      }

      // Xác định các chỉ số cột dựa trên dòng tiêu đề
      final headerRow = sheet.rows.first;
      final Map<String, int> columnIndices = {};
      final requiredColumns = [
        'content', 'optionA', 'optionB', 'optionC', 'optionD',
        'correctAnswerIndex', 'explanation'
      ];

      for (int i = 0; i < headerRow.length; i++) {
        final cellValue = headerRow[i]?.value?.toString().trim();
        if (cellValue != null) {
          columnIndices[cellValue] = i;
        }
      }

      // Kiểm tra xem tất cả các cột bắt buộc có tồn tại không
      for (var col in requiredColumns) {
        if (!columnIndices.containsKey(col)) {
          throw Exception("File Excel thiếu cột bắt buộc: '$col'");
        }
      }

      final categoryRef = FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryId);
      final questionsRef = categoryRef.collection('questions');
      final batch = FirebaseFirestore.instance.batch();
      int questionsAdded = 0;

      // 2. Lặp qua các dòng dữ liệu (bỏ qua dòng tiêu đề)
      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];

        // Lấy dữ liệu từ các ô một cách an toàn
        String? content = row[columnIndices['content']!]?.value?.toString();
        // Bỏ qua dòng trống
        if (content == null || content.trim().isEmpty) continue;

        List<String> options = [
          row[columnIndices['optionA']!]?.value?.toString() ?? '',
          row[columnIndices['optionB']!]?.value?.toString() ?? '',
          row[columnIndices['optionC']!]?.value?.toString() ?? '',
          row[columnIndices['optionD']!]?.value?.toString() ?? '',
        ];

        int? correctAnswerIndex =
        int.tryParse(row[columnIndices['correctAnswerIndex']!]?.value?.toString() ?? '');

        // Kiểm tra dữ liệu hợp lệ
        if (correctAnswerIndex == null || correctAnswerIndex < 0 || correctAnswerIndex > 3) {
          Fluttertoast.showToast(
            msg: "Bỏ qua dòng ${i + 1}: Cột 'correctAnswerIndex' không hợp lệ.",
            backgroundColor: AppTheme.error,
          );
          continue; // Bỏ qua dòng này
        }

        Map<String, dynamic> questionData = {
          'content': content.trim(),
          'options': options.map((e) => e.trim()).toList(),
          'correctAnswerIndex': correctAnswerIndex,
          'explanation':
          row[columnIndices['explanation']!]?.value?.toString().trim() ?? '',
          'difficulty': widget.difficulty, // Tự động gán độ khó
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdatedAt': FieldValue.serverTimestamp(),
        };

        // 3. Thêm vào batch
        batch.set(questionsRef.doc(), questionData);
        questionsAdded++;
      }

      if (questionsAdded == 0) {
        throw Exception("Không có câu hỏi hợp lệ nào được tìm thấy trong file.");
      }

      // 4. Cập nhật bộ đếm
      final difficultyField = _getDifficultyField(widget.difficulty);
      batch.update(categoryRef, {
        'questionCount': FieldValue.increment(questionsAdded),
        if (difficultyField.isNotEmpty)
          difficultyField: FieldValue.increment(questionsAdded),
      });

      // 5. Thực thi batch
      await batch.commit();

      Fluttertoast.showToast(
        msg: "Import thành công $questionsAdded câu hỏi!",
        backgroundColor: AppTheme.success,
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Lỗi Import: ${e.toString()}",
        backgroundColor: AppTheme.error,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  // ========================================================
  // =====          KẾT THÚC LOGIC IMPORT EXCEL           =====
  // ========================================================

  Color _getColorForDifficulty(String difficulty) {
    switch (difficulty) {
      case 'Dễ': return AppTheme.success;
      case 'Trung bình': return AppTheme.warning;
      case 'Khó': return AppTheme.error;
      default: return AppTheme.textSecondary;
    }
  }

  String _getDifficultyField(String difficulty) {
    switch (difficulty) {
      case 'Dễ': return 'easyCount';
      case 'Trung bình': return 'mediumCount';
      case 'Khó': return 'hardCount';
      default: return '';
    }
  }


  @override
  Widget build(BuildContext context) {
    final Color difficultyColor = _getColorForDifficulty(widget.difficulty);

    return Scaffold(
      appBar: AppBar(
        title: Text('Câu hỏi ${widget.difficulty}'),
        backgroundColor: difficultyColor,
        // << THÊM NÚT IMPORT VÀO ĐÂY >>
        actions: [
          // Nếu đang import thì hiển thị vòng xoay
          if (_isImporting)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: CircularProgressIndicator(color: Colors.white)),
            )
          // Nếu không thì hiển thị nút
          else
            IconButton(
              icon: const Icon(Icons.upload_file),
              onPressed: _showImportConfirmationDialog,
              tooltip: 'Import từ file Excel',
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .doc(widget.categoryId)
            .collection('questions')
            .where('difficulty', isEqualTo: widget.difficulty)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi tải câu hỏi: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            // << GIAO DIỆN KHI CHƯA CÓ CÂU HỎI >>
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.help_outline, size: 80, color: Colors.grey[400]),
                    SizedBox(height: 2.h),
                    const Text(
                      'Chưa có câu hỏi nào',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Bạn có thể thêm thủ công bằng nút (+) hoặc import hàng loạt từ file Excel bằng nút (↑) ở góc trên.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          final questions = snapshot.data!.docs;
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 12.h), // Thêm padding dưới
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final questionDoc = questions[index];
              final questionData = questionDoc.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.only(bottom: 2.h),
                elevation: 2,
                shadowColor: AppTheme.shadowLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                    backgroundColor: difficultyColor,
                    foregroundColor: Colors.white,
                  ),
                  title: Text(
                    questionData['content'] ?? 'Nội dung câu hỏi bị thiếu',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.lightTheme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditQuestionScreen(
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
      floatingActionButton: FloatingActionButton(
        onPressed: _isImporting
            ? null // Vô hiệu hóa nút khi đang import
            : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditQuestionScreen(
                categoryId: widget.categoryId,
                initialDifficulty: widget.difficulty,
              ),
            ),
          );
        },
        backgroundColor: _isImporting ? Colors.grey : difficultyColor,
        child: const Icon(Icons.add),
        tooltip: 'Thêm câu hỏi ${widget.difficulty}',
      ),
    );
  }

  // Hộp thoại xác nhận và hướng dẫn trước khi import
  Future<void> _showImportConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Hướng Dẫn Import Excel'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Vui lòng chuẩn bị file Excel (.xlsx) với các cột sau:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text('• content'),
                Text('• optionA'),
                Text('• optionB'),
                Text('• optionC'),
                Text('• optionD'),
                Text('• correctAnswerIndex (0=A, 1=B, 2=C, 3=D)'),
                Text('• explanation'),
                SizedBox(height: 15),
                Text(
                  'Lưu ý: Dòng đầu tiên phải là dòng tiêu đề chứa chính xác các tên cột trên.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            FilledButton.icon(
              icon: Icon(Icons.file_upload),
              label: const Text('Chọn File & Import'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _importFromExcel();
              },
            ),
          ],
        );
      },
    );
  }
}
