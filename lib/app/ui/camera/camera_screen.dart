import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';

import 'package:demeterapp/app/core/themes/app_colors.dart';
import 'package:demeterapp/app/ui/camera/camera_view_model.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _overlayScaleAnimation;
  late Animation<Offset> _controlsSlideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _overlayScaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    _controlsSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraViewModelProvider);

    ref.listen<CameraState>(cameraViewModelProvider, (previous, next) {
      if (next.capturedImage != null && previous?.capturedImage == null) {
        Navigator.pushNamed(
          context,
          '/result',
          arguments: next.capturedImage!,
        ).then((_) {
          ref.read(cameraViewModelProvider.notifier).clearCapturedImage();
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          if (cameraState.status == CameraStatus.ready &&
              cameraState.controller != null)
            FadeTransition(
              opacity: _fadeAnimation,
              child: _CameraPreview(controller: cameraState.controller!),
            )
          else if (cameraState.status == CameraStatus.permissionDenied)
            const _PermissionDeniedView()
          else if (cameraState.status == CameraStatus.error)
            _ErrorView(message: cameraState.errorMessage ?? 'Erro desconhecido')
          else
            const _LoadingView(),
          if (cameraState.status == CameraStatus.ready &&
              cameraState.controller != null) ...[
            ScaleTransition(
              scale: _overlayScaleAnimation,
              child: const _FocusOverlay(),
            ),
            const _TopBar(),
            SlideTransition(
              position: _controlsSlideAnimation,
              child: const _BottomBar(),
            ),
          ],
          if (cameraState.status == CameraStatus.capturing ||
              cameraState.status == CameraStatus.processing)
            const _ProcessingOverlay(),
        ],
      ),
    );
  }
}

class _CameraPreview extends StatelessWidget {
  final CameraController controller;

  const _CameraPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize!.height,
          height: controller.value.previewSize!.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

class _FocusOverlay extends StatelessWidget {
  const _FocusOverlay();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final overlaySize = size.width * 0.6;

    return Center(
      child: SizedBox(
        width: overlaySize,
        height: overlaySize,
        child: Stack(
          children: [
            Positioned(top: 0, left: 0, child: _CornerMarker(isTopLeft: true)),
            Positioned(
              top: 0,
              right: 0,
              child: _CornerMarker(isTopRight: true),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: _CornerMarker(isBottomLeft: true),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: _CornerMarker(isBottomRight: true),
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerMarker extends StatelessWidget {
  final bool isTopLeft;
  final bool isTopRight;
  final bool isBottomLeft;
  final bool isBottomRight;

  const _CornerMarker({
    this.isTopLeft = false,
    this.isTopRight = false,
    this.isBottomLeft = false,
    this.isBottomRight = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(48, 48),
      painter: _CornerPainter(
        isTopLeft: isTopLeft,
        isTopRight: isTopRight,
        isBottomLeft: isBottomLeft,
        isBottomRight: isBottomRight,
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool isTopLeft;
  final bool isTopRight;
  final bool isBottomLeft;
  final bool isBottomRight;

  _CornerPainter({
    required this.isTopLeft,
    required this.isTopRight,
    required this.isBottomLeft,
    required this.isBottomRight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    if (isTopLeft) {
      canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), paint);
      canvas.drawLine(const Offset(0, 0), Offset(0, size.height), paint);
    } else if (isTopRight) {
      canvas.drawLine(Offset(size.width, 0), const Offset(0, 0), paint);
      canvas.drawLine(
        Offset(size.width, 0),
        Offset(size.width, size.height),
        paint,
      );
    } else if (isBottomLeft) {
      canvas.drawLine(Offset(0, size.height), const Offset(0, 0), paint);
      canvas.drawLine(
        Offset(0, size.height),
        Offset(size.width, size.height),
        paint,
      );
    } else if (isBottomRight) {
      canvas.drawLine(
        Offset(size.width, size.height),
        Offset(size.width, 0),
        paint,
      );
      canvas.drawLine(
        Offset(size.width, size.height),
        Offset(0, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80 + MediaQuery.of(context).padding.top,
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.4),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        color: AppColors.black,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const _ModeSelector(),
              const SizedBox(height: 24),
              SizedBox(
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: const [
                    Positioned(left: 24, child: _GalleryButton()),
                    Center(child: _CaptureButton()),
                    Positioned(right: 24, child: _SwitchCameraButton()),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  const _ModeSelector();

  @override
  Widget build(BuildContext context) {
    final modes = ['Document', 'Video', 'Photo', 'Portrait', 'Night'];
    final activeMode = 'Photo';

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: modes.length,
        separatorBuilder: (context, index) => const SizedBox(width: 24),
        itemBuilder: (context, index) {
          final mode = modes[index];
          final isActive = mode == activeMode;

          return Center(
            child: Text(
              mode,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                color: isActive ? AppColors.yellow : AppColors.white,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CaptureButton extends ConsumerStatefulWidget {
  const _CaptureButton();

  @override
  ConsumerState<_CaptureButton> createState() => _CaptureButtonState();
}

class _CaptureButtonState extends ConsumerState<_CaptureButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraViewModelProvider);
    final isCapturing = cameraState.status == CameraStatus.capturing;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: (_) {
          if (!isCapturing) {
            _scaleController.forward();
          }
        },
        onTapUp: (_) {
          _scaleController.reverse();
          if (!isCapturing) {
            ref.read(cameraViewModelProvider.notifier).takePicture();
          }
        },
        onTapCancel: () {
          _scaleController.reverse();
        },
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 6),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GalleryButton extends ConsumerWidget {
  const _GalleryButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(cameraViewModelProvider.notifier).pickFromGallery();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.grey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.white, width: 2),
        ),
        child: const Icon(
          Icons.photo_library,
          color: AppColors.white,
          size: 24,
        ),
      ),
    );
  }
}

class _SwitchCameraButton extends ConsumerWidget {
  const _SwitchCameraButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(cameraViewModelProvider.notifier).switchCamera();
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.cameraswitch, color: AppColors.white, size: 24),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Inicializando câmera...',
            style: TextStyle(color: AppColors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _PermissionDeniedView extends ConsumerWidget {
  const _PermissionDeniedView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: AppColors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Permissão de câmera necessária',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Para classificar grãos, precisamos acessar sua câmera.',
              style: TextStyle(color: AppColors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ref
                      .read(cameraViewModelProvider.notifier)
                      .requestPermissions();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Permitir acesso',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Voltar',
                style: TextStyle(color: AppColors.grey, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: AppColors.error),
            const SizedBox(height: 24),
            const Text(
              'Erro',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: AppColors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Voltar',
                style: TextStyle(color: AppColors.grey, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProcessingOverlay extends StatelessWidget {
  const _ProcessingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.black.withValues(alpha: 0.7),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Processando...',
              style: TextStyle(color: AppColors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
