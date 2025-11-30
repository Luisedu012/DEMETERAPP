import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import 'package:demeterapp/app/core/themes/app_colors.dart';
import 'package:demeterapp/app/ui/classifications/classifications_view_model.dart';
import 'package:demeterapp/app/ui/classifications/details_modal.dart';

class ClassificationsScreen extends ConsumerStatefulWidget {
  const ClassificationsScreen({super.key});

  @override
  ConsumerState<ClassificationsScreen> createState() =>
      _ClassificationsScreenState();
}

class _ClassificationsScreenState extends ConsumerState<ClassificationsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupScrollController();
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
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _headerSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );
  }

  void _setupScrollController() {
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(classificationsViewModelProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(classificationsViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Column(
          children: [
            SlideTransition(
              position: _headerSlideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _CustomHeader(
                  dateRange: state.dateRange,
                  onDateRangeTap: () => _showDateRangePicker(context),
                  onClearDateRange: () {
                    ref
                        .read(classificationsViewModelProvider.notifier)
                        .filterByDateRange(null);
                  },
                ),
              ),
            ),
            Expanded(child: _buildBody(state)),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }

  Widget _buildBody(ClassificationsState state) {
    if (state.status == ClassificationsStatus.initial) {
      return _buildShimmerLoading();
    }

    if (state.status == ClassificationsStatus.empty) {
      return _buildEmptyState();
    }

    if (state.status == ClassificationsStatus.error) {
      return _buildErrorState(state.errorMessage);
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(classificationsViewModelProvider.notifier).refresh(),
      color: AppColors.primary,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 16,
          bottom: 24,
        ),
        itemCount:
            state.items.length +
            (state.status == ClassificationsStatus.loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            return const _LoadingMoreIndicator();
          }

          final item = state.items[index];
          return _AnimatedClassificationCard(
            item: item,
            index: index,
            animation: _fadeAnimation,
          );
        },
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: 6,
      itemBuilder: (context, index) => const _ShimmerCard(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: AppColors.greyMedium.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma classificação encontrada',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.greyMedium,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tente ajustar os filtros ou fazer\numa nova classificação',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.greyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 80, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'Erro ao carregar',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.greyMedium,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(classificationsViewModelProvider.notifier).refresh();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'Tentar novamente',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context) async {
    final state = ref.read(classificationsViewModelProvider);
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: state.dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.greyDark,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref
          .read(classificationsViewModelProvider.notifier)
          .filterByDateRange(picked);
    }
  }
}

class _CustomHeader extends StatelessWidget {
  final DateTimeRange? dateRange;
  final VoidCallback onDateRangeTap;
  final VoidCallback onClearDateRange;

  const _CustomHeader({
    required this.dateRange,
    required this.onDateRangeTap,
    required this.onClearDateRange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Lista de classificação',
            style: TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.brown,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _DateRangeSelector(
              dateRange: dateRange,
              onTap: onDateRangeTap,
              onClear: onClearDateRange,
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Todas as classificações',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.greyDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRangeSelector extends StatelessWidget {
  final DateTimeRange? dateRange;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateRangeSelector({
    required this.dateRange,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = dateRange != null
        ? '${DateFormat('dd/MM/yyyy').format(dateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(dateRange!.end)}'
        : 'Selecionar período';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                dateText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: dateRange != null
                      ? AppColors.greyDark
                      : AppColors.greyMedium,
                ),
              ),
            ),
            if (dateRange != null)
              InkWell(
                onTap: () {
                  onClear();
                },
                borderRadius: BorderRadius.circular(20),
                child: const Icon(
                  Icons.close,
                  color: AppColors.greyMedium,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedClassificationCard extends StatelessWidget {
  final ClassificationListItem item;
  final int index;
  final Animation<double> animation;

  const _AnimatedClassificationCard({
    required this.item,
    required this.index,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 60)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: _ClassificationCard(item: item),
    );
  }
}

class _ClassificationCard extends StatelessWidget {
  final ClassificationListItem item;

  const _ClassificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(item.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          showDetailsModal(context, item.id.toString());
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              _CardIcon(grainType: item.grainType),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.grainType,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.greyDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.greyMedium,
                      ),
                    ),
                  ],
                ),
              ),
              _ConfidenceBadge(confidence: item.confidence),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardIcon extends StatelessWidget {
  final String grainType;

  const _CardIcon({required this.grainType});

  IconData get iconData {
    switch (grainType.toUpperCase()) {
      case 'MILHO':
        return Icons.grain;
      case 'SOJA':
        return Icons.eco;
      case 'TRIGO':
        return Icons.bakery_dining;
      case 'ARROZ':
        return Icons.rice_bowl;
      case 'FEIJÃO':
        return Icons.restaurant;
      default:
        return Icons.grass;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(iconData, color: AppColors.primary, size: 24),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor, width: 1.5),
      ),
      child: Text(
        '${(confidence * 100).toStringAsFixed(0)}%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.grey.withValues(alpha: 0.3),
            highlightColor: AppColors.grey.withValues(alpha: 0.1),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: AppColors.grey.withValues(alpha: 0.3),
                  highlightColor: AppColors.grey.withValues(alpha: 0.1),
                  child: Container(
                    width: 120,
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Shimmer.fromColors(
                  baseColor: AppColors.grey.withValues(alpha: 0.3),
                  highlightColor: AppColors.grey.withValues(alpha: 0.1),
                  child: Container(
                    width: 80,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Shimmer.fromColors(
            baseColor: AppColors.grey.withValues(alpha: 0.3),
            highlightColor: AppColors.grey.withValues(alpha: 0.1),
            child: Container(
              width: 50,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingMoreIndicator extends StatelessWidget {
  const _LoadingMoreIndicator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(
            icon: Icons.home_outlined,
            label: 'Início',
            isActive: false,
            onTap: () => Navigator.pushReplacementNamed(context, '/home'),
          ),
          _NavBarItem(
            icon: Icons.search,
            label: 'Buscar',
            isActive: true,
            onTap: () {},
          ),
          _NavBarItem(
            icon: Icons.person_outline,
            label: 'Perfil',
            isActive: false,
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.greyMedium,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.greyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
