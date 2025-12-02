// lib/core/app_routes.dart
import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/user/home_screen.dart';
import '../screens/user/quiz_screen.dart';
import '../screens/user/result_screen.dart';
import '../screens/user/explanation_screen.dart';
import '../screens/user/history_screen.dart';
import '../screens/user/history_detail_screen.dart';
import '../screens/user/settings_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/manage_questions_screen.dart';
import '../screens/admin/add_edit_question_screen.dart';
import '../screens/admin/manage_users_screen.dart';
import '../screens/admin/manage_categories_screen.dart';
import '../screens/admin/add_edit_category_screen.dart';
import '../screens/admin/statistics_screen.dart';

class AppRoutes {
  static const String login = '/login';                    // màn hình chung Login + Register
  static const String userHome = '/user-home';
  static const String quiz = '/quiz';
  static const String result = '/result';
  static const String explanation = '/explanation';
  static const String history = '/history';
  static const String historyDetail = '/history-detail';
  static const String settings = '/settings';

  static const String adminDashboard = '/admin-dashboard';
  static const String manageQuestions = '/admin/questions';
  static const String addEditQuestion = '/admin/question-edit';
  static const String manageUsers = '/admin/users';
  static const String manageCategories = '/admin/categories';
  static const String addEditCategory = '/admin/category-edit';
  static const String statistics = '/admin/statistics';
}

final Map<String, WidgetBuilder> appRoutes = {
  AppRoutes.login             : (_) => const LoginScreen(),           // chung Login + Register
  AppRoutes.userHome          : (_) => const HomeScreen(),
  AppRoutes.quiz              : (_) => const QuizScreen(),
  AppRoutes.result            : (_) => const ResultScreen(),
  AppRoutes.explanation       : (_) => const ExplanationScreen(),
  AppRoutes.history           : (_) => const HistoryScreen(),
  AppRoutes.historyDetail     : (_) => const HistoryDetailScreen(),
  AppRoutes.settings          : (_) => const SettingsScreen(),

  AppRoutes.adminDashboard    : (_) => const AdminDashboardScreen(),
  AppRoutes.manageQuestions   : (_) => const ManageQuestionsScreen(),
  AppRoutes.addEditQuestion : (_) => const AddEditQuestionScreen(),
  AppRoutes.manageUsers       : (_) => const ManageUsersScreen(),
  AppRoutes.manageCategories  : (_) => const ManageCategoriesScreen(),
  AppRoutes.addEditCategory   : (_) => const AddEditCategoryScreen(),
  AppRoutes.statistics        : (_) => const StatisticsScreen(),
};