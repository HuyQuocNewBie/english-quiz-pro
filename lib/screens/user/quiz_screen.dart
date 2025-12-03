import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../core/app_routes.dart';
import '../../providers/auth_provider.dart';

class QuizScreen extends StatefulWidget {
  final String category;
  const QuizScreen({super.key, required this.category});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Timer? _timer;
  int timeLeft = 30;

  // Màu sắc theo design
  static const Color primaryColor = Color(0xFF3879E8);
  static const Color backgroundColor = Color(0xFFF0F4FF);
  static const Color successColor = Color(0xFF22C55E);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color timerColor = Color(0xFFFFC700);
  static const Color cardColor = Colors.white;
  static const Color cardBorderColor = Color(0xFFD2DEFF);
  static const Color textColor = Color(0xFF051029);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuizProvider>(context, listen: false).loadQuestions(widget.category);
    });
    // Không start timer ngay, đợi questions load xong
  }

  void startTimer() {
    _timer?.cancel();
    timeLeft = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          // Hết thời gian, tự động chuyển câu
          nextQuestion();
        }
      });
    });
  }

  void nextQuestion() {
    _timer?.cancel();
    final quiz = Provider.of<QuizProvider>(context, listen: false);

    if (quiz.currentIndex < quiz.questions.length - 1) {
      quiz.nextQuestion();
      startTimer();
    } else {
      endQuiz();
    }
  }

  void endQuiz() {
    _timer?.cancel();
    final quiz = Provider.of<QuizProvider>(context, listen: false);
    quiz.saveResult(Provider.of<AuthProvider>(context, listen: false).user!.uid, widget.category);

    Navigator.pushNamed(
      context,
      AppRoutes.result,
      arguments: {
        'score': quiz.score,
        'total': quiz.questions.length * 10,
        'category': widget.category,
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quiz, child) {
        // Start timer khi questions đã load xong và chưa có timer nào chạy
        if (!quiz.isLoading && quiz.questions.isNotEmpty && _timer == null && quiz.userAnswers[quiz.currentIndex] == -1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            startTimer();
          });
        }

        if (quiz.isLoading) {
          return Scaffold(
            backgroundColor: backgroundColor,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (quiz.questions.isEmpty) {
          return Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor: backgroundColor,
              elevation: 0,
              title: Text(widget.category, style: const TextStyle(color: textColor)),
            ),
            body: const Center(
              child: Text('Chưa có câu hỏi nào', style: TextStyle(color: textColor)),
            ),
          );
        }

        final currentQ = quiz.questions[quiz.currentIndex];
        final userAnswer = quiz.userAnswers[quiz.currentIndex];
        final showResult = userAnswer != -1;
        final progress = (quiz.currentIndex + 1) / quiz.questions.length;
        // Thêm progress cho timer (đếm ngược từ 30 giây)
        final timerProgress = showResult ? 0.0 : (timeLeft / 30.0);

        return Scaffold(
          backgroundColor: backgroundColor,
          body: Column(
            children: [
              // Header sticky
              Container(
                decoration: BoxDecoration(
                  color: backgroundColor.withOpacity(0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Nút back
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 28,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Progress bar - hiển thị thời gian đếm ngược
                        Expanded(
                          child: Container(
                            height: 14,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: Colors.grey[200],
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: timerProgress, // Thay đổi từ progress sang timerProgress
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  color: timeLeft > 10 ? primaryColor : errorColor, // Đổi màu khi sắp hết thời gian
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Timer với số giây
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: timerColor.withOpacity(0.2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.timer,
                                color: timerColor,
                                size: 20,
                              ),
                              Text(
                                '$timeLeft',
                                style: TextStyle(
                                  color: timeLeft > 10 ? timerColor : errorColor, // Đổi màu khi sắp hết
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question number
                      Text(
                        'Question ${quiz.currentIndex + 1} of ${quiz.questions.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Question text
                      Text(
                        currentQ.question,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Answers
                      ...List.generate(currentQ.answers.length, (index) {
                        final isSelected = userAnswer == index;
                        final isCorrect = index == currentQ.correctIndex;
                        final isWrong = isSelected && !isCorrect;

                        Color borderColor = cardBorderColor;
                        Color backgroundColor = cardColor;
                        Widget? trailingIcon;

                        if (showResult) {
                          if (isCorrect) {
                            borderColor = successColor;
                            backgroundColor = successColor.withOpacity(0.1);
                            trailingIcon = const Icon(
                              Icons.check_circle,
                              color: successColor,
                              size: 24,
                            );
                          } else if (isWrong) {
                            borderColor = errorColor;
                            backgroundColor = errorColor.withOpacity(0.1);
                            trailingIcon = const Icon(
                              Icons.cancel,
                              color: errorColor,
                              size: 24,
                            );
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: showResult
                                  ? null
                                  : () {
                                      // Chọn đáp án
                                      quiz.answerQuestion(index);
                                      // Dừng timer khi đã chọn
                                      _timer?.cancel();
                                      setState(() {}); // Trigger rebuild để hiện kết quả
                                    },
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: double.infinity,
                                constraints: const BoxConstraints(minHeight: 60),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: backgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: borderColor,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        currentQ.answers[index],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                          decoration: isWrong && showResult
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                    ),
                                    if (trailingIcon != null) ...[
                                      const SizedBox(width: 8),
                                      trailingIcon,
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Footer sticky
              Container(
                decoration: BoxDecoration(
                  color: backgroundColor.withOpacity(0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: showResult
                            ? () {
                                nextQuestion();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          disabledBackgroundColor: Colors.grey[300],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: showResult ? 8 : 0,
                          shadowColor: primaryColor.withOpacity(0.3),
                        ),
                        child: Text(
                          quiz.currentIndex < quiz.questions.length - 1
                              ? 'Next Question'
                              : 'Finish Quiz',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}