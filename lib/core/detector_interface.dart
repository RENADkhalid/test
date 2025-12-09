abstract class SignDetector {
  bool get ready;
  Future<void> init();
  Future<String> detect(List<double> input);
  void close();
}
