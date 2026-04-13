class PredictionResult {
  final String className;
  final String label;
  final double confidence;
  final Map<String, double> probabilities;

  const PredictionResult({
    required this.className,
    required this.label,
    required this.confidence,
    required this.probabilities,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      className: json['class_name'] as String,
      label: json['label'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      probabilities: (json['probabilities'] as Map<String, dynamic>).map(
        (k, v) => MapEntry(k, (v as num).toDouble()),
      ),
    );
  }
}
