import 'package:flutter/material.dart';
import 'package:haya/shared/widgets/haya_button.dart';

class Step1Welcome extends StatelessWidget {
  final VoidCallback onNext;
  const Step1Welcome({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text('Welcome to Haya', style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 16),
          Text(
            'Your private, trigger-free sanctuary for breaking habits and building spiritual resilience.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          HayaButton(text: 'Bismillah (Begin)', onPressed: onNext),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
