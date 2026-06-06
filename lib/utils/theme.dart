import 'package:flutter/material.dart';

class AppTheme {
  // Color palette matching the original RepFiles design EXACTLY
  // Dark theme (Nocturnal Mode) - Primary colors
  static const Color primaryColor = Color(0xFF00FF00); // Bright green
  static const Color primaryLight = Color(0xFF00D4FF); // Cyan
  static const Color secondaryColor = Color(0xFF00FF00); // Green
  static const Color accentColor = Color(0xFFFFA500); // Orange
  
  // Background colors (Dark theme)
  static const Color bgPrimary = Color(0xFF1A1A1A);
  static const Color bgSecondary = Color(0xFF2C2C2C);
  static const Color bgTertiary = Color(0xFF3A3A3A);
  
  // Text colors (Dark theme)
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFCCCCCC);
  static const Color textLight = Color(0xFF999999);
  
  // Status colors (Dark theme)
  static const Color successColor = Color(0xFF00FF00); // Green
  static const Color warningColor = Color(0xFFFFA500); // Orange
  static const Color dangerColor = Color(0xFFFF0000); // Red
  static const Color infoColor = Color(0xFF00D4FF); // Cyan
  
  // Border colors (Dark theme)
  static const Color borderColor = Color(0xFF4A4A4A);
  static const Color borderLight = Color(0xFF3A3A3A);
  
  // Light theme colors (Diurnal Mode)
  static const Color lightPrimaryColor = Color(0xFF2C5530);
  static const Color lightPrimaryLight = Color(0xFF4A7C59);
  static const Color lightSecondaryColor = Color(0xFF8BC34A);
  static const Color lightAccentColor = Color(0xFFFF9800);
  static const Color lightSuccessColor = Color(0xFF4CAF50);
  static const Color lightWarningColor = Color(0xFFFF9800);
  static const Color lightDangerColor = Color(0xFFF44336);
  static const Color lightInfoColor = Color(0xFF2196F3);
  
  // Light theme backgrounds
  static const Color lightBgPrimary = Color(0xFFFFFFFF);
  static const Color lightBgSecondary = Color(0xFFF8F9FA);
  static const Color lightBgTertiary = Color(0xFFE9ECEF);
  
  // Light theme text colors
  static const Color lightTextPrimary = Color(0xFF333333);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightTextLight = Color(0xFF999999);
  
  // Light theme border colors
  static const Color lightBorderColor = Color(0xFFE0E0E0);
  static const Color lightBorderLight = Color(0xFFF1F3F4);
  
  // Shadows
  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 25,
      offset: Offset(0, 10),
    ),
  ];
  
  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
  
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  // Border radius
  static const double borderRadius = 8.0;
  static const double borderRadiusLg = 12.0;
  static const double borderRadiusSm = 4.0;

  // Transitions
  static const Duration transition = Duration(milliseconds: 300);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: bgSecondary,
        surfaceContainerHighest: bgTertiary,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        error: dangerColor,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: bgSecondary,
      appBarTheme: AppBarTheme(
        backgroundColor: bgPrimary,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: true,
        shadowColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        color: bgPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: borderColor),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgTertiary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: textSecondary),
        hintStyle: TextStyle(color: textLight),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: textPrimary, fontSize: 22, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
        bodySmall: TextStyle(color: textLight, fontSize: 12),
      ),
      iconTheme: IconThemeData(
        color: textSecondary,
        size: 20,
      ),
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: bgPrimary,
        selectedItemColor: primaryColor,
        unselectedItemColor: textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: lightPrimaryColor,
        secondary: lightSecondaryColor,
        surface: lightBgSecondary,
        surfaceContainerHighest: lightBgTertiary,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightTextPrimary,
        onSurfaceVariant: lightTextSecondary,
        error: lightDangerColor,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: lightBgSecondary,
      appBarTheme: AppBarTheme(
        backgroundColor: lightBgPrimary,
        foregroundColor: lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        shadowColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        color: lightBgPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightPrimaryColor,
          side: BorderSide(color: lightPrimaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightPrimaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightBgPrimary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: lightBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: lightBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: lightPrimaryColor, width: 2),
        ),
        labelStyle: TextStyle(color: lightTextSecondary),
        hintStyle: TextStyle(color: lightTextLight),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: lightTextPrimary, fontSize: 32, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: lightTextPrimary, fontSize: 28, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: lightTextPrimary, fontSize: 24, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: lightTextPrimary, fontSize: 22, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: lightTextPrimary, fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: lightTextPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: lightTextPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: lightTextPrimary, fontSize: 14, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: lightTextPrimary, fontSize: 12, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: lightTextPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: lightTextSecondary, fontSize: 14),
        bodySmall: TextStyle(color: lightTextLight, fontSize: 12),
      ),
      iconTheme: IconThemeData(
        color: lightTextSecondary,
        size: 20,
      ),
      dividerTheme: DividerThemeData(
        color: lightBorderColor,
        thickness: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightBgPrimary,
        selectedItemColor: lightPrimaryColor,
        unselectedItemColor: lightTextLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
} 