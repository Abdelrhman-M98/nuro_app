import 'package:flutter/material.dart';
import 'package:nervix_app/Core/utils/const.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: kBackgroundColor,
      primaryColor: kPrimaryColor,
      colorScheme: const ColorScheme.dark(
        primary: kPrimaryColor,
        secondary: kAccentColor,
        surface: kSurfaceColor,
        error: kErrorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black87,
        onSurface: kOnSurfaceColor,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: kOnBackgroundColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: kSurfaceColor,
        labelStyle: const TextStyle(color: kOnSurfaceVariantColor),
        hintStyle: const TextStyle(color: kOnSurfaceVariantColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kSurfaceLightColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kAccentColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kErrorColor),
        ),
      ),
      cardTheme: CardThemeData(
        color: kSurfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: kSurfaceLightColor,
        contentTextStyle: const TextStyle(color: kOnBackgroundColor),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
