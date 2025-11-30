class ClassificationRequest {
  final String grainType;
  final double confidence;
  final String quality;
  final String? imagePath;

  ClassificationRequest({
    required this.grainType,
    required this.confidence,
    required this.quality,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'grain_type': grainType,
      'confidence': confidence,
      'quality': quality,
      'image_path': imagePath,
    };
  }
}
