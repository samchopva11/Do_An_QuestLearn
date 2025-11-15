import 'package:flutter/material.dart';
import '../presentation/admin_dashboard_screen/admin_dashboard_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/profile_screen/edit_profile_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/main_screen/main_screen.dart';
import '../presentation/forgot_password_screen/forgot_password_screen.dart';
import '../presentation/admin_dashboard_screen/add_category_screen.dart';


class AppRoutes {
  // TODO: Add your routes here
  static const String mainScreen = '/main-screen';
  static const String adminDashboard = '/admin-dashboard-screen';
  static const String loginScreen = '/login-screen';
  static const String registration = '/registration-screen';
  static const String editProfileScreen = '/edit-profile-screen';
  static const String forgotPassword = '/forgot-password-screen';
  static const String addCategoryScreen = '/add-category-screen';



  static Map<String, WidgetBuilder> routes = {
    mainScreen: (context) => const MainScreen(),
    adminDashboard: (context) => const AdminDashboardScreen(),
    loginScreen: (context) => const LoginScreen(),
    editProfileScreen: (context) => EditProfileScreen(),
    registration: (context) => const RegistrationScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    addCategoryScreen: (context) => const AddCategoryScreen(),
    // TODO: Add your other routes here
  };
}
