import 'package:flutter/material.dart';
import 'quiz_service_with_images.dart';
import 'result_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final QuizService _quizService = QuizService();
  final List<Map<String, String>> _chat = [];

  @override
  void initState() {
    super.initState();
    _quizService.fetchQuestions().then((_) {
      if (_quizService.totalQuestions > 0) {
        _loadQuestion();
      }
    });
  }

  void _loadQuestion() {
    final q = _quizService.getCurrentQuestion();
    setState(() {
      _chat.add({'bot': q['question']});
    });
  }

  void _handleAnswer(String selectedOption) {
    final isCorrect = _quizService.checkAnswer(selectedOption);
    _quizService.selectAnswer(selectedOption);

    setState(() {
      _chat.add({'user': selectedOption});
      _chat.add({
        'bot': isCorrect ? '✅ إجابة صحيحة' : '❌ إجابة خاطئة',
      });
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (_quizService.nextQuestion()) {
        _loadQuestion();
      } else {
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (_) => ResultPage(
              score: _quizService.correctAnswersCount,
              total: _quizService.totalQuestions,
              answers: _quizService.answers,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_quizService.totalQuestions == 0) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentQ = _quizService.getCurrentQuestion();
    final List<String> options = List<String>.from(currentQ['options']);
    final imagePath = currentQ['image'];

    return Scaffold(
      backgroundColor: const Color(0xFFE7EAF6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF113F67),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward,
                color: Colors.white), // ✅ سهم يمين بلون أبيض
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
        title: const Text(
          'اختبر فهمك للغة الإشارة',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _chat.length,
              itemBuilder: (context, index) {
                final message = _chat[index];
                final isBot = message.containsKey('bot');
                final content = message[isBot ? 'bot' : 'user']!;
                return Align(
                  alignment:
                      isBot ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isBot ? Colors.white : const Color(0xFF38598B),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: content.startsWith('http')
                        ? Image.network(content, height: 120)
                        : Text(
                            content,
                            style: TextStyle(
                              color: isBot ? Colors.black : Colors.white,
                              fontFamily: 'Tajawal',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
          if (imagePath != null && imagePath.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Image.network(imagePath, height: 160),
            ),
          const Divider(),
          if (currentQ['selected'] == null)
            Column(
              children: options.map((option) {
                final isImage = option.startsWith('http');
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF113F67),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    onPressed: () => _handleAnswer(option),
                    child: isImage
                        ? Image.network(option, height: 50)
                        : Text(
                            option,
                            style: const TextStyle(
                                fontSize: 18, fontFamily: 'Tajawal'),
                          ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
