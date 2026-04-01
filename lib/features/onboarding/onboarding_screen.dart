import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:haya/app.dart';
import 'steps/step1_welcome.dart';
import 'steps/step2_not_alone.dart';
import 'steps/step3_privacy.dart';
import 'steps/step4_intention.dart';
import 'steps/step5_ready.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _nextPage() {
    if (_currentIndex < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Hive.box('preferences').put('onboardingCompleted', true);
    ref.read(onboardingCompleteProvider.notifier).state = true;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // User must tap buttons to advance
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          Step1Welcome(onNext: _nextPage),
          Step2NotAlone(onNext: _nextPage),
          Step3Privacy(onNext: _nextPage),
          Step4Intention(onNext: _nextPage),
          Step5Ready(onFinish: _nextPage),
        ],
      ),
    );
  }
}
