import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'core/detector.dart';
import 'custom_navbar.dart';
import 'services/ocr.dart';
import 'services/model_comparator.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  bool isSignToArabic = true;
  Uint8List? _imageBytes;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();
  bool _showSignImage = false;
  final int _selectedIndex = 2;
  final ImagePicker _picker = ImagePicker();
  final FlutterTts _tts = FlutterTts();
  bool _speaking = false;
  double _fontSize = 16;
  bool _loadingOcr = false;
  late stt.SpeechToText _speech;
  bool _hasSpeech = false;
  bool _listening = false;
  Map<String, String> _signMap = {};
  bool _loadingMap = true;

  final ModelComparator _modelComparator = ModelComparator();
  String _currentWord = '';

  final _detector = createSignDetector();

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

  void _onTextChanged() {
    setState(() {
      _showSignImage = _textController.text.trim().isNotEmpty;
    });
  }

  void _addLetterToWord(String letter) {
    setState(() {
      _currentWord += letter;
      _resultController.text = _currentWord;
    });
  }

  void _clearCurrentWord() {
    setState(() {
      _currentWord = '';
      _resultController.clear();
    });
  }

  void _resetTranslation() {
    setState(() {
      isSignToArabic = true;
      _imageBytes = null;
      _textController.clear();
      _resultController.clear();
      _currentWord = '';
      _showSignImage = false;
      _listening = false;
    });

    _speech.stop();
    _tts.stop();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
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
    );

    if (source == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _resultController.clear();
    });

    await _processPickedImage();
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

  @override
  void initState() {
    super.initState();
    _initTts();
    _textController.addListener(_onTextChanged);
    _initSpeechToText();
    _loadSignMap();
    _modelComparator.loadModels();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ar-SA');
    _tts.setStartHandler(() => setState(() => _speaking = true));
    _tts.setCompletionHandler(() => setState(() => _speaking = false));
    _tts.setCancelHandler(() => setState(() => _speaking = false));
  }

  Future<void> _initSpeechToText() async {
    _speech = stt.SpeechToText();
    _hasSpeech = await _speech.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _loadSignMap() async {
    try {
      // قائمة الحروف العربية
      final letters = [
        'ا', 'أ', 'إ', 'آ',
        'ب', 'ت', 'ث',
        'ج', 'ح', 'خ',
        'د', 'ذ',
        'ر', 'ز',
        'س', 'ش',
        'ص', 'ض',
        'ط', 'ظ',
        'ع', 'غ',
        'ف', 'ق',
        'ك', 'ل', 'م',
        'ن', 'ه', 'و', 'ي'
      ];

      final map = <String, String>{};

      for (final letter in letters) {
        final assetPath = 'assets/signs/signs/$letter.jpg';

        final key = _normalizeArabic(letter);

        map[key] = assetPath;
        map.putIfAbsent(letter, () => assetPath);
      }

      if (mounted) {
        setState(() {
          _signMap = map;
          _loadingMap = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingMap = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر تحميل صور الحروف')),
        );
      }
    }
  }


  Future<void> _processPickedImage() async {
    if (_imageBytes == null) return;
    setState(() => _loadingOcr = true);

    try {
      if (isSignToArabic) {
        final url = config.api;
        final base64Image = base64Encode(_imageBytes!);
        final response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/x-www-form-urlencoded"},
          body: base64Image,
        );
        if (response.statusCode == 200) {
          final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

          final predsDynamic = data['predictions'];
          if (predsDynamic == null || predsDynamic is! List || predsDynamic.isEmpty) {
            setState(() => _resultController.text = "لم يتم التعرف على أي حرف.");
          } else {
            final List<Map<String, dynamic>> preds =
            predsDynamic.cast<Map<String, dynamic>>();

            preds.sort((a, b) {
              final ax = (a['x'] as num?) ?? 0;
              final bx = (b['x'] as num?) ?? 0;
              return ax.compareTo(bx);
            });

            String letters = "";
            for (final p in preds) {
              final label = (p['class'] ?? '').toString().trim();
              final arabic = _classToArabic[label] ?? label;
              print("LABEL: $label  ->  $arabic");
              letters += arabic;
            }

            if (letters.isEmpty) {
              setState(() => _resultController.text = "لم يتم التعرف على أي حرف.");
            } else {
              _addLetterToWord(letters);
            }
          }
        } else {
          setState(() => _resultController.text = "خطأ أثناء الاتصال بالخادم.");
        }
      } else {
        // OCR كما هو
        final text = await OcrService.processBytes(_imageBytes!);
        setState(() {
          _resultController.text =
          text.trim().isEmpty ? 'لم يتم العثور على نص.' : text;
        });
      }
    } catch (e, s) {
      print("DETECTION ERROR: $e");
      print(s);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء التعرف.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingOcr = false);
    }
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

  Future<void> _stopSpeak() async {
    await _tts.stop();
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
            child: Image.asset(
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
        backgroundColor: const Color(0xFFE9EDF6),
        appBar: AppBar(
          backgroundColor: const Color(0xFF153C64),
          centerTitle: true,
          title: const SizedBox.shrink(),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: _resetTranslation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCDD6E4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "إنهاء الترجمة",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isSignToArabic ? "لغة الإشارة" : "العربية",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_horiz),
                      onPressed: () {
                        setState(() {
                          isSignToArabic = !isSignToArabic;
                          _imageBytes = null;
                          _textController.clear();
                          _resultController.clear();
                          _currentWord = '';
                          _showSignImage = false;
                        });
                      },
                    ),
                    Text(
                      isSignToArabic ? "العربية" : "لغة الإشارة",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: _boxStyle(),
                  child: isSignToArabic
                      ? Column(
                    children: [
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _imageBytes == null
                            ? const Center(child: Text("لا توجد صورة"))
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(_imageBytes!,
                              fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _pickImage,
                          style: _buttonStyle(),
                          child: const Text("اختيار/التقاط صورة"),
                        ),
                      ),
                    ],
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: _toggleListen,
                          icon: Icon(
                              _listening ? Icons.mic_off : Icons.mic),
                          tooltip: _listening
                              ? 'إيقاف الإملاء'
                              : 'إملاء صوتي',
                        ),
                      ),
                      TextField(
                        controller: _textController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "اكتب النص هنا...",
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: _boxStyle(),
                  child: isSignToArabic
                      ? (_loadingOcr
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "الكلمة المكونة:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          if (_currentWord.isNotEmpty)
                            IconButton(
                              onPressed: _clearCurrentWord,
                              icon: const Icon(Icons.clear),
                              tooltip: 'مسح الكلمة',
                            ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _resultController.text =
                                "${_resultController.text} ";
                                _currentWord =
                                    _resultController.text;
                              });
                            },
                            icon: const Icon(Icons.space_bar),
                            tooltip: 'مسافة',
                          ),
                          IconButton(
                            onPressed: () {
                              final t =
                              _resultController.text.trim();
                              if (t.isNotEmpty) {
                                Clipboard.setData(
                                    ClipboardData(text: t));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                      content:
                                      Text('تم نسخ النص')),
                                );
                              }
                            },
                            icon: const Icon(Icons.copy),
                            tooltip: 'نسخ',
                          ),
                          IconButton(
                            onPressed: () =>
                                _speak(_resultController.text),
                            icon: const Icon(Icons.volume_up),
                            tooltip: 'نطق',
                          ),
                        ],
                      ),

                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F9),
                          borderRadius: BorderRadius.circular(15),
                          border:
                          Border.all(color: Colors.grey.shade300),
                        ),
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              _resultController.text,
                              style: TextStyle(
                                fontSize: _fontSize * 1.4,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF153C64),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),

                      Row(
                        children: [
                          const Text("حجم الخط"),
                          Expanded(
                            child: Slider(
                              value: _fontSize,
                              min: 12,
                              max: 28,
                              onChanged: (v) =>
                                  setState(() => _fontSize = v),
                            ),
                          ),
                          Text(_fontSize.toStringAsFixed(0)),
                        ],
                      ),
                    ],
                  ))
                      : (_loadingMap
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      runSpacing: 6,
                      children:
                      _buildSignFromText(_textController.text),
                    ),
                  )),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: (i) {},
        ),
      ),
    );
  }

  BoxDecoration _boxStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade300,
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFE7E9EB),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
