// Dán toàn bộ code này vào file: lib/presentation/admin_dashboard_screen/admin_dashboard_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../../core/app_export.dart';
import './widgets/statistics_card_widget.dart';
import '../admin_add_user_screen/admin_add_user_screen.dart';
import '../admin_category_management_screen/admin_category_management_screen.dart';
import '../admin_user_detail_screen/admin_user_detail_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  int _totalCategories = 0;
  int _totalUsers = 0;

  final List<String> _chartTypes = ['Người dùng mới', 'Chủ đề mới'];
  final List<String> _timeRanges = ['Ngày', 'Tháng', 'Năm'];
  String _selectedChartType = 'Người dùng mới';
  String _selectedTimeRange = 'Ngày';

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 6));
  DateTime _endDate = DateTime.now();

  Map<String, int> _groupedData = {};
  bool _isChartLoading = true;
  double _chartMaxY = 10.0;

  // State cho việc tìm kiếm
  final TextEditingController _categorySearchController = TextEditingController();
  final TextEditingController _userSearchController = TextEditingController();
  String _categorySearchQuery = "";
  String _userSearchQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isLoading = true;
    _fetchDashboardData();
    _fetchChartData();

    // Lắng nghe sự thay đổi của các thanh tìm kiếm
    _categorySearchController.addListener(() {
      if (mounted) {
        setState(() {
          _categorySearchQuery = _categorySearchController.text;
        });
      }
    });

    _userSearchController.addListener(() {
      if (mounted) {
        setState(() {
          _userSearchQuery = _userSearchController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Dispose các controller tìm kiếm
    _categorySearchController.dispose();
    _userSearchController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.loginScreen, (route) => false);
    }
  }

  Future<void> _fetchDashboardData() async {
    final categorySnapshot = await FirebaseFirestore.instance.collection('categories').get();
    final userSnapshot = await FirebaseFirestore.instance.collection('users').get();
    if (mounted) {
      setState(() {
        _totalCategories = categorySnapshot.docs.length;
        _totalUsers = userSnapshot.docs.length;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _isLoading = true;
      _isChartLoading = true;
    });
    await _fetchDashboardData();
    await _fetchChartData();
  }

  Future<void> _navigateAndRefreshForAddCategory() async {
    final result = await Navigator.pushNamed(context, AppRoutes.addCategoryScreen);
    if (result == true && mounted) {
      _refreshDashboard();
    }
  }

  Future<void> _navigateAndRefreshForAddUser() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminAddUserScreen()),
    );

    if (result == true && mounted) {
      _refreshDashboard();
    }
  }

  // ... các hàm _fetchChartData, _selectDate, v.v... giữ nguyên ...
  Future<void> _fetchChartData() async {
    setState(() {
      _isChartLoading = true;
      _groupedData = {};
    });

    final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final end = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59);

    if (end.isBefore(start)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Lỗi: Ngày kết thúc không thể trước ngày bắt đầu.'),
              backgroundColor: AppTheme.error),
        );
      }
      setState(() => _isChartLoading = false);
      return;
    }

    try {
      String collectionPath;
      String dateField;
      switch (_selectedChartType) {
        case 'Chủ đề mới':
          collectionPath = 'categories';
          dateField = 'createdAt';
          break;
        case 'Người dùng mới':
        default:
          collectionPath = 'users';
          dateField = 'createdAt';
          break;
      }

      final snapshots = await FirebaseFirestore.instance
          .collection(collectionPath)
          .where(dateField, isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where(dateField, isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();

      final docs = snapshots.docs;
      Map<String, int> processedData = {};

      DateTime currentDate = start;
      while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
        String key;
        switch (_selectedTimeRange) {
          case 'Tháng':
            key = DateFormat('yyyy-MM').format(currentDate);
            processedData.putIfAbsent(key, () => 0);
            currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
            break;
          case 'Năm':
            key = DateFormat('yyyy').format(currentDate);
            processedData.putIfAbsent(key, () => 0);
            currentDate = DateTime(currentDate.year + 1, 1, 1);
            break;
          default: // Ngày
            key = DateFormat('yyyy-MM-dd').format(currentDate);
            processedData.putIfAbsent(key, () => 0);
            currentDate = currentDate.add(const Duration(days: 1));
        }
      }

      for (var doc in docs) {
        final docData = doc.data() as Map<String, dynamic>;
        if (docData.containsKey(dateField) && docData[dateField] is Timestamp) {
          final createdAt = (docData[dateField] as Timestamp).toDate();
          String key;
          switch (_selectedTimeRange) {
            case 'Tháng':
              key = DateFormat('yyyy-MM').format(createdAt);
              break;
            case 'Năm':
              key = DateFormat('yyyy').format(createdAt);
              break;
            default:
              key = DateFormat('yyyy-MM-dd').format(createdAt);
          }
          if (processedData.containsKey(key)) {
            processedData[key] = processedData[key]! + 1;
          }
        }
      }

      double newMaxY = 10.0;
      if (processedData.isNotEmpty) {
        final maxDataValue = processedData.values.reduce((a, b) => a > b ? a : b);
        if (maxDataValue > 0) {
          newMaxY = (maxDataValue / 5).ceil() * 5.0;
        }
      }

      if (mounted) {
        setState(() {
          _groupedData = processedData;
          _chartMaxY = newMaxY < 10.0 ? 10.0 : newMaxY;
          _isChartLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi tải dữ liệu biểu đồ: $e'),
              backgroundColor: AppTheme.error),
        );
        setState(() => _isChartLoading = false);
      }
    }
  }


  Future<void> _selectDate(BuildContext context) async {
    if (_selectedTimeRange == 'Ngày') {
      final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );

      if (picked != null) {
        setState(() {
          _startDate = picked.start;
          _endDate = picked.end;
        });
        _fetchChartData();
      }
    } else if (_selectedTimeRange == 'Tháng') {
      showMonthPicker(
        context: context,
        initialDate: _endDate,
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      ).then((date) {
        if (date != null) {
          setState(() {
            _startDate = DateTime(date.year, date.month, 1);
            _endDate = DateTime(date.year, date.month + 1, 0);
          });
          _fetchChartData();
        }
      });
    } else if (_selectedTimeRange == 'Năm') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Chọn năm"),
            content: SizedBox(
              width: 300,
              height: 300,
              child: YearPicker(
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                selectedDate: _endDate,
                onChanged: (DateTime date) {
                  setState(() {
                    _startDate = DateTime(date.year, 1, 1);
                    _endDate = DateTime(date.year, 12, 31);
                  });
                  Navigator.of(context).pop();
                  _fetchChartData();
                },
              ),
            ),
          );
        },
      );
    }
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12);
    String text = '';
    final sortedKeys = _groupedData.keys.toList()..sort();

    if (value.toInt() < sortedKeys.length) {
      final int showEvery = (sortedKeys.length / 5).ceil();
      if (value.toInt() % showEvery == 0) {
        final key = sortedKeys[value.toInt()];
        try {
          switch (_selectedTimeRange) {
            case 'Tháng':
              text = DateFormat('MM/yy').format(DateTime.parse('$key-01'));
              break;
            case 'Năm':
              text = key;
              break;
            default: // Ngày
              text = DateFormat('dd/MM').format(DateTime.parse(key));
          }
        } catch(e) { text = '';}
      }
    }

    return SideTitleWidget(axisSide: meta.axisSide, space: 8.0, child: Text(text, style: style));
  }

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12);
    if (value % meta.appliedInterval == 0) {
      return Text(value.toInt().toString(), style: style, textAlign: TextAlign.center);
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppTheme.lightTheme.colorScheme.surface,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chào mừng, Admin',
                                style: AppTheme.lightTheme.textTheme.headlineSmall
                                    ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Text(
                                'Quản lý nền tảng học tập của bạn',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 12.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'admin_panel_settings',
                              color: AppTheme.primary,
                              size: 24,
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        IconButton(
                          icon: Icon(Icons.logout, color: AppTheme.textSecondary),
                          onPressed: _handleLogout,
                          tooltip: 'Đăng xuất',
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: const [
                      Tab(text: 'Dashboard'),
                      Tab(text: 'Categories'),
                      Tab(text: 'Users'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDashboardTab(),
                  _buildCategoriesTab(),
                  _buildUsersTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    final sortedKeys = _groupedData.keys.toList()..sort();
    final List<FlSpot> chartSpots = [];
    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      if (_groupedData[key] != null) {
        chartSpots.add(FlSpot(i.toDouble(), _groupedData[key]!.toDouble()));
      }
    }

    return RefreshIndicator(
      onRefresh: _refreshDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thống kê tổng quan', style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 2.h),
            _isLoading
                ? _buildLoadingGrid()
                : Wrap(
              spacing: 4.w,
              runSpacing: 2.h,
              children: [
                StatisticsCardWidget(
                    title: 'Tổng Chủ Đề',
                    value: _totalCategories.toString(),
                    isPositive: true,
                    changePercentage: '',
                    iconName: 'category'
                ),
                StatisticsCardWidget(
                    title: 'Tổng Người Dùng',
                    value: _totalUsers.toString(),
                    isPositive: true,
                    changePercentage: '',
                    iconName: 'group'
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Text("Thống Kê Chi Tiết", style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: 2.h),

            DropdownButtonFormField<String>(
              value: _selectedChartType,
              items: _chartTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() { _selectedChartType = value; });
                  _fetchChartData();
                }
              },
              decoration: const InputDecoration(labelText: 'Nội dung hiển thị', border: OutlineInputBorder()),
            ),
            SizedBox(height: 2.h),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedTimeRange,
                    items: _timeRanges.map((range) => DropdownMenuItem(value: range, child: Text(range))).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() { _selectedTimeRange = value; });
                        _fetchChartData();
                      }
                    },
                    decoration: const InputDecoration(labelText: 'Thống kê theo', border: OutlineInputBorder()),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Chọn khoảng thời gian',
                        border: const OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _selectedTimeRange == 'Ngày'
                              ? '${DateFormat('dd/MM/yy').format(_startDate)} - ${DateFormat('dd/MM/yy').format(_endDate)}'
                              : (_selectedTimeRange == 'Tháng'
                              ? DateFormat('MM/yyyy').format(_endDate)
                              : DateFormat('yyyy').format(_endDate)),
                          style: AppTheme.lightTheme.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 4.h),

            AspectRatio(
              aspectRatio: 1.5,
              child: Card(
                elevation: 2,
                shadowColor: AppTheme.shadowLight,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 24, 12),
                  child: _isChartLoading
                      ? const Center(child: CircularProgressIndicator())
                      : chartSpots.isEmpty
                      ? const Center(child: Text("Không có dữ liệu trong khoảng thời gian này."))
                      : LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: AppTheme.primary.withOpacity(0.8),
                          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                            return touchedBarSpots.map((barSpot) {
                              return LineTooltipItem(
                                barSpot.y.toInt().toString(),
                                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1)),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 1, getTitlesWidget: _bottomTitleWidgets)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: _leftTitleWidgets,
                              interval: 5
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.withOpacity(0.3))),
                      minX: 0,
                      maxX: (chartSpots.length -1).toDouble(),
                      minY: 0,
                      maxY: _chartMaxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartSpots,
                          isCurved: true,
                          color: AppTheme.primary,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(show: true, color: AppTheme.primary.withOpacity(0.2)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================
  // ===== BẮT ĐẦU PHẦN CHỈNH SỬA CHO CHỨC NĂNG TÌM KIẾM =====
  // ========================================================

  Widget _buildCategoriesTab() {
    // << THÊM MỚI: Thêm câu lệnh print để gỡ lỗi >>
    final searchQuery = _categorySearchQuery.toLowerCase().trim(); // Chuyển sang chữ thường và loại bỏ khoảng trắng
    print("Đang tìm kiếm với từ khóa đã xử lý: '$searchQuery'");

    return Scaffold(
      body: Column(
        children: [
          // Thanh tìm kiếm cho chủ đề (Giữ nguyên)
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 0),
            child: TextField(
              controller: _categorySearchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm chủ đề theo tên...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                suffixIcon: _categorySearchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _categorySearchController.clear(),
                )
                    : null,
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // << THAY ĐỔI: Sử dụng biến searchQuery đã được trim() và toLowerCase() >>
              stream: (searchQuery.isEmpty)
                  ? FirebaseFirestore.instance
                  .collection('categories')
                  .orderBy('createdAt', descending: true)
                  .snapshots()
                  : FirebaseFirestore.instance
                  .collection('categories')
                  .where('name_lowercase', isGreaterThanOrEqualTo: searchQuery)
                  .where('name_lowercase', isLessThanOrEqualTo: searchQuery + '\uf8ff')
                  .snapshots(),
              builder: (context, snapshot) {
                // Phần builder bên dưới giữ nguyên...
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: AppTheme.primary));
                }
                if (snapshot.hasError) {
                  // << THÊM MỚI: In lỗi ra console để dễ thấy >>
                  print("🔥 LỖI FIREBASE: ${snapshot.error}");
                  return Center(child: Text('Đã có lỗi xảy ra: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(iconName: 'search_off', size: 64, color: AppTheme.textSecondary),
                        SizedBox(height: 2.h),
                        Text(
                          _categorySearchQuery.isEmpty ? 'Chưa có chủ đề nào' : 'Không tìm thấy kết quả',
                          style: AppTheme.lightTheme.textTheme.titleLarge,
                        ),
                        if (_categorySearchQuery.isEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 1.h),
                            child: Text(
                              'Nhấn nút + để thêm chủ đề đầu tiên của bạn!',
                              style: AppTheme.lightTheme.textTheme.bodyMedium,
                            ),
                          ),
                      ],
                    ),
                  );
                }
                final categories = snapshot.data!.docs;
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final data = category.data() as Map<String, dynamic>;
                    final String? base64String = data['imageBase64'];
                    Widget imageWidget;
                    if (base64String != null && base64String.isNotEmpty) {
                      final String pureBase64 = base64String.split(',').last;
                      try {
                        final imageBytes = base64Decode(pureBase64);
                        imageWidget = Image.memory(
                          imageBytes,
                          width: 20.w,
                          height: 10.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.broken_image, size: 24, color: AppTheme.error),
                        );
                      } catch (e) {
                        imageWidget =
                            Icon(Icons.broken_image, size: 24, color: AppTheme.error);
                      }
                    } else {
                      imageWidget = Container(
                        width: 20.w,
                        height: 10.h,
                        color: AppTheme.surface,
                        child: Icon(Icons.image_not_supported,
                            color: AppTheme.textSecondary),
                      );
                    }
                    return Card(
                      margin: EdgeInsets.only(bottom: 2.h),
                      elevation: 2,
                      shadowColor: AppTheme.shadowLight,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: imageWidget,
                        ),
                        title: Text(
                          data['name'] ?? 'Chủ đề không tên',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${data['questionCount'] ?? 0} câu hỏi',
                          style: AppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios,
                            size: 16, color: AppTheme.textSecondary),
                        onTap: () {
                          final String categoryId = category.id;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminCategoryManagementScreen(categoryId: categoryId),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndRefreshForAddCategory,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Thêm chủ đề mới',
      ),
    );
  }

  Widget _buildUsersTab() {
    return Scaffold(
      body: Column(
        children: [
          // Thanh tìm kiếm cho người dùng
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 0),
            child: TextField(
              controller: _userSearchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm người dùng theo email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
                suffixIcon: _userSearchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _userSearchController.clear(),
                )
                    : null,
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Cập nhật câu truy vấn stream để tìm kiếm theo email
              stream: (_userSearchQuery.isEmpty)
                  ? FirebaseFirestore.instance.collection('users').snapshots()
                  : FirebaseFirestore.instance
                  .collection('users')
                  .where('email', isGreaterThanOrEqualTo: _userSearchQuery.toLowerCase())
                  .where('email', isLessThanOrEqualTo: _userSearchQuery.toLowerCase() + '\uf8ff')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Đã có lỗi xảy ra: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text(_userSearchQuery.isEmpty
                          ? 'Chưa có người dùng nào.'
                          : 'Không tìm thấy người dùng nào.'));
                }

                final users = snapshot.data!.docs;

                // Code hiển thị ListView.builder giữ nguyên như file gốc của bạn
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final userData = user.data() as Map<String, dynamic>;
                    final String fullName = userData['displayName'] ?? 'Người dùng không tên';
                    final String email = userData['email'] ?? 'Không có email';
                    final String photoURL = userData['photoURL'] ?? '';

                    return Card(
                      margin: EdgeInsets.only(bottom: 2.h),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: photoURL.isNotEmpty ? NetworkImage(photoURL) : null,
                          child: photoURL.isEmpty ? const Icon(Icons.person) : null,
                        ),
                        title: Text(fullName),
                        subtitle: Text(email),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminUserDetailScreen(userId: user.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndRefreshForAddUser,
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Thêm người dùng mới',
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return Wrap(
      spacing: 4.w,
      runSpacing: 2.h,
      children: List.generate(2, (index) {
        return Container(
          width: 42.w,
          height: 15.h,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}
