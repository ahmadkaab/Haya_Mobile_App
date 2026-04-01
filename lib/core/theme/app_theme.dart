import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class HayaTheme {
  // ─── Arabic Text Style (Amiri) ─────────────────────────────────────────────
  // Use this for ALL Quranic ayat, dhikr, and Arabic script in the app.
  static TextStyle arabicTextStyle({
    double fontSize = 26,
    Color color = HayaColors.textDark,
    FontWeight fontWeight = FontWeight.normal,
    double height = 2.0,
  }) {
    return GoogleFonts.amiri(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight,
      height: height,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: HayaColors.primaryCream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: HayaColors.primaryTeal,
        primary: HayaColors.primaryTeal,
        secondary: HayaColors.accentGold,
        surface: HayaColors.surfaceCream,
        error: HayaColors.danger,
        onPrimary: HayaColors.primaryCream,
        onSurface: HayaColors.textDark,
      ),

      // ── Typography ─────────────────────────────────────────────────────────
      // Display (Headings): EB Garamond — elegant serif to match the Arabic calligraphy in the logo
      // Body: DM Sans — clean, readable
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.ebGaramond(
          color: HayaColors.primaryTeal,
          fontWeight: FontWeight.bold,
          fontSize: 40,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.ebGaramond(
          color: HayaColors.primaryTeal,
          fontWeight: FontWeight.w700,
          fontSize: 32,
          letterSpacing: -0.5,
        ),
        displaySmall: GoogleFonts.ebGaramond(
          color: HayaColors.primaryTeal,
          fontWeight: FontWeight.w600,
          fontSize: 26,
        ),
        headlineLarge: GoogleFonts.ebGaramond(
          color: HayaColors.textDark,
          fontWeight: FontWeight.bold,
          fontSize: 28,
        ),
        headlineMedium: GoogleFonts.ebGaramond(
          color: HayaColors.textDark,
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
        headlineSmall: GoogleFonts.ebGaramond(
          color: HayaColors.textDark,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        titleLarge: GoogleFonts.dmSans(
          color: HayaColors.textDark,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: 0.2,
        ),
        titleMedium: GoogleFonts.dmSans(
          color: HayaColors.textDark,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        titleSmall: GoogleFonts.dmSans(
          color: HayaColors.primaryTeal,
          fontWeight: FontWeight.w600,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
        bodyLarge: GoogleFonts.dmSans(
          color: HayaColors.textDark,
          fontSize: 16,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.dmSans(
          color: HayaColors.textLight,
          fontSize: 14,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.dmSans(
          color: HayaColors.textLight,
          fontSize: 12,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.dmSans(
          color: HayaColors.primaryCream,
          fontWeight: FontWeight.w700,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
        labelMedium: GoogleFonts.dmSans(
          color: HayaColors.accentGold,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 1.0,
        ),
        labelSmall: GoogleFonts.dmSans(
          color: HayaColors.textLight,
          fontWeight: FontWeight.w500,
          fontSize: 11,
          letterSpacing: 0.8,
        ),
      ),

      // ── Buttons ─────────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: HayaColors.primaryTeal,
          foregroundColor: HayaColors.primaryCream,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          textStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: HayaColors.primaryTeal,
          side: const BorderSide(color: HayaColors.primaryTeal, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),

      // ── Cards ────────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shadowColor: HayaColors.primaryTeal.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: HayaColors.primaryTeal.withOpacity(0.08), width: 1),
        ),
      ),

      // ── App Bar ──────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: HayaColors.primaryCream,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: HayaColors.primaryTeal),
        titleTextStyle: GoogleFonts.ebGaramond(
          color: HayaColors.primaryTeal,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),

      // ── Input ────────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: HayaColors.primaryTeal.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: HayaColors.primaryTeal.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: HayaColors.primaryTeal, width: 1.5),
        ),
        labelStyle: GoogleFonts.dmSans(color: HayaColors.textLight),
        hintStyle: GoogleFonts.dmSans(color: HayaColors.textLight.withOpacity(0.6)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),

      // ── Divider ──────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: HayaColors.primaryTeal.withOpacity(0.1),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
