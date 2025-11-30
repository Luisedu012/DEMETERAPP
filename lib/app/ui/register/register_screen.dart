import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:validatorless/validatorless.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'package:demeterapp/app/core/themes/app_colors.dart';
import 'package:demeterapp/app/core/themes/app_text_styles.dart';
import 'package:demeterapp/app/ui/register/register_view_model.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  late AnimationController _animationController;
  late Animation<double> _titleFadeAnimation;
  late Animation<Offset> _titleSlideAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<Offset> _subtitleSlideAnimation;
  late List<Animation<double>> _fieldFadeAnimations;
  late List<Animation<Offset>> _fieldSlideAnimations;

  @override
  void initState() {
    super.initState();

    // Listener reativo para mudanças de estado
    ref.listenManual(registerViewModelProvider, (previous, next) {
      if (!mounted) return;

      if (next.status == RegisterStatus.success) {
        _showSuccessSnackBar();
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
      } else if (next.status == RegisterStatus.error) {
        _showErrorSnackBar(next.errorMessage ?? 'Erro ao criar conta');
      }
    });

    _setupAnimations();
    _animationController.forward();
    _passwordController.addListener(_onPasswordChanged);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _titleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
          ),
        );

    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
      ),
    );

    _subtitleSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
          ),
        );

    _fieldFadeAnimations = List.generate(5, (index) {
      final start = 0.2 + (index * 0.1);
      final end = start + 0.3;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _fieldSlideAnimations = List.generate(5, (index) {
      final start = 0.2 + (index * 0.1);
      final end = start + 0.3;
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });
  }

  void _onPasswordChanged() {
    ref
        .read(registerViewModelProvider.notifier)
        .updatePasswordStrength(_passwordController.text);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(registerViewModelProvider.notifier)
          .register(
            name: _nameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            password: _passwordController.text,
          );
      // O listener em initState cuida da navegação e feedback
    }
  }

  void _showSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Conta criada com sucesso!'),
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

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.length < 2) {
      return 'Nome deve ter no mínimo 2 caracteres';
    }
    if (value.length > 100) {
      return 'Nome muito longo';
    }
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(value)) {
      return 'Nome inválido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Senha é obrigatória';
    }
    if (value.length < 8) {
      return 'Mínimo 8 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Deve conter letra maiúscula';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Deve conter letra minúscula';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Deve conter número';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Deve conter caractere especial (!@#\$%)';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirmação é obrigatória';
    }
    if (value != _passwordController.text) {
      return 'Senhas não conferem';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length != 11) {
      return 'Telefone inválido';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final registerState = ref.watch(registerViewModelProvider);
    final isLoading = registerState.status == RegisterStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.greyDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _buildTitle(),
              const SizedBox(height: 16),
              _buildSubtitle(),
              const SizedBox(height: 32),
              _buildForm(isLoading, registerState),
              const SizedBox(height: 32),
              _buildPoweredBy(),
              const SizedBox(height: 24),
            ],
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
          'Criar Conta',
          style: AppTextStyles.titleMedium,
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
          'Crie sua conta e explore os nossos recursos',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.black),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildForm(bool isLoading, RegisterState state) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAnimatedField(0, _buildNameField(isLoading)),
          const SizedBox(height: 16),
          _buildAnimatedField(1, _buildEmailField(isLoading)),
          const SizedBox(height: 16),
          _buildAnimatedField(2, _buildPasswordField(isLoading)),
          const SizedBox(height: 8),
          _buildPasswordStrengthIndicator(state.passwordStrength),
          const SizedBox(height: 16),
          _buildAnimatedField(3, _buildConfirmPasswordField(isLoading)),
          const SizedBox(height: 16),
          _buildAnimatedField(4, _buildPhoneField(isLoading)),
          const SizedBox(height: 32),
          _buildRegisterButton(isLoading),
          const SizedBox(height: 24),
          _buildLoginLink(),
        ],
      ),
    );
  }

  Widget _buildAnimatedField(int index, Widget child) {
    return FadeTransition(
      opacity: _fieldFadeAnimations[index],
      child: SlideTransition(
        position: _fieldSlideAnimations[index],
        child: child,
      ),
    );
  }

  Widget _buildNameField(bool isLoading) {
    return TextFormField(
      controller: _nameController,
      focusNode: _nameFocusNode,
      textCapitalization: TextCapitalization.words,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      enabled: !isLoading,
      decoration: const InputDecoration(hintText: 'Nome'),
      validator: _validateName,
      onFieldSubmitted: (_) => _emailFocusNode.requestFocus(),
    );
  }

  Widget _buildEmailField(bool isLoading) {
    return TextFormField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      enabled: !isLoading,
      decoration: const InputDecoration(hintText: 'Email'),
      validator: Validatorless.multiple([
        Validatorless.required('Email é obrigatório'),
        Validatorless.email('Email inválido'),
      ]),
      onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
    );
  }

  Widget _buildPasswordField(bool isLoading) {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      obscureText: !_passwordVisible,
      textInputAction: TextInputAction.next,
      enabled: !isLoading,
      decoration: InputDecoration(
        hintText: 'Senha',
        suffixIcon: IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility_off : Icons.visibility,
            color: AppColors.greyMedium,
          ),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
      ),
      validator: _validatePassword,
      onFieldSubmitted: (_) => _confirmPasswordFocusNode.requestFocus(),
    );
  }

  Widget _buildPasswordStrengthIndicator(PasswordStrength? strength) {
    if (strength == null || _passwordController.text.isEmpty) {
      return const SizedBox.shrink();
    }

    Color barColor;
    double barWidth;
    String strengthText;

    switch (strength) {
      case PasswordStrength.weak:
        barColor = AppColors.error;
        barWidth = 0.33;
        strengthText = 'Fraca';
        break;
      case PasswordStrength.medium:
        barColor = AppColors.alert;
        barWidth = 0.66;
        strengthText = 'Média';
        break;
      case PasswordStrength.strong:
        barColor = AppColors.success;
        barWidth = 1.0;
        strengthText = 'Forte';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: barWidth,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Força da senha: $strengthText',
          style: AppTextStyles.bodySmall.copyWith(
            color: barColor,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(bool isLoading) {
    return TextFormField(
      controller: _confirmPasswordController,
      focusNode: _confirmPasswordFocusNode,
      obscureText: !_confirmPasswordVisible,
      textInputAction: TextInputAction.next,
      enabled: !isLoading,
      decoration: InputDecoration(
        hintText: 'Confirme sua senha',
        suffixIcon: IconButton(
          icon: Icon(
            _confirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: AppColors.greyMedium,
          ),
          onPressed: () {
            setState(() {
              _confirmPasswordVisible = !_confirmPasswordVisible;
            });
          },
        ),
      ),
      validator: _validateConfirmPassword,
      onFieldSubmitted: (_) => _phoneFocusNode.requestFocus(),
    );
  }

  Widget _buildPhoneField(bool isLoading) {
    return TextFormField(
      controller: _phoneController,
      focusNode: _phoneFocusNode,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      enabled: !isLoading,
      inputFormatters: [_phoneMask],
      decoration: const InputDecoration(hintText: 'Telefone'),
      validator: _validatePhone,
      onFieldSubmitted: (_) => _handleRegister(),
    );
  }

  Widget _buildRegisterButton(bool isLoading) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _handleRegister,
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Text('Registrar', style: AppTextStyles.buttonLarge),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text(
          'Possuo uma conta',
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
