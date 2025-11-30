import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:demeterapp/app/core/providers/core_providers.dart';
import 'package:demeterapp/app/core/exceptions/api_exception.dart';

part 'details_view_model.g.dart';

enum DetailsStatus {
  loading,
  loaded,
  error,
}

class ClassificationDetails {
  final int id;
  final String grainType;
  final double confidence;
  final DateTime timestamp;
  final String imagePath;
  final int? grainsDetected;
  final int? totalDefects;
  final double? defectPercentage;
  final String? llmSummary;

  ClassificationDetails({
    required this.id,
    required this.grainType,
    required this.confidence,
    required this.timestamp,
    required this.imagePath,
    this.grainsDetected,
    this.totalDefects,
    this.defectPercentage,
    this.llmSummary,
  });
}

class DetailsState {
  final DetailsStatus status;
  final ClassificationDetails? details;
  final String? errorMessage;

  DetailsState({
    required this.status,
    this.details,
    this.errorMessage,
  });

  DetailsState.initial()
      : status = DetailsStatus.loading,
        details = null,
        errorMessage = null;

  DetailsState.loading()
      : status = DetailsStatus.loading,
        details = null,
        errorMessage = null;

  DetailsState copyWith({
    DetailsStatus? status,
    ClassificationDetails? details,
    String? errorMessage,
  }) {
    return DetailsState(
      status: status ?? this.status,
      details: details ?? this.details,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class DetailsViewModel extends _$DetailsViewModel {
  @override
  DetailsState build(int classificationId) {
    loadDetails(classificationId);
    return DetailsState.initial();
  }

  Future<void> loadDetails(int classificationId) async {
    state = DetailsState.loading();

    try {
      final repository = ref.read(classificationRepositoryProvider);
      final classification = await repository.getClassificationById(classificationId);

      final details = ClassificationDetails(
        id: classification.id,
        grainType: classification.grainType,
        confidence: classification.confidenceScore ?? 0.0,
        timestamp: classification.createdAt,
        imagePath: classification.imagePath,
        grainsDetected: classification.totalGrains,
        totalDefects: classification.totalDefects,
        defectPercentage: classification.defectPercentage,
        llmSummary: classification.llmSummary,
      );

      state = DetailsState(
        status: DetailsStatus.loaded,
        details: details,
      );
    } on ApiException catch (e) {
      state = DetailsState(
        status: DetailsStatus.error,
        errorMessage: e.userFriendlyMessage,
      );
    } catch (e) {
      state = DetailsState(
        status: DetailsStatus.error,
        errorMessage: 'Erro ao carregar detalhes',
      );
    }
  }
}
