import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../core/constants/app_constants.dart';
import '../models/pokemon_entry.dart';

/// Sort options for Pokemon list
enum SortOption {
  nameAsc,
  nameDesc,
  idAsc,
  idDesc,
}

/// Service class for loading and managing Pokemon data
class PokemonService {
  // Singleton pattern
  PokemonService._();
  static final PokemonService _instance = PokemonService._();
  static PokemonService get instance => _instance;

  /// Load Pokemon data from JSON asset
  Future<List<PokemonEntry>> loadPokemon() async {
    try {
      final jsonString = await rootBundle.loadString(AppConstants.pokemonDataPath);
      final data = json.decode(jsonString) as List<dynamic>;

      return data
          .map((e) => PokemonEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading Pokémon: $e');
      rethrow;
    }
  }

  /// Sort a list of Pokemon based on the given sort option
  List<PokemonEntry> sortPokemon(
    List<PokemonEntry> pokemonList,
    SortOption sortOption,
  ) {
    final sorted = List<PokemonEntry>.from(pokemonList);

    switch (sortOption) {
      case SortOption.nameAsc:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        sorted.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.idAsc:
        sorted.sort((a, b) => (a.dexNumber ?? 0).compareTo(b.dexNumber ?? 0));
        break;
      case SortOption.idDesc:
        sorted.sort((a, b) => (b.dexNumber ?? 0).compareTo(a.dexNumber ?? 0));
        break;
    }

    return sorted;
  }
}
