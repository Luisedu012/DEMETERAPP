import 'package:demeterapp/app/core/config/env.dart';

class ClassificationModel {
  final int id;
  final int userId;
  final String imagePath;
  final String grainType;
  final double? confidenceScore;
  final Map<String, dynamic>? extraData;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClassificationModel({
    required this.id,
    required this.userId,
    required this.imagePath,
    required this.grainType,
    this.confidenceScore,
    this.extraData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClassificationModel.fromJson(Map<String, dynamic> json) {
    double? parseConfidence(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    return ClassificationModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      imagePath: json['image_path'] as String,
      grainType: json['grain_type'] as String,
      confidenceScore: parseConfidence(json['confidence_score']),
      extraData: json['extra_data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'image_path': imagePath,
      'grain_type': grainType,
      'confidence_score': confidenceScore,
      'extra_data': extraData,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isMock => extraData?['mock'] ?? true;
  String? get jobId => extraData?['job_id'];
  int? get totalGrains => extraData?['total_grains'];
  String? get llmSummary => extraData?['llm_summary'];
  bool? get processedImageAvailable => extraData?['processed_image_available'];

  Map<String, dynamic>? get defects => extraData?['defects'];
  int? get totalDefects => defects?['total'];
  double? get defectPercentage => defects?['percentage'];

  /// Retorna a URL completa da imagem concatenando base URL + caminho relativo
  String get fullImageUrl {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    final baseUrl = Env.apiBaseUrl;
    final cleanPath = imagePath.startsWith('/') ? imagePath : '/$imagePath';
    return '$baseUrl$cleanPath';
  }

  String get qualityLevel {
    final percentage = defectPercentage ?? 0.0;
    if (percentage < 20) return 'EXCELENTE';
    if (percentage < 50) return 'REGULAR';
    return 'RUIM';
  }

  ClassificationModel copyWith({
    int? id,
    int? userId,
    String? imagePath,
    String? grainType,
    double? confidenceScore,
    Map<String, dynamic>? extraData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClassificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imagePath: imagePath ?? this.imagePath,
      grainType: grainType ?? this.grainType,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      extraData: extraData ?? this.extraData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ClassificationModel(id: $id, grainType: $grainType, confidence: $confidenceScore)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ClassificationModel &&
        other.id == id &&
        other.userId == userId &&
        other.grainType == grainType;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ grainType.hashCode;
  }
}
