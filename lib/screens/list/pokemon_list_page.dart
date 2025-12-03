import 'package:flutter/material.dart';

import '../../services/pokemon_service.dart';
import '../../models/pokemon_entry.dart';
import '../../models/filter_options.dart';
import '../detail/pokemon_detail_page.dart';
import 'widgets/pokemon_list_tile.dart';
import 'widgets/pokemon_card.dart';
import 'widgets/filter_widget.dart';
import 'widgets/pokemon_list_header.dart';
import 'widgets/pokeball_fab.dart';

enum ViewMode { list, grid }

/// Main list page displaying all Pokemon
class PokemonListPage extends StatefulWidget {
  const PokemonListPage({super.key});

  @override
  State<PokemonListPage> createState() => _PokemonListPageState();
}

class _PokemonListPageState extends State<PokemonListPage> {
  final _pokemonService = PokemonService.instance;
  List<PokemonEntry> _allPokemon = []; // Store all loaded Pokemon
  List<PokemonEntry> _displayedPokemon = []; // Store filtered and sorted Pokemon
  bool _loading = true;
  SortOption _currentSort = SortOption.idAsc;
  ViewMode _viewMode = ViewMode.list;
  FilterOptions _currentFilters = const FilterOptions();

  @override
  void initState() {
    super.initState();
    _loadPokemon();
  }

  Future<void> _loadPokemon() async {
    try {
      final pokemonList = await _pokemonService.loadPokemon();
      setState(() {
        _allPokemon = pokemonList;
        _applyFiltersAndSort();
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading Pokémon: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  void _applyFiltersAndSort() {
    var filtered = _pokemonService.filterPokemon(_allPokemon, _currentFilters);
    _displayedPokemon = _pokemonService.sortPokemon(filtered, _currentSort);
  }

  void _sortList(SortOption newSort) {
    setState(() {
      _currentSort = newSort;
      _applyFiltersAndSort();
    });
  }

  void _openFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterWidget(
        currentFilters: _currentFilters,
        onApply: (filters) {
          setState(() {
            _currentFilters = filters;
            _applyFiltersAndSort();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              PokemonListHeader(
                onFilterPressed: _openFilterDialog,
                onSortPressed: () {
                  // TODO: Show sort menu
                },
                onViewModePressed: () {
                  setState(() {
                    _viewMode = _viewMode == ViewMode.list ? ViewMode.grid : ViewMode.list;
                  });
                },
                isGridView: _viewMode == ViewMode.grid,
              ),
              Expanded(
                child: _displayedPokemon.isEmpty
                    ? const Center(child: Text('No Pokémon found matching filters.', style: TextStyle(color: Colors.white)))
                    : _viewMode == ViewMode.list
                        ? ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80), // Space for FAB
                            itemCount: _displayedPokemon.length,
                            itemBuilder: (context, index) {
                              final entry = _displayedPokemon[index];
                              return PokemonListTile(
                                entry: entry,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => PokemonDetailPage(entry: entry),
                                    ),
                                  );
                                },
                              );
                            },
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.only(
                              left: 8,
                              right: 8,
                              top: 8,
                              bottom: 80, // Space for FAB
                            ),
                            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 120, // Cards will be at most 120px wide
                              childAspectRatio: 0.75, // Slightly taller to fit content comfortably
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            itemCount: _displayedPokemon.length,
                            itemBuilder: (context, index) {
                              final entry = _displayedPokemon[index];
                              return PokemonCard(
                                entry: entry,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => PokemonDetailPage(entry: entry),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: PokeballFab(
                onPressed: _openFilterDialog, // Using FAB for menu/filter for now
              ),
            ),
          ),
        ],
      ),
    );
  }
}
