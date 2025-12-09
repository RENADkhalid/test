import 'package:flutter/material.dart';
import 'profile.dart';

void main() => runApp(const MaterialApp(home: PrivacyPolicyPage(), debugShowCheckedModeBanner: false));

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFEFF1FA),
        body: SafeArea(
          child: Column(
            children: [
           
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7D94C2), Color(0xFFB1C0E2)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color.from(alpha: 1, red: 0.008, green: 0.008, blue: 0.008)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AccountSettingsPage()),
                            );
                          },
                        ),
                        Image.asset('assets/logo.png', height: 50),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'سياسة الخصوصية',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'شكراً لاستخدامك تطبيقنا. نحن نهتم بخصوصيتك\nونلتزم بحماية بياناتك الشخصية.',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

      
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      _buildPrivacyCard(
                        title: 'جمع المعلومات',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('نحن نجمع المعلومات التي تقدمها عند استخدام التطبيق، بما في ذلك:'),
                            const SizedBox(height: 12),
                            _buildBulletPoint('معلومات التسجيل'),
                            _buildBulletPoint('يتطلب التطبيق الوصول إلى الكاميرا لأغراض الترجمة وتحليل إشارات لغة الإشارة. لا نقوم بتخزين أو مشاركة أي صور أو فيديوهات مأخوذة من الكاميرا'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildPrivacyCard(
                        title: 'حماية المعلومات',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('نحن نتخذ إجراءات أمنية لحماية معلوماتك، بما في ذلك:'),
                            const SizedBox(height: 12),
                            _buildBulletPoint('التشفير'),
                            _buildBulletPoint('التخزين الآمن'),
                            _buildBulletPoint('الوصول المحدود'),
                            _buildBulletPoint('المراقبة المستمرة'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildPrivacyCard(
                        title: 'حقوقك',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('لديك الحق في:'),
                            const SizedBox(height: 12),
                            _buildBulletPoint('الوصول إلى بياناتك'),
                            _buildBulletPoint('تصحيح بياناتك'),
                            _buildBulletPoint('حذف بياناتك'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyCard({required String title, required Widget content}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF143E64),
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 3, right: 8),
            child: Text('•', style: TextStyle(fontSize: 16)),
          ),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}