import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:validatorless/validatorless.dart';

import 'package:demeterapp/app/core/themes/app_colors.dart';
import 'package:demeterapp/app/core/themes/app_text_styles.dart';
import 'package:demeterapp/app/ui/login/login_view_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  late AnimationController _animationController;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<Offset> _subtitleSlideAnimation;
  late Animation<double> _formFadeAnimation;
  late Animation<Offset> _formSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Listener reativo para mudanças de estado
    ref.listenManual(loginViewModelProvider, (previous, next) {
      if (!mounted) return;

      if (next.status == LoginStatus.success) {
        _showSuccessSnackBar();
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        });
      } else if (next.status == LoginStatus.error) {
        _showErrorSnackBar(next.errorMessage ?? 'Erro ao fazer login');
        _passwordController.clear();
      }
    });

    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
          ),
        );

    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
      ),
    );

    _subtitleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.1, 0.6, curve: Curves.easeOut),
          ),
        );

    _formFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _formSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
          ),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(loginViewModelProvider.notifier)
          .login(_emailController.text, _passwordController.text);
      // O listener em initState cuida da navegação e feedback
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Login realizado com sucesso!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewModelProvider);
    final isLoading = loginState.status == LoginStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
            child: Column(
              children: [
                const Spacer(flex: 2),
                _buildTitle(),
                const SizedBox(height: 24),
                _buildSubtitle(),
                const SizedBox(height: 48),
                _buildForm(isLoading),
                const Spacer(flex: 2),
                _buildPoweredBy(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return FadeTransition(
      opacity: _titleFadeAnimation,
      child: SlideTransition(
        position: _titleSlideAnimation,
        child: Text(
          'Login',
          style: AppTextStyles.titleLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return FadeTransition(
      opacity: _subtitleFadeAnimation,
      child: SlideTransition(
        position: _subtitleSlideAnimation,
        child: Text(
          'Bem vindo de volta!',
          style: AppTextStyles.h2,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildForm(bool isLoading) {
    return FadeTransition(
      opacity: _formFadeAnimation,
      child: SlideTransition(
        position: _formSlideAnimation,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildEmailField(),
              const SizedBox(height: 16),
              _buildPasswordField(),
              const SizedBox(height: 12),
              _buildForgotPasswordLink(),
              const SizedBox(height: 32),
              _buildLoginButton(isLoading),
              const SizedBox(height: 24),
              _buildCreateAccountLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      enabled: ref.watch(loginViewModelProvider).status != LoginStatus.loading,
      decoration: const InputDecoration(hintText: 'Email'),
      validator: Validatorless.multiple([
        Validatorless.required('Email é obrigatório'),
        Validatorless.email('Email inválido'),
      ]),
      onFieldSubmitted: (_) {
        _passwordFocusNode.requestFocus();
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      obscureText: true,
      textInputAction: TextInputAction.done,
      enabled: ref.watch(loginViewModelProvider).status != LoginStatus.loading,
      decoration: const InputDecoration(hintText: 'Senha'),
      validator: Validatorless.multiple([
        Validatorless.required('Senha é obrigatória'),
        Validatorless.min(8, 'Senha deve ter no mínimo 8 caracteres'),
      ]),
      onFieldSubmitted: (_) => _handleLogin(),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Em breve'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Esqueceu sua senha?',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _buildLoginButton(bool isLoading) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleLogin,
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Text('Entrar', style: AppTextStyles.buttonLarge),
      ),
    );
  }

  Widget _buildCreateAccountLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, '/register');
        },
        child: Text(
          'Criar nova conta',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.greyDark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPoweredBy() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Powered By',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          'Genius',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
