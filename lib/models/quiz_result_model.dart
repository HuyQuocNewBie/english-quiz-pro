import 'package:cloud_firestore/cloud_firestore.dart';

class QuizResultModel {
  final String id;
  final String userId;
  final String category;
  final int score;
  final int total;
  final DateTime completedAt;
  final Map<String, dynamic> answers; // {questionId: userAnswerIndex}

  QuizResultModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.score,
    required this.total,
    required this.completedAt,
    required this.answers,
  });

  factory QuizResultModel.fromMap(Map<String, dynamic> data, String id) {
    return QuizResultModel(
      id: id,
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
      score: data['score'] ?? 0,
      total: data['total'] ?? 0,
      completedAt: (data['completedAt'] as Timestamp).toDate(),
      answers: Map<String, dynamic>.from(data['answers'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'category': category,
      'score': score,
      'total': total,
      'completedAt': Timestamp.fromDate(completedAt),
      'answers': answers,
    };
  }
}