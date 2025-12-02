class AppConstants {
  static const String appName = 'EnglishQuiz Pro';
  
  // Thời gian & số lượng câu hỏi
  static const Duration quizTimePerQuestion = Duration(seconds: 30);
  static const int questionsPerQuiz = 10;

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String categoriesCollection = 'categories';
  static const String questionsCollection = 'questions';
  static const String quizResultsCollection = 'quiz_results';

  // Role
  static const String roleUser = 'user';
  static const String roleAdmin = 'admin';
}