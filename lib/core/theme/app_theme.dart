import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryNavy = Color(0xFF0F172A);
  static const Color accentGreen = Color(0xFF059669);
  static const Color accentSaffron = Color(0xFFFF671F);
  static const Color backgroundDark = Color(0xFF090D16);
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF94A3B8);

  // Standardized Constant Glassmorphism Colors (Prevents GC spikes)
  static const Color glassWhite03 = Color(0x08FFFFFF); // 3% opacity
  static const Color glassWhite05 = Color(0x0DFFFFFF); // 5% opacity
  static const Color glassWhite08 = Color(0x14FFFFFF); // 8% opacity
  static const Color glassWhite10 = Color(0x1AFFFFFF); // 10% opacity
  static const Color glassWhite15 = Color(0x26FFFFFF); // 15% opacity
  static const Color glassWhite20 = Color(0x33FFFFFF); // 20% opacity
  static const Color glassBlack30 = Color(0x4D000000); // 30% black
  static const Color glassBlack50 = Color(0x80000000); // 50% black

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: accentGreen,
      colorScheme: const ColorScheme.dark(
        primary: accentGreen,
        secondary: accentSaffron,
        surface: cardDark,
        background: backgroundDark,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: const TextStyle(color: textLight, fontWeight: FontWeight.bold),
        titleLarge: const TextStyle(color: textLight, fontWeight: FontWeight.w600),
        bodyLarge: const TextStyle(color: textLight),
        bodyMedium: const TextStyle(color: textMuted),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
