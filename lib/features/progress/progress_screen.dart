import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/data/streak_repository.dart';
import '../../core/data/auth_repository.dart';
import '../../core/data/journal_repository.dart';
import '../../core/data/badge_repository.dart';
import '../../core/data/sync_service.dart';
import '../../core/theme/app_colors.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakData = ref.watch(streakRepositoryProvider);
    final user = ref.watch(currentUserProvider);
    final badges = ref.watch(badgeRepositoryProvider);
    final unlockedCount = badges.where((b) => b.isUnlocked).length;
    final totalCount = badges.length;

    // Auto-evaluate streak badges whenever screen renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(badgeRepositoryProvider.notifier).evaluateStreak(streakData);
    });

    return Scaffold(
      backgroundColor: HayaColors.primaryCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Journey',
                style: GoogleFonts.ebGaramond(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: HayaColors.textDark,
                ),
              ),
              const SizedBox(height: 32),

              // Statistics Section
              Text(
                'LIFETIME STATISTICS',
                style: GoogleFonts.ebGaramond(
                  color: HayaColors.primaryTeal,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(child: _buildStatCard(context, "Total Relapses", streakData.totalRelapses.toString(), LucideIcons.rotateCcw, HayaColors.danger)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildStatCard(context, "Longest Streak", "${streakData.longestStreakHours}h", LucideIcons.trophy, HayaColors.accentGold)),
                ],
              ),
              
              const SizedBox(height: 32),

              // ── Achievements ─────────────────────────────────────────────
              Text(
                'ACHIEVEMENTS',
                style: GoogleFonts.ebGaramond(
                  color: HayaColors.primaryTeal,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              _BadgesSummaryCard(
                unlocked: unlockedCount,
                total: totalCount,
                onTap: () => context.push('/progress/badges'),
              ),
              const SizedBox(height: 32),

              // Settings Section
              Text(
                'CLOUD BACKUP',
                style: GoogleFonts.ebGaramond(
                  color: HayaColors.primaryTeal,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              if (user == null)
                _buildSettingsTile(
                  icon: LucideIcons.cloud,
                  title: 'Secure Your Data',
                  subtitle: 'Create a free account to sync to cloud',
                  color: HayaColors.primaryTeal,
                  onTap: () => context.push('/auth'),
                )
              else
                _CloudSyncedTile(user: user),
              
              const SizedBox(height: 32),
              
              Text(
                'YOUR DATA',
                style: GoogleFonts.ebGaramond(
                  color: HayaColors.primaryTeal,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildSettingsTile(
                icon: LucideIcons.trash2,
                title: 'Reset All Data',
                subtitle: 'Permanently wipe your journal & streaks locally',
                color: HayaColors.danger,
                onTap: () => _showResetDialog(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: HayaColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: HayaColors.textLight, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: HayaColors.textDark)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: HayaColors.textLight, fontSize: 13)),
                ],
              ),
            ),
            Icon(LucideIcons.chevronRight, color: HayaColors.textLight, size: 20),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Reset All Data?'),
        content: const Text('This will permanently delete out all your Journal entries, relapse history, and high scores. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: HayaColors.textLight)),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(streakRepositoryProvider.notifier).clearAllData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data has been completely erased.')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: HayaColors.danger, foregroundColor: Colors.white),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }
}

// ─── Badges Summary Card ──────────────────────────────────────────────────────
class _BadgesSummaryCard extends StatelessWidget {
  final int unlocked;
  final int total;
  final VoidCallback onTap;
  const _BadgesSummaryCard({required this.unlocked, required this.total, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : unlocked / total;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: HayaColors.accentGold.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: HayaColors.accentGold.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Text('🏅', style: TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$unlocked / $total Badges',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: HayaColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 5,
                      backgroundColor: HayaColors.textLight.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(HayaColors.accentGold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    unlocked == 0 ? 'Earn your first badge ✨' : 'View your collection →',
                    style: const TextStyle(color: HayaColors.textLight, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: HayaColors.textLight, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Cloud Synced Tile with live Sync Now button ────────────────────────────
class _CloudSyncedTile extends ConsumerStatefulWidget {
  final User user;
  const _CloudSyncedTile({required this.user});

  @override
  ConsumerState<_CloudSyncedTile> createState() => _CloudSyncedTileState();
}

class _CloudSyncedTileState extends ConsumerState<_CloudSyncedTile> {
  bool _isSyncing = false;

  Future<void> _syncNow() async {
    setState(() => _isSyncing = true);
    
    try {
      final syncService = ref.read(syncServiceProvider);
      await syncService.backupToCloud();
      
      if (mounted) {
        setState(() => _isSyncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data secured to cloud. 🛡️☁️'),
            backgroundColor: HayaColors.primaryTeal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSyncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Wait: $e'),
            backgroundColor: HayaColors.danger,
            duration: const Duration(seconds: 10),
          ),
        );
      }
    }
  }

  void _showOptions() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Cloud Options'),
        content: Text('Signed in as:\n${widget.user.email}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(authRepositoryProvider).signOut();
              Navigator.pop(ctx);
            },
            child: const Text('Log Out', style: TextStyle(color: HayaColors.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HayaColors.primaryTeal.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: HayaColors.primaryTeal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.cloudCheck, color: HayaColors.primaryTeal, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Cloud Synced', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: HayaColors.textDark)),
                const SizedBox(height: 4),
                Text(widget.user.email ?? 'Connected', style: const TextStyle(color: HayaColors.textLight, fontSize: 12)),
              ],
            ),
          ),
          if (_isSyncing)
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: HayaColors.primaryTeal))
          else
            Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.refreshCw, color: HayaColors.primaryTeal, size: 20),
                  tooltip: 'Sync Now',
                  onPressed: _syncNow,
                ),
                IconButton(
                  icon: const Icon(LucideIcons.settings, color: HayaColors.textLight, size: 20),
                  tooltip: 'Options',
                  onPressed: _showOptions,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
