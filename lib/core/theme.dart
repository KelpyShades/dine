import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppColors {
  static const Color black = Color(0xFF141414);
  static const Color darkGreen = Color(0xFF1f382d);
  static const Color lightGreen = Color(0xFFece4df);
  static const Color orange = Color(0xFFff5f14);
  static const Color red = Color(0xFFd23d2d);
}

final themeProvider = Provider<ThemeData>((ref) {
  return ThemeData(
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.orange,
      onPrimary: Colors.white,
      secondary: AppColors.darkGreen,
      onSecondary: Colors.white,
      error: AppColors.red,
      onError: Colors.white,
      surface: AppColors.lightGreen,
      onSurface: AppColors.black,
    ),
    scaffoldBackgroundColor: AppColors.lightGreen,
    // appBarTheme: const AppBarTheme(
    //   backgroundColor: AppColors.darkGreen,
    //   foregroundColor: AppColors.lightGreen,
    //   elevation: 0,
    // ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.orange,
        foregroundColor: AppColors.black,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.darkGreen),
    ),
    useMaterial3: true,
    fontFamily: 'Poppins',
  );
});
