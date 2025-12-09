import 'package:flutter/material.dart';

// صفحات المشروع
import 'homepage.dart';
import 'education_category.dart';
import 'translation_page.dart';
import 'articles_page.dart';
import 'profile.dart';

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  static const Color activeColor = Color(0xFF113F67);
  static const Color inactiveColor = Color(0xFFA2A8D3);

  void _navigateToPage(BuildContext context, int index) {
    Widget targetPage;
    switch (index) {
      case 0:
        targetPage = const HomePage();
        break;
      case 1:
        targetPage = const EducationCategoryScreen();
        break;
      case 2:
        targetPage = const TranslationScreen();
        break;
      case 3:
        targetPage = const ArticlesPage(); 

        break;
      case 4:
        targetPage = const AccountSettingsPage();
        break;
      default:
        targetPage = const HomePage();
    }

    if (index != selectedIndex) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => targetPage),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIcon(context, index: 0, icon: Icons.home),
             _buildIcon(context, index: 1, icon: Icons.auto_stories),

              const SizedBox(width: 60), // زر المنتصف
            _buildIcon(context, index: 3, icon: Icons.article),

              _buildIcon(context, index: 4, icon: Icons.person),
            ],
          ),
        ),
        // 🔵 الزر العائم للصورة (لغة الإشارة)
        Positioned(
          top: -30,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _navigateToPage(context, 2);
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: activeColor,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/sign-language.png',
                    width: 32,
                    height: 32,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIcon(BuildContext context, {required int index, required IconData icon}) {
    final bool isSelected = selectedIndex == index;

    return IconButton(
      icon: Icon(
        icon,
        size: 28,
        color: isSelected ? activeColor : inactiveColor,
      ),
      onPressed: () => _navigateToPage(context, index),
    );
  }
}