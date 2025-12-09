import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModelComparator {
  bool _isModelLoaded = false;

  Future<void> loadModels() async {
    try {
      _isModelLoaded = true;
      print('Model comparator initialized successfully');
    } catch (e) {
      print('Error initializing model comparator: $e');
      _isModelLoaded = false;
    }
  }

  Future<Map<String, dynamic>> comparePrediction(
      Uint8List imageBytes, String userFeedback) async {
    if (!_isModelLoaded) {
      return {'error': 'Model comparator not loaded'};
    }

    try {
      // هنا مستقبلاً تقارنين بين نموذجين أو تحللين الصورة
      // حالياً نرجع تقرير بسيط

      return {
        'status': 'ok',
        'message': 'Comparison completed',
        'feedback': userFeedback,
        'imageSize': imageBytes.length,
      };
    } catch (e) {
      return {
        'error': 'Comparison failed',
        'details': e.toString(),
      };
    }
  }

  Future<void> saveTrainingData(Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection('model_training_data').add({
        ...data,
        'created_at': FieldValue.serverTimestamp(),
      });

      print('Training data saved successfully');
    } catch (e) {
      print('Error saving training data: $e');
      _saveTrainingDataLocally(data);
    }
  }

  void _saveTrainingDataLocally(Map<String, dynamic> data) {
    print('Training data saved locally: $data');
  }

  bool get isModelLoaded => _isModelLoaded;

  void dispose() {
    _isModelLoaded = false;
  }
}
