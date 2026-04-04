import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFFE8E4DC);
  static const bg2 = Color(0xFFF0EDE6);
  static const white = Color(0xFFFAFAF7);
  static const card = Color(0xFFFAFAF7);

  static const dark = Color(0xFF1C1C14);
  static const dark2 = Color(0xFF2C2C1E);

  static const green = Color(0xFF3D6B35);
  static const green2 = Color(0xFF4A7C3F);
  static const greenLt = Color(0xFFD6E8D2);

  static const muted = Color(0xFF7A7A68);
  static const muted2 = Color(0xFFA8A898);

  static const border = Color(0xFFDEDAD2);

  static const red = Color(0xFFC0392B);
  static const redLt = Color(0xFFFDECEA);
  static const amber = Color(0xFF92600A);
  static const amberLt = Color(0xFFFEF3CD);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,

      // ✅ FIXED ColorScheme
      colorScheme: ColorScheme.light(
        primary: AppColors.green,
        secondary: AppColors.dark,
        surface: AppColors.white,
        error: AppColors.red,
      ),

      scaffoldBackgroundColor: AppColors.bg,

      // ✅ Text Theme
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.dmSans(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.dark,
          letterSpacing: -0.3,
        ),
        displayMedium: GoogleFonts.dmSans(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: AppColors.dark,
          letterSpacing: -0.2,
        ),
        displaySmall: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.dark,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 14,
          color: AppColors.dark,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 12,
          color: AppColors.muted,
        ),
        bodySmall: GoogleFonts.dmSans(
          fontSize: 10,
          color: AppColors.muted,
        ),
        labelLarge: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.muted,
          letterSpacing: 0.7,
        ),
      ),

      // ✅ AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.dark,
        ),
        iconTheme: const IconThemeData(color: AppColors.dark),
      ),

      // ✅ Bottom Nav
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.green,
        unselectedItemColor: AppColors.muted2,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // ✅ Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.border,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.green,
            width: 1.5,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        hintStyle: GoogleFonts.dmSans(
          fontSize: 14,
          color: AppColors.muted2,
        ),
      ),

      // ✅ Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.dark,
          foregroundColor: AppColors.white,
          shape: const StadiumBorder(),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),

      // ✅ FIXED CardTheme → CardThemeData
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        shadowColor: Colors.black.withOpacity(0.09),
      ),
    );
  }
}