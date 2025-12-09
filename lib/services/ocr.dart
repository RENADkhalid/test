import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

// If you later want real OCR on mobile, you can enable this:
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  static Future<String> processBytes(Uint8List bytes) async {
    if (kIsWeb) {
      // You can integrate a JS/web OCR later; for now return empty.
      return '';
    }

    // --- Mobile path (uncomment if you add ML Kit to mobile) ---
    // final inputImage = InputImage.fromBytes(
    //   bytes: bytes,
    //   inputImageData: InputImageData(
    //     size: const Size(0, 0), // MLKit ignores for Latin/Arabic detection
    //     imageRotation: InputImageRotation.rotation0deg,
    //     inputImageFormat: InputImageFormat.nv21,
    //     planeData: [],
    //   ),
    // );
    // final recognizer = TextRecognizer();
    // final res = await recognizer.processImage(inputImage);
    // await recognizer.close();
    // return res.text;

    return '';
  }
}
