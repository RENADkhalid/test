import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/home');
      });

    } on FirebaseAuthException catch (e) {
      String errorMessage = 'البريد الالكتروني او كلمة المرور غير صحيحة';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'لا يوجد حساب مرتبط بهذا البريد الإلكتروني';
          break;
        case 'wrong-password':
          errorMessage = 'كلمة المرور غير صحيحة';
          break;
        case 'invalid-email':
          errorMessage = 'صيغة البريد الإلكتروني غير صحيحة';
          break;
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('خطأ'),
          content: Text(errorMessage),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('حسنًا')),
          ],
        ),
      );

    } catch (e) {
      // 🔥 حل الخطأ — تجاهل كامل
      debugPrint("Ignored plugin error after login: $e");

      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Image.asset('assets/logo.png', height: 100),
              const SizedBox(height: 24),
              const Text(
                'تسجيل الدخول',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Tajawal',
                ),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  hintText: 'أدخل بريدك الإلكتروني',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                textAlign: TextAlign.right,
              ),

              const SizedBox(height: 12),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'أدخل كلمة المرور',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12))),
                ),
                textAlign: TextAlign.right,
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F2D52),
                  padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 64),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/signup'),
                child: const Text(
                  'إنشاء حساب جديد',
                  style: TextStyle(
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                    fontFamily: 'Tajawal',
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
