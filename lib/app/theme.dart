import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  AppColors._();

  // ── Brand Colors ──────────────────────────────────────────────────────────
  static const Color primaryOrange  = Color(0xFFFF7F0E);
  static const Color primaryBrown   = Color(0xFF8B5A3C);
  static const Color primaryRed     = Color(0xFFD93B3B);

  // ── Semantic Colors ───────────────────────────────────────────────────────
  static const Color successGreen   = Color(0xFF58CC02);
  static const Color successDark    = Color(0xFF45A800);
  static const Color warningYellow  = Color(0xFFFFC800);
  static const Color xpBlue         = Color(0xFF1CB0F6);
  static const Color xpBlueDark     = Color(0xFF0D94CC);

  // ── Neutral ───────────────────────────────────────────────────────────────
  static const Color darkText       = Color(0xFF3C3C3C);
  static const Color mediumText     = Color(0xFF777777);
  static const Color lightGrey      = Color(0xFFF7F7F7);
  static const Color borderGrey     = Color(0xFFE5E5E5);
  static const Color lockedGrey     = Color(0xFFAFAFAF);
  static const Color white          = Color(0xFFFFFFFF);

  // ── Surface Colors ────────────────────────────────────────────────────────
  static const Color cardWhite      = Color(0xFFFFFFFF);
  static const Color scaffoldBg     = Color(0xFFFAFAF8);

  // ── Gradient Presets ──────────────────────────────────────────────────────
  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFF9A3C), Color(0xFFFF6B00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brownGradient = LinearGradient(
    colors: [Color(0xFFA0704E), Color(0xFF6B3F22)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF7AE819), Color(0xFF58CC02)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  AppTheme._();

  // ── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.07),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> buttonShadow(Color color) => [
    BoxShadow(
      color: Color.lerp(color, Colors.black, 0.35)!.withOpacity(0.8),
      blurRadius: 0,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  // ── Light Theme ───────────────────────────────────────────────────────────
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primaryOrange,
      primary:   AppColors.primaryOrange,
      secondary: AppColors.primaryBrown,
      surface:   AppColors.cardWhite,
      error:     AppColors.primaryRed,
    ),
    scaffoldBackgroundColor: AppColors.scaffoldBg,
    fontFamily: 'Nunito',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: TextStyle(
        fontFamily: 'Nunito',
        color: AppColors.darkText,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge:  TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, color: AppColors.darkText),
      displayMedium: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w900, color: AppColors.darkText),
      headlineLarge: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: AppColors.darkText),
      headlineMedium:TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: AppColors.darkText),
      headlineSmall: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: AppColors.darkText),
      titleLarge:    TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, color: AppColors.darkText),
      titleMedium:   TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: AppColors.darkText),
      bodyLarge:     TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, color: AppColors.darkText),
      bodyMedium:    TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w500, color: AppColors.mediumText),
      labelLarge:    TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, letterSpacing: 0.5),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.borderGrey, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.borderGrey, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryOrange, width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryRed, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primaryRed, width: 2.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: const TextStyle(
        fontFamily: 'Nunito',
        color: AppColors.lockedGrey,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkText,
      contentTextStyle: const TextStyle(
        fontFamily: 'Nunito',
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
