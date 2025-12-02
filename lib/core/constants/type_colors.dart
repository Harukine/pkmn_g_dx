import 'package:flutter/material.dart';

/// Standard Pokemon type colors
class TypeColors {
  TypeColors._();

  static const Map<String, Color> typeColors = {
    'Normal': Color(0xFFA8A878),
    'Fire': Color(0xFFF08030),
    'Water': Color(0xFF6890F0),
    'Grass': Color(0xFF78C850),
    'Electric': Color(0xFFF8D030),
    'Ice': Color(0xFF98D8D8),
    'Fighting': Color(0xFFC03028),
    'Poison': Color(0xFFA040A0),
    'Ground': Color(0xFFE0C068),
    'Flying': Color(0xFFA890F0),
    'Psychic': Color(0xFFF85888),
    'Bug': Color(0xFFA8B820),
    'Rock': Color(0xFFB8A038),
    'Ghost': Color(0xFF705898),
    'Dragon': Color(0xFF7038F8),
    'Dark': Color(0xFF705848),
    'Steel': Color(0xFFB8B8D0),
    'Fairy': Color(0xFFEE99AC),
  };

  /// Get color for a Pokemon type, returns a default gray if not found
  static Color getColorForType(String type) {
    return typeColors[type] ?? const Color(0xFF68A090);
  }

  /// Check if a type color exists (case-insensitive)
  static bool hasType(String type) {
    return typeColors.containsKey(type);
  }
}
