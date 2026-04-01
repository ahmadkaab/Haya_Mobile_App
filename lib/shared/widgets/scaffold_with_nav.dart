import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ScaffoldWithNav extends StatelessWidget {
  const ScaffoldWithNav({
    Key? key,
    required this.navigationShell,
  }) : super(key: key ?? const ValueKey('ScaffoldWithNav'));

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: const [
          NavigationDestination(icon: Icon(LucideIcons.home), label: 'Home'),
          NavigationDestination(icon: Icon(LucideIcons.shieldAlert), label: 'Urge'),
          NavigationDestination(icon: Icon(LucideIcons.heartHandshake), label: 'Dhikr'),
          NavigationDestination(icon: Icon(LucideIcons.book), label: 'Journal'),
          NavigationDestination(icon: Icon(LucideIcons.trendingUp), label: 'Progress'),
        ],
      ),
    );
  }
}
