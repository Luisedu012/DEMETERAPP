import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              color: AppColors.grey.withValues(alpha: 0.2),
              child: Center(
                child: Shimmer.fromColors(
                  baseColor: AppColors.grey.withValues(alpha: 0.3),
                  highlightColor: AppColors.grey.withValues(alpha: 0.1),
                  child: const Icon(
                    Icons.image,
                    size: 80,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: _buildShimmerCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFB3E9B6),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerRow(),
          const SizedBox(height: 16),
          _buildShimmerRow(),
          const SizedBox(height: 16),
          _buildShimmerRow(),
          const SizedBox(height: 16),
          _buildShimmerRow(),
          const Spacer(),
          Center(
            child: Shimmer.fromColors(
              baseColor: const Color(0xFF2E5C2E).withValues(alpha: 0.5),
              highlightColor: const Color(0xFF2E5C2E).withValues(alpha: 0.1),
              child: Container(
                width: 100,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E5C2E),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerRow() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF2E5C2E).withValues(alpha: 0.3),
      highlightColor: const Color(0xFF2E5C2E).withValues(alpha: 0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 120,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF2E5C2E),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Container(
            width: 80,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF2E5C2E),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
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
        color: AppColors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: _buildImage(details),
          ),
          Expanded(
            flex: 4,
            child: _buildInfoCard(details, formattedDate),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(ClassificationDetails details) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: CachedNetworkImage(
        imageUrl: details.imagePath,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.grey.withValues(alpha: 0.2),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.grey.withValues(alpha: 0.2),
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              size: 64,
              color: AppColors.greyMedium,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(ClassificationDetails details, String formattedDate) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFB3E9B6),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 16),
              child: Column(
                children: [
                  _buildInfoRow('Tipo de Grão:', details.grainType),
                  const SizedBox(height: 16),
                  _buildInfoRow('Confiança:', '${details.confidence}%'),
                  const SizedBox(height: 24),
                  _QualityBadge(details: details),
                  const SizedBox(height: 16),
                  _AISummaryCard(details: details),
                  const SizedBox(height: 24),
                  _buildInfoRow('Data:', formattedDate),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
            child: _buildBackButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E5C2E),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E5C2E),
          ),
        ),
      ],
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
            color: Color(0xFF2E5C2E),
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
