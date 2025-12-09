import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile.dart';

void main() {
  runApp(MyApp());
}

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  bool _obscurePassword = true;
  bool _isEditingName = false;
  bool _isEditingEmail = false;
  bool _isEditingPassword = false;
  bool _isEditingAvatar = false;
  bool _isSaving = false;
  String? _avatarUrl;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('UserAccount')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _nameController.text = data['Name'] ?? '';
          _emailController.text = user.email ?? '';
          _passwordController.text = '';
          _avatarUrl = data['customAvatar'];
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<String?> _showPasswordDialog() async {
    String password = '';
    return await showDialog<String>( 
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("أدخل كلمة المرور لتأكيد التغيير"),
          content: TextField(
            obscureText: true,
            decoration: const InputDecoration(labelText: "كلمة المرور"),
            onChanged: (value) => password = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, password),
              child: const Text("تأكيد"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _isSaving = false);
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    setState(() => _isSaving = true);
    final userDoc = FirebaseFirestore.instance.collection('UserAccount').doc(currentUser.uid);

    try {
      if (_isEditingName) {
        await userDoc.update({'Name': _nameController.text.trim()});
      }

      if (_isEditingEmail && _emailController.text.trim() != currentUser.email) {
        final password = await _showPasswordDialog();
        if (password == null) {
          setState(() => _isSaving = false);
          return;
        }

        final cred = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: password,
        );
        await currentUser.reauthenticateWithCredential(cred);
        await currentUser.verifyBeforeUpdateEmail(_emailController.text.trim());
        await userDoc.update({'email': _emailController.text.trim()});
      }

      if (_isEditingPassword && _passwordController.text.isNotEmpty) {
        final password = await _showPasswordDialog();
        if (password == null) {
          setState(() => _isSaving = false);
          return;
        }

        final cred = EmailAuthProvider.credential(
          email: currentUser.email!,
          password: password,
        );
        await currentUser.reauthenticateWithCredential(cred);
        await currentUser.updatePassword(_passwordController.text);
      }

      if (_isEditingAvatar) {
        await userDoc.update({'customAvatar': _avatarUrl});
      }

      showMessage("✅ تم تحديث المعلومات بنجاح.");
      setState(() {
        _isEditingName = false;
        _isEditingEmail = false;
        _isEditingPassword = false;
        _isEditingAvatar = false;
      });
    } on FirebaseAuthException catch (e) {
      showMessage("❌ خطأ: ${e.message ?? "حدث خطأ غير متوقع"}");
    } catch (e) {
      showMessage("❌ حدث خطأ أثناء الحفظ: $e");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  bool get _showAnyEdit =>
    _isEditingName || _isEditingEmail || _isEditingPassword || _isEditingAvatar;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFEFF0FA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFEFF0FA),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'تعديل الملف الشخصي',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF113F67),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF113F67)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AccountSettingsPage()),
              );
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Image.asset('assets/logo.png', height: 80),
                ),
                const SizedBox(height: 10),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 55,
                      backgroundColor: const Color(0xFFE0E0E0),
                      backgroundImage: _avatarUrl != null
                          ? (_avatarUrl!.startsWith('assets/')
                              ? AssetImage(_avatarUrl!)
                              : NetworkImage(_avatarUrl!)) as ImageProvider
                              : const AssetImage('assets/avatars/avatar0.png'),
                    
                      child: _avatarUrl == null
                          ? const Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                    if (!_isEditingAvatar)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.edit, color: Color.fromARGB(255, 10, 43, 70)),
                          ),
                          onPressed: () {
                            setState(() => _isEditingAvatar = true);
                          },
                        ),
                      ),
                  ],
                ),
                if (_isEditingAvatar) ...[
                  const SizedBox(height: 20),
                  const Text('اختر صورة رمزية:'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 11,
                      itemBuilder: (context, index) {
                        final path = 'assets/avatars/avatar$index.png';
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _avatarUrl = path;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: CircleAvatar(
                              radius: 35,
                              backgroundImage: AssetImage(path),
                              backgroundColor: Colors.grey[200],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                ],
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Text(
                          'المعلومات الشخصية',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildEditableField('الاسم', _nameController, _isEditingName, () {
                        setState(() => _isEditingName = !_isEditingName);
                      }),
                      const SizedBox(height: 16),
                      _buildEditableField('البريد الالكتروني', _emailController, _isEditingEmail, () {
                        setState(() => _isEditingEmail = !_isEditingEmail);
                      }),
                      const SizedBox(height: 16),
                      _buildEditableField('كلمة المرور', _passwordController, _isEditingPassword, () {
                        setState(() {
                          _isEditingPassword = !_isEditingPassword;
                          if (_isEditingPassword) {
                            _passwordController.clear();
                            _confirmPasswordController.clear();
                          }
                        });
                      }, obscure: true),
                      if (_isEditingPassword) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'تأكيد كلمة المرور',
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (value) {
                            if (_isEditingPassword && value != _passwordController.text) {
                              return 'كلمة المرور غير متطابقة';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                if (_showAnyEdit || _isEditingAvatar) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38598B),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('حفظ', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving
                          ? null
                          : () {
                              setState(() {
                                _isEditingName = false;
                                _isEditingEmail = false;
                                _isEditingPassword = false;
                                _isEditingAvatar = false;
                              });
                              _loadUserData();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA2A8D3),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('الرجوع', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller,
    bool isEditing,
    VoidCallback onTap, {
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            IconButton(
              icon: Icon(isEditing ? Icons.check : Icons.edit),
              onPressed: onTap,
            ),
          ],
        ),
        TextFormField(
          controller: controller,
          readOnly: !isEditing,
          obscureText: obscure && _obscurePassword,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            suffixIcon: obscure
                ? IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  )
                : null,
          ),
          validator: (value) {
            if (isEditing) {
              if (label == 'الاسم' && (value == null || value.isEmpty)) {
                return 'الرجاء إدخال الاسم';
              }
              if (label == 'البريد الالكتروني' && (value == null || !value.contains('@'))) {
                return 'البريد الإلكتروني غير صالح';
              }
              if (label == 'كلمة المرور') {
                if (value == null || value.length < 8) return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                if (!RegExp(r'[A-Z]').hasMatch(value)) return 'يجب أن تحتوي على حرف كبير';
                if (!RegExp(r'[a-z]').hasMatch(value)) return 'يجب أن تحتوي على حرف صغير';
                if (!RegExp(r'\d').hasMatch(value)) return 'يجب أن تحتوي على رقم';
              }
            }
            return null;
          },
        ),
      ],
    );
  }
}