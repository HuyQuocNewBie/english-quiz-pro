import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../core/app_routes.dart';

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminProvider()..loadCategories(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F8),
        body: SafeArea(
          child: Consumer<AdminProvider>(
            builder: (context, adminProvider, child) {
              final categories = adminProvider.categories;

              return Column(
                children: [
                  // HEADER
                  Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F7F8).withOpacity(0.9),
                      border: const Border(
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
                            'Quản lý Danh mục',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // sau này có thể mở search/filter
                          },
                          icon: const Icon(
                            Icons.search,
                            size: 24,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // BODY
                  Expanded(
                    child: adminProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : categories.isEmpty
                            ? const Center(
                                child: Text(
                                  'Chưa có danh mục nào',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  final cat = categories[index];
                                  final iconData = _getCategoryIcon(cat.name);
                                  final bgColor = _getCategoryBgColor(cat.name);
                                  final iconColor = _getCategoryColor(cat.name);

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        // ICON VÒNG TRÒN
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: bgColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            iconData,
                                            color: iconColor,
                                            size: 26,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // TÊN DANH MỤC
                                        Expanded(
                                          child: Text(
                                            cat.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                        // NÚT SỬA/XÓA
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit,
                                                size: 20,
                                                color: Color(0xFF6B7280),
                                              ),
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  AppRoutes.addEditCategory,
                                                  arguments: cat.id,
                                                );
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete,
                                                size: 20,
                                                color: Color(0xFFEF4444),
                                              ),
                                              onPressed: () => _showDeleteDialog(
                                                context,
                                                adminProvider,
                                                cat.id,
                                                cat.name,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              );
            },
          ),
        ),

        // NÚT THÊM MỚI
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.addEditCategory),
          backgroundColor: const Color(0xFF13A4EC),
          icon: const Icon(Icons.add, size: 24),
          label: const Text(
            'Thêm Mới',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  // === Dialog xoá giữ nguyên logic cũ ===
  void _showDeleteDialog(
    BuildContext context,
    AdminProvider provider,
    String id,
    String name,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa danh mục?'),
        content: Text('Tất cả câu hỏi trong "$name" sẽ bị xóa vĩnh viễn!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await provider.deleteCategory(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa danh mục "$name"')),
        );
      }
    }
  }

  // === Màu & icon theo tên danh mục (tuỳ chỉnh thêm nếu cần) ===
  IconData _getCategoryIcon(String name) {
    switch (name) {
      case 'Thành ngữ':
        return Icons.format_quote;
      case 'Từ vựng':
        return Icons.translate;
      case 'Điền từ':
        return Icons.short_text;
      case 'Nghe hiểu':
        return Icons.headphones;
      case 'Ngữ pháp':
        return Icons.spellcheck;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryBgColor(String name) {
    switch (name) {
      case 'Thành ngữ':
        return const Color(0xFFDBEAFE); // blue-100
      case 'Từ vựng':
        return const Color(0xFFD1FAE5); // green-100
      case 'Điền từ':
        return const Color(0xFFFEF3C7); // yellow-100
      case 'Nghe hiểu':
        return const Color(0xFFEDE9FE); // purple-100
      case 'Ngữ pháp':
        return const Color(0xFFFEE2E2); // red-100
      default:
        return const Color(0xFFE5E7EB); // gray-200
    }
  }

  Color _getCategoryColor(String name) {
    switch (name) {
      case 'Thành ngữ':
        return const Color(0xFF2563EB); // blue-500
      case 'Từ vựng':
        return const Color(0xFF16A34A); // green-600
      case 'Điền từ':
        return const Color(0xFFEAB308); // yellow-500
      case 'Nghe hiểu':
        return const Color(0xFF7C3AED); // purple-600
      case 'Ngữ pháp':
        return const Color(0xFFEF4444); // red-500
      default:
        return const Color(0xFF4B5563); // gray-600
    }
  }
}