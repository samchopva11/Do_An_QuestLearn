// Dán toàn bộ code này vào file: lib/presentation/add_edit_question_screen/add_edit_question_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class AddEditQuestionScreen extends StatefulWidget {
  final String categoryId;
  final String? questionId;

  const AddEditQuestionScreen({
    Key? key,
    required this.categoryId,
    this.questionId,
  }) : super(key: key);

  @override
  State<AddEditQuestionScreen> createState() => _AddEditQuestionScreenState();
}

class _AddEditQuestionScreenState extends State<AddEditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _optionAController = TextEditingController();
  final _optionBController = TextEditingController();
  final _optionCController = TextEditingController();
  final _optionDController = TextEditingController();
  final _explanationController = TextEditingController();

  int? _correctAnswerIndex;
  String? _selectedDifficulty;
  final List<String> _difficulties = ['Dễ', 'Trung bình', 'Khó'];

  bool _isLoading = false;
  bool get _isEditMode => widget.questionId != null;

  String? _originalDifficulty;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      _loadQuestionData();
    }
  }

  Future<void> _loadQuestionData() async {
    setState(() => _isLoading = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryId)
          .collection('questions')
          .doc(widget.questionId!)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _contentController.text = data['content'] ?? '';
        _explanationController.text = data['explanation'] ?? '';
        _correctAnswerIndex = data['correctAnswerIndex'];
        _selectedDifficulty = data['difficulty'];
        _originalDifficulty = data['difficulty'];

        if (data['options'] is List && data['options'].length == 4) {
          _optionAController.text = data['options'][0];
          _optionBController.text = data['options'][1];
          _optionCController.text = data['options'][2];
          _optionDController.text = data['options'][3];
        }
      }
    } catch (e) {
      // Xử lý lỗi
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate() ||
        _correctAnswerIndex == null ||
        _selectedDifficulty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ các thông tin bắt buộc.'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final categoryRef =
    FirebaseFirestore.instance.collection('categories').doc(widget.categoryId);

    try {
      List<String> options = [
        _optionAController.text.trim(),
        _optionBController.text.trim(),
        _optionCController.text.trim(),
        _optionDController.text.trim(),
      ];

      Map<String, dynamic> questionData = {
        'content': _contentController.text.trim(),
        'options': options,
        'correctAnswerIndex': _correctAnswerIndex,
        'explanation': _explanationController.text.trim(),
        'difficulty': _selectedDifficulty,
        'lastUpdatedAt': FieldValue.serverTimestamp(),
      };

      final collectionRef = categoryRef.collection('questions');
      WriteBatch batch = FirebaseFirestore.instance.batch();

      if (_isEditMode) {
        final questionRef = collectionRef.doc(widget.questionId!);
        batch.update(questionRef, questionData);

        if (_originalDifficulty != null &&
            _originalDifficulty != _selectedDifficulty) {
          final oldField = _getDifficultyField(_originalDifficulty!);
          final newField = _getDifficultyField(_selectedDifficulty!);

          // Dùng set + merge để đảm bảo an toàn
          if (oldField.isNotEmpty) {
            batch.set(categoryRef, {oldField: FieldValue.increment(-1)}, SetOptions(merge: true));
          }
          if (newField.isNotEmpty) {
            batch.set(categoryRef, {newField: FieldValue.increment(1)}, SetOptions(merge: true));
          }
        }
      } else {
        // --- CHẾ ĐỘ THÊM MỚI ---
        questionData['createdAt'] = FieldValue.serverTimestamp();
        final newQuestionRef = collectionRef.doc();
        batch.set(newQuestionRef, questionData);

        // ==========================================================
        // =====    SỬA LỖI: DÙNG SET + MERGE THAY CHO UPDATE    =====
        // ==========================================================
        final difficultyField = _getDifficultyField(_selectedDifficulty!);
        batch.set(
          categoryRef,
          {
            'questionCount': FieldValue.increment(1),
            if (difficultyField.isNotEmpty)
              difficultyField: FieldValue.increment(1),
          },
          SetOptions(merge: true), // Quan trọng nhất!
        );
      }

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode
              ? 'Cập nhật câu hỏi thành công!'
              : 'Tạo câu hỏi thành công!'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Đã có lỗi xảy ra: $e'),
            backgroundColor: AppTheme.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    _optionCController.dispose();
    _optionDController.dispose();
    _explanationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Sửa Câu Hỏi' : 'Thêm Câu Hỏi Mới'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveQuestion,
            tooltip: 'Lưu Câu Hỏi',
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Nội dung câu hỏi'),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Câu hỏi'),
                maxLines: 3,
                validator: (v) =>
                v!.isEmpty ? 'Không được để trống' : null,
              ),
              SizedBox(height: 3.h),
              _buildSectionTitle('Độ khó'),
              DropdownButtonFormField<String>(
                value: _selectedDifficulty,
                hint: const Text('Chọn độ khó'),
                items: _difficulties
                    .map((String difficulty) => DropdownMenuItem<String>(
                    value: difficulty, child: Text(difficulty)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedDifficulty = v),
                validator: (v) => v == null ? 'Vui lòng chọn độ khó' : null,
              ),
              SizedBox(height: 3.h),
              _buildSectionTitle('Các lựa chọn trả lời'),
              _buildOptionField(_optionAController, 'Lựa chọn A'),
              _buildOptionField(_optionBController, 'Lựa chọn B'),
              _buildOptionField(_optionCController, 'Lựa chọn C'),
              _buildOptionField(_optionDController, 'Lựa chọn D'),
              SizedBox(height: 3.h),
              _buildSectionTitle('Đáp án đúng'),
              _buildCorrectAnswerSelector(),
              SizedBox(height: 3.h),
              _buildSectionTitle('Giải thích (Không bắt buộc)'),
              TextFormField(
                controller: _explanationController,
                decoration:
                const InputDecoration(labelText: 'Giải thích đáp án'),
                maxLines: 2,
              ),
              SizedBox(height: 5.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveQuestion,
                  icon: const Icon(Icons.save),
                  label: Text(_isEditMode ? 'Cập Nhật' : 'Lưu Câu Hỏi'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Text(title,
          style: AppTheme.lightTheme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildOptionField(TextEditingController controller, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (v) => v!.isEmpty ? 'Lựa chọn không được để trống' : null,
      ),
    );
  }

  Widget _buildCorrectAnswerSelector() {
    return Column(
      children: List.generate(4, (index) {
        return RadioListTile<int>(
          title: Text('Lựa chọn ${String.fromCharCode(65 + index)}'),
          value: index,
          groupValue: _correctAnswerIndex,
          onChanged: (v) => setState(() => _correctAnswerIndex = v),
        );
      }),
    );
  }
}
