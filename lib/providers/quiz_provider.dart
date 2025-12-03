import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question_model.dart';
import '../models/quiz_result_model.dart';
import '../core/constants.dart';

class QuizProvider with ChangeNotifier {
  List<QuestionModel> _questions = [];
  List<int> _userAnswers = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _isLoading = false;

  List<QuestionModel> get questions => _questions;
  List<int> get userAnswers => _userAnswers;
  int get currentIndex => _currentIndex;
  int get score => _score;
  bool get isLoading => _isLoading;

  Future<void> loadQuestions(String category) async {
    _isLoading = true;
    notifyListeners();

    final snapshot = await FirebaseFirestore.instance
        .collection('questions')
        .where('category', isEqualTo: category)
        .limit(10)
        .get();

    _questions = snapshot.docs
        .map((doc) => QuestionModel.fromMap(doc.data(), doc.id))
        .toList();
    _userAnswers = List.generate(_questions.length, (index) => -1);
    _currentIndex = 0;
    _score = 0;

    _isLoading = false;
    notifyListeners();
  }

  void answerQuestion(int answerIndex) {
    _userAnswers[_currentIndex] = answerIndex;
    if (answerIndex == _questions[_currentIndex].correctIndex) {
      _score += 10;
    }
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  Future<void> saveResult(String userId, String category) async {
    final result = QuizResultModel(
      id: '',
      userId: userId,
      category: category,
      score: _score,
      total: _questions.length * 10,
      completedAt: DateTime.now(),
      answers: Map.fromIterables(_questions.map((q) => q.id), _userAnswers),
    );

    // Lưu kết quả quiz
    await FirebaseFirestore.instance
        .collection('quiz_results')
        .add(result.toMap());

    // Cập nhật highScore
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    await FirebaseFirestore.instance.runTransaction((txn) async {
      final snap = await txn.get(userRef);
      final currentTotal = (snap.data()?['totalScore'] as num?)?.toInt() ?? 0;
      txn.update(userRef, {'totalScore': currentTotal + _score});
    });

    final userDoc = await userRef.get();
    if (userDoc.exists) {
      final userData = userDoc.data()!;
      final currentHighScore = userData['highScore'] ?? 0;
      final categoryHighScores = Map<String, int>.from(
        userData['categoryHighScores'] ?? {},
      );
      final currentCategoryHighScore = categoryHighScores[category] ?? 0;

      // Cập nhật highScore tổng nếu điểm mới cao hơn
      if (_score > currentHighScore) {
        await userRef.update({'highScore': _score});
      }

      // Cập nhật categoryHighScores nếu điểm mới cao hơn
      if (_score > currentCategoryHighScore) {
        categoryHighScores[category] = _score;
        await userRef.update({'categoryHighScores': categoryHighScores});
      }
    }
  }

  void reset() {
    _questions.clear();
    _userAnswers.clear();
    _currentIndex = 0;
    _score = 0;
    notifyListeners();
  }
}
