import 'package:flutter/material.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'play_withlaweh.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MyApp());
}

// ignore: use_key_in_widget_constructors
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: Locale('ar', 'AE'),
      supportedLocales: [
        Locale('ar', 'AE'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      home: WordBuilderGame(),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
    );
  }
}

// ignore: use_key_in_widget_constructors
class WordBuilderGame extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _WordBuilderGameState createState() => _WordBuilderGameState();
}

class _WordBuilderGameState extends State<WordBuilderGame> {
  final List<String> _words = [
    "بيت", "قلم", "شمس", "كتاب", "علم", "نجم", "باب", "جمل",
    "طفل", "دجاج", "قلب", "قوس", "أسد", "سقف", "قمر", "غزال",
    "سفر", "حبر", "بحر"
  ];

  final Map<String, String> letterImages = {
    'ا': 'assets/signs/signs/ا.jpg',
    'أ': 'assets/signs/signs/أ.jpg',
    'ب': 'assets/signs/signs/ب.jpg',
    'ت': 'assets/signs/signs/ت.jpg',
    'ث': 'assets/signs/signs/ث.jpg',
    'ج': 'assets/signs/signs/ج.jpg',
    'ح': 'assets/signs/signs/ح.jpg',
    'خ': 'assets/signs/signs/خ.jpg',
    'د': 'assets/signs/signs/د.jpg',
    'ذ': 'assets/signs/signs/ذ.jpg',
    'ر': 'assets/signs/signs/ر.jpg',
    'ز': 'assets/signs/signs/ز.jpg',
    'س': 'assets/signs/signs/س.jpg',
    'ش': 'assets/signs/signs/ش.jpg',
    'ص': 'assets/signs/signs/ص.jpg',
    'ض': 'assets/signs/signs/ض.jpg',
    'ط': 'assets/signs/signs/ط.jpg',
    'ظ': 'assets/signs/signs/ظ.jpg',
    'ع': 'assets/signs/signs/ع.jpg',
    'غ': 'assets/signs/signs/غ.jpg',
    'ف': 'assets/signs/signs/ف.jpg',
    'ق': 'assets/signs/signs/ق.jpg',
    'ك': 'assets/signs/signs/ك.jpg',
    'ل': 'assets/signs/signs/ل.jpg',
    'م': 'assets/signs/signs/م.jpg',
    'ن': 'assets/signs/signs/ن.jpg',
    'ه': 'assets/signs/signs/ه.jpg',
    'و': 'assets/signs/signs/و.jpg',
    'ي': 'assets/signs/signs/ي.jpg',
    'ى': 'assets/signs/signs/ى.jpg',
    'ة': 'assets/signs/signs/ة.jpg',
    'ئ': 'assets/signs/signs/ئ.jpg',
    'ؤ': 'assets/signs/signs/ؤ.jpg',
    'لا': 'assets/signs/signs/لا.jpg',
  };

  String _currentWord = '';
  List<Map<String, String>> _availableLetters = [];
  List<Map<String, String>> _shuffledImages = [];
  List<String> _selectedLetters = [];
  List<bool> _letterUsed = [];

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _startNewRound();
  }

  void _startNewRound() {
    String word = _words[Random().nextInt(_words.length)];
    _currentWord = word;

    _availableLetters = word
        .split('')
        .map((letter) => {'letter': letter, 'image': letterImages[letter]!})
        .toList();
    
    _shuffledImages = List.from(_availableLetters);
    _shuffledImages.shuffle();

    _selectedLetters = List.generate(word.length, (index) => '');
    _letterUsed = List.generate(word.length, (index) => false);

    setState(() {});
  }

  void _onLetterSelected(int index, String letter) {
    int letterIndex = -1;
    for (int i = 0; i < _availableLetters.length; i++) {
      if (_availableLetters[i]['letter'] == letter && !_letterUsed[i]) {
        letterIndex = i;
        break;
      }
    }

    if (letterIndex != -1) {
      setState(() {
        _selectedLetters[index] = letter;
        _letterUsed[letterIndex] = true;
        _shuffledImages = _availableLetters
            .asMap()
            .entries
            .where((entry) => !_letterUsed[entry.key])
            .map((entry) => entry.value)
            .toList();
      });
    }
  }

  void _removeLetter(int index) {
    if (_selectedLetters[index].isNotEmpty) {
      String letter = _selectedLetters[index];
      int firstUnusedIndex = _availableLetters.indexWhere(
        (item) => item['letter'] == letter && !_letterUsed[_availableLetters.indexOf(item)]
      );

      if (firstUnusedIndex != -1) {
        setState(() {
          _selectedLetters[index] = '';
          _letterUsed[firstUnusedIndex] = false;
          _shuffledImages = _availableLetters
              .asMap()
              .entries
              .where((entry) => !_letterUsed[entry.key])
              .map((entry) => entry.value)
              .toList();
        });
      }
    }
  }

  void _checkAnswer() {
    if (_selectedLetters.contains('')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text("رتب حروف لغة الإشارة في الأماكن المناسبة"),
          ),
        ),
      );
    } else if (_selectedLetters.join() == _currentWord) {
      _confettiController.play();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text("أحسنت! إجابة صحيحة ✅"),
          ),
        ),
      );
      Future.delayed(Duration(seconds: 1), _startNewRound);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Text("إجابة غير صحيحة، حاول مرة أخرى ❌"),
          ),
        ),
      );
      setState(() {
        _selectedLetters = List.generate(_currentWord.length, (index) => '');
        _letterUsed = List.generate(_availableLetters.length, (index) => false);
        _shuffledImages = List.from(_availableLetters);
        _shuffledImages.shuffle();
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE7EAF6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => PlayWithLaweh()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
          
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'رتب حروف لغة الإشارة لتكوين الكلمة الصحيحة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF113F67),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 80),
            Text(
              _currentWord,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF113F67),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              children: _shuffledImages.map((item) {
                return Draggable<String>(
                  data: item['letter']!,
                  // ignore: sort_child_properties_last
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      item['image']!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  feedback: Material(
                    color: Colors.transparent,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        item['image']!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // ignore: sized_box_for_whitespace
                  childWhenDragging: Container(width: 80, height: 80),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_currentWord.length, (index) {
                return DragTarget<String>(
                  // ignore: deprecated_member_use
                  onAccept: (letter) => _onLetterSelected(index, letter),
                  // ignore: deprecated_member_use
                  onWillAccept: (data) => true,
                  onLeave: (data) {},
                  builder: (context, candidateData, rejectedData) {
                    return GestureDetector(
                      onTap: () => _removeLetter(index),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        width: 80,
                        height: 80,
                        margin: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: candidateData.isNotEmpty
                                ? Colors.blue
                                : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.grey[200],
                        ),
                        child: Center(
                          child: _selectedLetters[index] != ''
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.asset(
                                    letterImages[_selectedLetters[index]]!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            SizedBox(height: 80),
            ElevatedButton(
              onPressed: _checkAnswer,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                backgroundColor: Color(0xFF38598B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'تحقق من الإجابة',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ConfettiWidget(
        confettiController: _confettiController,
        blastDirectionality: BlastDirectionality.explosive,
        blastDirection: pi,
        shouldLoop: false,
        colors: [Colors.white, Colors.amber, Colors.redAccent, Colors.green],
      ),
    );
  }
}
