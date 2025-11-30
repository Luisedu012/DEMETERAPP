import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import 'package:demeterapp/app/core/themes/app_colors.dart';
import 'package:demeterapp/app/ui/profile/profile_view_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _avatarScaleAnimation;
  late Animation<double> _fadeAnimation;

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

    _avatarScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
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
    final profileState = ref.watch(profileViewModelProvider);

    ref.listen<ProfileState>(profileViewModelProvider, (previous, next) {
      if (next.status == ProfileStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Erro desconhecido'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Tentar novamente',
              textColor: AppColors.white,
              onPressed: () {
                ref.read(profileViewModelProvider.notifier).loadProfile();
              },
            ),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _buildBody(profileState),
                ),
              ],
            ),
          ),
          if (profileState.status == ProfileStatus.loggingOut)
            _buildLoadingOverlay(),
        ],
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }

  Widget _buildBody(ProfileState state) {
    if (state.status == ProfileStatus.loading) {
      return _buildLoadingState();
    }

    if (state.profile != null) {
      return _buildLoadedState(state.profile!);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 48),
          _buildShimmerAvatar(),
          const SizedBox(height: 40),
          _buildShimmerSection(),
        ],
      ),
    );
  }

  Widget _buildShimmerAvatar() {
    return Shimmer.fromColors(
      baseColor: AppColors.grey.withValues(alpha: 0.3),
      highlightColor: AppColors.grey.withValues(alpha: 0.1),
      child: Container(
        width: 120,
        height: 120,
        decoration: const BoxDecoration(
          color: AppColors.grey,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildShimmerSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.grey.withValues(alpha: 0.3),
            highlightColor: AppColors.grey.withValues(alpha: 0.1),
            child: Container(
              width: 80,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.black, height: 1),
          const SizedBox(height: 16),
          _buildShimmerItem(),
          const SizedBox(height: 16),
          _buildShimmerItem(),
          const SizedBox(height: 16),
          _buildShimmerItem(),
        ],
      ),
    );
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: AppColors.grey.withValues(alpha: 0.3),
      highlightColor: AppColors.grey.withValues(alpha: 0.1),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 100,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const Spacer(),
          Container(
            width: 120,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(UserProfile profile) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 48),
          ScaleTransition(
            scale: _avatarScaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const _Avatar(),
            ),
          ),
          const SizedBox(height: 40),
          FadeTransition(
            opacity: _fadeAnimation,
            child: _ProfileSection(profile: profile),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: AppColors.black.withValues(alpha: 0.5),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
        border: Border.all(
          color: AppColors.white,
          width: 4,
        ),
      ),
      child: const Icon(
        Icons.person,
        size: 64,
        color: AppColors.white,
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final UserProfile profile;

  const _ProfileSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PERFIL',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.black,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.black, height: 1),
          const SizedBox(height: 16),
          _AnimatedProfileItem(
            icon: Icons.person,
            label: 'Nome',
            value: profile.name,
            delay: 0,
          ),
          const SizedBox(height: 16),
          _AnimatedProfileItem(
            icon: Icons.phone,
            label: 'Telefone',
            value: profile.phone,
            delay: 80,
          ),
          const SizedBox(height: 16),
          _AnimatedProfileItem(
            icon: Icons.email,
            label: 'Email',
            value: profile.email,
            delay: 160,
          ),
          const SizedBox(height: 24),
          const _EditProfileButton(),
          const SizedBox(height: 24),
          const Divider(color: AppColors.black, height: 1),
          const SizedBox(height: 32),
          const _LogoutButton(),
        ],
      ),
    );
  }
}

class _AnimatedProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final int delay;

  const _AnimatedProfileItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + delay),
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
      child: _ProfileItem(
        icon: icon,
        label: label,
        value: value,
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: AppColors.black,
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileButton extends StatelessWidget {
  const _EditProfileButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, '/edit-profile');
        },
        icon: const Icon(
          Icons.edit,
          size: 18,
          color: AppColors.primary,
        ),
        label: const Text(
          'Editar Perfil',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends ConsumerStatefulWidget {
  const _LogoutButton();

  @override
  ConsumerState<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends ConsumerState<_LogoutButton> {
  bool _isPressed = false;

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => _LogoutDialog(
        onConfirm: () async {
          Navigator.pop(dialogContext);
          await ref.read(profileViewModelProvider.notifier).logout();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _showLogoutDialog();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: Transform.scale(
          scale: _isPressed ? 0.95 : 1.0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Text(
              'Sair',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF5722),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const _LogoutDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Sair da conta',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.greyDark,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tem certeza que deseja sair?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.greyMedium,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.grey,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5722),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Sair',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
            isActive: false,
            onTap: () => Navigator.pushNamed(context, '/classifications'),
          ),
          _NavBarItem(
            icon: Icons.person,
            label: 'Perfil',
            isActive: true,
            onTap: () {},
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
