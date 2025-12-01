import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:demeterapp/app/core/themes/app_colors.dart';
import 'package:demeterapp/app/ui/classifications/details_view_model.dart';

void showDetailsModal(BuildContext context, String classificationId) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: AppColors.black.withValues(alpha: 0.5),
    builder: (context) => _DetailsModal(classificationId: int.parse(classificationId)),
  );
}

class _DetailsModal extends ConsumerStatefulWidget {
  final int classificationId;

  const _DetailsModal({required this.classificationId});

  @override
  ConsumerState<_DetailsModal> createState() => _DetailsModalState();
}

class _DetailsModalState extends ConsumerState<_DetailsModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scrimAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scrimAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _closeModal() async {
    await _animationController.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailsState = ref.watch(
      detailsViewModelProvider(widget.classificationId),
    );

    ref.listen<DetailsState>(
      detailsViewModelProvider(widget.classificationId),
      (previous, next) {
        if (next.status == DetailsStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage ?? 'Erro ao carregar detalhes'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              _closeModal();
            }
          });
        }
      },
    );

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _closeModal();
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: FadeTransition(
          opacity: _scrimAnimation,
          child: GestureDetector(
            onTap: _closeModal,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
              child: Center(
                child: GestureDetector(
                  onTap: () {},
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildContent(detailsState),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(DetailsState state) {
    if (state.status == DetailsStatus.loading) {
      return _buildLoadingState();
    }

    if (state.status == DetailsStatus.error) {
      return _buildErrorState();
    }

    if (state.details != null) {
      return _buildLoadedState(state.details!);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadingState() {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      width: double.infinity,
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              'Carregando detalhes...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.greyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          const Text(
            'Erro ao carregar detalhes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.greyDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Fechando automaticamente...',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.greyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(ClassificationDetails details) {
    final screenHeight = MediaQuery.of(context).size.height;
    final formattedDate = DateFormat('dd/MM/yyyy').format(details.timestamp);

    return Container(
      width: double.infinity,
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ResultCard(details: details),
                  const SizedBox(height: 16),
                  _QualityBadge(details: details),
                  const SizedBox(height: 16),
                  _AISummaryCard(details: details),
                  const SizedBox(height: 24),
                  _DetailsSection(details: details, formattedDate: formattedDate),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 24),
            child: _buildBackButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: _closeModal,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        child: const Text(
          'Voltar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final ClassificationDetails details;

  const _ResultCard({required this.details});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            details.grainType,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.greyDark,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Confiança: ${details.confidence.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.greyMedium,
            ),
          ),
          const SizedBox(height: 16),
          _ConfidenceBadge(confidence: details.confidence / 100),
        ],
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
  final ClassificationDetails details;
  final String formattedDate;

  const _DetailsSection({
    required this.details,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
        if (details.grainsDetected != null) ...[
          _DetailItem(
            label: 'Grãos detectados',
            value: details.grainsDetected.toString(),
          ),
          const SizedBox(height: 12),
        ],
        if (details.defectPercentage != null) ...[
          _DetailItem(
            label: 'Defeitos',
            value: '${details.defectPercentage!.toStringAsFixed(1)}%',
          ),
          const SizedBox(height: 12),
        ],
        _DetailItem(label: 'Data', value: formattedDate),
      ],
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

class _QualityBadge extends StatelessWidget {
  final ClassificationDetails details;

  const _QualityBadge({required this.details});

  @override
  Widget build(BuildContext context) {
    final percentage = details.defectPercentage ?? 0.0;
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
  final ClassificationDetails details;

  const _AISummaryCard({required this.details});

  @override
  State<_AISummaryCard> createState() => _AISummaryCardState();
}

class _AISummaryCardState extends State<_AISummaryCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final summary = widget.details.llmSummary;

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
