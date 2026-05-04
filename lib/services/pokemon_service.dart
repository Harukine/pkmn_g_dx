import 'dart:convert';
import 'package:flutter/foundation.dart';
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
  attackAsc,
  attackDesc,
  defenseAsc,
  defenseDesc,
  staminaAsc,
  staminaDesc,
  maxCpAsc,
  maxCpDesc,
}

/// A node in the evolution chain, representing a specific Pokemon and optionally a specific form
class EvolutionNode {
  final PokemonEntry entry;
  final String? formId;
  final String name;
  final String? iconUrl;
  final int? candyCost;

  EvolutionNode({
    required this.entry,
    this.formId,
    required this.name,
    this.iconUrl,
    this.candyCost,
  });
}

/// Service class for loading and managing Pokemon data
class PokemonService {
  PokemonService();



  /// Find a Pokemon entry by its ID or species ID
  PokemonEntry? findEntryById(String id) {
    // 1. Try exact match first (O(1))
    if (_idIndex.containsKey(id)) {
      return _idIndex[id];
    }

    // 2. Special alias mapping for known data mismatches
    String? aliasId;
    if (id == 'NIDORAN_FEMALE') aliasId = 'NIDORAN';
    if (id == 'NIDORAN') aliasId = 'NIDORAN_FEMALE'; // Try reverse too
    
    if (aliasId != null && _idIndex.containsKey(aliasId)) {
      return _idIndex[aliasId];
    }
    
    // 3. Try base species ID (e.g. VENUSAUR_MEGA -> VENUSAUR)
    final baseId = id.split('_').first;
    if (baseId != id && _idIndex.containsKey(baseId)) {
      return _idIndex[baseId];
    }
    
    return null;
  }
  final Map<String, PokemonEntry> _idIndex = {};

  /// Load Pokemon data from JSON asset
  Future<List<PokemonEntry>> loadPokemon() async {
    try {
      final jsonString = await rootBundle.loadString(AppConstants.pokemonDataPath);
      final data = await compute(jsonDecode, jsonString) as List<dynamic>;

      final rawList = data
          .map((e) => PokemonEntry.fromJson(e as Map<String, dynamic>))
          .toList();

      final allPokemon = _deduplicatePokemon(rawList);
      
      // Build O(1) lookup index for fast queries
      _idIndex.clear();
      _evolutionChainCache.clear();
      for (final entry in allPokemon) {
        _idIndex[entry.basePokemonId] = entry;
        _idIndex[entry.defaultPokemonId] = entry;
        for (final form in entry.forms) {
          _idIndex[form.pokemonId] = entry;
          if (form.formId != null) {
            _idIndex[form.formId!] = entry;
          }
        }
      }

      return allPokemon;
    } catch (e) {
      debugPrint('Error loading Pokémon: $e');
      rethrow;
    }
  }

