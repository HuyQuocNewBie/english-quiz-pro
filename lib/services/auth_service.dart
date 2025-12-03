// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // API cũ, chạy ngon

  // Stream theo dõi trạng thái đăng nhập
  Stream<User?> get user => _auth.authStateChanges();

  // ==================== ĐĂNG KÝ EMAIL ====================
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Cập nhật tên (nếu có)
      if (name != null && name.isNotEmpty) {
        await credential.user!.updateDisplayName(name);
      }

      // Tạo document Firestore
      await _createUserDocument(credential.user!);

      return (await getCurrentUserModel())!;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== ĐĂNG NHẬP EMAIL ====================
  Future<UserModel> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return (await getCurrentUserModel())!;
    } catch (e) {
      rethrow;
    }
  }

  // ==================== GOOGLE SIGN IN – CHẠY NGON 100% ====================
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Xóa cache cũ (tránh lỗi "đã đăng nhập rồi")
      await _googleSignIn.signOut();

      // Mở popup chọn tài khoản Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Người dùng bấm hủy
      if (googleUser == null) return null;

      // Lấy token
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Tạo credential cho Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) return null;

      // Kiểm tra đã có document chưa → nếu chưa thì tạo
      final docRef = FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(user.uid);

      final doc = await docRef.get();
      if (!doc.exists) {
        await _createUserDocument(user);
      }

      return await getCurrentUserModel();
    } catch (e) {
      rethrow;
    }
  }

  // Lấy UserModel hiện tại từ Firestore
  Future<UserModel?> getCurrentUserModel() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(firebaseUser.uid)
        .get();

    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data()!, doc.id);
  }

  // Tạo document user lần đầu tiên
  Future<void> _createUserDocument(User user) async {
    await FirebaseFirestore.instance
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set({
      'email': user.email,
      'displayName': user.displayName ?? user.email!.split('@').first,
      'photoURL': user.photoURL,
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
      'highScore': 0,
      'categoryHighScores': <String, int>{},
    });
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}