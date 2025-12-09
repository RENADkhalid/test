import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'play_withlaweh.dart'; // Correct import
// ignore: unused_import
import 'homepage.dart'; // Assuming you have this file

// ignore: use_key_in_widget_constructors
class MemoryMatchGameScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _MemoryMatchGameScreenState createState() => _MemoryMatchGameScreenState();
}

class _MemoryMatchGameScreenState extends State<MemoryMatchGameScreen> {
  final List<String> _allArabicLetters = [
    "أ", "ب", "ت", "ث", "ج", "ح", "خ", "د", "ذ", "ر",
    "ز", "س", "ش", "ص", "ض", "ط", "ظ", "ع", "غ", "ف",
    "ق", "ك", "ل", "م", "ن", "ه", "و", "ي"
  ];

  List<String> _shuffledCards = [];
  List<bool> _cardFlips = [];
  List<int> _flippedIndexes = [];
  int _matchCount = 0;
  bool _canFlip = true;

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 2));
    _startNewGame();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _startNewGame() {
    // ignore: unused_local_variable
    final random = Random();
    List<String> selectedLetters = List.from(_allArabicLetters)..shuffle();
    selectedLetters = selectedLetters.take(4).toList();

    List<String> pairs = [];
    for (var letter in selectedLetters) {
      pairs.add(letter);
      pairs.add("assets/signs/signs/$letter.jpg");
    }

    pairs.shuffle();

    setState(() {
      _shuffledCards = pairs;
      _cardFlips = List.filled(pairs.length, false);
      _flippedIndexes = [];
      _matchCount = 0;
      _canFlip = true;
    });
  }

  void _flipCard(int index) {
    if (!_canFlip || _cardFlips[index]) return;

    setState(() {
      _cardFlips[index] = true;
      _flippedIndexes.add(index);
    });

    if (_flippedIndexes.length == 2) {
      _canFlip = false;

      final first = _shuffledCards[_flippedIndexes[0]];
      final second = _shuffledCards[_flippedIndexes[1]];

      bool isMatch = false;

      if (first.contains('assets') && !second.contains('assets')) {
        isMatch = first.contains(second);
      } else if (!first.contains('assets') && second.contains('assets')) {
        isMatch = second.contains(first);
      }

      if (isMatch) {
        setState(() {
          _matchCount++;
          _flippedIndexes.clear();
          _canFlip = true;
        });

        if (_matchCount == 4) {
          _confettiController.play();
          Future.delayed(Duration(milliseconds: 600), () => _showGameOverDialog());
        }
      } else {
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _cardFlips[_flippedIndexes[0]] = false;
            _cardFlips[_flippedIndexes[1]] = false;
            _flippedIndexes.clear();
            _canFlip = true;
          });
        });
      }
    }
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xFF38598B),
        title: Text("🎉 أحسنت!", style: TextStyle(color: Colors.white)),
        content: Text("أنهيت اللعبة بنجاح! 🎊", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startNewGame();
            },
            child: Text("🔁 العب مجدداً", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => PlayWithLaweh()),
              );
            },
            child: Text("🔙 العودة إلى القائمة الرئيسية", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Color(0xFF38598B),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: Icon(Icons.arrow_forward, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => PlayWithLaweh()),
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    "طابق الحرف مع إشارته",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    itemCount: _shuffledCards.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _flipCard(index),
                        child: Card(
                          color: Color(0xFFE7EAF6),
                          child: Center(
                            child: _buildCardContent(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: [Colors.white, Colors.amber, Colors.redAccent, Colors.green],
          ),
        ),
      ],
    );
  }

  Widget _buildCardContent(int index) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: _cardFlips[index]
          ? (_shuffledCards[index].contains("assets")
              ? Image.asset(_shuffledCards[index])
              : Text(
                  _shuffledCards[index],
                  style: TextStyle(fontSize: 24, color: Colors.black),
                ))
          : Image.asset('assets/logo.png'),
    );
  }
}
