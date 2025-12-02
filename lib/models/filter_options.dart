import 'package:flutter/material.dart';
import 'pokemon_form.dart';

class FilterOptions {
  final Set<String> types;
  final RangeValues? attackRange;
  final RangeValues? defenseRange;
  final RangeValues? staminaRange;
  final Set<int> generations;
  final Set<FormType> formTypes;

  const FilterOptions({
    this.types = const {},
    this.attackRange,
    this.defenseRange,
    this.staminaRange,
    this.generations = const {},
    this.formTypes = const {},
  });

  FilterOptions copyWith({
    Set<String>? types,
    RangeValues? attackRange,
    RangeValues? defenseRange,
    RangeValues? staminaRange,
    Set<int>? generations,
    Set<FormType>? formTypes,
  }) {
    return FilterOptions(
      types: types ?? this.types,
      attackRange: attackRange ?? this.attackRange,
      defenseRange: defenseRange ?? this.defenseRange,
      staminaRange: staminaRange ?? this.staminaRange,
      generations: generations ?? this.generations,
      formTypes: formTypes ?? this.formTypes,
    );
  }

  bool get isEmpty =>
      types.isEmpty &&
      attackRange == null &&
      defenseRange == null &&
      staminaRange == null &&
      generations.isEmpty &&
      formTypes.isEmpty;
}
