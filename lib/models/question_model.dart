class QuestionModel {
  final String id;
  final String question;
  final List<String> answers;
  final int correctIndex;
  final String explanation;
  final String category;

  QuestionModel({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctIndex,
    required this.explanation,
    required this.category,
  });

  factory QuestionModel.fromMap(Map<String, dynamic> data, String id) {
    return QuestionModel(
      id: id,
      question: data['question'] ?? '',
      answers: List<String>.from(data['answers'] ?? []),
      correctIndex: data['correctIndex'] ?? 0,
      explanation: data['explanation'] ?? '',
      category: data['category'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answers': answers,
      'correctIndex': correctIndex,
      'explanation': explanation,
      'category': category,
    };
  }
}