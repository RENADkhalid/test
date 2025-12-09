import 'package:flutter/material.dart';
import 'package:laweh_app/education_numbers.dart';
import 'package:laweh_app/education_letters.dart';
import 'package:laweh_app/name_to_sign.dart';
import 'package:laweh_app/custom_navbar.dart'; 
import 'chat_page.dart';
import 'homepage.dart';
import 'articles_page.dart';
import 'profile.dart';
import 'translation_page.dart';

class EducationCategoryScreen extends StatefulWidget {
  const EducationCategoryScreen({super.key});

  @override
  State<EducationCategoryScreen> createState() => _EducationCategoryScreenState();
}

class _EducationCategoryScreenState extends State<EducationCategoryScreen> {
  final Color primary = const Color(0xFF113F67);
  final Color background = const Color(0xFFE7EAF6);

  // ignore: prefer_final_fields
  int _selectedIndex = 1; 

  final List<Map<String, dynamic>> categories = const [
    {'title': 'تعلم الاحرف', 'text': 'ض', 'isText': true},
    {'title': 'تعلم الارقام', 'text': '٧', 'isText': true},
    {'title': 'تعلم بنفسك', 'icon': Icons.menu_book, 'isIcon': true},
    {'title': 'اختبر نفسك', 'icon': Icons.quiz, 'isIcon': true},
  ];

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
        MaterialPageRoute(builder: (_) => const ArticlesPage()),
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
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: primary,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false, 
          title: const Text(
            'الدروس التعليمية',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: categories.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 30,
                        crossAxisSpacing: 20,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final category = categories[index];

                        Widget visual;
                        if (category['isText'] == true) {
                          visual = Text(
                            category['text'],
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          );
                        } else if (category['isIcon'] == true) {
                          visual = Icon(
                            category['icon'],
                            color: primary,
                            size: 48,
                          );
                        } else {
                          visual = const SizedBox.shrink();
                        }

                        return GestureDetector(
                          onTap: () {
                            if (category['title'] == 'تعلم الاحرف') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const LettersScreen()),
                              );
                            } else if (category['title'] == 'تعلم الارقام') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const NumbersScreen()),
                              );
                            } else if (category['title'] == 'تعلم بنفسك') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const NameToSignScreen()),
                              );
                            }
                            else if (category['title'] == 'اختبر نفسك') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ChatPage()),
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              border: Border.all(color: primary, width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                visual,
                                const SizedBox(height: 10),
                                Text(
                                  category['title'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      child: Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF5F5F5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Image.asset('assets/logo.png'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: CustomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}