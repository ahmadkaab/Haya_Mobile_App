import 'package:flutter/material.dart';
import 'package:haya/shared/widgets/haya_button.dart';

class Step5Ready extends StatelessWidget {
  final VoidCallback onFinish;
  const Step5Ready({super.key, required this.onFinish});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text('Ready?', style: Theme.of(context).textTheme.displayLarge),
          const SizedBox(height: 16),
          Text(
            'Your path to purity and discipline starts right now. We cover your back.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          HayaButton(text: 'Enter My Dashboard', onPressed: onFinish),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
