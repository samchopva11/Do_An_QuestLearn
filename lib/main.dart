// Dán toàn bộ code này vào file: lib/main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:provider/provider.dart';
import 'package:app_demo/presentation/main_screen/main_screen.dart';
import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';
import 'package:app_demo/firebase_options.dart';

// <<<< THÊM MỚI: Import màn hình AuthWrapper >>>>
import 'package:app_demo/presentation/auth_wrapper/auth_wrapper.dart';

// Hàm main đã được cấu trúc lại để chạy tuần tự
Future<void> main() async {
  // 1. Đảm bảo các widget binding của Flutter đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khóa hướng màn hình (thực hiện và chờ cho đến khi xong)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // 3. Khởi tạo Firebase (thực hiện và chờ cho đến khi xong)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Firebase.initializeApp(
    name: 'AdminAuth',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 4. Cấu hình xử lý lỗi tùy chỉnh của bạn (giữ nguyên)
  bool _hasShownError = false;
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!_hasShownError) {
      _hasShownError = true;
      Future.delayed(Duration(seconds: 5), () {
        _hasShownError = false;
      });
      return CustomErrorWidget(
        errorDetails: details,
      );
    }
    return SizedBox.shrink();
  };

  // 5. Sau khi tất cả đã sẵn sàng, chạy ứng dụng
  runApp(
    ChangeNotifierProvider(
      create: (context) => MainScreenStateProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        title: 'quiz_learning_app',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
        // 🚨 END CRITICAL SECTION
        debugShowCheckedModeBanner: false,

        // <<<< CHỈNH SỬA: Thay đổi cách xử lý route >>>>

        // 1. Dùng 'home' thay cho 'initialRoute'
        // Điểm khởi đầu của ứng dụng sẽ là AuthWrapper
        home: const AuthWrapper(),

        // 2. Giữ nguyên 'routes' để các điều hướng khác vẫn hoạt động
        routes: AppRoutes.routes,
      );
    });
  }
}
