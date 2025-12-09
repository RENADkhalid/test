// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'login_page.dart';
import 'signup_page.dart';
import 'resetpassword_page.dart';
import 'education_letters.dart';
import 'homepage.dart';
import 'profile.dart';
import 'articles_page.dart';
import 'welcome.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? initError;

  try {
    // تهيئة فايربيز مرة واحدة فقط
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, st) {
    // في حالة إعادة التهيئة على الويب أو حالات خاصة، نتجاهل duplicate-app
    if (e.toString().contains('duplicate-app')) {
      print('Duplicate Firebase app detected, ignoring in this run.');
      initError = null;
    } else {
      initError = '$e\n$st';
      print('FIREBASE INIT ERROR: $e\n$st');
    }
  }

  runApp(_BootstrapApp(initError: initError));
}

class _BootstrapApp extends StatelessWidget {
  final String? initError;
  const _BootstrapApp({super.key, this.initError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: initError == null
          ? const WelcomePage()
          : Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Init failed:\n\n$initError',
              style: const TextStyle(fontSize: 14, color: Colors.red),
            ),
          ),
        ),
      ),
      routes: {
        '/login': (_) => const LoginPage(),
        '/signup': (_) => const SignUpPage(),
        '/reset': (_) => const ResetPasswordPage(),
        '/letters': (_) => const LettersScreen(),
        '/home': (_) => const HomePage(),
        '/profile': (_) => const AccountSettingsPage(),
        '/articles': (_) => ArticlesPage(),
      },
    );
  }
}
