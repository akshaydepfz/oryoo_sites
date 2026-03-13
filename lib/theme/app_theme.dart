import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Layout constants for responsive design
class AppLayout {
  AppLayout._();

  static const double maxWidth = 1200;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;

  static int productGridColumns(double width) {
    if (width >= desktopBreakpoint) return 4;
    if (width >= tabletBreakpoint) return 3;
    return 2;
  }
}

/// App theme and typography
class AppTheme {
  AppTheme._();

  static ThemeData buildTheme(Color primaryColor) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
      ),
      scaffoldBackgroundColor: Colors.white,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.cormorantGaramond(
          fontSize: 36,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A2E),
        ),
        headlineMedium: GoogleFonts.cormorantGaramond(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A2E),
        ),
        headlineSmall: GoogleFonts.cormorantGaramond(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A1A2E),
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          height: 1.6,
          color: const Color(0xFF4A4A4A),
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFF4A4A4A),
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: const Color(0xFF6B6B6B),
        ),
      ),
    );
  }
}
