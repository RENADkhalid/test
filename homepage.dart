import 'dart:async';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:laweh_app/play_withlaweh.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'custom_navbar.dart';
import 'correct_me.dart';
import 'translation_page.dart';
import 'articles_page.dart';
import 'education_category.dart';
import 'chat_page.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;
  late VideoPlayerController _videoController;
  List<Widget> _banners = [];

  String? userName;

  @override
  void initState() {
    super.initState();

    // ignore: avoid_print
    print('🔥 initState بدأ');

    final uid = FirebaseAuth.instance.currentUser?.uid;
    // ignore: avoid_print
    print('📌 UID: $uid');

    if (uid != null) {
      FirebaseFirestore.instance
          .collection('UserAccount')
          .doc(uid)
          .get()
          .then((doc) {
        // ignore: avoid_print
        print('📥 تم جلب الوثيقة من Firestore');
        if (doc.exists && doc.data()!.containsKey('Name')) {
          // ignore: avoid_print
          print('✅ اسم المستخدم: ${doc.get('Name')}');
          setState(() {
            userName = doc.get('Name');
          });
        } else {
          // ignore: avoid_print
          print('⚠️ الوثيقة لا تحتوي على الاسم');
          setState(() {
            userName = 'زائر';
          });
        }
      }).catchError((error) {
        // ignore: avoid_print
        print('❌ خطأ في Firestore: $error');
        setState(() {
          userName = 'زائر';
        });
      });
    } else {
      // ignore: avoid_print
      print('⚠️ UID غير موجود');
    }

    // ignore: avoid_print
    print('🎬 جاري تهيئة الفيديو');
    _videoController = VideoPlayerController.asset('assets/startNowBanner.mp4')
      ..initialize().then((_) {
        // ignore: avoid_print
        print('✅ تم تحميل الفيديو');

        setState(() {
          _videoController.setLooping(true);
          _videoController.setVolume(0);
          _videoController.play();

          _banners = [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: VideoPlayer(_videoController),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/banner2.jpg', fit: BoxFit.cover),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset('assets/banner3.jpg', fit: BoxFit.cover),
            ),
          ];
        });
      }).catchError((error) {
        // ignore: avoid_print
        print('❌ خطأ في تحميل الفيديو: $error');
      });

    // ignore: avoid_print
    print('⏱️ بدء المؤقت لعرض البانرات');
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_banners.isNotEmpty) {
        setState(() {
          _currentPage = (_currentPage + 1) % _banners.length;
        });
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    _videoController.dispose();
    super.dispose();
  }

  // ignore: prefer_final_fields
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EducationCategoryScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TranslationScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ChatPage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AccountSettingsPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFEFF1FA),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/logo.png', height: 80),
                          const SizedBox(width: 12),
                          Row(
                            children: [
                              Text(
                                'مرحبا، ${userName ?? '...'}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1D3557),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const AnimatedWaveHand(),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(2, 4),
                            ),
                          ],
                        ),
                        child: _banners.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : PageView.builder(
                                controller: _pageController,
                                itemCount: _banners.length,
                                itemBuilder: (context, index) =>
                                    _banners[index],
                              ),
                      ),
                      const SizedBox(height: 10),
                      if (_banners.isNotEmpty)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _banners.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: _currentPage == index ? 10 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? Colors.blueAccent
                                    : Colors.grey[400],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CorrectMeApp(),
                                ),
                              );
                            },
                            child: const HomeFeatureButton(
                              icon: FontAwesomeIcons.masksTheater,
                              label: 'صححني',
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArticlesPage(),
                                ),
                              );
                            },
                            child: const HomeFeatureButton(
                              icon: Icons.article,
                              label: 'مقالات',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PlayWithLaweh()),
                          );
                        },
                        child: const HomeFeatureButton(
                          icon: FontAwesomeIcons.bookOpenReader,
                          label: 'العب مع لوّح',
                          fullWidth: true,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}

class HomeFeatureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool fullWidth;

  const HomeFeatureButton({
    super.key,
    required this.icon,
    required this.label,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth
          ? double.infinity
          : MediaQuery.of(context).size.width * 0.42,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 2),
          )
        ],
      ),
      child: Column(
        children: [
          FaIcon(icon, color: const Color(0xFF1D3557)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF1D3557),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedWaveHand extends StatefulWidget {
  const AnimatedWaveHand({super.key});

  @override
  State<AnimatedWaveHand> createState() => _AnimatedWaveHandState();
}

class _AnimatedWaveHandState extends State<AnimatedWaveHand>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rotation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 0.3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: -0.3), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.3, end: 0.2), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.2, end: -0.1), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -0.1, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  void _startWaving() {
    if (!_controller.isAnimating) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _startWaving,
      child: AnimatedBuilder(
        animation: _rotation,
        child: const Text('👋', style: TextStyle(fontSize: 22)),
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotation.value,
            child: child,
          );
        },
      ),
    );
  }
}
