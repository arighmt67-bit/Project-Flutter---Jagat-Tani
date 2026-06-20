import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'models/prediction_result.dart';
import '../services/padi_classifier_service.dart';

class PadiClassifierProvider extends ChangeNotifier {
  final PadiClassifierService _service = PadiClassifierService();

  bool _modelReady = false;
  bool _isPredicting = false;
  PredictionResult? _result;

  bool get modelReady => _modelReady;
  bool get isPredicting => _isPredicting;
  PredictionResult? get result => _result;

  Future<void> initModel() async {
    await _service.loadModel();
    _modelReady = true;
    notifyListeners();
  }

  Future<void> classifyImage(File imageFile) async {
    _isPredicting = true;
    notifyListeners();

    final bytes = await imageFile.readAsBytes();
    final decoded = img.decodeImage(bytes);

    if (decoded == null) {
      _isPredicting = false;
      notifyListeners();
      throw Exception("Gagal membaca gambar");
    }

    final prediction = _service.classify(decoded);
    _result = prediction;

    _isPredicting = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
