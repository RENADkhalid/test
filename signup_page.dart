import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // ========================= VALIDATORS =============================

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) return 'الرجاء إدخال اسم المستخدم';
    if (RegExp(r'^\d').hasMatch(value)) return 'الاسم لا يجب أن يبدأ برقم';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'الرجاء إدخال البريد الإلكتروني';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'البريد الإلكتروني غير صالح';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'الرجاء إدخال كلمة المرور';
    if (value.length < 8) return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'يجب أن تحتوي على حرف كبير';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'يجب أن تحتوي على حرف صغير';
    if (!RegExp(r'\d').hasMatch(value)) return 'يجب أن تحتوي على رقم';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != passwordController.text) return 'كلمتا المرور غير متطابقتين';
    return null;
  }

  // ========================= ERROR DIALOG =============================

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسنًا'),
          ),
        ],
      ),
    );
  }

  // ========================= REGISTER =============================

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final username = usernameController.text.trim();

      // إنشاء حساب
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // تحديث displayName
      await userCredential.user!.updateDisplayName(username);

      // حفظ البيانات في Firestore
      await FirebaseFirestore.instance
          .collection('UserAccount')
          .doc(userCredential.user!.uid)
          .set({
        'Name': username,
        'email': email,
        'uid': userCredential.user!.uid,
        'created_time': Timestamp.now(),
        'customAvatar': 'assets/default.png',
      });

      if (!mounted) return;

      // الانتقال للصفحة الرئيسية بدون الرجوع للخلف
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? 'حدث خطأ غير متوقع');
    } catch (e) {
      _showError('حدث خطأ أثناء التسجيل: $e');
    }
  }

  // ========================= BUILD UI =============================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/logo.png', height: 100),
                const SizedBox(height: 24),
                const Text(
                  'إنشاء حساب',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  'اسم المستخدم',
                  controller: usernameController,
                  validator: _validateUsername,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'البريد الإلكتروني',
                  controller: emailController,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'كلمة المرور',
                  controller: passwordController,
                  validator: _validatePassword,
                  isPassword: true,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  'تأكيد كلمة المرور',
                  controller: confirmPasswordController,
                  validator: _validateConfirmPassword,
                  isPassword: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F2D52),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 64),
                  ),
                  child: const Text(
                    'إنشاء حساب',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/login'),
                  child: const Text(
                    'لديك حساب؟ تسجيل الدخول',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========================= TEXT FIELD WIDGET =============================

  Widget _buildTextField(
    String hint, {
    required TextEditingController controller,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    bool isConfirm = controller == confirmPasswordController;

    bool obscure = isPassword
        ? (isConfirm ? _obscureConfirmPassword : _obscurePassword)
        : false;

    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    if (isConfirm) {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    } else {
                      _obscurePassword = !_obscurePassword;
                    }
                  });
                },
              )
            : null,
      ),
      textAlign: TextAlign.right,
    );
  }
}
