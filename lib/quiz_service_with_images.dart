// ignore: file_names



import 'package:cloud_firestore/cloud_firestore.dart';


class QuizService {
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int correctAnswersCount = 0;
  final List<Map<String, dynamic>> answers = [];
Future<void> fetchQuestions() async {
  try {
    final snapshot = await FirebaseFirestore.instance.collection('chatQ').get();

    final allQuestions = snapshot.docs
        .map((doc) => doc.data())
        .where((q) =>
            q.containsKey('question') &&
            q.containsKey('correctAnswer') &&
            q.containsKey('options'))
        .toList();

    allQuestions.shuffle(); // خلط الأسئلة
    _questions = allQuestions.take(5).toList(); // أخذ 5 أسئلة فقط
  } catch (e) {
    // ignore: avoid_print
    print('حدث خطأ أثناء تحميل الأسئلة: $e');
    _questions = [];
  }
}


  Map<String, dynamic> getCurrentQuestion() => _questions[_currentIndex];
  int get totalQuestions => _questions.length;

  bool checkAnswer(String answer) {
    return getCurrentQuestion()['correctAnswer'] == answer;
  }

  void selectAnswer(String answer) {
    final current = getCurrentQuestion();
    final isCorrect = checkAnswer(answer);
    answers.add({
      'question': current['question'],
      'selected': answer,
      'correct': isCorrect,
    });
    if (isCorrect) correctAnswersCount++;
  }

  bool nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      return true;
    }
    return false;
  }
}
