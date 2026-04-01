import 'package:flutter/material.dart';
import 'package:haya/shared/widgets/haya_button.dart';

class Step4Intention extends StatelessWidget {
  final VoidCallback onNext;
  const Step4Intention({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text('Renew Your Intention', style: Theme.of(context).textTheme.displayMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(
            '"Actions are according to intentions, and everyone will get what was intended."\n\nTake a deep breath and intend this journey for the sake of Allah.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          HayaButton(text: 'My intention is set', onPressed: onNext),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
