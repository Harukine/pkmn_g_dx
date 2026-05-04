import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pkmn_g_dx/models/filter_options.dart';
import 'package:pkmn_g_dx/models/pokemon_entry.dart';
import 'package:pkmn_g_dx/models/pokemon_form.dart';
import 'package:pkmn_g_dx/services/pokemon_service.dart';

void main() {
  late PokemonService service;
  late List<PokemonEntry> testData;

  setUp(() {
    service = PokemonService();
    testData = [
      const PokemonEntry(
        basePokemonId: 'BULBASAUR',
        name: 'Bulbasaur',
        defaultPokemonId: 'BULBASAUR',
        types: ['Grass', 'Poison'],
        baseAttack: 118,
        baseDefense: 111,
        baseStamina: 128,
        hasCostumeForms: false,
        dexNumber: 1,
        goIconUrl: null,
        forms: [
          PokemonForm(
            pokemonId: 'BULBASAUR',
            formId: 'NORMAL',
            formName: 'Normal',
            formType: FormType.normal,
            types: ['Grass', 'Poison'],
            baseAttack: 118,
            baseDefense: 111,
            baseStamina: 128,
            dexNumber: 1,
            goIconUrl: null,
            maxCp: 1115,
          ),
        ],
        maxCp: 1115,
        searchKey: 'bulbasaur 1',
      ),
      const PokemonEntry(
        basePokemonId: 'CHARMANDER',
        name: 'Charmander',
        defaultPokemonId: 'CHARMANDER',
        types: ['Fire'],
        baseAttack: 116,
        baseDefense: 93,
        baseStamina: 118,
        hasCostumeForms: false,
        dexNumber: 4,
        goIconUrl: null,
        forms: [
          PokemonForm(
            pokemonId: 'CHARMANDER',
            formId: 'NORMAL',
            formName: 'Normal',
            formType: FormType.normal,
            types: ['Fire'],
            baseAttack: 116,
            baseDefense: 93,
            baseStamina: 118,
            dexNumber: 4,
            goIconUrl: null,
            maxCp: 980,
          ),
        ],
        maxCp: 980,
        searchKey: 'charmander 4',
      ),
      const PokemonEntry(
        basePokemonId: 'MEWTWO',
        name: 'Mewtwo',
        defaultPokemonId: 'MEWTWO',
        types: ['Psychic'],
        baseAttack: 300,
        baseDefense: 182,
        baseStamina: 214,
        hasCostumeForms: false,
        dexNumber: 150,
        goIconUrl: null,
        forms: [
          PokemonForm(
            pokemonId: 'MEWTWO',
            formId: 'NORMAL',
            formName: 'Normal',
            formType: FormType.normal,
            types: ['Psychic'],
            baseAttack: 300,
            baseDefense: 182,
            baseStamina: 214,
            dexNumber: 150,
            goIconUrl: null,
            maxCp: 4178,
          ),
          PokemonForm(
            pokemonId: 'MEWTWO',
            formId: 'ARMORED',
            formName: 'Armored',
            formType: FormType.special,
            types: ['Psychic'],
            baseAttack: 182,
            baseDefense: 278,
            baseStamina: 214,
            dexNumber: 150,
            goIconUrl: null,
            maxCp: 3187,
          ),
        ],
        maxCp: 4178,
        searchKey: 'mewtwo 150',
      ),
    ];
  });

  group('PokemonService Filtering', () {
    test('Filter by Type', () {
      final filters = FilterOptions(types: {'Fire'});
      final result = service.filterPokemon(testData, filters);
      expect(result.length, 1);
      expect(result.first.name, 'Charmander');
    });

    test('Filter by Generation', () {
      final filters = FilterOptions(generations: {1});
      final result = service.filterPokemon(testData, filters);
      expect(result.length, 3); // All are Gen 1
    });

    test('Filter by Stats (Attack)', () {
      final filters = FilterOptions(
        attackRange: const RangeValues(200, 400),
      );
      final result = service.filterPokemon(testData, filters);
      expect(result.length, 1);
      expect(result.first.name, 'Mewtwo');
    });

    test('Filter by Form Type', () {
      final filters = FilterOptions(formTypes: {FormType.special});
      final result = service.filterPokemon(testData, filters);
      expect(result.length, 1);
      expect(result.first.name, 'Mewtwo');
    });
  });

  group('PokemonService Sorting', () {
    test('Sort by Attack Descending', () {
      final result = service.sortPokemon(testData, SortOption.attackDesc);
      expect(result[0].name, 'Mewtwo');
      expect(result[1].name, 'Bulbasaur');
      expect(result[2].name, 'Charmander');
    });
  });
}
