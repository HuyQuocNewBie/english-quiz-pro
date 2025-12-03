import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../core/app_routes.dart';
import '../../widgets/bottom_nav_bar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Màu sắc theo design
  static const Color primaryColor = Color(0xFF4A90E2);
  static const Color backgroundColor = Color(0xFFF7F9FC);
  static const Color successColor = Color(0xFF34C759);
  static const Color warningColor = Color(0xFFFF9500);
  static const Color dangerColor = Color(0xFFFF3B30);
  static const Color textColor = Color(0xFF1F2937);
  static const Color textSecondaryColor = Color(0xFF6B7280);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getRatingText(double percentage) {
    if (percentage >= 90) return 'Xuất sắc';
    if (percentage >= 70) return 'Tốt';
    return 'Cần cố gắng';
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 90) return successColor;
    if (percentage >= 70) return warningColor;
    return dangerColor;
  }

  Color _getIconBgColor(double percentage) {
    if (percentage >= 90) return const Color(0xFFEBF9F0);
    if (percentage >= 70) return const Color(0xFFFFF6E6);
    return const Color(0xFFFFEBEA);
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: const Center(child: Text('Vui lòng đăng nhập')),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Header sticky
          Container(
            color: backgroundColor,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  // Spacer thay cho nút back (để title ở giữa)
                  const SizedBox(width: 40),
                  // Title
                  const Expanded(
                    child: Text(
                      'Lịch sử Quiz',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  // Nút filter
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // TODO: Implement filter functionality
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.filter_list,
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

          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Tìm kiếm bài quiz...',
                hintStyle: const TextStyle(color: textSecondaryColor),
                prefixIcon: const Icon(Icons.search, color: textSecondaryColor, size: 24),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: const BorderSide(color: primaryColor, width: 2),
                ),
              ),
            ),
          ),

          // List of results
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('quiz_results')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Lỗi tải dữ liệu',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final results = snapshot.data!.docs;

                if (results.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('Chưa có bài làm nào', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  );
                }

                // Sort theo completedAt descending trong code
                final sortedResults = results.toList()
                  ..sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aTime = (aData['completedAt'] as Timestamp?)?.toDate() ?? DateTime(0);
                    final bTime = (bData['completedAt'] as Timestamp?)?.toDate() ?? DateTime(0);
                    return bTime.compareTo(aTime); // Descending
                  });

                // Filter theo search query
                final filteredResults = sortedResults.where((doc) {
                  if (_searchQuery.isEmpty) return true;
                  final data = doc.data() as Map<String, dynamic>;
                  final category = (data['category'] ?? '').toString().toLowerCase();
                  return category.contains(_searchQuery);
                }).toList();

                if (filteredResults.isEmpty) {
                  return const Center(
                    child: Text('Không tìm thấy kết quả', style: TextStyle(fontSize: 16)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredResults.length,
                  itemBuilder: (context, index) {
                    final doc = filteredResults[index];
                    final data = doc.data() as Map<String, dynamic>;

                    final score = data['score'] ?? 0;
                    final total = data['total'] ?? 1;
                    final correctCount = (score / 10).round(); // Giả sử mỗi câu 10 điểm
                    final percentage = (score / total) * 100;
                    final completedAt = data['completedAt'] as Timestamp?;
                    final category = data['category'] ?? 'Không rõ';

                    final scoreColor = _getScoreColor(percentage);
                    final iconBgColor = _getIconBgColor(percentage);
                    final ratingText = _getRatingText(percentage);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: completedAt != null
                              ? () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.historyDetail,
                                    arguments: {
                                      'category': category,
                                      'score': score,
                                      'total': total,
                                      'date': completedAt.toDate(),
                                      'timeSpent': data['timeSpent'] ?? 'Không rõ',
                                      'resultId': doc.id,
                                    },
                                  );
                                }
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[100]!),
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
                                // Icon với background màu
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: iconBgColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.task_alt,
                                    color: scoreColor,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Thông tin quiz
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: textColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        completedAt != null
                                            ? 'Hoàn thành: ${DateFormat('dd/MM/yyyy').format(completedAt.toDate())}'
                                            : 'Hoàn thành: Không rõ',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: textSecondaryColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Điểm số và đánh giá
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '$correctCount/$total',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: scoreColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      ratingText,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: textSecondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}