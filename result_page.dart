import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';

class ResultPage extends StatelessWidget {
  final int score;
  final int total;
  final List<Map<String, dynamic>> answers;

  const ResultPage({
    super.key,
    required this.score,
    required this.total,
    required this.answers,
  });

  @override
  Widget build(BuildContext context) {
    final bool passed = score >= (total * 0.8).round();

   
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FirebaseFirestore.instance.collection('chatbotQuizResults').add({
        'score': score,
        'total': total,
        'answers': answers,
        'created_at': Timestamp.now(),
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFFE9ECF7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: passed
                    ? Colors.green
                    : const Color.fromARGB(255, 249, 140, 133),
              ),
              child: Center(
                child: Icon(
                  passed ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 100,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              passed ? '🎉 !تهانينا، لقد نجحت' : '😢  !لم تنجح، حاول مرة أخرى',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Tajawal',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'النتيجة: $score من $total',
              style: const TextStyle(fontSize: 18, fontFamily: 'Tajawal'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F2D52),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'العودة',
                style: TextStyle(fontSize: 16, fontFamily: 'Tajawal'),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0F2D52),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontSize: 16, fontFamily: 'Tajawal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
