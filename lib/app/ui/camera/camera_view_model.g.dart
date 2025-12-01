// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'camera_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CameraViewModel)
const cameraViewModelProvider = CameraViewModelProvider._();

final class CameraViewModelProvider
    extends $NotifierProvider<CameraViewModel, CameraState> {
  const CameraViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cameraViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cameraViewModelHash();

  @$internal
  @override
  CameraViewModel create() => CameraViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CameraState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CameraState>(value),
    );
  }
}

String _$cameraViewModelHash() => r'8c9f6a8909955549ecff8708d38388a0dbc79bb7';

abstract class _$CameraViewModel extends $Notifier<CameraState> {
  CameraState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<CameraState, CameraState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CameraState, CameraState>,
              CameraState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
