import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  Future<String> processFilePath(String path) async {
    final inputImage = InputImage.fromFilePath(path);
    final textRecognizer = TextRecognizer();
    try {
      final recognized = await textRecognizer.processImage(inputImage);
      return recognized.text.trim();
    } finally {
      await textRecognizer.close();
    }
  }
}
