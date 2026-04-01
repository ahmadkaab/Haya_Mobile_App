import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/dua_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class DuaDetailSheet extends StatelessWidget {
  final DuaModel dua;
  const DuaDetailSheet({super.key, required this.dua});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Handle ────────────────────────────────────────────────────
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: HayaColors.textLight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Title Badge ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: HayaColors.primaryTeal.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              dua.title.toUpperCase(),
              style: GoogleFonts.dmSans(
                color: HayaColors.primaryTeal,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Gold divider ──────────────────────────────────────────────
          Container(
            height: 2,
            width: 48,
            decoration: BoxDecoration(
              color: HayaColors.accentGold,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // ── Arabic Text — Amiri font ──────────────────────────────────
          Text(
            dua.arabic,
            style: HayaTheme.arabicTextStyle(
              fontSize: 30,
              color: HayaColors.textDark,
              fontWeight: FontWeight.bold,
              height: 2.0,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 18),

          // ── Transliteration ───────────────────────────────────────────
          Text(
            dua.transliteration,
            style: GoogleFonts.dmSans(
              color: HayaColors.primaryTeal.withOpacity(0.85),
              fontSize: 15,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),

          // ── English Translation ───────────────────────────────────────
          Text(
            '"${dua.english}"',
            style: GoogleFonts.dmSans(
              color: HayaColors.textLight,
              fontSize: 15,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
