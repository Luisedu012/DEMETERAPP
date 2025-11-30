// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classifications_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ClassificationsViewModel)
const classificationsViewModelProvider = ClassificationsViewModelProvider._();

final class ClassificationsViewModelProvider
    extends $NotifierProvider<ClassificationsViewModel, ClassificationsState> {
  const ClassificationsViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'classificationsViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$classificationsViewModelHash();

  @$internal
  @override
  ClassificationsViewModel create() => ClassificationsViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClassificationsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClassificationsState>(value),
    );
  }
}

String _$classificationsViewModelHash() =>
    r'e872bd504e54fc8b3110ceedb4c3d7c5842adf73';

abstract class _$ClassificationsViewModel
    extends $Notifier<ClassificationsState> {
  ClassificationsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ClassificationsState, ClassificationsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ClassificationsState, ClassificationsState>,
              ClassificationsState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
