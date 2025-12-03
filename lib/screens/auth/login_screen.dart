import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../core/app_routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  late TabController _tabController;
  bool _isLogin = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() => _isLogin = _tabController.index == 0);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, child) {
        if (auth.isLoggedIn) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final user = auth.user;
            final targetRoute = (user != null && user.isAdmin)
                ? AppRoutes.adminDashboard   // nếu admin → vào Admin Dashboard
                : AppRoutes.userHome;        // còn lại → Home user

            Navigator.pushNamedAndRemoveUntil(
              context,
              targetRoute,
              (route) => false,
            );
          });
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 100,
            flexibleSpace: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF3873F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.school, size: 48, color: Colors.white),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Bắt đầu học nào!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Đăng nhập hoặc đăng ký để tham gia các bài quiz thú vị.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Tab Đăng Nhập / Đăng Ký
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF3873F6),
                    unselectedLabelColor: Colors.grey[600],
                    indicator: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: const EdgeInsets.all(4),
                    tabs: const [
                      Tab(text: 'Đăng Nhập'),
                      Tab(text: 'Đăng Ký'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (!_isLogin) ...[
                        _buildTextField(
                          controller: _nameController,
                          label: 'Họ và tên',
                          icon: Icons.person_outline,
                          hint: 'Nhập họ và tên của bạn',
                        ),
                        const SizedBox(height: 16),
                      ],
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.mail_outline,
                        hint: 'Nhập email của bạn',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => v!.contains('@') ? null : 'Email không hợp lệ',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Mật khẩu',
                        icon: Icons.lock_outline,
                        hint: 'Nhập mật khẩu của bạn',
                        obscureText: true,
                        validator: (v) => v!.length >= 6 ? null : 'Mật khẩu ít nhất 6 ký tự',
                      ),
                      const SizedBox(height: 24),

                      CustomButton(
                        text: _isLogin ? 'Đăng Nhập' : 'Đăng Ký',
                        isLoading: auth.isLoading,
                        onPressed: auth.isLoading ? null : () => _submit(auth),
                        backgroundColor: const Color(0xFF3873F6),
                        height: 56,
                      ),

                      const SizedBox(height: 32),
                      const Text('Hoặc tiếp tục với', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),

                      // NÚT GOOGLE SIÊU ĐẸP
                      SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: Image.asset(
                            'assets/images/google_logo.png',
                            width: 20,
                            height: 20,
                            errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, color: Colors.red, size: 24),
                          ),
                          label: const Text('Google', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: auth.isLoading ? null : auth.signInWithGoogle,
                        ),
                      ),

                      const SizedBox(height: 32),
                      Text(
                        'Bằng việc đăng nhập, bạn đồng ý với Điều khoản Dịch vụ & Chính sách Bảo mật của chúng tôi.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1F2937))),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3873F6), width: 2),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  void _submit(AuthProvider auth) {
    if (_formKey.currentState!.validate()) {
      _isLogin
          ? auth.signIn(_emailController.text.trim(), _passwordController.text)
          : auth.signUp(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              name: _nameController.text.trim(),
            );
    }
  }
}