import 'package:flutter/material.dart';
import 'package:haya/shared/widgets/haya_button.dart';

class Step2NotAlone extends StatelessWidget {
  final VoidCallback onNext;
  const Step2NotAlone({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text('You Are Not Alone', style: Theme.of(context).textTheme.displayMedium, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(
            'Over 70% of men struggle with this at some point. It is a modern trial, and overcoming it is a true jihad of the nafs.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          HayaButton(text: 'I understand', onPressed: onNext),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
