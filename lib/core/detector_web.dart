// Web stub – no tflite or dart:ffi here.
import 'detector_interface.dart';

class _WebDetector implements SignDetector {
  @override
  bool get ready => false;

  @override
  Future<void> init() async {}

  @override
  Future<String> detect(List<double> input) async =>
      'Web build: detector not available';

  @override
  void close() {}
}

// This symbol is what detector.dart calls (via alias).
SignDetector createDetectorImpl() => _WebDetector();
