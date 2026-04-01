import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/notification_service.dart';

class NotificationSetupScreen extends ConsumerWidget {
  const NotificationSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: HayaColors.primaryCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: HayaColors.textDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              // Icon
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: HayaColors.primaryTeal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.bellRing, size: 60, color: HayaColors.primaryTeal),
                ),
              ),
              const SizedBox(height: 24),
              
              // Title
              Text(
                "Stay Strong,\nEvery Single Day.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: HayaColors.textDark,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              
              // Subtitle
              const Text(
                "We'll send you funny, highly relatable, and deeply supportive Islamic reminders exactly when you need them most.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: HayaColors.textLight,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Examples
              const Text("WHAT IT LOOKS LIKE:", style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: HayaColors.textLight
              )),
              const SizedBox(height: 16),
              
              const _MockNotification(
                time: "8:00 AM",
                title: "Haya Morning",
                body: "Your streak is looking healthier than a Biryani without elaichi. Keep it going! 🍛",
              ),
              const SizedBox(height: 12),
              const _MockNotification(
                time: "10:30 PM",
                title: "Haya Late Night",
                body: "You up? Yeah, so are the angels writing your good deeds. Go to sleep with Wudu. 💧",
              ),

              const SizedBox(height: 40),
              
              // Button
              ElevatedButton(
                onPressed: () async {
                  final service = ref.read(notificationServiceProvider);
                  await service.init();
                  final granted = await service.requestPermission();
                  
                  if (granted && context.mounted) {
                    await service.scheduleDailyReminders();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Amazing! Reminders scheduled. 🛡️"),
                        backgroundColor: HayaColors.primaryTeal,
                      )
                    );
                    context.pop();
                  } else if (context.mounted) {
                    // Denied or error
                    context.pop(); 
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HayaColors.primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  "Enable Reminders",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _MockNotification extends StatelessWidget {
  final String time;
  final String title;
  final String body;

  const _MockNotification({required this.time, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
               color: HayaColors.primaryTeal.withOpacity(0.1),
               borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.bell, color: HayaColors.primaryTeal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: HayaColors.textDark)),
                    Text(time, style: const TextStyle(color: HayaColors.textLight, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(color: HayaColors.textLight, fontSize: 13, height: 1.4),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
