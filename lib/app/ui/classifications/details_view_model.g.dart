// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'details_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DetailsViewModel)
const detailsViewModelProvider = DetailsViewModelFamily._();

final class DetailsViewModelProvider
    extends $NotifierProvider<DetailsViewModel, DetailsState> {
  const DetailsViewModelProvider._({
    required DetailsViewModelFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'detailsViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$detailsViewModelHash();

  @override
  String toString() {
    return r'detailsViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DetailsViewModel create() => DetailsViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DetailsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DetailsState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DetailsViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$detailsViewModelHash() => r'7fcae296f756e232dd55e82aff15eec0f09a22ac';

final class DetailsViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          DetailsViewModel,
          DetailsState,
          DetailsState,
          DetailsState,
          int
        > {
  const DetailsViewModelFamily._()
    : super(
        retry: null,
        name: r'detailsViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DetailsViewModelProvider call(int classificationId) =>
      DetailsViewModelProvider._(argument: classificationId, from: this);

  @override
  String toString() => r'detailsViewModelProvider';
}

abstract class _$DetailsViewModel extends $Notifier<DetailsState> {
  late final _$args = ref.$arg as int;
  int get classificationId => _$args;

  DetailsState build(int classificationId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<DetailsState, DetailsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DetailsState, DetailsState>,
              DetailsState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
