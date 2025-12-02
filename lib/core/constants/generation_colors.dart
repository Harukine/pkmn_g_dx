import 'package:flutter/material.dart';

class GenerationColors {
  GenerationColors._();

  static const Map<int, List<Color>> generationGradients = {
    1: [Color(0xFFFF0000), Color(0xFF0000FF)], // Red / Blue
    2: [Color(0xFFDAA520), Color(0xFFC0C0C0)], // Gold / Silver
    3: [Color(0xFFA00000), Color(0xFF0000A0)], // Ruby / Sapphire
    4: [Color(0xFFAAAAFF), Color(0xFFFFAAAA)], // Diamond / Pearl
    5: [Color(0xFF444444), Color(0xFFE1E1E1)], // Black / White
    6: [Color(0xFF0055FF), Color(0xFFFF0055)], // X / Y
    7: [Color(0xFFF08030), Color(0xFF705898)], // Sun / Moon
    8: [Color(0xFF00A1E9), Color(0xFFE3007E)], // Sword / Shield
    9: [Color(0xFFFF2400), Color(0xFF8A2BE2)], // Scarlet / Violet
  };

  static List<Color> getGradient(int gen) {
    return generationGradients[gen] ?? [Colors.grey, Colors.grey];
  }
}
