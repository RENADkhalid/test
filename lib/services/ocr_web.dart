class OcrService {
  Future<String> processFilePath(String path) async {
    // Not supported on web; you can integrate a web OCR later.
    throw UnimplementedError('التعرّف على النص غير مدعوم على الويب.');
  }
}
