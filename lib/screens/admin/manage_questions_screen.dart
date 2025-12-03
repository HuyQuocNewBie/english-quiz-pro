import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../core/app_routes.dart';

class ManageQuestionsScreen extends StatefulWidget {
  const ManageQuestionsScreen({super.key});

  @override
  State<ManageQuestionsScreen> createState() => _ManageQuestionsScreenState();
}

class _ManageQuestionsScreenState extends State<ManageQuestionsScreen> {
  String _searchText = '';
  String _selectedCategory = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminProvider()..loadQuestions(),
      child: Consumer<AdminProvider>(
        builder: (context, admin, child) {
          final questions = admin.questions.where((q) {
            final matchSearch = _searchText.isEmpty ||
                q.question.toLowerCase().contains(_searchText.toLowerCase());
            final matchCategory = _selectedCategory == 'Tất cả' ||
                q.category == _selectedCategory;
            return matchSearch && matchCategory;
          }).toList();

          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            body: SafeArea(
              child: Column(
                children: [
                  // HEADER
                  Container(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      border: Border(
                        bottom: BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 22,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            'Quản lý Câu Hỏi',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.more_vert,
                            size: 24,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // THANH TÌM KIẾM + FILTER NÚT
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _searchText = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm câu hỏi...',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color(0xFF64748B),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 16,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(999),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(999),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(999),
                                borderSide: const BorderSide(
                                  color: Color(0xFF09A0E8),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Icon(
                            Icons.tune,
                            color: Color(0xFF09A0E8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // FILTER CATEGORIES (STATIC / GỢI Ý)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        _buildFilterChip('Tất cả'),
                        _buildFilterChip('Thành ngữ'),
                        _buildFilterChip('Từ vựng'),
                        _buildFilterChip('Điền từ'),
                        _buildFilterChip('Nghe hiểu'),
                        _buildFilterChip('Ngữ pháp'),
                      ],
                    ),
                  ),

                  // DANH SÁCH CÂU HỎI
                  Expanded(
                    child: admin.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : questions.isEmpty
                            ? const Center(
                                child: Text(
                                  'Chưa có câu hỏi nào',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                                itemCount: questions.length,
                                itemBuilder: (ctx, i) {
                                  final q = questions[i];
                                  return _QuestionCard(
                                    question: q.question,
                                    category: q.category,
                                    correctAnswer: q.answers.isNotEmpty
                                        ? q.answers[q.correctIndex]
                                        : '',
                                    onEdit: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.addEditQuestion,
                                      arguments: q,
                                    ),
                                    onDelete: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Xóa câu hỏi?'),
                                          content: const Text(
                                              'Hành động này không thể hoàn tác.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Hủy'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text(
                                                'Xóa',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await admin.deleteQuestion(q.id);
                                      }
                                    },
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),

            // NÚT THÊM MỚI
            floatingActionButtonLocation:
                FloatingActionButtonLocation.endFloat,
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.addEditQuestion),
              backgroundColor: const Color(0xFF09A0E8),
              icon: const Icon(Icons.add_circle, size: 24),
              label: const Text(
                'Thêm Mới',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool selected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() {
            _selectedCategory = label;
          });
        },
        selectedColor: const Color(0xFF09A0E8),
        labelStyle: TextStyle(
          color: selected ? Colors.white : const Color(0xFF0F172A),
          fontWeight: FontWeight.w500,
        ),
        backgroundColor: const Color(0xFFE2E8F0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide.none,
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final String question;
  final String category;
  final String correctAnswer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _QuestionCard({
    required this.question,
    required this.category,
    required this.correctAnswer,
    required this.onEdit,
    required this.onDelete,
  });

  Color _categoryColor() {
    switch (category) {
      case 'Thành ngữ':
        return const Color(0xFF22C55E); // green
      case 'Từ vựng':
        return const Color(0xFF8B5CF6); // purple
      case 'Điền từ':
        return const Color(0xFFEAB308); // yellow
      case 'Nghe hiểu':
        return const Color(0xFF6366F1); // indigo
      case 'Ngữ pháp':
        return const Color(0xFF0EA5E9); // sky
      default:
        return const Color(0xFF6B7280); // gray
    }
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          // CÂU HỎI + ĐÁP ÁN ĐÚNG
          Text(
            question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle,
                  size: 18, color: Color(0xFF22C55E)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Đáp án đúng: $correctAnswer',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // CATEGORY + ACTIONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: catColor,
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    color: const Color(0xFF4B5563),
                    tooltip: 'Chỉnh sửa',
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete),
                    color: const Color(0xFFDC2626),
                    tooltip: 'Xóa',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}