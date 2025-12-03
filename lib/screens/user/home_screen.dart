import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../core/app_routes.dart';
import '../../widgets/bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0FDF4),
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: user?.photoURL != null
                ? NetworkImage(user!.photoURL!)
                : const AssetImage('assets/images/avatar_default.png') as ImageProvider,
          ),
        ),
        title: const Text(
          'Chào mừng quay trở lại!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_outlined, color: Colors.black54),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Card điểm cao nhất
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Điểm cao nhất', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    '${user?.highScore ?? 0}',
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text('Hãy tiếp tục phát huy để phá kỷ lục mới nhé!', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ],
              ),
            ),

            // Thanh tìm kiếm
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm chủ đề quiz',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Chọn một danh mục', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),

            // Grid danh mục – ĐÃ ĐẸP NHƯ BẠN MUỐN
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('categories').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final categories = snapshot.data!.docs;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.0,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final catDoc = categories[index];
                    final catName = catDoc['name'] as String;

                    return FutureBuilder<int>(
                      future: FirebaseFirestore.instance
                          .collection('questions')
                          .where('category', isEqualTo: catName)
                          .get()
                          .then((snap) => snap.size),
                      builder: (context, countSnap) {
                        final questionCount = countSnap.data ?? 0;
                        final maxScore = questionCount * 10;
                        final userCategoryScore =
                            user?.categoryHighScores[catName]?.toDouble() ?? 0.0;

                        final progress = (maxScore > 0)
                            ? (userCategoryScore / maxScore).clamp(0.0, 1.0)
                            : 0.0;

                        return GestureDetector(
                          onTap: questionCount == 0
                              ? null
                              : () => Navigator.pushNamed(context, AppRoutes.quiz, arguments: catName),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: _getBgColor(catName),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: _getBgColor(catName).withOpacity(0.4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _getIconForCategory(catName),
                                    color: _getIconColor(catName),
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        catName,
                                        style: TextStyle(
                                          fontSize: 18, // TO HƠN
                                          fontWeight: FontWeight.bold, // IN ĐẬM
                                          color: _getTextColor(catName),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Hoàn thành ${(progress * 100).toInt()}%',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: _getTextColor(catName).withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  // Các hàm màu + icon giữ nguyên như cũ
  Color _getBgColor(String category) {
    switch (category) {
      case 'Ngữ pháp': return const Color(0xFFFFFBEB);
      case 'Từ vựng': return const Color(0xFFEFF6FF);
      case 'Thành ngữ': return const Color(0xFFF0F9FF);
      case 'Điền từ': return const Color(0xFFFDF2F8);
      case 'Nghe hiểu': return const Color(0xFFFEF2F2);
      default: return Colors.grey.shade100;
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Ngữ pháp': return Icons.book;
      case 'Từ vựng': return Icons.translate;
      case 'Thành ngữ': return Icons.chat_bubble;
      case 'Điền từ': return Icons.headphones;
      case 'Nghe hiểu': return Icons.format_list_bulleted;
      default: return Icons.quiz;
    }
  }

  Color _getIconColor(String category) {
    switch (category) {
      case 'Ngữ pháp': return const Color(0xFFD97706);
      case 'Từ vựng': return const Color(0xFF2563EB);
      case 'Thành ngữ': return const Color(0xFF0284C7);
      case 'Điền từ': return const Color(0xFFBE185D);
      case 'Nghe hiểu': return const Color(0xFFDC2626);
      default: return Colors.grey;
    }
  }

  Color _getTextColor(String category) {
    switch (category) {
      case 'Ngữ pháp': return const Color(0xFF92400E);
      case 'Từ vựng': return const Color(0xFF1E40AF);
      case 'Thành ngữ': return const Color(0xFF0369A1);
      case 'Điền từ': return const Color(0xFF5B21B6);
      case 'Nghe hiểu': return const Color(0xFFB91C1C);
      default: return Colors.black87;
    }
  }
}