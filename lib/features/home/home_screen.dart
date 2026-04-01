import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/data/dua_repository.dart';
import '../../core/data/streak_repository.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakData = ref.watch(streakRepositoryProvider);
    final today = DateFormat('EEEE, MMMM d').format(DateTime.now());

    // Hijri Calculations
    final hijriToday = HijriCalendar.now();
    final hijriDateString =
        '${hijriToday.hDay} ${hijriToday.getLongMonthName()} ${hijriToday.hYear} AH';

    return Scaffold(
      backgroundColor: HayaColors.surfaceCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header Row (Logo + Greeting) ────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo — circular clip, no square edges
                  ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peace be upon you,',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: HayaColors.textLight,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hijriDateString,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: HayaColors.primaryTeal,
                                    letterSpacing: 0.4,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                today,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: HayaColors.textDark,
                    ),
              ),
              const SizedBox(height: 32),

              // ── Main Tracking Card ───────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D3B2E), Color(0xFF1A5C4A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: HayaColors.primaryTeal.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'STREAK',
                      style: GoogleFonts.dmSans(
                        color: Colors.white54,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 148,
                          height: 148,
                          child: CircularProgressIndicator(
                            value: 0.8,
                            strokeWidth: 8,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                HayaColors.accentGold),
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              streakData.displayString == 'Just Now'
                                  ? '0'
                                  : streakData.displayString.split(' ')[0],
                              style: GoogleFonts.ebGaramond(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 52,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              streakData.displayString == 'Just Now'
                                  ? 'mins clean'
                                  : '${streakData.displayString.split(' ')[1]} clean',
                              style: GoogleFonts.dmSans(
                                color: Colors.white70,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // ── I HAVE AN URGE — Panic Button ────────────────────────────
              InkWell(
                onTap: () async {
                  await HapticFeedback.heavyImpact();
                  if (context.mounted) context.go('/urge');
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 20, horizontal: 24),
                  decoration: BoxDecoration(
                    color: HayaColors.danger.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: HayaColors.danger, width: 1.8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.shieldAlert,
                          color: HayaColors.danger, size: 26),
                      const SizedBox(width: 12),
                      Text(
                        'I HAVE AN URGE',
                        style:
                            Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: HayaColors.danger,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Daily Check-ins Banner ───────────────────────────────────
              InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/notification-setup');
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 18, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: HayaColors.primaryTeal.withOpacity(0.2),
                        width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(11),
                        decoration: BoxDecoration(
                          color: HayaColors.primaryTeal.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.bellRing,
                            color: HayaColors.primaryTeal, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Check-ins',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Stay accountable with gentle Islamic reminders. 🌙',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: HayaColors.textLight),
                            ),
                          ],
                        ),
                      ),
                      const Icon(LucideIcons.chevronRight,
                          color: HayaColors.textLight, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // ── Daily Inspiration ────────────────────────────────────────
              Text(
                'Daily Inspiration',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: HayaColors.primaryTeal,
                    ),
              ),
              const SizedBox(height: 14),

              Builder(builder: (context) {
                final ayah = getDailyAyah();
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: HayaColors.accentGold.withOpacity(0.3),
                        width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: HayaColors.primaryTeal.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Gold top accent bar
                      Container(
                        height: 3,
                        width: 48,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: HayaColors.accentGold,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      // Arabic Ayah — Amiri font
                      Text(
                        ayah.arabic,
                        textAlign: TextAlign.right,
                        style: HayaTheme.arabicTextStyle(
                          fontSize: 26,
                          color: HayaColors.textDark,
                          fontWeight: FontWeight.bold,
                          height: 2.0,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // English translation — italic DM Sans
                      Text(
                        '"${ayah.english}"',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: HayaColors.textLight,
                              height: 1.6,
                            ),
                      ),
                      const SizedBox(height: 10),
                      // Reference badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: HayaColors.accentGold.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              ayah.reference,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: HayaColors.accentGold,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
