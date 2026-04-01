import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/data/streak_repository.dart';
import '../../core/theme/app_colors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakData = ref.watch(streakRepositoryProvider);

    return Scaffold(
      backgroundColor: HayaColors.primaryCream,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Profile',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: HayaColors.textDark,
                ),
              ),
              const SizedBox(height: 32),

              // Statistics Section
              Text(
                'LIFETIME STATISTICS',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: HayaColors.primaryTeal,
                  fontWeight: FontWeight.w600,
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
              
              const SizedBox(height: 48),

              // Settings Section
              Text(
                'SETTINGS & DATA',
                style: TextStyle(
                  fontFamily: 'Outfit',
                  color: HayaColors.primaryTeal,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildSettingsTile(
                icon: LucideIcons.bellRing,
                title: 'Daily Reminders',
                subtitle: 'Push notifications (Coming Soon)',
                color: HayaColors.primaryTeal,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Push notifications arriving in Phase 5!')));
                },
              ),
              const SizedBox(height: 16),
              _buildSettingsTile(
                icon: LucideIcons.trash2,
                title: 'Reset All Data',
                subtitle: 'Permanently wipe your journal & streaks',
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
