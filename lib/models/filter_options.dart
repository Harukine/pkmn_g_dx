import 'package:flutter/material.dart';
import 'pokemon_form.dart';

class FilterOptions {
  final Set<String> types;
  final RangeValues? attackRange;
  final RangeValues? defenseRange;
  final RangeValues? staminaRange;
  final Set<int> generations;
  final Set<FormType> formTypes;
  final Set<String> pokemonClasses;
  final String searchQuery;

  const FilterOptions({
    this.types = const {},
    this.attackRange,
    this.defenseRange,
    this.staminaRange,
    this.generations = const {},
    this.formTypes = const {},
    this.pokemonClasses = const {},
    this.searchQuery = '',
  });

  FilterOptions copyWith({
    Set<String>? types,
    RangeValues? attackRange,
    RangeValues? defenseRange,
    RangeValues? staminaRange,
    Set<int>? generations,
    Set<FormType>? formTypes,
    Set<String>? pokemonClasses,
    String? searchQuery,
  }) {
    return FilterOptions(
      types: types ?? this.types,
      attackRange: attackRange ?? this.attackRange,
      defenseRange: defenseRange ?? this.defenseRange,
      staminaRange: staminaRange ?? this.staminaRange,
      generations: generations ?? this.generations,
      formTypes: formTypes ?? this.formTypes,
      pokemonClasses: pokemonClasses ?? this.pokemonClasses,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get isEmpty =>
      types.isEmpty &&
      attackRange == null &&
      defenseRange == null &&
      staminaRange == null &&
      generations.isEmpty &&
      formTypes.isEmpty &&
      pokemonClasses.isEmpty &&
      searchQuery.isEmpty;
}
