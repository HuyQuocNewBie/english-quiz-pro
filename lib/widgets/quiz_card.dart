import 'package:flutter/material.dart';

class QuizCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int questionCount;
  final VoidCallback? onTap;

  const QuizCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.questionCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.8), // SỬA: withOpacity(0.8) → withValues(alpha: 0.8)
              color,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4), // SỬA: withOpacity(0.4) → withValues(alpha: 0.4)
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$questionCount câu hỏi',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9), // SỬA: withOpacity(0.9) → withValues(alpha: 0.9)
              ),
            ),
          ],
        ),
      ),
    );
  }
}