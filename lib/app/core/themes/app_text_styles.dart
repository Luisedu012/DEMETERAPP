import 'package:flutter/material.dart';
import 'package:demeterapp/app/core/themes/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _serifFontFamily = 'Cinzel';
  static const String _sansFontFamily = 'Roboto';

  static TextStyle get _serifFont => const TextStyle(fontFamily: _serifFontFamily);
  static TextStyle get _sansSerifFont => const TextStyle(fontFamily: _sansFontFamily);

  static TextStyle get h1 => _sansSerifFont.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.greyDark,
        height: 1.2,
      );

  static TextStyle get h2 => _sansSerifFont.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.greyDark,
        height: 1.3,
      );

  static TextStyle get h3 => _sansSerifFont.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.greyDark,
        height: 1.3,
      );

  static TextStyle get h4 => _sansSerifFont.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.greyDark,
        height: 1.4,
      );

  static TextStyle get bodyLarge => _sansSerifFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.greyDark,
        height: 1.5,
      );

  static TextStyle get bodyMedium => _sansSerifFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.greyDark,
        height: 1.5,
      );

  static TextStyle get bodySmall => _sansSerifFont.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.grey,
        height: 1.5,
      );

  static TextStyle get buttonLarge => _sansSerifFont.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        height: 1.2,
      );

  static TextStyle get buttonMedium => _sansSerifFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
        height: 1.2,
      );

  static TextStyle get buttonSmall => _sansSerifFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
        height: 1.2,
      );

  static TextStyle get labelLarge => _sansSerifFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.greyMedium,
        height: 1.3,
      );

  static TextStyle get labelMedium => _sansSerifFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.greyMedium,
        height: 1.3,
      );

  static TextStyle get labelSmall => _sansSerifFont.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.greyMedium,
        height: 1.3,
      );

  static TextStyle get logoText => _serifFont.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: AppColors.gold,
        letterSpacing: 4.0,
        height: 1.2,
      );

  static TextStyle get logoTextSmall => _serifFont.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        letterSpacing: 2.0,
        height: 1.2,
      );

  static TextStyle get titleLarge => _sansSerifFont.copyWith(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: AppColors.brown,
        height: 1.2,
      );

  static TextStyle get titleMedium => _sansSerifFont.copyWith(
        fontSize: 42,
        fontWeight: FontWeight.w700,
        color: AppColors.brown,
        height: 1.2,
      );

  static TextStyle get titleSmall => _sansSerifFont.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        height: 1.2,
      );

  static TextStyle get sectionTitle => _sansSerifFont.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.brown,
        height: 1.3,
      );

  static TextStyle get cardTitle => _sansSerifFont.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        height: 1.3,
      );

  static TextStyle get cardSubtitle => _sansSerifFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.white,
        height: 1.3,
      );

  static TextStyle get confidenceNumber => _sansSerifFont.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        height: 1.2,
      );

  static TextStyle get confidenceLabel => _sansSerifFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.white,
        height: 1.2,
      );

  static TextStyle get link => _sansSerifFont.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.primary,
        decoration: TextDecoration.underline,
        height: 1.3,
      );

  static TextStyle get error => _sansSerifFont.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.error,
        height: 1.3,
      );

  static TextStyle get placeholder => _sansSerifFont.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.greyMedium,
        height: 1.5,
      );
}
