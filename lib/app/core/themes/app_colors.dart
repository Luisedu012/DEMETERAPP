import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryLight = Color(0xFFA4F9A8);
  static const Color primaryLighter = Color(0xFFB3F9B6);
  static const Color primaryDark = Color(0xFF375038);
  static const Color primaryDarker = Color(0xFF2E5C2E);
  static const Color accent = Color(0xFFB3E9B6);

  static const Color brown = Color(0xFF8D6E63);
  static const Color gold = Color(0xFFC9A961);
  static const Color yellow = Color(0xFFF9D71C);

  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFAFAFA);
  static const Color black = Color(0xFF000000);
  static const Color greyLight = Color(0xFFF1F4FF);
  static const Color greyLighter = Color(0xFFD9D9D9);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyMedium = Color(0xFF626262);
  static const Color greyDark = Color(0xFF494949);
  static const Color greyBorder = Color(0xFFE0E0E0);

  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF5722);
  static const Color alert = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);

  static const Color beige = Color(0xFFF5F5DC);
  static const Color scrim = Color(0x80000000);

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFA4F9A8), Color(0xFFA4F9A8), Color(0xFFFFFFFF)],
    stops: [0.0, 0.5, 1.0],
  );
}
