import 'package:flutter/material.dart';
import 'package:haya/shared/widgets/haya_button.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class Step3Privacy extends StatelessWidget {
  final VoidCallback onNext;
  const Step3Privacy({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const Icon(LucideIcons.lock, size: 64, color: Color(0xFF0D3B3A)),
          const SizedBox(height: 24),
          Text('100% Private', style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 16),
          Text(
            'We don\'t ask for your name or email. Your journal is encrypted and stored only on your device. We track nothing.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          HayaButton(text: 'Continue', onPressed: onNext),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
