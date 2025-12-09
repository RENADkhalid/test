import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'package:laweh_app/homepage.dart';
import 'services/model_comparator.dart';

class CorrectMeApp extends StatefulWidget {
  const CorrectMeApp({super.key});

  @override
  State<CorrectMeApp> createState() => _CorrectMeAppState();
}

class _CorrectMeAppState extends State<CorrectMeApp> {
  bool isSignToArabic = true;

  Uint8List? _imageBytes;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();
  final TextEditingController _correctionController = TextEditingController();

  final FlutterTts _tts = FlutterTts();
  bool _speaking = false;

  double _fontSize = 18;
  bool _loadingOcr = false;

  late stt.SpeechToText _speech;
  bool _hasSpeech = false;
  bool _listening = false;

  Map<String, String> _signMap = {};
  bool _loadingMap = true;

  final ModelComparator _modelComparator = ModelComparator();

  bool _showTrainingUI = false;
  String? _currentPrediction;
  double? _currentConfidence;
  String? _actualLabel;
  bool _isTesting = false;

  late ConfettiController _confettiController;

  final Map<String, String> _classToArabic = const {
    'ain': 'ع',
    'aliph': 'ص',
    'bari yay': 'م',
    'bay': '',
    'chay': 'ك',
    'choti yay': 'ی',
    'daal': 'ر',
    'dal': 'ط',
    'fay': 'ت',
    'ghaf': 'ب',
    'ghain': 'ذ',
    'hamza': 'ظ',
    'hay': 'ت',
    'jeem': 'م',
    'kaaf': 'ظ',
    'khay': 'ت',
    'laam': 'ل',
    'meem': 'ح',
    'noon': 'ع',
    'pay': 'ط',
    'quaf': 'د',
    'ray': 'ب',
    'rrray': '',
    'say': 'ح',
    'seen': 'س',
    'sheen': 'ه',
    'swaad': 'ض',
    'tay': 'خ',
    'toyen': 'ط',
    'ttay': 'ف',
    'wow': 'و',
    'zaal': 'ن',
    'zay': 'ب',
    'zhe': 'ت',
    'zoyen': 'ز',
    'zwaad': 'ا',
  };

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));

    _initTts();
    _initSpeechToText();
    _loadSignMap();
    _modelComparator.loadModels();

    _textController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ar-SA');
    _tts.setStartHandler(() {
      setState(() => _speaking = true);
    });
    _tts.setCompletionHandler(() {
      setState(() => _speaking = false);
    });
    _tts.setCancelHandler(() {
      setState(() => _speaking = false);
    });
  }

  Future<void> _initSpeechToText() async {
    _speech = stt.SpeechToText();
    _hasSpeech = await _speech.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _loadSignMap() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('Education-letters')
          .orderBy('lettrrorder')
          .get();

      final map = <String, String>{};
      for (final d in snap.docs) {
        final data = d.data();
        final raw = (data['letter'] ?? '').toString().trim();
        final url = (data['imgletter'] ?? '').toString().trim();
        if (raw.isEmpty || url.isEmpty) continue;

        final key = _normalizeArabic(raw);
        map[key] = url;
        map.putIfAbsent(raw, () => url);
      }

      if (mounted) {
        setState(() {
          _signMap = map;
          _loadingMap = false;
        });
      }
    } catch (_) {
      if (mounted) {
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _resultController.dispose();
    _correctionController.dispose();
    _tts.stop();
    _speech.stop();
    _modelComparator.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _resetAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _showTrainingUI = false;
      _currentPrediction = null;
      _currentConfidence = null;
      _actualLabel = null;
      _correctionController.clear();
    });
  }

  Future<void> _toggleListen() async {
    if (!_hasSpeech) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الميزة غير متاحة على هذا الجهاز')),
      );
      return;
    }
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    setState(() => _listening = true);
    await _speech.listen(
      localeId: 'ar_SA',
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      onResult: (res) {
        setState(() {
          _textController.text = res.recognizedWords;
          _textController.selection = TextSelection.fromPosition(
            TextPosition(offset: _textController.text.length),
          );
        });
      },
    );
  }

  Future<void> _pickImage() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('المعرض'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('الكاميرا'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final ImagePicker picker = ImagePicker();
    final XFile? picked =
    await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _resultController.clear();
      _showTrainingUI = false;
      _currentPrediction = null;
      _currentConfidence = null;
    });

    await _processPickedImage();
  }

  Future<void> _processPickedImage() async {
    if (_imageBytes == null) return;

    setState(() {
      _loadingOcr = true;
    });

    try {
   
      final url = config.api;

      final base64Image = base64Encode(_imageBytes!);

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: base64Image,
      );

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

        final predsDynamic = data["predictions"];

        if (predsDynamic == null ||
            predsDynamic is! List ||
            predsDynamic.isEmpty) {
          setState(() {
            _resultController.text = 'لم يتم التعرف على أي حرف.';
          });
        } else {
          final List<Map<String, dynamic>> preds =
          predsDynamic.cast<Map<String, dynamic>>();

          // ترتيب من اليسار لليمين حسب X
          preds.sort((a, b) {
            final ax = (a['x'] as num?) ?? 0;
            final bx = (b['x'] as num?) ?? 0;
            return ax.compareTo(bx);
          });

          final letters = preds.map((p) {
            final label = (p['class'] ?? '').toString().trim();
            final arabic = _classToArabic[label] ?? label;
            print("LABEL: $label → $arabic");
            return arabic;
          }).join();

          setState(() {
            _resultController.text = letters;
          });
        }
      } else {
        setState(() {
          _resultController.text = 'خطأ أثناء الاتصال بالخادم.';
        });
      }
    } catch (e, s) {
      debugPrint('Error in _processPickedImage: $e');
      debugPrint(s.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء التعرف على الحرف.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingOcr = false;
        });
      }
    }
  }

  /// 🔥 هذه الدالة الآن تستخدم الـ API بدل YOLO لاختبار الحرف
  Future<void> _testSignLetter() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى التقاط صورة أولاً')),
      );
      return;
    }

    setState(() {
      _isTesting = true;
      _loadingOcr = true;
      _showTrainingUI = false;
      _currentPrediction = null;
      _currentConfidence = null;
    });

    try {
      const String apiKey = "FKdLA8yXAidNCuef7chM";
      const String modelId = "sign-language-detection-7cdpj";
      const int version = 2;

      final url =
          "https://detect.roboflow.com/$modelId/$version?api_key=$apiKey";

      final base64Image = base64Encode(_imageBytes!);

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: base64Image,
      );

      print("TEST STATUS: ${response.statusCode}");
      print("TEST BODY: ${response.body}");

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خطأ أثناء الاتصال بالخادم.')),
        );
        return;
      }

      final Map<String, dynamic> data =
      jsonDecode(response.body) as Map<String, dynamic>;

      final predsDynamic = data['predictions'];

      if (predsDynamic == null ||
          predsDynamic is! List ||
          predsDynamic.isEmpty) {
        setState(() {
          _currentPrediction = null;
          _showTrainingUI = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم التعرف على أي حرف.')),
        );
        return;
      }

      final List<Map<String, dynamic>> preds =
      predsDynamic.cast<Map<String, dynamic>>();

      // نأخذ أعلى ثقة
      preds.sort((a, b) {
        final ac = (a['confidence'] as num?) ?? 0;
        final bc = (b['confidence'] as num?) ?? 0;
        return bc.compareTo(ac); // أعلى أولاً
      });

      final best = preds.first;
      final label = (best['class'] ?? '').toString().trim();
      final conf = (best['confidence'] as num?)?.toDouble() ?? 0.0;
      final predictedLetter = _classToArabic[label] ?? label;

      setState(() {
        _currentPrediction = predictedLetter;
        _currentConfidence = conf;
        _showTrainingUI = true;
      });
    } catch (e, s) {
      debugPrint('Error in testing: $e');
      debugPrint(s.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء اختبار الحرف.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingOcr = false;
          _isTesting = false;
        });
      }
    }
  }

  Future<void> _handleUserFeedback(bool isCorrect) async {
    if (_currentPrediction == null || _imageBytes == null) return;

    final trainingData = {
      'prediction': _currentPrediction,
      'isCorrect': isCorrect,
      'actualLabel': isCorrect ? _currentPrediction : _actualLabel,
      'timestamp': DateTime.now().toIso8601String(),
      'userFeedback': isCorrect ? 'correct' : 'incorrect',
    };

    await _modelComparator.saveTrainingData(trainingData);

    final comparisonResult = await _modelComparator.comparePrediction(
      _imageBytes!,
      isCorrect ? 'correct' : 'incorrect',
    );

    debugPrint('Comparison result: $comparisonResult');
  }

  void _onUserConfirmedCorrect() async {
    await _handleUserFeedback(true);
    _confettiController.play();

    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('شكرًا لمساعدتك!'),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }

    _resetAfterDelay();
  }

  void _onUserIncorrect() {
    _showCorrectionDialog();
  }

  void _onUserSubmitIncorrect() async {
    if (_actualLabel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار الحرف الصحيح')),
      );
      return;
    }

    await _handleUserFeedback(false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text('شكرًا للتصحيح! سنحسن أداء التطبيق 📝'),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }

    _resetAfterDelay();
  }

  void _showCorrectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ما هو الحرف الصحيح؟'),
        content: DropdownButtonFormField<String>(
          items: _classToArabic.values.toSet().map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: const TextStyle(fontSize: 20)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _actualLabel = value);
          },
          decoration: const InputDecoration(
            labelText: 'اختر الحرف الصحيح',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              if (_actualLabel != null) {
                Navigator.pop(context);
                _onUserSubmitIncorrect();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('يرجى اختيار الحرف الصحيح')),
                );
              }
            },
            child: const Text('تأكيد التصحيح'),
          ),
        ],
      ),
    );
  }

  Future<void> _speak(String text) async {
    final t = text.trim();
    if (t.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد نص للنطق')),
      );
      return;
    }
    await _tts.setLanguage('ar-SA');
    await _tts.speak(t);
  }

  String _normalizeArabic(String s) {
    final diacritics = RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]');
    s = s.replaceAll(diacritics, '');
    s = s
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAll('ى', 'ي')
        .replaceAll('ة', 'ه');
    return s;
  }

  List<Widget> _buildSignFromText(String text) {
    if (_loadingMap) {
      return const [
        Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(),
        )
      ];
    }
    final widgets = <Widget>[];
    final norm = _normalizeArabic(text);
    for (int i = 0; i < norm.length; i++) {
      final ch = norm[i];
      if (ch.trim().isEmpty) {
        widgets.add(const SizedBox(width: 16));
        continue;
      }
      final url = _signMap[ch];
      if (url != null && url.isNotEmpty) {
        widgets.add(Padding(
          padding: const EdgeInsets.all(4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              url,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallbackBox(ch),
            ),
          ),
        ));
      } else {
        widgets.add(_fallbackBox(ch));
      }
    }
    if (widgets.isEmpty) {
      return const [Center(child: Text('ستظهر لغة الإشارة هنا'))];
    }
    return widgets;
  }

  Widget _fallbackBox(String ch) {
    return Container(
      width: 64,
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE9ECF7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCDD6E4)),
      ),
      child: Text(
        ch,
        style: const TextStyle(fontSize: 22, color: Color(0xFF153C64)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
                padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'صححني',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F3D56)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'كن جزءاً في تحسين النموذج',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    const SizedBox(height: 20),

                    isSignToArabic
                        ? _buildSignToArabicSection()
                        : _buildArabicToSignSection(),

                    const SizedBox(height: 24),

                    _buildInstructions(),
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
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.purple,
                  Colors.pink
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSwitcher() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isSignToArabic = true;
                  _imageBytes = null;
                  _resultController.clear();
                  _showTrainingUI = false;
                  _currentPrediction = null;
                  _currentConfidence = null;
                });
              },
              child: Container(
                padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSignToArabic
                      ? const Color(0xFF9FA5E4)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'لغة الإشارة → العربية',
                    style: TextStyle(
                      fontSize: 14,
                      color: isSignToArabic ? Colors.white : Colors.black54,
                      fontWeight: isSignToArabic
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isSignToArabic = false;
                  _imageBytes = null;
                  _resultController.clear();
                  _showTrainingUI = false;
                  _currentPrediction = null;
                  _currentConfidence = null;
                });
              },
              child: Container(
                padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: !isSignToArabic
                      ? const Color(0xFF9FA5E4)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    'العربية → لغة الإشارة',
                    style: TextStyle(
                      fontSize: 14,
                      color: !isSignToArabic ? Colors.white : Colors.black54,
                      fontWeight:
                      !isSignToArabic ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignToArabicSection() {
    return Column(
      children: [
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
              _imageBytes != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  _imageBytes!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
                  : Icon(Icons.camera_alt,
                  size: 100, color: Colors.grey[400]),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 159, 165, 228),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text(
                  'التقاط صورة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              if (_imageBytes != null)
                ElevatedButton(
                  onPressed: _isTesting ? null : _testSignLetter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isTesting ? Colors.grey : Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: _isTesting
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Text(
                    'اختبار الحرف',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (_loadingOcr)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          )
        else if (_resultController.text.isNotEmpty)
          _buildResultCard(),

        const SizedBox(height: 20),

        if (_showTrainingUI && _currentPrediction != null)
          _buildPredictionCard(),
      ],
    );
  }

  Widget _buildResultCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'الحرف المتوقع من النموذج:',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  final t = _resultController.text.trim();
                  if (t.isNotEmpty) {
                    Clipboard.setData(ClipboardData(text: t));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم نسخ النص')),
                    );
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: () => _speak(_resultController.text),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F9),
              borderRadius: BorderRadius.circular(12),
            ),
            constraints: const BoxConstraints(minHeight: 80),
            child: TextField(
              controller: _resultController,
              maxLines: null,
              style: TextStyle(fontSize: _fontSize),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
                hintText: 'سيظهر الحرف المستخرج هنا…',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'حجم الخط:',
                style: TextStyle(fontSize: 12),
              ),
              Expanded(
                child: Slider(
                  value: _fontSize,
                  min: 10,
                  max: 26,
                  onChanged: (v) {
                    setState(() => _fontSize = v);
                  },
                ),
              ),
              Text(
                _fontSize.toStringAsFixed(0),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
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
          const Text('الحرف المتوقع:',
              style: TextStyle(fontSize: 18, color: Colors.black54)),
          const SizedBox(height: 10),
          Text(
            _currentPrediction ?? '',
            style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          if (_currentConfidence != null) ...[
            const SizedBox(height: 6),
            Text(
              'الدقة: ${( (_currentConfidence ?? 0) * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _onUserIncorrect,
                icon: const Icon(Icons.close),
                label: const Text('خاطئ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _onUserConfirmedCorrect,
                icon: const Icon(Icons.check),
                label: const Text('صحيح'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArabicToSignSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'اكتب النص بالعربية:',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3F3D56)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _textController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'اكتب النص هنا...',
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip:
                        _listening ? 'إيقاف الإملاء' : 'إملاء صوتي',
                        icon: Icon(
                          _listening ? Icons.mic_off : Icons.mic,
                        ),
                        onPressed: _toggleListen,
                      ),
                      IconButton(
                        tooltip: 'نطق النص',
                        icon: const Icon(Icons.volume_up),
                        onPressed: () => _speak(_textController.text),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: _loadingMap
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Wrap(
              alignment: WrapAlignment.center,
              runSpacing: 4,
              children: _buildSignFromText(_textController.text),
            ),
          ),
        ),
      ],
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
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F3D56)),
            ),
            SizedBox(height: 10),
            Text(
                '1. اختر الوضع: "لغة الإشارة → العربية" أو "العربية → لغة الإشارة".'),
            Text('2. في وضع لغة الإشارة → العربية: التقط صورة لإشارة اليد.'),
            Text('3. انتظر حتى يتعرف النموذج على الحرف ويعرضه لك.'),
            Text('4. اختر إذا كان الحرف صحيحاً أو خاطئاً.'),
            Text('5. إذا كان خاطئاً، صحح الحرف وساعد في تحسين النموذج.'),
            Text(
                '6. في وضع العربية → لغة الإشارة: اكتب النص أو استخدم الإملاء الصوتي لرؤية إشارات الحروف.'),
          ],
        ),
      ),
    );
  }
}
