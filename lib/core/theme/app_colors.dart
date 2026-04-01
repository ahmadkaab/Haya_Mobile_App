import 'package:flutter/material.dart';

class HayaColors {
  // Primary (Deep Teal + Gold/Cream accent)
  static const Color primaryTeal = Color(0xFF0D3B3A); // Deep spiritual teal
  static const Color primaryCream = Color(0xFFF9F6F0); // Paper cream background
  static const Color accentGold = Color(0xFFD4AF37); // Subtle gold for milestones/progress

  // Semantic
  static const Color danger = Color(0xFFE57373); // Soft red for relapse/warnings
  static const Color success = Color(0xFF81C784); // Soft green for check-ins

  // Neutral / Text
  static const Color textDark = Color(0xFF1C1C1E);
  static const Color textLight = Color(0xFF8E8E93);
  
  // Surfaces
  static const Color surfaceCream = Color(0xFFF5F0E6); // Slightly darker for cards
  static const Color surfaceOpaqueTeal = Color(0x1A0D3B3A); // 10% opacity for backgrounds

  // Gradients
  static const LinearGradient coreGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryCream, surfaceCream],
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryTeal, Color(0xFF092928)], // Subtle deep drop
  );
}
