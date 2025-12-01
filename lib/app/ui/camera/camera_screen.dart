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

class _CameraScreenState extends ConsumerState<CameraScreen> {
  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraViewModelProvider);

    ref.listen<CameraState>(cameraViewModelProvider, (prev, next) {
      if (next.capturedImage != null && prev?.capturedImage == null) {
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
          _buildMainView(cameraState),

          if (cameraState.status == CameraStatus.ready &&
              cameraState.controller != null) ...[
            const _FocusOverlay(),
            const _TopBar(),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSlide(
                offset: Offset.zero,
                duration: const Duration(milliseconds: 400),
                child: const _BottomBar(),
              ),
            ),
          ],

          if (cameraState.status == CameraStatus.capturing ||
              cameraState.status == CameraStatus.processing)
            const _StateOverlay(title: 'Processando...', showLoader: true),
        ],
      ),
    );
  }

  Widget _buildMainView(CameraState state) {
    if (state.status == CameraStatus.ready && state.controller != null) {
      return AnimatedOpacity(
        opacity: 1,
        duration: const Duration(milliseconds: 300),
        child: _CameraPreview(controller: state.controller!),
      );
    }

    if (state.status == CameraStatus.permissionDenied) {
      return _StateOverlay(
        title: 'Permissão necessária',
        message: 'Precisamos de acesso à câmera.',
        buttonLabel: 'Permitir acesso',
        onPressed: () {
          ref.read(cameraViewModelProvider.notifier).requestPermissions();
        },
      );
    }

    if (state.status == CameraStatus.error) {
      return _StateOverlay(
        title: 'Erro',
        message: state.errorMessage ?? 'Erro desconhecido',
        buttonLabel: 'Voltar',
        onPressed: () => Navigator.pop(context),
      );
    }

    return const _StateOverlay(
      title: 'Inicializando câmera...',
      showLoader: true,
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
    return SizedBox.expand(child: CameraPreview(controller));
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80 + MediaQuery.of(context).padding.top,
        color: AppColors.black.withValues(alpha: 0.4),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: SafeArea(
              bottom: false,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.white,
                  size: 28,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends ConsumerWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppColors.black,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: SizedBox(
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 24,
                  child: _ActionButton(
                    size: 56,
                    icon: Icons.photo_library,
                    onTap: () => ref
                        .read(cameraViewModelProvider.notifier)
                        .pickFromGallery(),
                  ),
                ),
                const _CaptureButton(),
                Positioned(
                  right: 24,
                  child: _ActionButton(
                    size: 48,
                    icon: Icons.cameraswitch,
                    shape: BoxShape.circle,
                    background: AppColors.black.withValues(alpha: 0.6),
                    onTap: () => ref
                        .read(cameraViewModelProvider.notifier)
                        .switchCamera(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CaptureButton extends ConsumerStatefulWidget {
  const _CaptureButton();

  @override
  ConsumerState<_CaptureButton> createState() => _CaptureButtonState();
}

class _CaptureButtonState extends ConsumerState<_CaptureButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isCapturing =
        ref.watch(cameraViewModelProvider).status == CameraStatus.capturing;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (!isCapturing) {
          ref.read(cameraViewModelProvider.notifier).takePicture();
        }
      },
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1,
        duration: const Duration(milliseconds: 120),
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

class _ActionButton extends StatelessWidget {
  final double size;
  final IconData icon;
  final VoidCallback onTap;
  final BoxShape shape;
  final Color background;

  const _ActionButton({
    required this.size,
    required this.icon,
    required this.onTap,
    this.shape = BoxShape.rectangle,
    this.background = AppColors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          shape: shape,
          borderRadius: shape == BoxShape.rectangle
              ? BorderRadius.circular(8)
              : null,
          border: Border.all(color: AppColors.white, width: 2),
        ),
        child: Icon(icon, color: AppColors.white, size: 24),
      ),
    );
  }
}

// ================= OVERLAY DE FOCO =================

class _FocusOverlay extends StatelessWidget {
  const _FocusOverlay();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.6;

    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _FocusPainter()),
      ),
    );
  }
}

class _FocusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    const len = 32.0;

    // Top left
    canvas.drawLine(const Offset(0, 0), Offset(len, 0), paint);
    canvas.drawLine(const Offset(0, 0), Offset(0, len), paint);

    // Top right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - len, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);

    // Bottom left
    canvas.drawLine(
      Offset(0, size.height),
      Offset(0, size.height - len),
      paint,
    );
    canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint);

    // Bottom right
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width - len, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, size.height),
      Offset(size.width, size.height - len),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ================= VIEW GENÉRICA DE ESTADOS =================

class _StateOverlay extends StatelessWidget {
  final String title;
  final String? message;
  final bool showLoader;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  const _StateOverlay({
    required this.title,
    this.message,
    this.showLoader = false,
    this.buttonLabel,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.black.withValues(alpha: 0.7),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showLoader)
                const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.grey),
                ),
              ],
              if (buttonLabel != null) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text(buttonLabel!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
