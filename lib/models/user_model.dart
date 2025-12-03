import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String role; // 'user' hoặc 'admin'
  final DateTime createdAt;
  final int highScore;
  final Map<String, int> categoryHighScores;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    this.role = 'user',
    required this.createdAt,
    this.highScore = 0,
    this.categoryHighScores = const {},
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      role: data['role'] ?? 'user',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      highScore: data['highScore'] ?? 0,
      categoryHighScores: Map<String, int>.from(data['categoryHighScores'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'role': role,
      'createdAt': Timestamp.fromDate(createdAt),
      'highScore': highScore,
      'categoryHighScores': categoryHighScores,
    };
  }

  UserModel copyWith({
    String? displayName,
    String? photoURL,
    String? role,
    int? highScore,
    Map<String, int>? categoryHighScores,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      createdAt: createdAt,
      highScore: highScore ?? this.highScore,
      categoryHighScores: categoryHighScores ?? this.categoryHighScores,
    );
  }

  bool get isAdmin => role == 'admin';
}