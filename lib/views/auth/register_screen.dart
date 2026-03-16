import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chấp nhận điều khoản dịch vụ')),
      );
      return;
    }

    final authViewModel = context.read<AuthViewModel>();

    final success = await authViewModel.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng Ký Tài Khoản'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildErrorBanner(),
                  _buildLabel('Họ và tên'),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Nhập họ và tên',
                    icon: Icons.person_outline,
                    validator: (val) =>
                        val!.isEmpty ? 'Vui lòng nhập họ tên' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Địa chỉ Email'),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'example@gmail.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) =>
                        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(val!)
                            ? 'Email không hợp lệ'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Mật khẩu'),
                  _buildTextField(
                    controller: _passwordController,
                    hint: 'Tối thiểu 6 ký tự',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: _obscurePassword,
                    onToggleVisibility: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    validator: (val) =>
                        val!.length < 6 ? 'Mật khẩu quá ngắn' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Xác nhận mật khẩu'),
                  _buildTextField(
                    controller: _confirmPasswordController,
                    hint: 'Nhập lại mật khẩu',
                    icon: Icons.lock_reset_outlined,
                    isPassword: true,
                    obscureText: _obscureConfirmPassword,
                    onToggleVisibility: () => setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword),
                    validator: (val) => val != _passwordController.text
                        ? 'Mật khẩu không khớp'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTermsCheckbox(),
                  const SizedBox(height: 24),
                  _buildRegisterButton(),
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
                icon:
                    Icon(obscureText ? Icons.visibility_off : Icons.visibility),
                onPressed: onToggleVisibility,
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        if (authVM.errorMessage == null) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Text(
            authVM.errorMessage!,
            style: TextStyle(color: Colors.red[900], fontSize: 13),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (val) => setState(() => _agreeToTerms = val ?? false),
          ),
        ),
        const SizedBox(width: 8),
        const Text('Tôi đồng ý với ', style: TextStyle(fontSize: 13)),
        Text(
          'Điều khoản dịch vụ',
          style: TextStyle(
              color: Colors.teal[700],
              fontWeight: FontWeight.bold,
              fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        return SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: authVM.isLoading ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: authVM.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Text('Đăng Ký',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Đã có tài khoản?'),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đăng nhập',
              style:
                  TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
