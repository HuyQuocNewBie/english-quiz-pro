import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../providers/quiz_provider.dart';
import '../../core/app_routes.dart';
import '../../providers/auth_provider.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  // Màu sắc theo design
  static const Color primaryColor = Color(0xFF4ade80);
  static const Color backgroundColor = Color(0xFFf0fdf4);
  static const Color successColor = Color(0xFF4ade80);
  static const Color errorColor = Color(0xFFf87171);
  static const Color textColor = Color(0xFF0f172a);
  static const Color textSecondaryColor = Color(0xFF475569);

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final score = quizProvider.score;
    final total = quizProvider.questions.length * 10;
    final totalQuestions = quizProvider.questions.length;
    
    // Tính số câu đúng và sai
    int correctCount = 0;
    int wrongCount = 0;
    for (int i = 0; i < quizProvider.questions.length; i++) {
      if (quizProvider.userAnswers[i] == quizProvider.questions[i].correctIndex) {
        correctCount++;
      } else {
        wrongCount++;
      }
    }

    final percentage = total > 0 ? (score / total) * 100 : 0;
    final percentageRounded = percentage.round();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            color: backgroundColor,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  // Nút close
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.close,
                          size: 24,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  // Title
                  const Expanded(
                    child: Text(
                      'Kết Quả Quiz',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  // Nút share
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // TODO: Implement share functionality
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 48,
                        height: 48,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.share,
                          size: 24,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Column(
                children: [
                  // Tiêu đề
                  const Text(
                    'Tuyệt vời!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Bạn đã hoàn thành bài quiz.',
                    style: TextStyle(
                      fontSize: 16,
                      color: textSecondaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Circular progress indicator
                  SizedBox(
                    width: 192,
                    height: 192,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background circle
                        SizedBox(
                          width: 192,
                          height: 192,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.grey),
                          ),
                        ),
                        // Progress circle
                        Transform.rotate(
                          angle: -math.pi / 2,
                          child: SizedBox(
                            width: 192,
                            height: 192,
                            child: CircularProgressIndicator(
                              value: percentage / 100,
                              strokeWidth: 12,
                              backgroundColor: Colors.transparent,
                              valueColor: const AlwaysStoppedAnimation<Color>(successColor),
                              strokeCap: StrokeCap.round,
                            ),
                          ),
                        ),
                        // Text ở giữa
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Điểm số',
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$percentageRounded%',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tổng điểm với progress bar
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tổng Điểm',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                          Text(
                            '$correctCount/$totalQuestions',
                            style: const TextStyle(
                              fontSize: 14,
                              color: textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: Colors.grey[200],
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: percentage / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: successColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Cards: Trả lời đúng và sai
                  Row(
                    children: [
                      // Card đúng
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: successColor.withOpacity(0.1),
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: successColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Trả lời đúng',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textSecondaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$correctCount',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Card sai
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: errorColor.withOpacity(0.1),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: errorColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Trả lời sai',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: textSecondaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$wrongCount',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Footer với các nút
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nút Xem Lại Đáp Án
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.explanation,
                          arguments: {
                            'questions': quizProvider.questions,
                            'userAnswers': quizProvider.userAnswers,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Xem Lại Đáp Án',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.015,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Nút Làm Lại Quiz
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        final category = quizProvider.questions.isNotEmpty
                            ? quizProvider.questions.first.category
                            : 'Quiz';
                        quizProvider.reset();
                        await quizProvider.loadQuestions(category, context);
                        Navigator.popUntil(
                          context,
                          ModalRoute.withName(AppRoutes.quiz),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor.withOpacity(0.2),
                        foregroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Làm Lại Quiz',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.015,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Nút Về Trang Chủ
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: TextButton(
                      onPressed: () async {
                        quizProvider.reset();
                        // Refresh user data để cập nhật highScore
                        final authProvider = Provider.of<AuthProvider>(context, listen: false);
                        await authProvider.refreshUser();
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.userHome,
                            (route) => false,
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: textColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Về Trang Chủ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.015,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
