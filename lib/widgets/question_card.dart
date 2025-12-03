import 'package:flutter/material.dart';

// lib/widgets/question_card.dart – SỬA LẠI onAnswerSelected

class QuestionCard extends StatelessWidget {
  final String question;
  final List<String> answers;
  final int? selectedAnswer;
  final int correctAnswer;
  final bool showResult;
  final Function(int)? onAnswerSelected; // ← NHẬN INDEX

  const QuestionCard({
    super.key,
    required this.question,
    required this.answers,
    this.selectedAnswer,
    required this.correctAnswer,
    this.showResult = false,
    this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(question, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: ListView.builder(
            itemCount: answers.length,
            itemBuilder: (ctx, i) {
              final isSelected = selectedAnswer == i;
              final isCorrect = i == correctAnswer;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  onPressed: onAnswerSelected != null && !showResult ? () => onAnswerSelected!(i) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: showResult
                        ? (isCorrect ? Colors.green[100] : (isSelected ? Colors.red[100] : null))
                        : null,
                    padding: const EdgeInsets.all(20),
                  ),
                  child: Text(answers[i], style: const TextStyle(fontSize: 18)),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}