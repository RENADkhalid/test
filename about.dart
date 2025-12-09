import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Features section
// Features section
// Features section
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xEDEFF3FF),
        appBar: AppBar(
          backgroundColor: const Color(0xFFB5BEE0),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'عن التطبيق',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header and logo
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB5BEE0),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Image(
                      image: AssetImage('assets/logo.png'),
                      height: 100,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // About section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'عن التطبيق',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.indigo,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'يقدم تطبيقنا تجربة شاملة لتعلم الحروف والأرقام بلغة الإشارة العربية، مدعومة بترجمة فورية ومقالات تثقيفية لتعزيز الفهم والتواصل. من خلال دروس تفاعلية وتمارين عملية، نساعد المستخدمين على إتقان الإشارات بسهولة، مما يجعل التعلم ممتعًا وفعّالًا للجميع.',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Features section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المميزات',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.indigo,
                        ),
                      ),
                      SizedBox(height: 20),
                      FeatureRow(
                        icon: FontAwesomeIcons.handsAslInterpreting,
                        text: 'ترجمة حروف لغة الاشارة العربية',
                      ),
                      SizedBox(height: 12),
                      FeatureRow(
                        icon: FontAwesomeIcons.graduationCap,
                        text: 'دروس تعليمية',
                      ),
                      SizedBox(height: 12),
                      FeatureRow(
                        icon: FontAwesomeIcons.solidHeart,
                        text: 'حفظ المفضلة',
                      ),
                      SizedBox(height: 12),
                      FeatureRow(
                        icon: FontAwesomeIcons.bullseye,
                        text: 'اختبارات',
                      ),
                      SizedBox(height: 12),
                      FeatureRow(
                        icon: FontAwesomeIcons.newspaper,
                        text: 'مقالات تثقيفية',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Contact section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'تواصل معنا',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.indigo,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.email, color: Colors.indigo),
                          SizedBox(width: 10),
                          Text(
                            'contactlaweh@gmail.com',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureRow({
    super.key,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FaIcon(icon, color: Colors.indigo),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
