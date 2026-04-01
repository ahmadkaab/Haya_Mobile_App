import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/data/dua_repository.dart';
import '../../core/models/dua_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/dua_detail_sheet.dart';

// Current dhikr phrase index (0=Subhanallah, 1=Alhamdulillah, 2=AllahuAkbar)
final _dhikrPhraseIndexProvider = StateProvider<int>((ref) => 0);

const _phrases = [
  ('سُبْحَانَ اللَّهِ', 'Subhanallah', 'Glory be to Allah'),
  ('الْحَمْدُ لِلَّهِ', 'Alhamdulillah', 'All praise is to Allah'),
  ('اللَّهُ أَكْبَرُ', 'Allahu Akbar', 'Allah is the Greatest'),
];

// Target per phrase: Subhanallah×33 + Alhamdulillah×33 + AllahuAkbar×34 = 100
const _targets = [33, 33, 34];

class DhikrScreen extends ConsumerStatefulWidget {
  const DhikrScreen({super.key});

  @override
  ConsumerState<DhikrScreen> createState() => _DhikrScreenState();
}

class _DhikrScreenState extends ConsumerState<DhikrScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnim;

  // Per-phrase counts — plain List so web DDC returns int, not int?
  final List<int> _counts = [0, 0, 0];
  bool _allComplete = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    final phraseIndex = ref.read(_dhikrPhraseIndexProvider);
    final target = _targets[phraseIndex];

    HapticFeedback.lightImpact();
    await _pulseController.forward();
    await _pulseController.reverse();

    await ref.read(dhikrRepositoryProvider.notifier).increment();

    setState(() {
      _counts[phraseIndex] = _counts[phraseIndex] + 1;
      // Fire celebration exactly once when all 3 first reach their targets
      if (!_allComplete &&
          _counts[0] >= _targets[0] &&
          _counts[1] >= _targets[1] &&
          _counts[2] >= _targets[2]) {
        _allComplete = true;
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _switchPhrase(int index) {
    ref.read(_dhikrPhraseIndexProvider.notifier).state = index;
  }

  void _resetAll() {
    setState(() {
      _counts[0] = 0;
      _counts[1] = 0;
      _counts[2] = 0;
      _allComplete = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final phraseIndex = ref.watch(_dhikrPhraseIndexProvider);
    final todayTotal = ref.watch(dhikrRepositoryProvider);
    final duas = ref.watch(duaListProvider);
    final ayah = getDailyAyah();
    final (arabic, _, meaning) = _phrases[phraseIndex];

    return Scaffold(
      backgroundColor: HayaColors.primaryCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // ── Daily Ayah Card ──────────────────────────────────────────
              _AyahCard(ayah: ayah),
              const SizedBox(height: 24),

              // ── Today's Total ─────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.star, size: 16, color: HayaColors.accentGold),
                  const SizedBox(width: 6),
                  Text(
                    'Total today: $todayTotal',
                    style: const TextStyle(
                      color: HayaColors.textLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Phrase Selector Tabs with live progress ─────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_phrases.length, (i) {
                    final selected = i == phraseIndex;
                    final count = _counts[i];
                    final done = count >= _targets[i];
                    return GestureDetector(
                      onTap: () => _switchPhrase(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: done
                              ? HayaColors.accentGold
                              : selected
                                  ? HayaColors.primaryTeal
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: done
                                ? HayaColors.accentGold
                                : selected
                                    ? HayaColors.primaryTeal
                                    : HayaColors.textLight.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (done)
                              const Padding(
                                padding: EdgeInsets.only(right: 6),
                                child: Icon(Icons.check_circle, color: Colors.white, size: 14),
                              ),
                            Text(
                              _phrases[i].$2,
                              style: TextStyle(
                                color: done || selected ? Colors.white : HayaColors.textLight,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            if (!done)
                              Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: Text(
                                  '$count/33',
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white.withOpacity(0.7)
                                        : HayaColors.textLight.withOpacity(0.6),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 36),

              // ── Big Counter Tap Button ────────────────────────────────────
              GestureDetector(
                onTap: _onTap,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [HayaColors.primaryTeal, Color(0xFF092928)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: HayaColors.primaryTeal.withOpacity(0.35),
                          blurRadius: 32,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          arabic,
                          style: HayaTheme.arabicTextStyle(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${_counts[phraseIndex]}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_counts[phraseIndex] < _targets[phraseIndex])
                          Text(
                            '/ ${_targets[phraseIndex]}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Meaning label
              Text(
                meaning,
                style: const TextStyle(
                  color: HayaColors.textLight,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Per-phrase done banner OR full 100 celebration
              AnimatedOpacity(
                opacity: (_allComplete || (_counts[phraseIndex] >= _targets[phraseIndex] && !_allComplete)) ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: _allComplete
                        ? HayaColors.accentGold.withOpacity(0.2)
                        : HayaColors.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: _allComplete
                          ? HayaColors.accentGold
                          : HayaColors.primaryTeal.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _allComplete ? LucideIcons.sparkles : LucideIcons.check,
                        color: _allComplete ? HayaColors.accentGold : HayaColors.primaryTeal,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _allComplete
                            ? 'MashaAllah! 100 Dhikr Complete! 🎉'
                            : '${_phrases[phraseIndex].$2} complete ✓',
                        style: TextStyle(
                          color: _allComplete ? HayaColors.accentGold : HayaColors.primaryTeal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_allComplete) ...[  
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _resetAll,
                          child: const Text(
                            'Start Again',
                            style: TextStyle(
                              color: HayaColors.textLight,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // ── Dua Cards ─────────────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'DUA & PROTECTION',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: HayaColors.primaryTeal,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: duas.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => _DuaCard(dua: duas[index]),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Ayah Card Widget ────────────────────────────────────────────────────────
class _AyahCard extends StatelessWidget {
  final AyahModel ayah;
  const _AyahCard({required this.ayah});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: HayaColors.darkGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.bookOpen, color: HayaColors.accentGold, size: 16),
              const SizedBox(width: 8),
              Text(
                'Verse of the Day',
                style: TextStyle(
                  color: HayaColors.accentGold,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ayah.arabic,
            style: HayaTheme.arabicTextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              height: 2.0,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 8),
          Text(
            ayah.english,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ayah.reference,
            style: TextStyle(
              color: HayaColors.accentGold.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Dua Card Widget ─────────────────────────────────────────────────────────
class _DuaCard extends StatelessWidget {
  final DuaModel dua;
  const _DuaCard({required this.dua});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDuaModal(context),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: HayaColors.primaryTeal.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    dua.title,
                    style: const TextStyle(
                      color: HayaColors.primaryTeal,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dua.arabic,
                  style: HayaTheme.arabicTextStyle(
                    fontSize: 13,
                    color: HayaColors.textDark,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 4),
                Text(
                  dua.english,
                  style: const TextStyle(
                    color: HayaColors.textLight,
                    fontSize: 11,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const Row(
              children: [
                Text(
                  'Tap to read',
                  style: TextStyle(
                    color: HayaColors.primaryTeal,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4),
                Icon(LucideIcons.arrowRight, size: 12, color: HayaColors.primaryTeal),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDuaModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DuaDetailSheet(dua: dua),
    );
  }
}
