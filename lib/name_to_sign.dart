import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: NameToSignScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class NameToSignScreen extends StatefulWidget {
  const NameToSignScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NameToSignScreenState createState() => _NameToSignScreenState();
}

class _NameToSignScreenState extends State<NameToSignScreen> {
  String name = '';

  final arabicCharacters = [
    'ا', 'ب', 'ت', 'ث', 'ج', 'ح', 'خ', 'د', 'ذ', 'ر', 'ز', 'س', 'ش', 'ص', 'ض',
    'ط', 'ظ', 'ع', 'غ', 'ف', 'ق', 'ك', 'ل', 'م', 'ن', 'ه', 'و', 'ي', 'ى', 'ة',
    'أ', 'آ', 'إ', 'ؤ', 'ئ', 'ء',
  ];

  String getAssetPath(String letter) {
    return 'assets/signs/signs/$letter.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Color(0xFFE7EAF6), 
       appBar: AppBar(
  backgroundColor: const Color.fromARGB(255, 95, 129, 174),
  centerTitle: true,
  title: const Text(
    'تعلم بنفسك',
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
      Navigator.pop(context);  
    },
  ),
),

        body: Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const SizedBox(height: 30), 
      const Text(
        'استكشف كيف تمثل حروف لغة الإشارة العربية',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 20),
      TextField(
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          labelText: 'اكتب الحرف باللغة بالعربية',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0), 
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: (val) {
          setState(() {
            name = val.trim();
          });
        },
      ),
      const SizedBox(height: 20),
      if (name.isNotEmpty) ...[
        const Text(
          'التمثيل بلغة الإشارة:',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: name.length,
            itemBuilder: (context, index) {
              final letter = name[index];
              final assetPath = getAssetPath(letter);
              return Column(
                children: [
                  Expanded(
                    child: Image.asset(
                      assetPath,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Text(
                              '?',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(letter, style: TextStyle(fontSize: 16)),
                ],
              );
            },
          ),
        ),
      ],
    ],
  ),
),
      ),
    );
  }
}