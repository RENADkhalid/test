import 'dart:typed_data';
import 'yolo_types.dart';

/// Web implementation: no TFLite. Provides API compatibility only.
class YoloSignService {
  bool get ready => false;
  Future<void> init() async {}
  Future<void> close() async {}

  Future<List<Detection>> detectBytes(Uint8List bytes) async {
    // You can implement a JS/WebAssembly path later if you want.
    // For now we throw to make it clear in UI.
    throw UnimplementedError('YOLO sign detection is not supported on Web yet.');
  }

  Future<void> debugDescribeModel() async {}
}
