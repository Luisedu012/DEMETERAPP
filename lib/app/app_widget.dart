import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:io';
import 'package:demeterapp/app/core/themes/app_theme.dart';
import 'package:demeterapp/app/ui/splash/splash_screen.dart';
import 'package:demeterapp/app/ui/login/login_screen.dart';
import 'package:demeterapp/app/ui/register/register_screen.dart';
import 'package:demeterapp/app/ui/home/home_screen.dart';
import 'package:demeterapp/app/ui/camera/camera_screen.dart';
import 'package:demeterapp/app/ui/camera/result_screen.dart';
import 'package:demeterapp/app/ui/classifications/classifications_screen.dart';
import 'package:demeterapp/app/ui/profile/profile_screen.dart';
import 'package:demeterapp/app/ui/profile/edit_profile_screen.dart';

class AppWidget extends ConsumerWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Demeter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/camera': (context) => const CameraScreen(),
        '/classifications': (context) => const ClassificationsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/result') {
          final imageFile = settings.arguments as File;
          return MaterialPageRoute(
            builder: (context) => ResultScreen(imageFile: imageFile),
          );
        }
        return null;
      },
    );
  }
}
