import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  String _searchText = '';
  String _roleFilter = 'Tất cả';

  @override
  void initState() {
    super.initState();
    // Load danh sách user sau khi build frame đầu tiên
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final admin = Provider.of<AdminProvider>(context, listen: false);
      if (admin.users.isEmpty && !admin.isLoading) {
        admin.loadUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminProvider>(context);

    // Lọc theo search + role
    final users = adminProvider.users.where((user) {
      final name = (user['displayName'] ?? '').toString().toLowerCase();
      final email = (user['email'] ?? '').toString().toLowerCase();
      final role = (user['role'] ?? 'user').toString();

      final matchSearch = _searchText.isEmpty ||
          name.contains(_searchText.toLowerCase()) ||
          email.contains(_searchText.toLowerCase());

      final matchRole = _roleFilter == 'Tất cả'
          ? true
          : (_roleFilter == 'Admin' ? role == 'admin' : role != 'admin');

      return matchSearch && matchRole;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F7F8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                      'Quản lý Người Dùng',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // chừa chỗ cân header
                ],
              ),
            ),

            // SEARCH BAR STICKY
            Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F7F8), // bg-background-light
            ),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFFE5E7EB).withOpacity(0.6), // bg-slate-200/60
              ),
              child: Row(
                children: [
                  // ICON CONTAINER
                  Container(
                    width: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB).withOpacity(0.6), // bg-slate-200/60
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(14),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.search,
                        size: 26,
                        color: Color(0xFF6B7280), // text-slate-500
                      ),
                    ),
                  ),

                  // INPUT
                  Expanded(
                    child: TextField(
                      onChanged: (value) => setState(() => _searchText = value),
                      style: const TextStyle(
                        color: Color(0xFF111827), // text-slate-900
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tìm theo tên hoặc email...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF6B7280), // placeholder slate-500
                        ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

            // FILTER CHIPS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  _buildFilterChip('Tất cả'),
                  _buildFilterChip('Admin'),
                  _buildFilterChip('User'),
                ],
              ),
            ),

            // DANH SÁCH USERS
            Expanded(
              child: adminProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : users.isEmpty
                      ? const Center(
                          child: Text(
                            'Không tìm thấy người dùng',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                          itemCount: users.length,
                          itemBuilder: (context, i) {
                            final user = users[i];
                            final bool isAdmin = user['role'] == 'admin';
                            final photoURL = user['photoURL'] as String?;
                            final displayName =
                                (user['displayName'] ?? 'Không tên')
                                    .toString();
                            final email = (user['email'] ?? '').toString();

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F7F8),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  // AVATAR
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage: photoURL != null
                                        ? NetworkImage(photoURL)
                                        : const AssetImage(
                                          'assets/images/avatar_default.png',
                                        ) as ImageProvider,
                                  ),
                                  const SizedBox(width: 12),

                                  // TÊN + EMAIL + CHIP ADMIN
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                displayName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF0F172A),
                                                ),
                                              ),
                                            ),
                                            if (isAdmin)
                                              Container(
                                                margin:
                                                    const EdgeInsets.only(left: 4),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFFEF3C7),
                                                  borderRadius:
                                                      BorderRadius.circular(999),
                                                ),
                                                child: const Text(
                                                  'Admin',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF92400E),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          email,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF6B7280),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // ACTION BUTTONS
                                  Row(
                                    children: [
                                      IconButton(
                                        tooltip: isAdmin
                                            ? 'Bỏ quyền admin'
                                            : 'Cấp quyền admin',
                                        onPressed: () => adminProvider
                                            .toggleAdminRole(user['uid']),
                                        icon: const Icon(Icons.edit, size: 20),
                                        color: const Color(0xFF4B5563),
                                      ),
                                      IconButton(
                                        tooltip: 'Xóa người dùng',
                                        onPressed: () => adminProvider
                                            .deleteUser(user['uid'], context),
                                        icon: const Icon(Icons.delete, size: 20),
                                        color: const Color(0xFFEF4444),
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
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool selected = _roleFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() => _roleFilter = label);
        },
        selectedColor: const Color(0xFF13A4EC),
        labelStyle: TextStyle(
          color: selected ? Colors.white : const Color(0xFF0F172A),
          fontWeight: FontWeight.w500,
        ),
        backgroundColor: const Color(0xFFE5E7EB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide.none,
        ),
      ),
    );
  }
}