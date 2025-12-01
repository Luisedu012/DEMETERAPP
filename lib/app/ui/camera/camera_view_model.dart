import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

part 'camera_view_model.g.dart';

enum CameraStatus {
  initial,
  permissionDenied,
  ready,
  capturing,
  processing,
  error,
}

class CameraState {
  final CameraStatus status;
  final CameraController? controller;
  final List<CameraDescription> cameras;
  final int currentCameraIndex;
  final String? errorMessage;
  final File? capturedImage;

  CameraState({
    required this.status,
    this.controller,
    required this.cameras,
    required this.currentCameraIndex,
    this.errorMessage,
    this.capturedImage,
  });

  CameraState.initial()
      : status = CameraStatus.initial,
        controller = null,
        cameras = [],
        currentCameraIndex = 0,
        errorMessage = null,
        capturedImage = null;

  CameraState copyWith({
    CameraStatus? status,
    CameraController? controller,
    List<CameraDescription>? cameras,
    int? currentCameraIndex,
    String? errorMessage,
    File? capturedImage,
  }) {
    return CameraState(
      status: status ?? this.status,
      controller: controller ?? this.controller,
      cameras: cameras ?? this.cameras,
      currentCameraIndex: currentCameraIndex ?? this.currentCameraIndex,
      errorMessage: errorMessage,
      capturedImage: capturedImage,
    );
  }
}

@riverpod
class CameraViewModel extends _$CameraViewModel {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  CameraState build() {
    initializeCamera();
    return CameraState.initial();
  }

  Future<void> initializeCamera() async {
    try {
      final hasPermission = await checkPermissions();

      if (!hasPermission) {
        state = state.copyWith(status: CameraStatus.permissionDenied);
        return;
      }

      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        state = state.copyWith(
          status: CameraStatus.error,
          errorMessage: 'Nenhuma câmera disponível',
        );
        return;
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      state = state.copyWith(
        status: CameraStatus.ready,
        controller: controller,
        cameras: cameras,
        currentCameraIndex: cameras.indexOf(backCamera),
      );
    } catch (e) {
      state = state.copyWith(
        status: CameraStatus.error,
        errorMessage: 'Erro ao inicializar câmera: ${e.toString()}',
      );
    }
  }

  Future<bool> checkPermissions() async {
    final cameraStatus = await Permission.camera.status;

    if (cameraStatus.isGranted) {
      return true;
    }

    if (cameraStatus.isDenied || cameraStatus.isLimited) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }

    return false;
  }

  Future<void> requestPermissions() async {
    final result = await Permission.camera.request();

    if (result.isGranted) {
      await initializeCamera();
    } else if (result.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  Future<void> takePicture() async {
    if (state.controller == null || !state.controller!.value.isInitialized) {
      return;
    }

    if (state.status == CameraStatus.capturing) {
      return;
    }

    try {
      state = state.copyWith(status: CameraStatus.capturing);

      final image = await state.controller!.takePicture();
      final imageFile = File(image.path);

      state = state.copyWith(status: CameraStatus.processing);

      final compressedImage = await _compressImage(imageFile);

      state = state.copyWith(
        status: CameraStatus.ready,
        capturedImage: compressedImage,
      );
    } catch (e) {
      state = state.copyWith(
        status: CameraStatus.error,
        errorMessage: 'Erro ao capturar foto: ${e.toString()}',
      );

      await Future.delayed(const Duration(seconds: 2));

      state = state.copyWith(
        status: CameraStatus.ready,
        errorMessage: null,
      );
    }
  }

  Future<void> switchCamera() async {
    if (state.cameras.length < 2) {
      return;
    }

    try {
      await state.controller?.dispose();

      final newIndex = (state.currentCameraIndex + 1) % state.cameras.length;
      final newCamera = state.cameras[newIndex];

      final controller = CameraController(
        newCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();

      state = state.copyWith(
        controller: controller,
        currentCameraIndex: newIndex,
      );
    } catch (e) {
      state = state.copyWith(
        status: CameraStatus.error,
        errorMessage: 'Erro ao trocar câmera: ${e.toString()}',
      );
    }
  }

  Future<void> pickFromGallery() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return;
      }

      state = state.copyWith(status: CameraStatus.processing);

      final imageFile = File(pickedFile.path);
      final compressedImage = await _compressImage(imageFile);

      state = state.copyWith(
        status: CameraStatus.ready,
        capturedImage: compressedImage,
      );
    } catch (e) {
      state = state.copyWith(
        status: CameraStatus.error,
        errorMessage: 'Erro ao selecionar imagem: ${e.toString()}',
      );

      await Future.delayed(const Duration(seconds: 2));

      state = state.copyWith(
        status: CameraStatus.ready,
        errorMessage: null,
      );
    }
  }

  Future<File> _compressImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    var image = img.decodeImage(bytes);

    if (image == null) {
      return imageFile;
    }

    // Corrigir orientação baseada em EXIF
    // A maioria das câmeras grava a orientação nos dados EXIF
    image = img.bakeOrientation(image);

    final maxSize = 1920;
    img.Image resized = image;

    if (image.width > maxSize || image.height > maxSize) {
      resized = img.copyResize(
        image,
        width: image.width > image.height ? maxSize : null,
        height: image.height > image.width ? maxSize : null,
      );
    }

    final compressed = img.encodeJpg(resized, quality: 85);

    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = path.join(tempDir.path, 'grain_$timestamp.jpg');

    final compressedFile = File(filePath);
    await compressedFile.writeAsBytes(compressed);

    return compressedFile;
  }

  void clearCapturedImage() {
    state = state.copyWith(
      capturedImage: null,
      status: CameraStatus.ready,
    );
  }
}
