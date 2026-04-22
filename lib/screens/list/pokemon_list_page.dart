import 'package:flutter/material.dart';

import '../../services/pokemon_service.dart';
import '../../models/pokemon_entry.dart';
import '../../models/filter_options.dart';
import '../detail/pokemon_detail_page.dart';
import 'widgets/pokemon_list_tile.dart';
import 'widgets/pokemon_card.dart';
import 'widgets/filter_widget.dart';
import 'widgets/pokemon_list_header.dart';

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

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Sort By',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildSortItem('ID', SortOption.idAsc, SortOption.idDesc, defaultIsAscending: true),
                _buildSortItem('Name', SortOption.nameAsc, SortOption.nameDesc, defaultIsAscending: true),
                _buildSortItem('CP', SortOption.maxCpDesc, SortOption.maxCpAsc, defaultIsAscending: false),
                _buildSortItem('Attack', SortOption.attackDesc, SortOption.attackAsc, defaultIsAscending: false),
                _buildSortItem('Defense', SortOption.defenseDesc, SortOption.defenseAsc, defaultIsAscending: false),
                _buildSortItem('HP', SortOption.staminaDesc, SortOption.staminaAsc, defaultIsAscending: false),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortItem(String label, SortOption defaultOption, SortOption alternateOption, {required bool defaultIsAscending}) {
    final isSelected = _currentSort == defaultOption || _currentSort == alternateOption;
    
    IconData? trailingIcon;
    if (isSelected) {
      bool isCurrentlyAscending = (_currentSort == defaultOption) ? defaultIsAscending : !defaultIsAscending;
      trailingIcon = isCurrentlyAscending ? Icons.arrow_upward : Icons.arrow_downward;
    }

    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.blue : null,
        ),
      ),
      trailing: isSelected ? Icon(trailingIcon, color: Colors.blue) : null,
      onTap: () {
        if (_currentSort == defaultOption) {
          _sortList(alternateOption);
        } else {
          _sortList(defaultOption);
        }
        Navigator.pop(context);
      },
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
                onSortPressed: _showSortMenu,
                onViewModePressed: () {
                  setState(() {
                    _viewMode = _viewMode == ViewMode.list ? ViewMode.grid : ViewMode.list;
                  });
                },
                onSearchChanged: (query) {
                  setState(() {
                    _currentFilters = _currentFilters.copyWith(searchQuery: query);
                    _applyFiltersAndSort();
                  });
                },
                isGridView: _viewMode == ViewMode.grid,
              ),
              Expanded(
                child: _displayedPokemon.isEmpty
                    ? const Center(child: Text('No Pokémon found matching filters.', style: TextStyle(color: Colors.white)))
                    : _viewMode == ViewMode.list
                        ? ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24), // Space removed for FAB
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
                        : Builder(
                            builder: (context) {
                              final screenWidth = MediaQuery.of(context).size.width;
                              int crossAxisCount;
                              if (screenWidth < 360) {
                                crossAxisCount = 2;
                              } else if (screenWidth < 600) {
                                crossAxisCount = 3;
                              } else if (screenWidth < 900) {
                                crossAxisCount = 5;
                              } else {
                                crossAxisCount = 7;
                              }
                              
                              return GridView.builder(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  top: 8,
                                  bottom: 24, // Space removed for FAB
                                ),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
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
                              );
                            }
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
