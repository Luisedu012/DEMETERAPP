import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:demeterapp/app/core/providers/core_providers.dart';
import 'package:demeterapp/app/core/exceptions/api_exception.dart';

part 'classifications_view_model.g.dart';

enum ClassificationsStatus {
  initial,
  loaded,
  loadingMore,
  empty,
  error,
  refreshing,
}

class ClassificationListItem {
  final int id;
  final String grainType;
  final double confidence;
  final DateTime timestamp;

  ClassificationListItem({
    required this.id,
    required this.grainType,
    required this.confidence,
    required this.timestamp,
  });
}

class ClassificationsState {
  final ClassificationsStatus status;
  final List<ClassificationListItem> items;
  final int currentPage;
  final bool hasMore;
  final String? errorMessage;
  final DateTimeRange? dateRange;

  ClassificationsState({
    required this.status,
    required this.items,
    required this.currentPage,
    required this.hasMore,
    this.errorMessage,
    this.dateRange,
  });

  ClassificationsState.initial()
      : status = ClassificationsStatus.initial,
        items = [],
        currentPage = 0,
        hasMore = true,
        errorMessage = null,
        dateRange = null;

  ClassificationsState.loading()
      : status = ClassificationsStatus.initial,
        items = [],
        currentPage = 0,
        hasMore = true,
        errorMessage = null,
        dateRange = null;

  ClassificationsState copyWith({
    ClassificationsStatus? status,
    List<ClassificationListItem>? items,
    int? currentPage,
    bool? hasMore,
    String? errorMessage,
    DateTimeRange? dateRange,
  }) {
    return ClassificationsState(
      status: status ?? this.status,
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      dateRange: dateRange ?? this.dateRange,
    );
  }
}

@riverpod
class ClassificationsViewModel extends _$ClassificationsViewModel {
  static const int itemsPerPage = 20;

  @override
  ClassificationsState build() {
    loadClassifications();
    return ClassificationsState.initial();
  }

  Future<void> loadClassifications() async {
    state = ClassificationsState.loading();

    try {
      final repository = ref.read(classificationRepositoryProvider);
      final classifications = await repository.getClassifications(
        limit: itemsPerPage,
        skip: 0,
      );

      final items = classifications
          .map((c) => ClassificationListItem(
                id: c.id,
                grainType: c.grainType,
                confidence: c.confidenceScore ?? 0.0,
                timestamp: c.createdAt,
              ))
          .toList();

      if (items.isEmpty) {
        state = ClassificationsState(
          status: ClassificationsStatus.empty,
          items: [],
          currentPage: 0,
          hasMore: false,
        );
      } else {
        state = ClassificationsState(
          status: ClassificationsStatus.loaded,
          items: items,
          currentPage: 1,
          hasMore: items.length >= itemsPerPage,
        );
      }
    } on ApiException catch (e) {
      state = ClassificationsState(
        status: ClassificationsStatus.error,
        items: [],
        currentPage: 0,
        hasMore: false,
        errorMessage: e.userFriendlyMessage,
      );
    } catch (e) {
      state = ClassificationsState(
        status: ClassificationsStatus.error,
        items: [],
        currentPage: 0,
        hasMore: false,
        errorMessage: 'Erro ao carregar classificações',
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.status == ClassificationsStatus.loadingMore) {
      return;
    }

    state = state.copyWith(status: ClassificationsStatus.loadingMore);

    try {
      final repository = ref.read(classificationRepositoryProvider);
      final classifications = await repository.getClassifications(
        limit: itemsPerPage,
        skip: state.currentPage * itemsPerPage,
      );

      final newItems = classifications
          .map((c) => ClassificationListItem(
                id: c.id,
                grainType: c.grainType,
                confidence: c.confidenceScore ?? 0.0,
                timestamp: c.createdAt,
              ))
          .toList();

      final allItems = [...state.items, ...newItems];

      state = state.copyWith(
        status: ClassificationsStatus.loaded,
        items: allItems,
        currentPage: state.currentPage + 1,
        hasMore: newItems.length >= itemsPerPage,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        status: ClassificationsStatus.error,
        errorMessage: e.userFriendlyMessage,
      );
    } catch (e) {
      state = state.copyWith(
        status: ClassificationsStatus.error,
        errorMessage: 'Erro ao carregar mais itens',
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(status: ClassificationsStatus.refreshing);

    try {
      final repository = ref.read(classificationRepositoryProvider);
      final classifications = await repository.getClassifications(
        limit: itemsPerPage,
        skip: 0,
      );

      final items = classifications
          .map((c) => ClassificationListItem(
                id: c.id,
                grainType: c.grainType,
                confidence: c.confidenceScore ?? 0.0,
                timestamp: c.createdAt,
              ))
          .toList();

      state = state.copyWith(
        status: ClassificationsStatus.loaded,
        items: items,
        currentPage: 1,
        hasMore: items.length >= itemsPerPage,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        status: ClassificationsStatus.error,
        errorMessage: e.userFriendlyMessage,
      );
    } catch (e) {
      state = state.copyWith(
        status: ClassificationsStatus.error,
        errorMessage: 'Erro ao atualizar',
      );
    }
  }

  Future<void> filterByDateRange(DateTimeRange? range) async {
    state = state.copyWith(
      dateRange: range,
      status: ClassificationsStatus.initial,
    );

    // Por enquanto recarregar todos
    // TODO: Implementar filtro por data na API
    await loadClassifications();
  }
}
