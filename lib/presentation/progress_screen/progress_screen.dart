// Dán toàn bộ code này vào file: lib/presentation/progress_screen/progress_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Stream để lắng nghe sự thay đổi trong các khóa học đã đăng ký của user
  Stream<List<Map<String, dynamic>>>? _enrolledCoursesStream;

  @override
  void initState() {
    super.initState();
    _setupStream();
  }

  void _setupStream() {
    final user = _auth.currentUser;
    if (user != null) {
      // Tạo một stream lắng nghe sub-collection 'enrolledCourses'
      _enrolledCoursesStream = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('enrolledCourses')
          .snapshots()
          .asyncMap((snapshot) async {
        // Với mỗi khóa học đã đăng ký, lấy thông tin chi tiết của nó
        List<Future<Map<String, dynamic>?>> futures =
        snapshot.docs.map((doc) async {
          final enrolledData = doc.data();
          final categoryId = doc.id;

          // Truy vấn đến collection 'categories' để lấy tên và các thông tin khác
          final categoryDoc =
          await _firestore.collection('categories').doc(categoryId).get();

          if (categoryDoc.exists) {
            final categoryData = categoryDoc.data()!;
            // Kết hợp dữ liệu từ cả hai nơi
            return {
              'id': categoryId,
              'name': categoryData['name'] ?? 'Chủ đề không tên',
              'progress': enrolledData['progress'] ?? 0.0,
            };
          }
          return null;
        }).toList();

        // Chờ tất cả các truy vấn hoàn thành và lọc ra các kết quả không null
        final results = await Future.wait(futures);
        return results.where((item) => item != null).cast<Map<String, dynamic>>().toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_auth.currentUser == null) {
      // Trường hợp người dùng chưa đăng nhập
      return _buildEmptyState(
        title: 'Bạn chưa đăng nhập',
        subtitle: 'Vui lòng đăng nhập để xem tiến độ học tập.',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tiến độ của bạn',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _enrolledCoursesStream,
        builder: (context, snapshot) {
          // Trạng thái đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Trạng thái có lỗi
          if (snapshot.hasError) {
            return Center(child: Text('Đã có lỗi xảy ra: ${snapshot.error}'));
          }

          // Trạng thái không có dữ liệu hoặc danh sách rỗng
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(
              title: 'Chưa có tiến độ',
              subtitle: 'Hãy đăng ký một vài chủ đề ở trang Home để bắt đầu theo dõi tiến độ học tập của bạn nhé!',
            );
          }

          // Khi đã có dữ liệu
          final enrolledCategories = snapshot.data!;
          return _buildProgressContent(enrolledCategories);
        },
      ),
    );
  }

  Widget _buildProgressContent(List<Map<String, dynamic>> enrolledCategories) {
    // Tính toán tiến độ trung bình
    double averageProgress = 0.0;
    if (enrolledCategories.isNotEmpty) {
      final totalProgress = enrolledCategories.fold<double>(0, (sum, cat) => sum + (cat['progress'] as double));
      averageProgress = totalProgress / enrolledCategories.length;
    }

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      children: [
        _buildOverallStatsCard(enrolledCategories.length, averageProgress),
        SizedBox(height: 3.h),
        Text(
          'Tiến độ chi tiết',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        ...enrolledCategories
            .map((category) => _buildProgressListItem(category))
            .toList(),
      ],
    );
  }

  Widget _buildOverallStatsCard(int enrolledCount, double averageProgress) {
    return Card(
      elevation: 2,
      shadowColor: AppTheme.shadowLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Đã đăng ký', enrolledCount.toString()),
            _buildStatItem('Hoàn thành', '${(averageProgress * 100).toInt()}%'),
          ],
        ),
      ),
    );
  }

  // --- Các hàm build widget con được giữ nguyên vì chúng đã tốt ---

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 10.sp),
        ),
      ],
    );
  }

  Widget _buildProgressListItem(Map<String, dynamic> category) {
    double progress = category['progress'] as double;
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 1,
      shadowColor: AppTheme.shadowLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category['name'] as String,
              style: AppTheme.lightTheme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 1.5.h),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 1.h,
                    backgroundColor: AppTheme.border.withOpacity(0.5),
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.sp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.trending_up, size: 60.sp, color: AppTheme.textSecondary),
            SizedBox(height: 3.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              subtitle,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.sp),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
