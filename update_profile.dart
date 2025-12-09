import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('UserAccount')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      nameController.text = doc['Name'] ?? '';
    }
  }

  Future<void> _update() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("الرجاء إدخال الاسم")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await user.updateDisplayName(nameController.text.trim());
      await FirebaseFirestore.instance
          .collection('UserAccount')
          .doc(user.uid)
          .update({
        'Name': nameController.text.trim(),
      });

      if (!mounted) return;
      Navigator.pop(context); // العودة للبروفايل

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ: $e")),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1FA),
      appBar: AppBar(
        title: const Text(
          "تعديل الحساب",
          style: TextStyle(fontFamily: "Tajawal", color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F2D52),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: "اسم المستخدم",
                labelStyle: const TextStyle(fontFamily: "Tajawal"),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isLoading ? null : _update,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F2D52),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                "حفظ التعديلات",
                style: TextStyle(
                  fontFamily: "Tajawal",
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
