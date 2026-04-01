import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:haya/core/theme/app_theme.dart';
import 'package:haya/features/home/home_screen.dart';
import 'package:haya/features/urge/urge_screen.dart';
import 'package:haya/features/dhikr/dhikr_screen.dart';
import 'package:haya/features/journal/journal_screen.dart';
import 'package:haya/features/progress/progress_screen.dart';
import 'package:haya/features/progress/badges_screen.dart';
import 'package:haya/features/onboarding/onboarding_screen.dart';
import 'package:haya/features/onboarding/notification_setup_screen.dart';
import 'package:haya/features/auth/auth_screen.dart';
import 'package:haya/shared/widgets/scaffold_with_nav.dart';
import 'package:haya/core/security/app_lock_wrapper.dart';
import 'package:hive_flutter/hive_flutter.dart';

// Provide onboarding state mapped natively to actual disk memory
final onboardingCompleteProvider = StateProvider<bool>((ref) {
  return Hive.box('preferences').get('onboardingCompleted', defaultValue: false);
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final hasCompletedOnboarding = ref.watch(onboardingCompleteProvider);

  return GoRouter(
    initialLocation: hasCompletedOnboarding ? '/home' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/notification-setup',
        builder: (context, state) => const NotificationSetupScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNav(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/urge',
                builder: (context, state) => const UrgeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dhikr',
                builder: (context, state) => const DhikrScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/journal',
                builder: (context, state) => const JournalScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
                routes: [
                  GoRoute(
                    path: 'badges',
                    builder: (context, state) => const BadgesScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class HayaApp extends ConsumerWidget {
  const HayaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Haya',
      theme: HayaTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => AppLockWrapper(child: child!),
    );
  }
}
