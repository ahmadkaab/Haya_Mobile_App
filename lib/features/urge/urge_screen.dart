import 'dart:async';
import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/streak_repository.dart';
import '../../core/data/badge_repository.dart';
import '../../core/data/dua_repository.dart';
import '../../shared/widgets/dua_detail_sheet.dart';

class UrgeScreen extends ConsumerStatefulWidget {
  const UrgeScreen({super.key});

  @override
  ConsumerState<UrgeScreen> createState() => _UrgeScreenState();
}

class _UrgeScreenState extends ConsumerState<UrgeScreen>
    with TickerProviderStateMixin {
  // ── 30s relapse lock ──────────────────────────────────────────────────────
  bool _canRelapse = false;
  int _secondsRemaining = 30;
  Timer? _countdownTimer;

  // ── Confetti ──────────────────────────────────────────────────────────────
  late ConfettiController _confettiController;

  // ── 4-7-8 Breathing ───────────────────────────────────────────────────────
  // Phase: 0 = Inhale (4s), 1 = Hold (7s), 2 = Exhale (8s)
  int _breathingPhase = 0;
  int _phaseSeconds = 4;
  Timer? _breathingTimer;

  // ── Breathing pulse animation ──────────────────────────────────────────────
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // ── Rotating diversion tactics ────────────────────────────────────────────
  int _diversionIndex = 0;
  Timer? _diversionTimer;
  final List<Map<String, String>> _diversions = [
    {
      'icon': '👆',
      'text': 'Look at the sky immediately.\nAllah is watching you right now.',
    },
    {
      'icon': '💧',
      'text': 'Go splash cold water on your face.\nThe urge will pass in 90 seconds.',
    },
    {
      'icon': '💪',
      'text': 'Drop and do 10 pushups now.\nBeat it with your body.',
    },
    {
      'icon': '🚶',
      'text': 'Leave the room you are in.\nChange your environment immediately.',
    },
    {
      'icon': '📿',
      "text": "Say: A'ūdhu billāhi minash-shayṭānir-rajīm.\nAllah is closer than your jugular vein.",
    },
    {
      'icon': '📞',
      'text': 'Call someone you trust right now.\nYou do not have to fight alone.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
    _startCountdownTimer();
    _startBreathingCycle();
    _startDiversionRotation();
  }

  void _startCountdownTimer() {
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() => _canRelapse = true);
        timer.cancel();
      }
    });
  }

  void _startBreathingCycle() {
    _breathingTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_phaseSeconds > 1) {
          _phaseSeconds--;
        } else {
          if (_breathingPhase == 0) {
            _breathingPhase = 1;
            _phaseSeconds = 7;
          } else if (_breathingPhase == 1) {
            _breathingPhase = 2;
            _phaseSeconds = 8;
          } else {
            _breathingPhase = 0;
            _phaseSeconds = 4;
          }
        }
      });
    });
  }

  void _startDiversionRotation() {
    _diversionTimer =
        Timer.periodic(const Duration(seconds: 7), (timer) {
      if (mounted) {
        setState(() {
          _diversionIndex = (_diversionIndex + 1) % _diversions.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _breathingTimer?.cancel();
    _diversionTimer?.cancel();
    _pulseController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _showRelapseWarning() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _RelapseWarningSheet(),
    );
  }

  void _showEmergencyDua() {
    final duas = ref.read(duaListProvider);
    final emergencyDua = duas.firstWhere(
      (d) => d.category == 'urge_protection',
      orElse: () => duas.first,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DuaDetailSheet(dua: emergencyDua),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ── Breathing phase config ─────────────────────────────────────────────
    final phaseConfigs = [
      {
        'label': 'Breathe In',
        'zikr': 'SubhanAllah',
        'arabic': 'سُبْحَانَ اللَّهِ',
        'color': const Color(0xFF4FC3A1),
        'scale': 1.3,
        'duration': const Duration(seconds: 4),
      },
      {
        'label': 'Hold',
        'zikr': 'Yaa Sabur',
        'arabic': 'يَا صَبُورُ',
        'color': HayaColors.accentGold,
        'scale': 1.3,
        'duration': const Duration(milliseconds: 300),
      },
      {
        'label': 'Breathe Out',
        'zikr': "A'udhu Billah",
        'arabic': 'أَعُوذُ بِاللَّهِ',
        'color': const Color(0xFF81C9F0),
        'scale': 0.75,
        'duration': const Duration(seconds: 8),
      },
    ];

    final phase = phaseConfigs[_breathingPhase];
    final phaseColor = phase['color'] as Color;
    final targetScale = phase['scale'] as double;
    final animDuration = phase['duration'] as Duration;

    return Scaffold(
      backgroundColor: const Color(0xFF041E1A),
      body: Stack(
        children: [
          // ── Deep starfield gradient ──────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.3),
                radius: 1.2,
                colors: [Color(0xFF0D3B2E), Color(0xFF041612)],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // ── Top bar ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go('/home'),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(LucideIcons.x,
                              color: Colors.white60, size: 20),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'SOS Mode',
                        style: GoogleFonts.dmSans(
                          color: Colors.white38,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Spacer(),
                      // Emergency Dua button
                      GestureDetector(
                        onTap: _showEmergencyDua,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(LucideIcons.bookOpen,
                              color: Colors.white60, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Headline ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Column(
                    children: [
                      Text(
                        "Don't give in.",
                        style: GoogleFonts.ebGaramond(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This feeling will pass. Breathe with Allah.',
                        style: GoogleFonts.dmSans(
                          color: Colors.white38,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // ── Rotating diversion card ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween(
                                  begin: const Offset(0, 0.15),
                                  end: Offset.zero)
                              .animate(anim),
                          child: child,
                        )),
                    child: Container(
                      key: ValueKey(_diversionIndex),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: phaseColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: phaseColor.withOpacity(0.3), width: 1),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _diversions[_diversionIndex]['icon']!,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _diversions[_diversionIndex]['text']!,
                              style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Breathing Circle ──────────────────────────────────────
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: 200,
                      height: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow ring
                        AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (context, child) => Transform.scale(
                            scale: _pulseAnim.value,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: phaseColor.withOpacity(0.04),
                              ),
                            ),
                          ),
                        ),
                        // Middle ring
                        AnimatedScale(
                          scale: targetScale * 0.85,
                          duration: animDuration,
                          curve: Curves.easeInOutSine,
                          child: Container(
                            width: 155,
                            height: 155,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: phaseColor.withOpacity(0.07),
                              border: Border.all(
                                  color: phaseColor.withOpacity(0.2),
                                  width: 1),
                            ),
                          ),
                        ),
                        // Core breathing circle
                        AnimatedScale(
                          scale: targetScale,
                          duration: animDuration,
                          curve: Curves.easeInOutSine,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  phaseColor.withOpacity(0.35),
                                  phaseColor.withOpacity(0.15),
                                ],
                              ),
                              border: Border.all(
                                  color: phaseColor.withOpacity(0.6),
                                  width: 1.5),
                            ),
                          ),
                        ),
                        // Text inside
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Arabic dhikr
                            Text(
                              phase['arabic'] as String,
                              style: HayaTheme.arabicTextStyle(
                                fontSize: 16,
                                color: phaseColor,
                                fontWeight: FontWeight.bold,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              phase['zikr'] as String,
                              style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            // Phase countdown
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${phase['label']}  $_phaseSeconds',
                                style: GoogleFonts.dmSans(
                                  color: Colors.white60,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                ),

                // ── Bottom action area ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    children: [
                      // I Survived button — primary CTA
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            HapticFeedback.heavyImpact();
                            ref
                                .read(badgeRepositoryProvider.notifier)
                                .evaluateUrge();
                            if (context.mounted) {
                              _confettiController.play();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Alhamdulillah! You survived the urge! 🛡️',
                                    style: GoogleFonts.dmSans(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  backgroundColor: const Color(0xFF0D6B50),
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                              await Future.delayed(
                                  const Duration(seconds: 2));
                              if (context.mounted) context.go('/home');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4FC3A1),
                            foregroundColor: const Color(0xFF041E1A),
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.shieldCheck, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                'I Survived — Alhamdulillah',
                                style: GoogleFonts.dmSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // I Relapsed — locked until 30s
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _canRelapse
                              ? () {
                                  HapticFeedback.vibrate();
                                  _showRelapseWarning();
                                }
                              : null,
                          style: TextButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(
                                color: _canRelapse
                                    ? HayaColors.danger.withOpacity(0.6)
                                    : Colors.white12,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Text(
                            _canRelapse
                                ? 'I gave in... (Report relapse)'
                                : 'Wait ${_secondsRemaining}s before you can report relapse',
                            style: GoogleFonts.dmSans(
                              color: _canRelapse
                                  ? HayaColors.danger.withOpacity(0.7)
                                  : Colors.white24,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Confetti ───────────────────────────────────────────────────
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              emissionFrequency: 0.05,
              numberOfParticles: 60,
              gravity: 0.1,
              colors: const [
                Color(0xFF4FC3A1),
                HayaColors.accentGold,
                Colors.white,
                Color(0xFF81C9F0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── High-Friction Relapse Sheet ──────────────────────────────────────────────
class _RelapseWarningSheet extends ConsumerStatefulWidget {
  const _RelapseWarningSheet();

  @override
  ConsumerState<_RelapseWarningSheet> createState() =>
      _RelapseWarningSheetState();
}

class _RelapseWarningSheetState
    extends ConsumerState<_RelapseWarningSheet> {
  int _seconds = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm = _seconds == 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 48),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1F1D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──────────────────────────────────────────────────
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          const SizedBox(height: 28),

          // ── Warning icon ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: HayaColors.danger.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.alertTriangle,
                color: HayaColors.danger, size: 40),
          ),
          const SizedBox(height: 20),

          // ── Title ────────────────────────────────────────────────
          Text(
            'Are you absolutely sure?',
            style: GoogleFonts.ebGaramond(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          Text(
            "Don't let a moment of weakness erase your progress. Close your eyes, take one deep breath, and ask Allah for strength.",
            style: GoogleFonts.dmSans(
              color: Colors.white54,
              fontSize: 14,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Arabic reminder
          Text(
            'إِنَّ اللَّهَ يُحِبُّ التَّوَّابِينَ',
            style: HayaTheme.arabicTextStyle(
              fontSize: 20,
              color: HayaColors.accentGold,
              fontWeight: FontWeight.bold,
              height: 1.8,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            '"Indeed, Allah loves those who repent."',
            style: GoogleFonts.dmSans(
              color: Colors.white38,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          // ── Confirm button (locked) ──────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canConfirm
                  ? () async {
                      await ref
                          .read(streakRepositoryProvider.notifier)
                          .relapse();
                      if (context.mounted) {
                        Navigator.pop(context);
                        context.go('/home');
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    canConfirm ? HayaColors.danger : Colors.white10,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.white10,
                disabledForegroundColor: Colors.white30,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                canConfirm
                    ? 'Yes, I gave in. Reset streak.'
                    : 'Wait $_seconds seconds...',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Fight back button ─────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                side: const BorderSide(
                    color: Color(0xFF4FC3A1), width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                'Nevermind — I will fight this.',
                style: GoogleFonts.dmSans(
                  color: const Color(0xFF4FC3A1),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
