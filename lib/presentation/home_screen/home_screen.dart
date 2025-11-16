// Dán toàn bộ code này vào file: lib/presentation/home_screen/home_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_demo/presentation/category_detail_screen/category_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:app_demo/presentation/main_screen/main_screen.dart';
import 'dart:convert'; // << THÊM LẠI
import '../../core/app_export.dart';
import './widgets/greeting_header_widget.dart';


// Widget mới cho phần "Đang học"
class EnrolledCoursesSection extends StatelessWidget {
  final Function(Map<String, dynamic>) onCategoryTap;
  final VoidCallback onSeeMoreTap;

  const EnrolledCoursesSection({
    Key? key,
    required this.onCategoryTap,
    required this.onSeeMoreTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: "Đang học", onSeeMore: onSeeMoreTap),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('enrolledCourses')
              .orderBy('lastStudied', descending: true)
              .limit(2)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [AppTheme.primary.withOpacity(0.8), AppTheme.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const ListTile(
                  leading: Icon(Icons.lightbulb_outline, color: Colors.white, size: 32),
                  title: Text("Bắt đầu hành trình tri thức!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text("Đăng ký một chủ đề để theo dõi tiến độ của bạn tại đây.", style: TextStyle(color: Colors.white70)),
                ),
              );
            }

            final docs = snapshot.data!.docs;
            return Column(
              children: docs.map((doc) {
                final progressData = doc.data() as Map<String, dynamic>;
                final categoryId = doc.id;

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('categories').doc(categoryId).get(),
                  builder: (context, categorySnapshot) {
                    if (categorySnapshot.connectionState == ConnectionState.waiting) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: SizedBox(
                          height: 90,
                          child: Center(child: Text("Đang tải khóa học...")),
                        ),
                      );
                    }

                    if (!categorySnapshot.hasData || !categorySnapshot.data!.exists) {
                      return Card(
                          color: Colors.grey[200],
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: const ListTile(
                            leading: Icon(Icons.error_outline, color: Colors.red),
                            title: Text('Chủ đề này không còn tồn tại'),
                            subtitle: Text('Bạn có thể xóa nó trong danh sách đã đăng ký.'),
                          )
                      );
                    }

                    final categoryData = categorySnapshot.data!.data() as Map<String, dynamic>;
                    categoryData['id'] = categoryId;

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primary.withOpacity(0.1),
                          child: (categoryData['imageBase64'] != null && categoryData['imageBase64'].isNotEmpty)
                              ? ClipOval(
                              child: Image.memory(
                                base64Decode(categoryData['imageBase64'].split(',').last),
                                fit: BoxFit.cover,
                                width: 40,
                                height: 40,
                                errorBuilder: (c, e, s) => Icon(Icons.school_outlined, color: AppTheme.primary),
                              )
                          )
                              : Icon(Icons.school_outlined, color: AppTheme.primary),
                        ),
                        title: Text(categoryData['name'] ?? 'Chủ đề không tên', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(
                                value: (progressData['progress'] ?? 0.0).toDouble(),
                                backgroundColor: Colors.grey[200],
                                color: AppTheme.primary,
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${((progressData['progress'] ?? 0.0) * 100).toStringAsFixed(0)}% Hoàn thành',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        onTap: () => onCategoryTap(categoryData),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// Widget mới cho phần "Gợi ý"
class SuggestedCoursesSection extends StatelessWidget {
  final Function(Map<String, dynamic>) onCategoryTap;
  final VoidCallback onSeeMoreTap;

  const SuggestedCoursesSection({
    Key? key,
    required this.onCategoryTap,
    required this.onSeeMoreTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: "Gợi ý cho bạn", onSeeMore: onSeeMoreTap),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('categories')
              .limit(4)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text("Không có chủ đề nào để gợi ý.");
            }

            final docs = snapshot.data!.docs;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                data['id'] = docs[index].id;

                return GestureDetector(
                  onTap: () => onCategoryTap(data),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Colors.grey[200],
                            child: (data['imageBase64'] != null && data['imageBase64'].isNotEmpty)
                                ? Image.memory(
                              base64Decode(data['imageBase64'].split(',').last),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.school, size: 40, color: AppTheme.primary.withOpacity(0.5));
                              },
                            )
                                : Icon(Icons.school, size: 40, color: AppTheme.primary.withOpacity(0.5)),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            alignment: Alignment.center,
                            child: Text(
                              data['name'] ?? '...',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

// Widget helper cho tiêu đề các phần (Giữ nguyên)
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeMore;

  const _SectionHeader({Key? key, required this.title, required this.onSeeMore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: onSeeMore,
            child: Row(
              children: [
                Text("Xem thêm", style: TextStyle(color: AppTheme.primary)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 16, color: AppTheme.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // <<<< BƯỚC 1: BỎ HÀM `_fetchUserData` và `_userName` >>>>
  // String _userName = 'bạn';
  // @override
  // void initState() {
  //   super.initState();
  //   _fetchUserData();
  // }
  // void _fetchUserData() { ... }


  void _onCategoryTap(Map<String, dynamic> category) {
    final String categoryId = category['id'];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailScreen(categoryId: categoryId),
      ),
    );
  }

  void _onSeeMoreEnrolled() {
    Provider.of<MainScreenStateProvider>(context, listen: false).goToTab(2);
  }

  void _onSeeMoreSuggested() {
    Provider.of<MainScreenStateProvider>(context, listen: false).goToTab(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 32.0),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
                ),
                // <<<< BƯỚC 2: THAY THẾ WIDGET CŨ BẰNG STREAMBUILDER >>>>
                child: StreamBuilder<User?>(
                  // Lắng nghe sự thay đổi của người dùng hiện tại
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    // Lấy tên người dùng một cách linh hoạt
                    String userName = 'bạn';
                    if (snapshot.hasData && snapshot.data != null) {
                      final user = snapshot.data!;
                      userName = user.displayName ?? user.email?.split('@')[0] ?? 'bạn';
                    }
                    // Trả về GreetingHeaderWidget với tên đã được cập nhật
                    return GreetingHeaderWidget(userName: userName);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    EnrolledCoursesSection(
                      onCategoryTap: _onCategoryTap,
                      onSeeMoreTap: _onSeeMoreEnrolled,
                    ),
                    SuggestedCoursesSection(
                      onCategoryTap: _onCategoryTap,
                      onSeeMoreTap: _onSeeMoreSuggested,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
