import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../provider/models/prediction_result.dart';

class PadiClassifierService {
  Interpreter? _interpreter;
  List<String> _labels = [];
  int inputSize = 224;
  int numChannels = 3;

  // quantization / tensor info
  TensorType? _inputType;
  TensorType? _outputType;
  double _inputScale = 1.0;
  int _inputZeroPoint = 0;
  double _outputScale = 1.0;
  int _outputZeroPoint = 0;

  /// Load model and labels from assets
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('models/model_padi.tflite');

      // read input tensor shape and quantization info if available
      try {
        final input = _interpreter!.getInputTensor(0);
        final shape = input.shape; // e.g. [1,224,224,3]
        if (shape.length >= 4) {
          inputSize = shape[1];
          numChannels = shape[3];
        }

        _inputType = input.type;
        try {
          final qp =
              (input as dynamic).quantizationParameters ??
              (input as dynamic).quantizationParams;
          if (qp != null) {
            _inputScale = (qp.scale as double?) ?? 1.0;
            _inputZeroPoint = (qp.zeroPoint as int?) ?? 0;
          }
        } catch (_) {
          // ignore - quant params not available on this TF Lite build
        }
      } catch (_) {
        // fallback to defaults
      }

      // try read output tensor quantization info
      try {
        final output = _interpreter!.getOutputTensor(0);
        _outputType = output.type;
        try {
          final qp =
              (output as dynamic).quantizationParameters ??
              (output as dynamic).quantizationParams;
          if (qp != null) {
            _outputScale = (qp.scale as double?) ?? 1.0;
            _outputZeroPoint = (qp.zeroPoint as int?) ?? 0;
          }
        } catch (_) {
          // ignore
        }
      } catch (_) {
        // ignore
      }

