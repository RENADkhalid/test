import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:async';
import 'package:laweh_app/homepage.dart';

class CorrectMeApp extends StatefulWidget {
  const CorrectMeApp({super.key});

  @override
  State<CorrectMeApp> createState() => _CorrectMeAppState();
}

class _CorrectMeAppState extends State<CorrectMeApp> {
  bool _imageCaptured = false;
  bool _showCorrectionField = false;
  final String _detectedLetter = 'أ';
  late ConfettiController _confettiController;
  final TextEditingController _correctionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _correctionController.dispose();
    super.dispose();
  }

  void _resetAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _imageCaptured = false;
      _showCorrectionField = false;
      _correctionController.clear();
    });
  }

  void _onCorrect() {
    _confettiController.play();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: const Text('شكرًا لمساعدتك!'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    _resetAfterDelay();
  }

  void _onIncorrect() {
    setState(() {
      _showCorrectionField = true;
    });
  }

  void _submitCorrection() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        content: const Text('شكرًا لمحاولتك تحسين النموذج!'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
    _resetAfterDelay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FF),
 appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  automaticallyImplyLeading: false, 
  actions: [ 
    IconButton(
      icon: const Icon(Icons.arrow_forward, color: Colors.black), 
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      },
    ),
  ],
),


      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'صححني',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF3F3D56)),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'كن جزءاً في تحسين النموذج',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _imageCaptured
                            ? Image.asset('assets/thumb.png', height: 200)
                            : Icon(Icons.camera_alt, size: 100, color: Colors.grey[400]),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _imageCaptured = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 159, 165, 228),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                          child: const Text(
                            'التقاط صورة',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (_imageCaptured) _buildPredictionCard(),
                  const SizedBox(height: 30),
                  if (!_imageCaptured) _buildInstructions(),
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
              colors: [Colors.green, Colors.blue, Colors.purple, Colors.pink],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          const Text('الحرف المتوقع:', style: TextStyle(fontSize: 18, color: Colors.black54)),
          const SizedBox(height: 10),
          Text(
            _detectedLetter,
            style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _onIncorrect,
                icon: const Icon(Icons.close),
                label: const Text('خاطئ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _onCorrect,
                icon: const Icon(Icons.check),
                label: const Text('صحيح'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          if (_showCorrectionField) ...[
            const SizedBox(height: 20),
            TextField(
              controller: _correctionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'اكتب الحرف الصحيح هنا',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitCorrection,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
              child: const Text('إرسال'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: const Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'طريقة الاستخدام:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3F3D56)),
            ),
            SizedBox(height: 10),
            Text('1. اضغط على زر "التقاط صورة".'),
            Text('2. انتظر حتى يتعرف النموذج على الحرف.'),
            Text('3. اختر إذا كان الحرف صحيحاً أو خاطئاً.'),
            Text('4. إذا كان خاطئاً، ساعدنا بكتابة الحرف الصحيح.'),
          ],
        ),
      ),
    );
  }
}
