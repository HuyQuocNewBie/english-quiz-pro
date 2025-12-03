// lib/providers/admin_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question_model.dart';
import '../models/category_model.dart';

class AdminProvider with ChangeNotifier {
  // Dữ liệu
  List<QuestionModel> _questions = [];
  List<CategoryModel> _categories = [];
  List<Map<String, dynamic>> _users = [];
  Map<String, double> _categoryAverages = {};

  // Số liệu tổng quan
  int _totalUsers = 0;
  int _totalQuestions = 0;
  int _totalResults = 0;

  // Trạng thái
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<QuestionModel> get questions => _questions;
  List<CategoryModel> get categories => _categories;
  List<Map<String, dynamic>> get users => _users;
  Map<String, double> get categoryAverages => _categoryAverages;

  int get totalUsers => _totalUsers;
  int get totalQuestions => _totalQuestions;
  int get totalResults => _totalResults;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Tải tất cả dữ liệu một lần
  Future<void> loadAllData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.wait([
        loadUsers(),
        loadQuestions(),
        loadCategories(),
        loadStatistics(),
      ]);
    } catch (e) {
      _errorMessage = 'Lỗi tải dữ liệu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load người dùng
  Future<void> loadUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    _users = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'uid': doc.id,
        'email': data['email'] ?? '',
        'displayName': data['displayName'] ?? 'Không tên',
        'photoURL': data['photoURL'],
        'role': data['role'] ?? 'user',
        'score':
            (data['totalScore'] as num?)?.toInt() ??
            (data['highScore'] as num?)?.toInt() ??
            0,
      };
    }).toList();
    _totalUsers = _users.length;
    notifyListeners();
  }

  // Toggle quyền admin
  Future<void> toggleAdminRole(String uid) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
    final snapshot = await userDoc.get();
    final currentRole = snapshot['role'] ?? 'user';
    await userDoc.update({'role': currentRole == 'admin' ? 'user' : 'admin'});
    await loadUsers(); // reload
  }

  // Xóa người dùng
  Future<void> deleteUser(String uid, BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa người dùng?'),
        content: const Text('Hành động này không thể hoàn tác'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      await loadUsers();
    }
  }

  // Load câu hỏi
  Future<void> loadQuestions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('questions')
        .get();
    _questions = snapshot.docs
        .map((doc) => QuestionModel.fromMap(doc.data(), doc.id))
        .toList();
    _totalQuestions = _questions.length;
    notifyListeners();
  }

  // Load danh mục
  Future<void> loadCategories() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('categories')
        .get();
    _categories = snapshot.docs
        .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
        .toList();
    notifyListeners();
  }

  // Load thống kê + điểm trung bình theo danh mục
  Future<void> loadStatistics() async {
    final resultsSnapshot = await FirebaseFirestore.instance
        .collection('quiz_results')
        .get();
    _totalResults = resultsSnapshot.size;

    // 1. TÍNH ĐIỂM THEO USER → DÙNG CHO "NGƯỜI DÙNG HÀNG ĐẦU"
    final Map<String, int> scoresByUser = {};

    for (var doc in resultsSnapshot.docs) {
      final data = doc.data();
      final userId = data['userId'] ?? '';
      final score = (data['score'] as num?)?.toInt() ?? 0;
      if (userId.isEmpty) continue;
      scoresByUser[userId] = (scoresByUser[userId] ?? 0) + score;
    }

    _users = _users.map((u) {
      return {...u, 'score': scoresByUser[u['uid']] ?? 0};
    }).toList();

    // 2. TÍNH ĐIỂM TRUNG BÌNH THEO DANH MỤC (đoạn cũ)
    final Map<String, List<int>> scoresByCategory = {};
    for (var doc in resultsSnapshot.docs) {
      final data = doc.data();
      final category = data['category'] as String? ?? 'Khác';
      final score = (data['score'] as num?)?.toInt() ?? 0;
      scoresByCategory.putIfAbsent(category, () => []).add(score);
    }

    _categoryAverages = scoresByCategory.map((key, value) {
      final avg = value.reduce((a, b) => a + b) / value.length;
      return MapEntry(key, double.parse(avg.toStringAsFixed(1)));
    });

    notifyListeners();
  }

  // Xóa câu hỏi
  Future<void> deleteQuestion(String id) async {
    await FirebaseFirestore.instance.collection('questions').doc(id).delete();
    await loadQuestions();
  }

  // Xóa danh mục + tất cả câu hỏi liên quan
  Future<void> deleteCategory(String id) async {
    final categoryName = _categories.firstWhere((c) => c.id == id).name;

    final questions = await FirebaseFirestore.instance
        .collection('questions')
        .where('category', isEqualTo: categoryName)
        .get();

    for (var q in questions.docs) {
      await q.reference.delete();
    }

    await FirebaseFirestore.instance.collection('categories').doc(id).delete();
    await loadCategories();
    await loadQuestions();
  }
}
