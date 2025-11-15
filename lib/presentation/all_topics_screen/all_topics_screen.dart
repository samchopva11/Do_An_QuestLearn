// Dán toàn bộ code này vào file: lib/presentation/all_topics_screen/all_topics_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../category_detail_screen/category_detail_screen.dart';

class AllTopicsScreen extends StatefulWidget {
  const AllTopicsScreen({Key? key}) : super(key: key);

  @override
  State<AllTopicsScreen> createState() => _AllTopicsScreenState();
}

class _AllTopicsScreenState extends State<AllTopicsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategoryTap(String categoryId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailScreen(categoryId: categoryId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Tất cả Chủ đề"),
        backgroundColor: AppTheme.background,
        elevation: 0,
        automaticallyImplyLeading: false, // Ẩn nút back vì đây là tab chính
      ),
      body: Column(
        children: [
          // 1. Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên chủ đề...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          // TODO: Có thể thêm các nút Lọc (Filter) ở đây nếu cần

          // 2. Danh sách kết quả
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('categories').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Lỗi: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Không có chủ đề nào."));
                }

                // Lọc kết quả dựa trên query tìm kiếm
                final results = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] as String? ?? '').toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();

                if (results.isEmpty) {
                  return const Center(child: Text("Không tìm thấy kết quả nào."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final doc = results[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: ListTile(
                        title: Text(data['name'] ?? 'Chủ đề không tên'),
                        subtitle: Text(data['description'] ?? 'Không có mô tả', maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _onCategoryTap(doc.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