      final labelsData = await rootBundle.loadString(
        'assets/models/labels.txt',
      );
      _labels =
          labelsData
              .split('\n')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
    } catch (e) {
      if (kDebugMode) print('Error loading model: $e');
      rethrow;
    }
  }

  /// Classify an image (package:image Image)
  PredictionResult classify(img.Image image) {
    if (_interpreter == null) {
      throw Exception('Interpreter not initialized. Call loadModel() first.');
    }

    // Resize image to model input size
    final resized = img.copyResize(image, width: inputSize, height: inputSize);

    // Build input according to tensor type. For float models we feed floats
    // normalized to [0,1]. For quantized (int8/uint8) we quantize using the
    // model's scale and zero point: q = round(real/scale) + zeroPoint.
    final bool inputQuantized =
        _inputType == TensorType.uint8 || _inputType == TensorType.int8;

    dynamic input;
    if (!inputQuantized) {
      input = List.generate(
        1,
        (_) => List.generate(
          inputSize,
          (_) => List.generate(inputSize, (_) => List.filled(numChannels, 0.0)),
        ),
      );

      for (var y = 0; y < inputSize; y++) {
        for (var x = 0; x < inputSize; x++) {
          final px = resized.getPixel(x, y);
          final r = (px.r) / 255.0;
          final g = (px.g) / 255.0;
          final b = (px.b) / 255.0;
          input[0][y][x][0] = r;
          if (numChannels > 1) input[0][y][x][1] = g;
          if (numChannels > 2) input[0][y][x][2] = b;
        }
      }
    } else {
      // quantized input: build integer-valued buffer
      input = List.generate(
        1,
        (_) => List.generate(
          inputSize,
          (_) => List.generate(inputSize, (_) => List.filled(numChannels, 0)),
        ),
      );

      for (var y = 0; y < inputSize; y++) {
        for (var x = 0; x < inputSize; x++) {
          final px = resized.getPixel(x, y);
          final rf = (px.r) / 255.0;
          final gf = (px.g) / 255.0;
          final bf = (px.b) / 255.0;

          int rq =
              (_inputScale != 0)
                  ? (rf / _inputScale).round() + _inputZeroPoint
                  : (rf * 255).round();
          int gq =
              (_inputScale != 0)
                  ? (gf / _inputScale).round() + _inputZeroPoint
                  : (gf * 255).round();
          int bq =
              (_inputScale != 0)
                  ? (bf / _inputScale).round() + _inputZeroPoint
                  : (bf * 255).round();

          // clamp based on type
          if (_inputType == TensorType.uint8) {
            rq = rq.clamp(0, 255);
            gq = gq.clamp(0, 255);
            bq = bq.clamp(0, 255);
          } else {
            rq = rq.clamp(-128, 127);
            gq = gq.clamp(-128, 127);
            bq = bq.clamp(-128, 127);
          }

          input[0][y][x][0] = rq;
          if (numChannels > 1) input[0][y][x][1] = gq;
          if (numChannels > 2) input[0][y][x][2] = bq;
        }
      }
    }

    // Prepare output buffer. Most classifier models output shape [1,NUM_LABELS]
    final bool outputQuantized =
        _outputType == TensorType.uint8 || _outputType == TensorType.int8;
    dynamic output;
    if (!outputQuantized) {
      output = List.generate(1, (_) => List.filled(_labels.length, 0.0));
    } else {
      output = List.generate(1, (_) => List.filled(_labels.length, 0));
    }

    // Run inference
    try {
      _interpreter!.run(input, output);
    } catch (e) {
      if (kDebugMode) print('Error during inference: $e');
      rethrow;
    }

    // Extract scores and dequantize if necessary
    List<double> scores = List.filled(_labels.length, 0.0);
    if (!outputQuantized) {
      final out = output[0] as List;
      for (var i = 0; i < out.length; i++) {
        scores[i] = (out[i] as num).toDouble();
      }
    } else {
      final out = output[0] as List;
      for (var i = 0; i < out.length; i++) {
        final v = out[i] as int;
        // dequantize
        scores[i] = (v - _outputZeroPoint) * _outputScale;
      }
    }

    // find max score
    double bestScore = -double.infinity;
    int bestIdx = 0;
    for (var i = 0; i < scores.length; i++) {
      final v = scores[i];
      if (v > bestScore) {
        bestScore = v;
        bestIdx = i;
      }
    }

    final label =
        (bestIdx >= 0 && bestIdx < _labels.length)
            ? _labels[bestIdx]
            : 'Unknown';

    // If outputs are not probabilities, bestScore may not be in [0,1]. We
    // return the raw bestScore; caller can interpret it. For nicer UI show
    // a percent by mapping if needed.
    final confidence = bestScore.isFinite ? bestScore : 0.0;

    final recommendation = _recommendationForLabel(label);

    return PredictionResult(
      label: label,
      confidence: confidence,
      recommendation: recommendation,
    );
  }

  String _recommendationForLabel(String label) {
    final l = label.toLowerCase();
    if (l.contains('blast') || l.contains('blas')) {
      return 'Gejala mengarah ke penyakit blas. Pisahkan tanaman terserang, singkirkan daun yang parah, dan pertimbangkan penggunaan fungisida yang sesuai. Konsultasikan dosis pada penyuluh lokal.';
    }
    if (l.contains('bakteri') || l.contains('hawar')) {
      return 'Kemungkinan hawar/bakteri. Kurangi kelembapan berlebih, perbaiki drainase, dan gunakan antibiotik/penanganan sesuai rekomendasi ahli.';
    }
    if (l.contains('bercak') || l.contains('brown') || l.contains('spot')) {
      return 'Ciri bercak coklat. Hapus daun terinfeksi dan pertimbangkan fungisida berbasis tembaga atau kontak lokal sesuai panduan.';
    }
    return 'Tidak teridentifikasi secara spesifik. Periksa kembali foto (pencahayaan, fokus), ambil beberapa sampel, atau konsultasikan dengan ahli pertanian.';
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
