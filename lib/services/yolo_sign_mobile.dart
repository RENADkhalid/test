import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'yolo_types.dart';

/// Mobile/desktop implementation that uses TensorFlow Lite.
class YoloSignService {
  Interpreter? _interpreter;

  bool get ready => _interpreter != null;

  Future<void> init() async {
    if (_interpreter != null) return;
    // Put your model path here (and list it under flutter: assets:)
    _interpreter = await Interpreter.fromAsset('assets/model.tflite');
  }

  /// Close/release the interpreter
  Future<void> close() async {
    _interpreter?.close();
    _interpreter = null;
  }

  /// Run detection from raw image bytes.
  /// TODO: implement your preprocessing (resize/normalize) → run → postprocess.
  Future<List<Detection>> detectBytes(Uint8List bytes) async {
    if (_interpreter == null) {
      throw StateError('YoloSignService not initialized. Call init() first.');
    }

    // -------------------------
    // TODO: Replace this stub with real logic:
    // - decode bytes (e.g. with `image` package)
    // - resize & normalize to your model input
    // - create input/output tensors
    // - _interpreter!.run(input, output)
    // - parse output into List<Detection>
    // -------------------------
    return <Detection>[];
  }

  /// Optional: print model input/output shapes for debug
  Future<void> debugDescribeModel() async {
    if (_interpreter == null) return;
    final inputs = _interpreter!.getInputTensor(0);
    final outputs = _interpreter!.getOutputTensor(0);
    // ignore: avoid_print
    print('TFLite in: ${inputs.shape}, out: ${outputs.shape}');
  }
}
