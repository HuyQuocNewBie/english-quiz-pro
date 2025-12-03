import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/bottom_nav_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = false;

  // Màu sắc theo design
  static const Color primaryColor = Color(0xFF4ade80);
  static const Color backgroundColor = Color(0xFFf0fdf4);
  static const Color foregroundColor = Colors.white;
  static const Color textColor = Color(0xFF1f2937);
  static const Color textSecondaryColor = Color(0xFF6b7280);
  static const Color redColor = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.user;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            color: backgroundColor,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  // Spacer để title ở giữa
                  const SizedBox(width: 40),
                  // Title
                  const Expanded(
                    child: Text(
                      'Cài Đặt',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  
                  // Section: Tài khoản
                  _buildSection(
                    title: 'TÀI KHOẢN',
                    children: [
                      _buildSettingItem(
                        icon: Icons.person,
                        title: 'Quản lý tài khoản',
                        onTap: () {
                          // TODO: Navigate to account management
                        },
                      ),
                      _buildSettingItem(
                        icon: Icons.logout,
                        title: 'Đăng xuất',
                        iconColor: redColor,
                        iconBgColor: const Color(0xFFFFEBEE),
                        titleColor: redColor,
                        onTap: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Đăng xuất'),
                              content: const Text('Bạn có chắc muốn đăng xuất?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text(
                                    'Đăng xuất',
                                    style: TextStyle(color: redColor),
                                  ),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true && context.mounted) {
                            await auth.signOut();
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/',
                                (route) => false,
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Section: Cài đặt chung
                  _buildSection(
                    title: 'CÀI ĐẶT CHUNG',
                    children: [
                      _buildSwitchItem(
                        icon: Icons.notifications,
                        title: 'Thông báo',
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() {
                            _notificationsEnabled = value;
                          });
                        },
                      ),
                      _buildSwitchItem(
                        icon: Icons.volume_up,
                        title: 'Âm thanh',
                        value: _soundEnabled,
                        onChanged: (value) {
                          setState(() {
                            _soundEnabled = value;
                          });
                        },
                      ),
                      _buildSwitchItem(
                        icon: Icons.vibration,
                        title: 'Rung',
                        value: _vibrationEnabled,
                        onChanged: (value) {
                          setState(() {
                            _vibrationEnabled = value;
                          });
                        },
                      ),
                      _buildSettingItem(
                        icon: Icons.language,
                        title: 'Ngôn ngữ',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tiếng Việt',
                              style: const TextStyle(
                                fontSize: 16,
                                color: textSecondaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.chevron_right,
                              size: 20,
                              color: textSecondaryColor,
                            ),
                          ],
                        ),
                        onTap: () {
                          // TODO: Navigate to language selection
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Section: Thông tin
                  _buildSection(
                    title: 'THÔNG TIN',
                    children: [
                      _buildSettingItem(
                        icon: Icons.groups,
                        title: 'Về chúng tôi',
                        onTap: () {
                          // TODO: Show about us
                        },
                      ),
                      _buildSettingItem(
                        icon: Icons.privacy_tip,
                        title: 'Chính sách bảo mật',
                        onTap: () {
                          // TODO: Show privacy policy
                        },
                      ),
                      _buildSettingItem(
                        icon: Icons.gavel,
                        title: 'Điều khoản dịch vụ',
                        onTap: () {
                          // TODO: Show terms of service
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Version
                  const Center(
                    child: Text(
                      'Phiên bản 1.0.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: textSecondaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textSecondaryColor,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: foregroundColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? iconBgColor,
    Color? titleColor,
  }) {
    final effectiveIconColor = iconColor ?? primaryColor;
    final effectiveIconBgColor = iconBgColor ?? primaryColor.withOpacity(0.1);
    final effectiveTitleColor = titleColor ?? textColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(minHeight: 56),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: effectiveIconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: effectiveTitleColor,
                  ),
                ),
              ),
              if (trailing != null)
                trailing
              else
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: textSecondaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(minHeight: 56),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: primaryColor,
          ),
        ],
      ),
    );
  }
}