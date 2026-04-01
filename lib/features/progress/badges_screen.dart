import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/badge_repository.dart';
import '../../core/models/badge_model.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badges = ref.watch(badgeRepositoryProvider);
    final unlocked = badges.where((b) => b.isUnlocked).length;
    final total = badges.length;

    final streakBadges = badges.where((b) => b.category == BadgeCategory.streak).toList();
    final spiritualBadges = badges.where((b) => b.category == BadgeCategory.spiritual).toList();
    final resilienceBadges = badges.where((b) => b.category == BadgeCategory.resilience).toList();

    return Scaffold(
      backgroundColor: HayaColors.primaryCream,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Badges',
                      style: GoogleFonts.ebGaramond(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: HayaColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Every step of purity is honoured',
                      style: GoogleFonts.dmSans(color: HayaColors.textLight, fontSize: 14),
                    ),
                    const SizedBox(height: 24),

                    // Progress bar
                    _ProgressBar(unlocked: unlocked, total: total),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Streak Section ───────────────────────────────────────────────
            _SectionHeader(title: '🏆 Streak Milestones'),
            _BadgeGrid(badges: streakBadges),

            // ── Spiritual Section ────────────────────────────────────────────
            _SectionHeader(title: '📿 Spiritual Practice'),
            _BadgeGrid(badges: spiritualBadges),

            // ── Resilience Section ───────────────────────────────────────────
            _SectionHeader(title: '🛡️ Resilience'),
            _BadgeGrid(badges: resilienceBadges),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ─── Progress Bar ─────────────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final int unlocked;
  final int total;
  const _ProgressBar({required this.unlocked, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : unlocked / total;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [HayaColors.primaryTeal, Color(0xFF0A3D36)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: HayaColors.primaryTeal.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Badges Collected',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Text(
                '$unlocked / $total',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(HayaColors.accentGold),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            unlocked == 0
                ? 'Begin your journey to earn your first badge'
                : unlocked == total
                    ? 'MashaAllah! All badges collected! 👑'
                    : '${total - unlocked} more to unlock — keep going!',
            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        child: Text(
          title,
          style: GoogleFonts.ebGaramond(
            color: HayaColors.primaryTeal,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
    );
  }
}

// ─── Badge Grid ───────────────────────────────────────────────────────────────
class _BadgeGrid extends StatelessWidget {
  final List<HayaBadge> badges;
  const _BadgeGrid({required this.badges});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, i) => _BadgeTile(badge: badges[i]),
          childCount: badges.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.82,
        ),
      ),
    );
  }
}

// ─── Badge Tile ───────────────────────────────────────────────────────────────
class _BadgeTile extends StatelessWidget {
  final HayaBadge badge;
  const _BadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    final unlocked = badge.isUnlocked;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: unlocked ? Colors.white : HayaColors.primaryCream,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: unlocked
                ? HayaColors.accentGold.withOpacity(0.5)
                : HayaColors.textLight.withOpacity(0.15),
            width: unlocked ? 1.5 : 1,
          ),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: HayaColors.accentGold.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emoji / lock
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: unlocked
                    ? HayaColors.accentGold.withOpacity(0.12)
                    : HayaColors.textLight.withOpacity(0.08),
              ),
              child: Center(
                child: unlocked
                    ? Text(badge.emoji, style: const TextStyle(fontSize: 26))
                    : const Icon(Icons.lock_outline,
                        color: HayaColors.textLight, size: 22),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                badge.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: unlocked ? HayaColors.textDark : HayaColors.textLight,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    HapticFeedback.lightImpact();
    final unlocked = badge.isUnlocked;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: HayaColors.textLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: unlocked
                    ? HayaColors.accentGold.withOpacity(0.12)
                    : HayaColors.textLight.withOpacity(0.08),
              ),
              child: Center(
                child: unlocked
                    ? Text(badge.emoji, style: const TextStyle(fontSize: 40))
                    : const Icon(Icons.lock_outline,
                        color: HayaColors.textLight, size: 36),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.title,
              style: GoogleFonts.ebGaramond(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: HayaColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              badge.description,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: HayaColors.textLight,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (unlocked && badge.unlockedAt != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: HayaColors.accentGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Earned on ${_formatDate(badge.unlockedAt!)}',
                  style: const TextStyle(
                    color: HayaColors.accentGold,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            if (!unlocked) ...[
              const SizedBox(height: 16),
              const Text(
                'Keep going — you\'ve got this! 💪',
                style: TextStyle(
                  color: HayaColors.primaryTeal,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}
