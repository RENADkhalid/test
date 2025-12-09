// Runs on Android/iOS/Windows/macOS/Linux (NOT web)
import 'package:tflite_flutter/tflite_flutter.dart';
import 'detector_interface.dart';

class _IoDetector implements SignDetector {
  late final Interpreter _interpreter;
  bool _ready = false;

  @override
  bool get ready => _ready;

  @override
  Future<void> init() async {
    _interpreter = await Interpreter.fromAsset('assets/model.tflite');
    _ready = true;
  }

  @override
  Future<String> detect(List<double> input) async {
    if (!_ready) throw StateError('Detector not initialized');
    // TODO: adjust shapes for your model
    final output = List<double>.filled(10, 0).reshape([1, 10]);
    _interpreter.run(input.reshape([1, input.length]), output);
    return output.toString();
  }

  @override
  void close() {
    if (_ready) {
      _interpreter.close();
      _ready = false;
    }
  }
}

// This symbol is what detector.dart calls (via alias).
SignDetector createDetectorImpl() => _IoDetector();
