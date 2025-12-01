import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'package:demeterapp/app/core/themes/app_colors.dart';
import 'package:demeterapp/app/ui/profile/edit_profile_view_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editState = ref.watch(editProfileViewModelProvider);

    if (editState.status == EditProfileStatus.editing &&
        _nameController.text.isEmpty) {
      _nameController.text = editState.name;
      _emailController.text = editState.email;
      _phoneController.text = editState.phone;
    }

    ref.listen<EditProfileState>(editProfileViewModelProvider,
        (previous, next) {
      if (next.status == EditProfileStatus.saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      } else if (next.status == EditProfileStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Erro ao atualizar perfil'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    final isSaving = editState.status == EditProfileStatus.saving;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 2,
        centerTitle: true,
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildNameField(),
                  const SizedBox(height: 16),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildPhoneField(),
                  const SizedBox(height: 32),
                  const Divider(color: AppColors.grey, height: 1),
                  const SizedBox(height: 32),
                  const _SectionTitle(title: 'Alterar Senha'),
                  const SizedBox(height: 16),
                  _buildCurrentPasswordField(),
                  const SizedBox(height: 16),
                  _buildNewPasswordField(),
                  const SizedBox(height: 16),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
          if (isSaving) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return _EditableField(
      controller: _nameController,
      label: 'Nome',
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value != null && value.isNotEmpty && value.length < 3) {
          return 'Nome deve ter no mínimo 3 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return _ReadOnlyField(
      controller: _emailController,
      label: 'Email',
      hint: 'Não editável',
    );
  }

  Widget _buildPhoneField() {
    return _EditableField(
      controller: _phoneController,
      label: 'Telefone',
      keyboardType: TextInputType.phone,
      inputFormatters: [_phoneMaskFormatter],
      validator: (value) {
        if (value != null && value.isNotEmpty && value.length < 14) {
          return 'Telefone inválido';
        }
        return null;
      },
    );
  }

  Widget _buildCurrentPasswordField() {
    return _PasswordField(
      controller: _currentPasswordController,
      label: 'Senha atual',
      validator: (value) => null,
    );
  }

  Widget _buildNewPasswordField() {
    return _PasswordField(
      controller: _newPasswordController,
      label: 'Nova senha',
      validator: (value) {
        if (value != null && value.isNotEmpty && value.length < 8) {
          return 'Senha deve ter no mínimo 8 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return _PasswordField(
      controller: _confirmPasswordController,
      label: 'Confirme nova senha',
      validator: (value) {
        if (_newPasswordController.text.isNotEmpty) {
          if (value == null || value.isEmpty) {
            return 'Confirmação de senha é obrigatória';
          }
          if (value != _newPasswordController.text) {
            return 'Senhas não conferem';
          }
        }
        return null;
      },
    );
  }

  Widget _buildSaveButton() {
    final isSaving =
        ref.watch(editProfileViewModelProvider).status ==
            EditProfileStatus.saving;

    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isSaving ? null : _saveChanges,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor:
              AppColors.primary.withValues(alpha: 0.6),
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
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : const Text(
                'Salvar Alterações',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                ),
              ),
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

  void _saveChanges() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final editState = ref.read(editProfileViewModelProvider);

    final nameChanged = _nameController.text.trim() != editState.name;
    final phoneDigits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final originalPhoneDigits = editState.phone.replaceAll(RegExp(r'[^0-9]'), '');
    final phoneChanged = phoneDigits != originalPhoneDigits;

    final passwordFilled = _newPasswordController.text.isNotEmpty;

    if (passwordFilled) {
      ref.read(editProfileViewModelProvider.notifier).changePassword(
            _newPasswordController.text,
          );
    } else if (nameChanged || phoneChanged) {
      ref.read(editProfileViewModelProvider.notifier).updateProfile(
            nameChanged ? _nameController.text.trim() : editState.name,
            phoneChanged ? phoneDigits : originalPhoneDigits,
          );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const _EditableField({
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF1F4FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const _ReadOnlyField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFE0E0E0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      style: const TextStyle(
        color: AppColors.greyMedium,
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    this.validator,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        filled: true,
        fillColor: const Color(0xFFF1F4FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: AppColors.greyMedium,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    );
  }
}
