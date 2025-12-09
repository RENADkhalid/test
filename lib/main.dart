import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
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
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // App Check:
    // - Web: optional (needs site key set up)
    // - Android/iOS: supported
    // - Desktop (Windows/macOS/Linux): skip
    if (kIsWeb) {
      // OPTIONAL: enable if you've added your reCAPTCHA v3 site key in web/index.html
      // await FirebaseAppCheck.instance.activate(
      //   webProvider: ReCaptchaV3Provider('YOUR-RECAPTCHA-V3-SITE-KEY'),
      // );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug, // change to .playIntegrity in prod
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      await FirebaseAppCheck.instance.activate(
        appleProvider: AppleProvider.debug, // change to .appAttest in prod
      );
    } else {
      // Windows/macOS/Linux → not supported; do nothing
    }

  } catch (e, st) {
    initError = '$e\n$st';
    // ignore: avoid_print
    print('FIREBASE INIT ERROR: $e\n$st');
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
