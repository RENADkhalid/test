import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'resetpassword_page.dart';
// ignore: unused_import
import 'welcome.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('حدث خطأ'),
          content: Text(e.message ?? 'حدث خطأ غير معروف'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسنًا'),
            ),
          ],
        ),
      );
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
            mainAxisAlignment: MainAxisAlignment.center,
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
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // حقل البريد الإلكتروني
       
const SizedBox(height: 8),
TextField(
  controller: emailController,
  decoration: const InputDecoration(
    hintText: 'أدخل بريدك الإلكتروني',
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    hintStyle: TextStyle(
      fontFamily: 'Tajawal',
      fontSize: 14,
      color: Colors.grey,
    ),
  ),
  textAlign: TextAlign.right,

),


              const SizedBox(height: 12),

              // حقل كلمة المرور
            
const SizedBox(height: 8),
TextField(
  controller: passwordController,
  obscureText: true,
  decoration: const InputDecoration(
    hintText: 'أدخل كلمة المرور',
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
    hintStyle: TextStyle(
      fontFamily: 'Tajawal',
      fontSize: 14,
      color: Colors.grey,
    ),
  ),
  textAlign: TextAlign.right,
),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F2D52),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 64),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Tajawal',
                    color: Colors.white,
                    
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Column(
                children: [
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'ليس لديك حساب؟ ',
                          style: TextStyle(fontFamily: 'Tajawal'),
                        ),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: const Text(
                              'إنشاء حساب',
                              style: TextStyle(
                                color: Colors.blue,
                                fontFamily: 'Tajawal',
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResetPasswordPage(), 
                        ),
                      );
                    },
                    child: const Text(
                      'نسيت كلمة المرور؟',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontFamily: 'Tajawal',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
