import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    // Lắng nghe trạng thái đăng nhập từ Firebase
    _authService.user.listen((firebaseUser) async {
      if (firebaseUser != null) {
        _user = await _authService.getCurrentUserModel();
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }

  // Đăng ký
  Future<void> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    _startLoading();
    try {
      _user = await _authService.signUp(email: email, password: password, name: name);
      _clearError();
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    }
    _stopLoading();
  }

  // Đăng nhập Email
  Future<void> signIn(String email, String password) async {
    _startLoading();
    try {
      _user = await _authService.signIn(email, password);
      _clearError();
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    }
    _stopLoading();
  }

  // Đăng nhập Google
  Future<void> signInWithGoogle() async {
    _startLoading();
    try {
      _user = await _authService.signInWithGoogle();
      _clearError();
    } catch (e) {
      _setError('Đăng nhập Google thất bại. Vui lòng thử lại!');
    }
    _stopLoading();
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _clearError();
    notifyListeners();
  }

  // Refresh user data từ Firestore (để cập nhật highScore sau khi làm quiz)
  Future<void> refreshUser() async {
    // getCurrentUserModel() đã kiểm tra currentUser bên trong, không cần .value
    _user = await _authService.getCurrentUserModel();
    notifyListeners();
  }

  void _startLoading() {
    _isLoading = true;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}