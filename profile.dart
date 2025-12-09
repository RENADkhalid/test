import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'update_profile.dart';
import 'about.dart';
import 'privacy.dart';
import 'custom_navbar.dart';
import 'homepage.dart';
import 'translation_page.dart';
import 'chat_page.dart';
import 'education_category.dart';
import 'welcome.dart';
import 'login_page.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  int _selectedIndex = 4;

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const EducationCategoryScreen()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TranslationScreen()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ChatPage()));
        break;
      case 4:
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.topRight,
                    child: Image.asset('assets/logo.png', height: 80),
                  ),

                  const SizedBox(height: 30),

                  // 🔵 مربع إعدادات الحساب
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Column(
                          children: [
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('UserAccount')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.grey,
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
                                  return const CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.grey,
                                    child: Icon(Icons.error),
                                  );
                                }

                                final data = snapshot.data!.data() as Map<String, dynamic>;
                                final avatarUrl = data['customAvatar'];

                                return CircleAvatar(
                                  radius: 40,
                                  backgroundImage: avatarUrl != null
                                      ? (avatarUrl.startsWith('assets/')
                                      ? AssetImage(avatarUrl)
                                      : NetworkImage(avatarUrl)) as ImageProvider
                                      : const AssetImage('assets/default.png'),
                                  backgroundColor: Colors.grey[200],
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'إعدادات الحساب',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E2F56),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        _buildListTile(
                          icon: Icons.edit,
                          title: 'حسابي',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const UpdateProfile()),
                            ).then((_) => setState(() {}));
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔵 مربع الدعم
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'الدعم',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E2F56),
                          ),
                        ),

                        const SizedBox(height: 10),

                        _buildListTile(
                          icon: Icons.info_outline,
                          title: 'عن التطبيق',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
                          },
                        ),

                        _buildListTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'سياسة الخصوصية',
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()));
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🔵 أزرار الحذف والخروج
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionButton(
                        text: 'حذف الحساب',
                        icon: Icons.delete_forever,
                        background: const Color(0xFFD9D9F1),
                        textColor: Colors.black,
                        onTap: _handleDeleteAccount,
                      ),
                      _buildActionButton(
                        text: 'تسجيل الخروج',
                        icon: Icons.logout,
                        background: const Color(0xFF11375B),
                        textColor: Colors.white,
                        onTap: _handleLogout,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
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

  Widget _buildListTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      color: const Color(0xFFF1F3FA),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1E2F56)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color background,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      icon: Icon(icon, color: textColor),
      label: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
    );
  }

  void _handleDeleteAccount() async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(child: const Text('إلغاء'), onPressed: () => Navigator.pop(context, false)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      try {
        await FirebaseAuth.instance.currentUser?.delete();
        if (!context.mounted) return;

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WelcomePage()));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف الحساب')));
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
      }
    }
  }

  void _handleLogout() async {
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد تسجيل الخروج'),
        content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(child: const Text('إلغاء'), onPressed: () => Navigator.pop(context, false)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('تسجيل الخروج'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmLogout == true) {
      try {
        await FirebaseAuth.instance.signOut();
        if (!context.mounted) return;

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل الخروج')));
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
      }
    }
  }
}
