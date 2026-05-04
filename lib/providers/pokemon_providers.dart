import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/filter_options.dart';
import '../models/pokemon_entry.dart';
import '../services/pokemon_service.dart';

/// Provider for the PokemonService
final pokemonServiceProvider = Provider<PokemonService>((ref) {
  return PokemonService();
});

/// FutureProvider that loads and parses all Pokemon data
final pokemonDataProvider = FutureProvider<List<PokemonEntry>>((ref) async {
  final service = ref.watch(pokemonServiceProvider);
  return await service.loadPokemon();
});

/// FutureProvider that loads and parses all Move stats
final moveStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(pokemonServiceProvider);
  return await service.loadMoveStats();
});

/// FutureProvider that pre-flattens the Pokemon list (Mega, Regional, etc.)
/// This avoids expensive re-flattening on every filter change.
final flattenedPokemonProvider = FutureProvider<List<PokemonEntry>>((ref) async {
  final asyncData = ref.watch(pokemonDataProvider);
  final allPokemon = asyncData.value ?? [];
  if (allPokemon.isEmpty) return [];
  
  final service = ref.read(pokemonServiceProvider);
  return await compute(service.flattenPokemonIsolate, allPokemon);
});

/// StateProvider for the search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// StateProvider for filter options
final filterOptionsProvider = StateProvider<FilterOptions>((ref) => const FilterOptions());

/// StateProvider for the active sort option
final sortOptionProvider = StateProvider<SortOption>((ref) => SortOption.idAsc);

/// Computed Provider that watches data, search query, filters, and sorting.
/// Uses a FutureProvider to offload filtering/sorting to a background isolate.
final filteredPokemonProvider = FutureProvider<List<PokemonEntry>>((ref) async {
  // Watch the flattened data
  final asyncData = ref.watch(flattenedPokemonProvider);
  
  // If data is not yet loaded or has an error, return empty list
  final allPokemon = asyncData.value ?? [];
  if (allPokemon.isEmpty) return [];

  // Watch current state
  final searchQuery = ref.watch(searchQueryProvider);
  final filters = ref.watch(filterOptionsProvider);
  final sortOption = ref.watch(sortOptionProvider);

  // Apply search query to filters if it exists
  final activeFilters = filters.copyWith(searchQuery: searchQuery);

  // Offload to background isolate
  return await compute(PokemonService.processPokemon, {
    'list': allPokemon,
    'filters': activeFilters,
    'sortOption': sortOption,
  });
});
