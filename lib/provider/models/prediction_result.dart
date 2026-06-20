class PredictionResult {
  final String label;
  final double confidence;
  final String recommendation;

  PredictionResult({
    required this.label,
    required this.confidence,
    required this.recommendation,
  });

  @override
  String toString() =>
      'PredictionResult(label: $label, confidence: $confidence)';
}
