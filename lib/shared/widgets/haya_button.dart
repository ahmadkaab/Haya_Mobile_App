import 'package:flutter/material.dart';

class HayaButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final bool isSecondary;

  const HayaButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: isSecondary
            ? ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.primary,
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
              )
            : null, // Uses default theme style
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}
