import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:laweh_app/education_category.dart';
import 'package:laweh_app/name_to_sign.dart';

class LettersScreen extends StatefulWidget {
  const LettersScreen({super.key});

  @override
  State<LettersScreen> createState() => _LettersScreenState();
}

class _LettersScreenState extends State<LettersScreen> {
  static const String kOrderField = 'lettrrorder';

  List<DocumentSnapshot<Map<String, dynamic>>> _allLetters = [];
  List<DocumentSnapshot<Map<String, dynamic>>> _filtered = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadLetters();
  }

  Future<void> _loadLetters() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('Education-letters')
          .orderBy(kOrderField)
          .get();

      setState(() {
        _allLetters = snapshot.docs;
        _filtered = List.of(_allLetters);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void _onSearch(String q) {
    setState(() {
      _query = q.trim();
      if (_query.isEmpty) {
        _filtered = List.of(_allLetters);
      } else {
        final lower = _query.toLowerCase();
        _filtered = _allLetters.where((d) {
          final data = d.data() ?? {};
          final letter = (data['letter'] ?? '').toString();
          return letter.toLowerCase().contains(lower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFE9ECF7),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_allLetters.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFFE9ECF7),
        body: Center(child: Text('لا توجد حروف حالياً')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE9ECF7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF153C64),
        centerTitle: true,
        title: const Text('قائمة الحروف', style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: TextField(
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: 'ابحث عن حرف…',
                  hintTextDirection: TextDirection.rtl,
                  suffixIcon: const Icon(Icons.search),
                  suffixIconConstraints: const BoxConstraints(minWidth: 40),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _filtered.isEmpty
                  ? const Center(child: Text('لا توجد نتائج مطابقة'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final data = _filtered[i].data() ?? {};
                        final letter = (data['letter'] ?? '').toString();
                        final imgUrl = (data['imgletter'] ?? '').toString();
                        final fullIndex = _allLetters.indexWhere(
                          (d) => d.id == _filtered[i].id,
                        );
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LetterDetailScreen(
                                  letters: _allLetters,
                                  initialIndex: fullIndex < 0 ? 0 : fullIndex,
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      letter,
                                      textDirection: TextDirection.rtl,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF153C64),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: imgUrl.isEmpty
                                      ? Container(
                                          width: 64,
                                          height: 64,
                                          color: const Color(0xFFE9ECF7),
                                          child: const Icon(Icons.image,
                                              color: Colors.grey),
                                        )
                                      : Image.network(
                                          imgUrl,
                                          width: 64,
                                          height: 64,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const SizedBox(
                                            width: 64,
                                            height: 64,
                                            child: Icon(
                                              Icons.image_not_supported,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class LetterDetailScreen extends StatefulWidget {
  final List<DocumentSnapshot<Map<String, dynamic>>> letters;
  final int initialIndex;

  const LetterDetailScreen({
    super.key,
    required this.letters,
    required this.initialIndex,
  });

  @override
  State<LetterDetailScreen> createState() => _LetterDetailScreenState();
}

class _LetterDetailScreenState extends State<LetterDetailScreen> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex.clamp(0, widget.letters.length - 1);
  }

  void _next(BuildContext context) {
    if (currentIndex < widget.letters.length - 1) {
      setState(() => currentIndex++);
    } else {
      _showLessonCompleteDialog(context);
    }
  }

  void _prev() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
    }
  }

  void _showLessonCompleteDialog(BuildContext context) {
    final confetti = ConfettiController(duration: const Duration(seconds: 3));
    confetti.play();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Stack(
        alignment: Alignment.topCenter,
        children: [
          Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: const Color(0xFFE9ECF7),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'الدرس مكتمل',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF113F67),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF153C64),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      confetti.stop();
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EducationCategoryScreen()),
                      );
                    },
                    child: const Text(
                      'العودة لصفحة الدروس',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      confetti.stop();
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NameToSignScreen()),
                      );
                    },
                    child: const Text(
                      'جرب كتابة اسمك',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -20,
            child: ConfettiWidget(
              confettiController: confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              emissionFrequency: 0.1,
              numberOfParticles: 10,
              maxBlastForce: 8,
              minBlastForce: 4,
              gravity: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.letters[currentIndex].data() ?? {};
    final imageUrl = (doc['imgletter'] ?? '').toString();
    final label = (doc['letter'] ?? '').toString();

    return Scaffold(
      backgroundColor: const Color(0xFFE9ECF7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (currentIndex + 1) / widget.letters.length,
                      backgroundColor: Colors.grey.shade400,
                      valueColor: const AlwaysStoppedAnimation(Colors.green),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward,
                        size: 28, color: Color(0xFF153C64)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: imageUrl.isEmpty
                            ? const SizedBox(
                                height: 300,
                                child: Center(child: Icon(Icons.image, size: 48)),
                              )
                            : Image.network(
                                imageUrl,
                                height: 300,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const SizedBox(
                                  height: 300,
                                  child: Center(
                                      child: Icon(Icons.image_not_supported)),
                                ),
                              ),
                      ),
                      const SizedBox(height: 36),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            label,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 64),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF153C64),
                            radius: 28,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () => _next(context),
                            ),
                          ),
                          if (currentIndex > 0)
                            CircleAvatar(
                              backgroundColor: const Color(0xFF153C64),
                              radius: 28,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_forward,
                                    color: Colors.white),
                                onPressed: _prev,
                              ),
                            ),
                        ],
                      ),
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
}