  /// Load Move stats from JSON asset
  Future<Map<String, dynamic>> loadMoveStats() async {
    try {
      final jsonString = await rootBundle.loadString('data/move_stats.json');
      return await compute(jsonDecode, jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error loading move stats: $e');
      return {};
    }
  }

  final Map<String, List<List<EvolutionNode>>> _evolutionChainCache = {};

  /// Get the full evolution chain for a Pokemon, including Mega/Primal forms.
  /// Respects regional variants (Alolan, Galarian, etc.)
  List<List<EvolutionNode>> getEvolutionChain(String pokemonId, {String? formId}) {
    // Check cache first (formId is usually just used to find the initial form type)
    if (_evolutionChainCache.containsKey(pokemonId)) {
      return _evolutionChainCache[pokemonId]!;
    }

    final initialEntry = findEntryById(pokemonId);
    if (initialEntry == null) return [];

    // Identify the specific form we are starting from
    final initialForm = initialEntry.forms.firstWhere(
      (f) => f.formId == formId && f.pokemonId == pokemonId,
      orElse: () => initialEntry.forms.firstWhere(
        (f) => f.pokemonId == pokemonId && f.formType != FormType.costume,
        orElse: () => initialEntry.forms.firstWhere(
          (f) => f.formType == FormType.normal && (f.formId == null || f.formId == 'NORMAL'),
          orElse: () => initialEntry.forms.first,
        ),
      ),
    );

    final currentFormType = initialForm.formType;

    // 1. Find the root of the chain
    PokemonEntry? root = initialEntry;
    PokemonForm? rootForm = initialForm;
    
    // Trace back to root
    while (true) {
      final parentId = rootForm?.parentPokemonId;
      if (parentId == null) break;
      
      final parent = findEntryById(parentId);
      if (parent == null || parent.basePokemonId == root?.basePokemonId) break;
      
      root = parent;
      final nonNullRoot = root;
      // Try to find a form in the parent that matches our current form type (e.g. Regional)
      rootForm = nonNullRoot.forms.firstWhere(
        (f) => f.formType == currentFormType,
        orElse: () => nonNullRoot.forms.firstWhere(
          (f) => f.formType == FormType.normal,
          orElse: () => nonNullRoot.forms.first,
        ),
      );
    }

    // 2. Build stages from root down
    List<List<EvolutionNode>> stages = [];
    
    // Internal helper for building the chain with context
    void buildChain(List<Map<PokemonEntry, _EvolutionContext>> currentEntriesWithContext) {
      if (currentEntriesWithContext.isEmpty) return;
      
      // Add current entries as a stage
      stages.add(currentEntriesWithContext.map((ctx) {
        final p = ctx.keys.first;
        final context = ctx.values.first;
        
        // Find the best form to represent this entry in this context
        final bestForm = p.forms.firstWhere(
          (f) => f.formType == context.type && (f.formId == null || f.formId == 'NORMAL' || f.formId == p.basePokemonId),
          orElse: () => p.forms.firstWhere(
            (f) => f.formType == context.type && !f.isCostume,
            orElse: () => p.forms.firstWhere(
              (f) => f.formType == FormType.normal && (f.formId == null || f.formId == 'NORMAL' || f.formId == p.basePokemonId),
              orElse: () => p.forms.firstWhere(
                (f) => f.formType == FormType.normal && !f.isCostume,
                orElse: () => p.forms.first,
              ),
            ),
          ),
        );

        return EvolutionNode(
          entry: p,
          formId: bestForm.formId,
          name: bestForm.formName == 'Normal' ? p.name : bestForm.formName,
          iconUrl: bestForm.goIconUrl,
          candyCost: context.candyCost,
        );
      }).toList());

      // Find next evolutions
      List<Map<PokemonEntry, _EvolutionContext>> nextContexts = [];
      for (final ctx in currentEntriesWithContext) {
        final p = ctx.keys.first;
        final context = ctx.values.first;
        
        final bestForm = p.forms.firstWhere(
          (f) => f.formType == context.type && (f.formId == null || f.formId == 'NORMAL' || f.formId == p.basePokemonId),
          orElse: () => p.forms.firstWhere(
            (f) => f.formType == context.type && !f.isCostume,
            orElse: () => p.forms.firstWhere(
              (f) => f.formType == FormType.normal && (f.formId == null || f.formId == 'NORMAL' || f.formId == p.basePokemonId),
              orElse: () => p.forms.firstWhere(
                (f) => f.formType == FormType.normal && !f.isCostume,
                orElse: () => p.forms.first,
              ),
            ),
          ),
        );

        for (final evo in bestForm.nextEvolutions) {
          final nextEntry = findEntryById(evo.evolutionId);
          if (nextEntry != null) {
            // Determine the form type of the evolution
            final targetId = evo.evolutionId.endsWith('_NORMAL') 
                ? evo.evolutionId.replaceAll('_NORMAL', '') 
                : evo.evolutionId;

            final nextForm = nextEntry.forms.firstWhere(
              (f) => f.pokemonId == targetId || f.pokemonId == evo.evolutionId,
              orElse: () => nextEntry.forms.firstWhere(
                (f) => f.formType == context.type && !f.isCostume,
                orElse: () => nextEntry.forms.firstWhere(
                  (f) => f.formType == FormType.normal && !f.isCostume,
                  orElse: () => nextEntry.forms.first,
                ),
              ),
            );
            nextContexts.add({nextEntry: _EvolutionContext(type: nextForm.formType, candyCost: evo.candyCost)});
          }
        }
      }

      if (nextContexts.isNotEmpty) {
        buildChain(nextContexts);
      }
    }

    buildChain([{root!: _EvolutionContext(type: rootForm?.formType ?? FormType.normal, candyCost: null)}]);
    
    // Save to cache before returning
    _evolutionChainCache[pokemonId] = stages;
    
    return stages;
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
      // Filter by Search Query
      if (filters.searchQuery.isNotEmpty) {
        final query = filters.searchQuery.toLowerCase();
        if (!entry.searchKey.contains(query)) {
          return false;
        }
      }

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

      // Filter by Pokemon Class
      if (filters.pokemonClasses.isNotEmpty) {
        final hasMatchingClass = entry.forms.any((form) {
          final pClass = form.pokemonClass;
          if (filters.pokemonClasses.contains('Normal')) {
            if (pClass == null || pClass == 'POKEMON_CLASS_NORMAL') return true;
          }
          if (filters.pokemonClasses.contains('Legendary') && pClass == 'POKEMON_CLASS_LEGENDARY') return true;
          if (filters.pokemonClasses.contains('Mythical') && pClass == 'POKEMON_CLASS_MYTHICAL') return true;
          if (filters.pokemonClasses.contains('Ultra Beast') && pClass == 'POKEMON_CLASS_ULTRA_BEAST') return true;
          return false;
        });
        if (!hasMatchingClass) return false;
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
    if (pokemonList.isEmpty) return [];
    
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
      case SortOption.attackAsc:
        sorted.sort((a, b) => a.baseAttack.compareTo(b.baseAttack));
        break;
      case SortOption.attackDesc:
        sorted.sort((a, b) => b.baseAttack.compareTo(a.baseAttack));
        break;
      case SortOption.defenseAsc:
        sorted.sort((a, b) => a.baseDefense.compareTo(b.baseDefense));
        break;
      case SortOption.defenseDesc:
        sorted.sort((a, b) => b.baseDefense.compareTo(a.baseDefense));
        break;
      case SortOption.staminaAsc:
        sorted.sort((a, b) => a.baseStamina.compareTo(b.baseStamina));
        break;
      case SortOption.staminaDesc:
        sorted.sort((a, b) => b.baseStamina.compareTo(a.baseStamina));
        break;
      case SortOption.maxCpAsc:
        sorted.sort((a, b) => a.maxCp.compareTo(b.maxCp));
        break;
      case SortOption.maxCpDesc:
        sorted.sort((a, b) => b.maxCp.compareTo(a.maxCp));
        break;
    }

    return sorted;
  }

  /// Static helper for background processing (compute)
  static List<PokemonEntry> processPokemon(Map<String, dynamic> params) {
    final List<PokemonEntry> list = params['list'] as List<PokemonEntry>;
    final FilterOptions filters = params['filters'] as FilterOptions;
    final SortOption sortOption = params['sortOption'] as SortOption;
    
    final service = PokemonService();
    
    // 1. Filter the list (Already flattened in provider)
    final filtered = service.filterPokemon(list, filters);
    
    // 2. Sort the filtered list
    return service.sortPokemon(filtered, sortOption);
  }

  /// Specialized isolate helper for one-time flattening
  List<PokemonEntry> flattenPokemonIsolate(List<PokemonEntry> list) {
    return _flattenPokemon(list);
  }

  /// Expands a list of Pokemon entries by creating separate entries for Megas and Regional forms.
  List<PokemonEntry> _flattenPokemon(List<PokemonEntry> list) {
    final List<PokemonEntry> expanded = [];

    for (final entry in list) {
      // Add the base/normal form as the primary entry
      expanded.add(entry);

      // Add Megas and Regional forms as separate entries
      for (final form in entry.forms) {
        if (form.formType == FormType.mega || 
            form.formType == FormType.primal || 
            form.formType == FormType.regional) {
          
          // Determine the formatted name
          String syntheticName = entry.name;
          if (form.formType == FormType.mega) {
            syntheticName = 'Mega ${entry.name}';
            if (form.formName.contains(' X')) syntheticName += ' X';
            if (form.formName.contains(' Y')) syntheticName += ' Y';
          } else if (form.formType == FormType.primal) {
            syntheticName = 'Primal ${entry.name}';
          } else if (form.formType == FormType.regional) {
            // Convert "Alolan Form" to "Alolan Rattata"
            final region = form.formName.replaceAll(' Form', '').trim();
            syntheticName = '$region ${entry.name}';
          }

          expanded.add(entry.copyWith(
            basePokemonId: form.pokemonId,
            name: syntheticName,
            defaultPokemonId: form.pokemonId,
            types: form.types,
            baseAttack: form.baseAttack,
            baseDefense: form.baseDefense,
            baseStamina: form.baseStamina,
            maxCp: form.maxCp,
            goIconUrl: form.goIconUrl,
            // Keep the forms list but ensure the current form is the first one
            forms: [form, ...entry.forms.where((f) => f.pokemonId != form.pokemonId)],
          ));
        }
      }
    }

    return expanded;
  }
}

class _EvolutionContext {
  final FormType type;
  final int? candyCost;
  _EvolutionContext({required this.type, this.candyCost});
}
