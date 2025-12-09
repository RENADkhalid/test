import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class YoloSign {
  late Interpreter _interpreter;
  bool _isLoaded = false;

  final int inputSize = 640;

  Future<void> init() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'models/best_float16.tflite',
        options: InterpreterOptions()..threads = 4,
      );
      _isLoaded = true;
      print("YOLO model loaded");
    } catch (e) {
      print("Failed loading YOLO model: $e");
    }
  }

  bool get ready => _isLoaded;

  Future<List<Detection>> detectBytes(Uint8List bytes) async {
    if (!_isLoaded) throw Exception("YOLO model not loaded");

    final img.Image? original = img.decodeImage(bytes);
    if (original == null) return [];

    final img.Image resized = img.copyResize(
      original,
      width: inputSize,
      height: inputSize,
    );

    final input = _preprocessImage(resized);

    // YOLO output
    final output = {
      0: List.filled(1 * 25200 * 85, 0.0).reshape([1, 25200, 85])
    };

    _interpreter.runForMultipleInputs([input], output);

    // Convert dynamic → double
    final processed = (output[0] as List)
        .map((e) => (e as List)
            .map((v) => (v as List).map((n) => (n as num).toDouble()).toList())
            .toList())
        .toList();

    return _processOutput(processed, original.width, original.height);
  }

  List<List<List<double>>> _preprocessImage(img.Image image) {
    return List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(
          inputSize,
          (x) {
            final pixel = image.getPixel(x, y);
            final r = img.getRed(pixel) / 255.0;
            final g = img.getGreen(pixel) / 255.0;
            final b = img.getBlue(pixel) / 255.0;
            return [r, g, b];
          },
        ),
      ),
    );
  }

  List<Detection> _processOutput(
      List<List<List<double>>> out, int origW, int origH) {
    final result = <Detection>[];

    final predictions = out[0];

    for (var pred in predictions) {
      final confidence = pred[4];
      if (confidence < 0.50) continue;

      double maxClassProb = 0;
      int classId = -1;

      for (int c = 5; c < pred.length; c++) {
        if (pred[c] > maxClassProb) {
          maxClassProb = pred[c];
          classId = c - 5;
        }
      }

      final totalScore = confidence * maxClassProb;
      if (totalScore < 0.50) continue;

      final cx = pred[0];
      final cy = pred[1];
      final w = pred[2];
      final h = pred[3];

      final left = (cx - w / 2) * origW;
      final top = (cy - h / 2) * origH;
      final width = w * origW;
      final height = h * origH;

      result.add(
        Detection(
          _className(classId),
          totalScore,
          BBox(left, top, width, height),
        ),
      );
    }

    return result;
  }

  String _className(int id) {
    const classes = [
      "aleff",
      "bb",
      "ta",
      "thaa",
      "jeem",
      "haa",
      "khaa",
      "dal",
      "thal",
      "ra",
      "zay",
      "seen",
      "sheen",
      "saad",
      "dhad",
      "taa2",
      "dha",
      "ain",
      "ghain",
      "fa",
      "gaaf",
      "kaaf",
      "laam",
      "meem",
      "nun",
      "ha",
      "waw",
      "ya"
    ];

    return (id >= 0 && id < classes.length) ? classes[id] : "Unknown";
  }

  void close() {
    if (_isLoaded) {
      _interpreter.close();
      _isLoaded = false;
    }
  }
}

class Detection {
  final String label;
  final double confidence;
  final BBox box;

  Detection(this.label, this.confidence, this.box);
}

class BBox {
  final double x;
  final double y;
  final double w;
  final double h;

  BBox(this.x, this.y, this.w, this.h);
}
