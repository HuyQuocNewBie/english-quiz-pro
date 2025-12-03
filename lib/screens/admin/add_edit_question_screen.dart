import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/admin_provider.dart';
import '../../models/question_model.dart';

class AddEditQuestionScreen extends StatefulWidget {
  const AddEditQuestionScreen({super.key});

  @override
  State<AddEditQuestionScreen> createState() => _AddEditQuestionScreenState();
}

class _AddEditQuestionScreenState extends State<AddEditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionCtrl = TextEditingController();
  final _answersCtrl = List.generate(4, (_) => TextEditingController());
  final _explanationCtrl = TextEditingController();

  String? _selectedCategory;
  int _correctIndex = 0;
  QuestionModel? _existingQuestion;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Lấy args nếu là sửa câu hỏi
    final args = ModalRoute.of(context)!.settings.arguments;
    if (_existingQuestion == null && args is QuestionModel) {
      _existingQuestion = args;
      _questionCtrl.text = _existingQuestion!.question;
      _explanationCtrl.text = _existingQuestion!.explanation;
      _selectedCategory = _existingQuestion!.category;
      _correctIndex = _existingQuestion!.correctIndex;
      for (int i = 0; i < _answersCtrl.length; i++) {
        if (i < _existingQuestion!.answers.length) {
          _answersCtrl[i].text = _existingQuestion!.answers[i];
        }
      }
    }

    // Đảm bảo đã load danh mục
    final admin = Provider.of<AdminProvider>(context, listen: false);
    if (admin.categories.isEmpty) {
      admin.loadCategories();
    }
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    for (final c in _answersCtrl) {
      c.dispose();
    }
    _explanationCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn danh mục')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final question = QuestionModel(
        id: _existingQuestion?.id ?? '',
        question: _questionCtrl.text.trim(),
        answers: _answersCtrl.map((c) => c.text.trim()).toList(),
        correctIndex: _correctIndex,
        explanation: _explanationCtrl.text.trim(),
        category: _selectedCategory!,
      );

      final col = FirebaseFirestore.instance.collection('questions');

      if (_existingQuestion == null) {
        await col.add(question.toMap());
      } else {
        await col.doc(question.id).update(question.toMap());
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lưu câu hỏi thất bại: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = _existingQuestion != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Consumer<AdminProvider>(
          builder: (context, admin, child) {
            final categories = admin.categories;

            return Column(
              children: [
                // HEADER
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9F9F9),
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          size: 24,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          isEdit ? 'Sửa Câu Hỏi' : 'Thêm Câu Hỏi Mới',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _isSaving ? null : _saveQuestion,
                        child: Text(
                          'Lưu',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _isSaving
                                ? Colors.grey
                                : const Color(0xFF28A745),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // FORM
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nội dung câu hỏi
                          const Text(
                            'Nội dung câu hỏi',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _questionCtrl,
                            maxLines: null,
                            minLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Nhập nội dung câu hỏi tại đây',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFD1D5DB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFD1D5DB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF28A745), width: 2),
                              ),
                            ),
                            validator: (v) =>
                                v == null || v.trim().isEmpty ? 'Bắt buộc' : null,
                          ),
                          const SizedBox(height: 20),

                          // Chọn danh mục
                          const Text(
                            'Chọn Danh Mục',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          InputDecorator(
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFD1D5DB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFD1D5DB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF28A745), width: 2),
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                hint: const Text('Chọn một danh mục'),
                                isExpanded: true,
                                items: categories
                                    .map(
                                      (c) => DropdownMenuItem<String>(
                                        value: c.name,
                                        child: Text(c.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  setState(() => _selectedCategory = v);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Các lựa chọn trả lời
                          const Text(
                            'Các lựa chọn trả lời',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(4, (i) {
                            const labels = ['A', 'B', 'C', 'D'];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE5E7EB),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      labels[i],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF4B5563),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _answersCtrl[i],
                                      decoration: InputDecoration(
                                        hintText:
                                            'Nhập câu trả lời ${labels[i]}',
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFFD1D5DB)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFFD1D5DB)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                              color: Color(0xFF28A745),
                                              width: 2),
                                        ),
                                      ),
                                      validator: (v) => v == null ||
                                              v.trim().isEmpty
                                          ? 'Bắt buộc'
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 12),

                          // Đáp án đúng
                          const Text(
                            'Đáp án đúng',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(4, (i) {
                              const labels = ['A', 'B', 'C', 'D'];
                              final selected = _correctIndex == i;
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: i == 3 ? 0 : 8),
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() => _correctIndex = i);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      side: BorderSide(
                                        color: selected
                                            ? const Color(0xFF28A745)
                                            : const Color(0xFFD1D5DB),
                                        width: selected ? 2 : 1,
                                      ),
                                      backgroundColor: selected
                                          ? const Color(0xFF28A745)
                                              .withOpacity(0.15)
                                          : Colors.white,
                                    ),
                                    child: Text(
                                      labels[i],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: selected
                                            ? const Color(0xFF28A745)
                                            : const Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 20),

                          // Giải thích chi tiết
                          const Text(
                            'Giải thích chi tiết (Không bắt buộc)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _explanationCtrl,
                            maxLines: null,
                            minLines: 5,
                            decoration: InputDecoration(
                              hintText:
                                  'Nhập giải thích chi tiết cho câu trả lời đúng',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFD1D5DB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFFD1D5DB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF28A745), width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}