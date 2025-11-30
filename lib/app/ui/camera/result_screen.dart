import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:demeterapp/app/core/themes/app_colors.dart';
import 'package:demeterapp/app/ui/camera/result_view_model.dart';

class ResultScreen extends ConsumerStatefulWidget {
  final File imageFile;

  const ResultScreen({super.key, required this.imageFile});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _imageScaleAnimation;
  late Animation<Offset> _cardSlideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();

    Future.microtask(() {
      ref.read(resultViewModelProvider.notifier).loadResult(widget.imageFile);
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _imageScaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _cardSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
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
    final resultState = ref.watch(resultViewModelProvider);

    ref.listen<ResultState>(resultViewModelProvider, (previous, next) {
      if (next.status == ResultStatus.saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Classificação salva com sucesso!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else if (next.status == ResultStatus.error) {
        final errorMsg = next.errorMessage ?? '';
        final isNoGrainsError =
            errorMsg.contains('grão') ||
            errorMsg.contains('detectar') ||
            errorMsg.contains('iluminação') ||
            errorMsg.contains('foto');

        if (isNoGrainsError) {
          _showNoGrainsDetectedDialog(context, errorMsg);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg.isEmpty ? 'Erro desconhecido' : errorMsg),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Resultado'),
        centerTitle: true,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.greyDark,
        elevation: 1,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body:
          resultState.status == ResultStatus.loaded &&
              resultState.result != null
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _imageScaleAnimation,
                      child: _ImagePreview(imageFile: widget.imageFile),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SlideTransition(
                    position: _cardSlideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _ResultCard(result: resultState.result!),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _QualityBadge(result: resultState.result!),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _AISummaryCard(result: resultState.result!),
                  ),
                  const SizedBox(height: 24),
                  _DetailsSection(result: resultState.result!),
                  const SizedBox(height: 32),
                  _ActionButtons(
                    isSaving: resultState.status == ResultStatus.saving,
                    onSave: () {
                      ref
                          .read(resultViewModelProvider.notifier)
                          .saveClassification();
                    },
                    onDiscard: () => _showDiscardDialog(context),
                    onNewClassification: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/camera',
                        (route) => false,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
    );
  }

  void _showDiscardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar classificação?'),
        content: const Text(
          'Esta ação não pode ser desfeita. Tem certeza que deseja descartar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
  }

  void _showNoGrainsDetectedDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error_outline, color: AppColors.alert, size: 64),
        title: const Text(
          'Nenhum grão detectado',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.greyDark,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.isNotEmpty
                  ? message
                  : 'Não foi possível detectar grãos na imagem.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Dicas para melhores resultados:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('• Tire a foto mais próxima dos grãos'),
                  Text('• Garanta boa iluminação'),
                  Text('• Evite sombras e reflexos'),
                  Text('• Foque apenas nos grãos'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
            child: const Text('Voltar ao início'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/camera',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text(
              'Tirar nova foto',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final File imageFile;

  const _ImagePreview({required this.imageFile});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.4;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: imageHeight,
          width: double.infinity,
          child: Image.file(imageFile, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _ResultCard extends StatefulWidget {
  final ClassificationResult result;

  const _ResultCard({required this.result});

  @override
  State<_ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<_ResultCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 50),
        ]).animate(
          CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
        );

    _pulseController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            const _CheckIcon(),
            const SizedBox(height: 16),
            Text(
              widget.result.grainType,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.greyDark,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Confiança: ${(widget.result.confidence * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.greyMedium,
              ),
            ),
            const SizedBox(height: 16),
            ScaleTransition(
              scale: _pulseAnimation,
              child: _ConfidenceBadge(confidence: widget.result.confidence),
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckIcon extends StatelessWidget {
  const _CheckIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, color: AppColors.white, size: 40),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final double confidence;

  const _ConfidenceBadge({required this.confidence});

  Color get badgeColor {
    if (confidence > 0.9) return AppColors.success;
    if (confidence >= 0.7) return AppColors.alert;
    return AppColors.error;
  }

  String get badgeText {
    if (confidence > 0.9) return 'Excelente';
    if (confidence >= 0.7) return 'Bom';
    return 'Baixo';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor, width: 1.5),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  final ClassificationResult result;

  const _DetailsSection({required this.result});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(result.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detalhes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.brown,
            ),
          ),
          const SizedBox(height: 16),
          _DetailItem(
            label: 'Grãos detectados',
            value: result.grainsDetected?.toString() ?? 'N/A',
          ),
          const SizedBox(height: 12),
          if (result.defectPercentage != null)
            _DetailItem(
              label: 'Defeitos',
              value: '${result.defectPercentage!.toStringAsFixed(1)}%',
            ),
          if (result.defectPercentage != null) const SizedBox(height: 12),
          const SizedBox(height: 12),
          _DetailItem(label: 'Data', value: formattedDate),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.greyMedium,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.greyDark,
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onSave;
  final VoidCallback onDiscard;
  final VoidCallback onNewClassification;

  const _ActionButtons({
    required this.isSaving,
    required this.onSave,
    required this.onDiscard,
    required this.onNewClassification,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isSaving ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.6,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    )
                  : const Text(
                      'Salvar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isSaving ? null : onDiscard,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.grey,
                disabledBackgroundColor: AppColors.grey.withValues(alpha: 0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Descartar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: isSaving ? null : onNewClassification,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Nova Classificação',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QualityBadge extends StatelessWidget {
  final ClassificationResult result;

  const _QualityBadge({required this.result});

  @override
  Widget build(BuildContext context) {
    final percentage = result.defectPercentage ?? 0.0;
    final quality = percentage < 20
        ? 'EXCELENTE'
        : percentage < 50
        ? 'REGULAR'
        : 'RUIM';
    final color = percentage < 20
        ? AppColors.success
        : percentage < 50
        ? AppColors.alert
        : AppColors.error;
    final icon = percentage < 20
        ? Icons.check_circle
        : percentage < 50
        ? Icons.warning
        : Icons.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quality,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}% defeitos',
                  style: TextStyle(fontSize: 14, color: color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AISummaryCard extends StatefulWidget {
  final ClassificationResult result;

  const _AISummaryCard({required this.result});

  @override
  State<_AISummaryCard> createState() => _AISummaryCardState();
}

class _AISummaryCardState extends State<_AISummaryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final summary = widget.result.llmSummary;

    if (summary == null || summary.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.psychology,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Análise da IA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greyDark,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.greyMedium,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                summary,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.greyDark,
                  height: 1.5,
                ),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
