import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({super.key});

  Future<_HistoryDetailData> _loadDetail(String resultId) async {
    final resultDoc = await FirebaseFirestore.instance.collection('quiz_results').doc(resultId).get();
    final data = resultDoc.data() as Map<String, dynamic>;

    final answers = Map<String, dynamic>.from(data['answers'] ?? {});
    final questionDocs = await Future.wait(
      answers.keys.map((id) => FirebaseFirestore.instance.collection('questions').doc(id).get()),
    );

    final questions = <QuestionDetail>[];
    for (final doc in questionDocs) {
      if (!doc.exists) continue;
      final qData = doc.data()!;
      final userAnswerIndex = answers[doc.id] ?? -1;
      questions.add(
        QuestionDetail(
          id: doc.id,
          question: qData['question'] ?? 'Câu hỏi',
          answers: List<String>.from(qData['answers'] ?? []),
          correctIndex: qData['correctIndex'] ?? 0,
          explanation: qData['explanation'] ?? 'Chưa có giải thích',
          userAnswerIndex: userAnswerIndex,
        ),
      );
    }

    return _HistoryDetailData(
      category: data['category'] ?? 'Quiz',
      score: data['score'] ?? 0,
      total: data['total'] ?? 0,
      completedAt: (data['completedAt'] as Timestamp).toDate(),
      timeSpent: data['timeSpent'] ?? 'Không rõ',
      questions: questions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final resultId = args['resultId'] as String?;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: resultId == null
          ? const Center(child: Text('Không tìm thấy dữ liệu chi tiết'))
          : FutureBuilder<_HistoryDetailData>(
              future: _loadDetail(resultId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Center(
                    child: Text('Lỗi tải dữ liệu: ${snapshot.error ?? 'Không xác định'}'),
                  );
                }

                final detail = snapshot.data!;
                final dateText = DateFormat('dd/MM/yyyy').format(detail.completedAt);

                return Column(
                  children: [
                    _HistoryAppBar(title: detail.category),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HeaderCard(category: detail.category, dateText: dateText),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    label: 'Tổng điểm',
                                    value: '${detail.score}/${detail.total}',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StatCard(
                                    label: 'Thời gian',
                                    value: DateFormat('HH:mm').format(detail.completedAt),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Chi tiết câu trả lời',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...detail.questions.map(
                              (q) => _QuestionTile(detail: q),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _HistoryAppBar extends StatelessWidget {
  final String title;
  const _HistoryAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A)),
            ),
            Expanded(
              child: Text(
                'Chi tiết - $title',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String category;
  final String dateText;
  const _HeaderCard({required this.category, required this.dateText});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              image: DecorationImage(
                image: NetworkImage(
                  'https://vinuni.edu.vn/wp-content/uploads/2024/07/hoc-ngu-phap-tieng-anh-cho-nguoi-mat-goc-6.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hoàn thành: $dateText',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionTile extends StatefulWidget {
  final QuestionDetail detail;
  const _QuestionTile({required this.detail});

  @override
  State<_QuestionTile> createState() => _QuestionTileState();
}

class _QuestionTileState extends State<_QuestionTile> {
  bool _showExplanation = false;

  @override
  Widget build(BuildContext context) {
    final detail = widget.detail;
    final isCorrect = detail.userAnswerIndex == detail.correctIndex && detail.userAnswerIndex != -1;
    final userAnswerText = detail.userAnswerIndex >= 0 && detail.userAnswerIndex < detail.answers.length
        ? detail.answers[detail.userAnswerIndex]
        : 'Chưa trả lời';
    final correctAnswerText = detail.correctIndex < detail.answers.length ? detail.answers[detail.correctIndex] : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isCorrect ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                child: Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.question,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Đáp án đúng: $correctAnswerText',
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                    Text(
                      'Câu trả lời của bạn: $userAnswerText',
                      style: TextStyle(
                        color: isCorrect ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                        decoration: !isCorrect ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => _showExplanation = !_showExplanation),
            child: Text(
              _showExplanation ? 'Ẩn giải thích' : 'Xem giải thích',
              style: const TextStyle(color: Color(0xFF13A4EC), fontWeight: FontWeight.w600),
            ),
          ),
          if (_showExplanation)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                detail.explanation,
                style: const TextStyle(color: Color(0xFF0F172A)),
              ),
            ),
        ],
      ),
    );
  }
}

class _HistoryDetailData {
  final String category;
  final int score;
  final int total;
  final DateTime completedAt;
  final String? timeSpent;
  final List<QuestionDetail> questions;

  _HistoryDetailData({
    required this.category,
    required this.score,
    required this.total,
    required this.completedAt,
    required this.timeSpent,
    required this.questions,
  });
}

class QuestionDetail {
  final String id;
  final String question;
  final List<String> answers;
  final int correctIndex;
  final int userAnswerIndex;
  final String explanation;

  QuestionDetail({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctIndex,
    required this.explanation,
    required this.userAnswerIndex,
  });
}