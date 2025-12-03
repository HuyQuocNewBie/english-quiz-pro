import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../core/app_routes.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final user = auth.user;

    // Giữ logic chặn non‑admin như cũ
    if (user == null || !user.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bạn không có quyền truy cập khu vực này!')),
        );
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.userHome, (route) => false);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(Icons.menu, size: 28, color: Color(0xFF0F172A)),
                  ),
                  const Expanded(
                    child: Text(
                      'Trang Chủ Admin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.account_circle, size: 30, color: Color(0xFF0F172A)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // THỐNG KÊ NHANH
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _StatCard(
                    label: 'Tổng số Người dùng',
                    countStream: FirebaseFirestore.instance
                        .collection('users')
                        .snapshots()
                        .map((s) => s.size),
                    changeText: '+5%',
                  ),
                  _StatCard(
                    label: 'Tổng số Câu hỏi',
                    countStream: FirebaseFirestore.instance
                        .collection('questions')
                        .snapshots()
                        .map((s) => s.size),
                    changeText: '+2%',
                  ),
                  _StatCard(
                    label: 'Chủ đề/Danh mục',
                    countStream: FirebaseFirestore.instance
                        .collection('categories')
                        .snapshots()
                        .map((s) => s.size),
                    changeText: '+1',
                  ),
                  _StatCard(
                    label: 'Lượt thi hôm nay',
                    // đơn giản: đếm tất cả quiz_results, sau này có thể lọc theo ngày
                    countStream: FirebaseFirestore.instance
                        .collection('quiz_results')
                        .snapshots()
                        .map((s) => s.size),
                    changeText: '+12%',
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Text(
                'Quản lý',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),

              // HÀNG QUẢN LÝ
              _ManageRow(
                icon: Icons.quiz,
                title: 'Quản lý Câu hỏi',
                subtitle: 'Thêm, sửa, hoặc xoá câu hỏi',
                onTap: () => Navigator.pushNamed(context, AppRoutes.manageQuestions),
              ),
              const SizedBox(height: 8),
              _ManageRow(
                icon: Icons.group,
                title: 'Quản lý Người dùng',
                subtitle: 'Xem và quản lý tài khoản',
                onTap: () => Navigator.pushNamed(context, AppRoutes.manageUsers),
              ),
              const SizedBox(height: 8),
              _ManageRow(
                icon: Icons.category,
                title: 'Quản lý Danh mục',
                subtitle: 'Tạo mới, chỉnh sửa các danh mục',
                onTap: () => Navigator.pushNamed(context, AppRoutes.manageCategories),
              ),
              const SizedBox(height: 8),
                            _ManageRow(
                icon: Icons.bar_chart,
                title: 'Báo cáo & Thống kê',
                subtitle: 'Phân tích chi tiết người dùng',
                onTap: () => Navigator.pushNamed(context, AppRoutes.statistics),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await auth.signOut();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Đăng xuất'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// CARD THỐNG KÊ NHANH
class _StatCard extends StatelessWidget {
  final String label;
  final Stream<int> countStream;
  final String changeText;  

  const _StatCard({
    required this.label,
    required this.countStream,
    required this.changeText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2, // 2 card/row
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: StreamBuilder<int>(
          stream: countStream,
          builder: (context, snapshot) {
            final value = snapshot.data ?? 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2933),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  changeText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF16A34A),
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

// DÒNG QUẢN LÝ
class _ManageRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ManageRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF13A4EC).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(          // ← dùng icon truyền vào, không hard-code nữa
                  icon,
                  color: const Color(0xFF13A4EC),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}