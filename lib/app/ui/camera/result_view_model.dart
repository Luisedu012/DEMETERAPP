import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:demeterapp/app/core/providers/core_providers.dart';
import 'package:demeterapp/app/core/exceptions/api_exception.dart';

part 'result_view_model.g.dart';

enum ResultStatus { initial, classifying, loaded, saving, saved, error }

class ClassificationResult {
  final int id;
  final String grainType;
  final double confidence;
  final File imageFile;
  final int? grainsDetected;
  final int? totalDefects;
  final double? defectPercentage;
  final String? llmSummary;
  final DateTime timestamp;

  ClassificationResult({
    required this.id,
    required this.grainType,
    required this.confidence,
    required this.imageFile,
    this.grainsDetected,
    this.totalDefects,
    this.defectPercentage,
    this.llmSummary,
    required this.timestamp,
  });
}

class ResultState {
  final ResultStatus status;
  final ClassificationResult? result;
  final String? errorMessage;

  ResultState({required this.status, this.result, this.errorMessage});

  ResultState.initial()
    : status = ResultStatus.initial,
      result = null,
      errorMessage = null;

  ResultState copyWith({
    ResultStatus? status,
    ClassificationResult? result,
    String? errorMessage,
  }) {
    return ResultState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class ResultViewModel extends _$ResultViewModel {
  @override
  ResultState build() {
    return ResultState.initial();
  }

  Future<void> loadResult(File imageFile) async {
    state = state.copyWith(status: ResultStatus.classifying);

    try {
      final repository = ref.read(classificationRepositoryProvider);

      final classification = await repository.createClassification(
        image: imageFile,
      );

      final result = ClassificationResult(
        id: classification.id,
        grainType: classification.grainType,
        confidence: classification.confidenceScore ?? 0.0,
        imageFile: imageFile,
        grainsDetected: classification.totalGrains,
        totalDefects: classification.totalDefects,
        defectPercentage: classification.defectPercentage,
        llmSummary: classification.llmSummary,
        timestamp: classification.createdAt,
      );

      state = state.copyWith(status: ResultStatus.loaded, result: result);
    } on ApiException catch (e) {
      final message = (e.statusCode == 400 || e.statusCode == 422)
          ? e.message
          : e.userFriendlyMessage;

      state = state.copyWith(status: ResultStatus.error, errorMessage: message);
    } catch (e) {
      state = state.copyWith(
        status: ResultStatus.error,
        errorMessage: 'Erro ao classificar imagem. Tente novamente.',
      );
    }
  }

  Future<void> saveClassification() async {
    // A classificação já foi salva automaticamente pela API
    // Este método agora apenas marca como salvo
    if (state.result == null) return;

    state = state.copyWith(status: ResultStatus.saved);
  }

  void reset() {
    state = ResultState.initial();
  }
}
