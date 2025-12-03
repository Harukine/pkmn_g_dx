import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../core/constants/app_constants.dart';
import '../models/filter_options.dart';
import '../models/pokemon_entry.dart';
import '../models/pokemon_form.dart';

/// Sort options for Pokemon list
enum SortOption {
  nameAsc,
  nameDesc,
  idAsc,
  idDesc,
  attackDesc,
  defenseDesc,
  staminaDesc,
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

      final rawList = data
          .map((e) => PokemonEntry.fromJson(e as Map<String, dynamic>))
          .toList();

      return _deduplicatePokemon(rawList);
    } catch (e) {
      debugPrint('Error loading Pokémon: $e');
      rethrow;
    }
  }

  List<PokemonEntry> _deduplicatePokemon(List<PokemonEntry> list) {
    final Map<String, PokemonEntry> uniqueEntries = {};

    for (final entry in list) {
      if (!uniqueEntries.containsKey(entry.name)) {
        uniqueEntries[entry.name] = entry;
      } else {
        final existing = uniqueEntries[entry.name]!;
        
        // Determine better ID (longest is usually correct, e.g. HO_OH vs HO)
        final betterId = entry.basePokemonId.length > existing.basePokemonId.length
            ? entry.basePokemonId
            : existing.basePokemonId;
            
        // Merge forms
        final Map<String, PokemonForm> mergedForms = {};
        
        // Helper to add forms
        void addForms(List<PokemonForm> forms) {
          for (final form in forms) {
            final key = form.formName; // Use formName as unique key
            if (!mergedForms.containsKey(key)) {
              mergedForms[key] = form;
            }
          }
        }
        
        addForms(existing.forms);
        addForms(entry.forms);
        
        // Create merged entry
        uniqueEntries[entry.name] = existing.copyWith(
          basePokemonId: betterId,
          forms: mergedForms.values.toList(),
        );
      }
    }

    return uniqueEntries.values.toList();
  }

  /// Filter a list of Pokemon based on the given filter options
  List<PokemonEntry> filterPokemon(
    List<PokemonEntry> pokemonList,
    FilterOptions filters,
  ) {
    if (filters.isEmpty) return pokemonList;

    return pokemonList.where((entry) {
      // Filter by Type
      if (filters.types.isNotEmpty) {
        final matchesType = entry.types.any((type) => filters.types.contains(type));
        if (!matchesType) return false;
      }

      // Filter by Generation (based on ID)
      if (filters.generations.isNotEmpty) {
        final gen = _getGeneration(entry.dexNumber ?? 0);
        if (!filters.generations.contains(gen)) return false;
      }

      // Filter by Stats (Base stats of the default form/entry)
      if (filters.attackRange != null) {
        if (entry.baseAttack < filters.attackRange!.start ||
            entry.baseAttack > filters.attackRange!.end) {
          return false;
        }
      }
      if (filters.defenseRange != null) {
        if (entry.baseDefense < filters.defenseRange!.start ||
            entry.baseDefense > filters.defenseRange!.end) {
          return false;
        }
      }
      if (filters.staminaRange != null) {
        if (entry.baseStamina < filters.staminaRange!.start ||
            entry.baseStamina > filters.staminaRange!.end) {
          return false;
        }
      }

      // Filter by Form Type
      // If any form matches the selected form types, include the entry
      if (filters.formTypes.isNotEmpty) {
        final hasMatchingForm = entry.forms.any((form) => filters.formTypes.contains(form.formType));
        if (!hasMatchingForm) return false;
      }

      return true;
    }).toList();
  }

  int _getGeneration(int dexNumber) {
    if (dexNumber <= 151) return 1;
    if (dexNumber <= 251) return 2;
    if (dexNumber <= 386) return 3;
    if (dexNumber <= 493) return 4;
    if (dexNumber <= 649) return 5;
    if (dexNumber <= 721) return 6;
    if (dexNumber <= 809) return 7;
    if (dexNumber <= 905) return 8;
    return 9;
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
      case SortOption.attackDesc:
        sorted.sort((a, b) => b.baseAttack.compareTo(a.baseAttack));
        break;
      case SortOption.defenseDesc:
        sorted.sort((a, b) => b.baseDefense.compareTo(a.baseDefense));
        break;
      case SortOption.staminaDesc:
        sorted.sort((a, b) => b.baseStamina.compareTo(a.baseStamina));
        break;
    }

    return sorted;
  }
}
