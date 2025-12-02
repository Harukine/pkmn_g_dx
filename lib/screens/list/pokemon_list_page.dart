import 'package:flutter/material.dart';

import '../../services/pokemon_service.dart';
import '../../models/pokemon_entry.dart';
import '../../models/filter_options.dart';
import '../detail/pokemon_detail_page.dart';
import 'widgets/pokemon_list_tile.dart';
import 'widgets/pokemon_card.dart';
import 'widgets/filter_widget.dart';

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
      appBar: AppBar(
        title: const Text('Pokédex'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: Icon(
              _viewMode == ViewMode.list ? Icons.grid_view : Icons.view_list,
            ),
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == ViewMode.list ? ViewMode.grid : ViewMode.list;
              });
            },
            tooltip: _viewMode == ViewMode.list ? 'Grid View' : 'List View',
          ),
          PopupMenuButton<SortOption>(
            onSelected: _sortList,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SortOption.nameAsc,
                child: Text('Name (A-Z)'),
              ),
              const PopupMenuItem(
                value: SortOption.nameDesc,
                child: Text('Name (Z-A)'),
              ),
              const PopupMenuItem(
                value: SortOption.idAsc,
                child: Text('ID (Low-High)'),
              ),
              const PopupMenuItem(
                value: SortOption.idDesc,
                child: Text('ID (High-Low)'),
              ),
              const PopupMenuItem(
                value: SortOption.attackDesc,
                child: Text('Attack (High-Low)'),
              ),
              const PopupMenuItem(
                value: SortOption.defenseDesc,
                child: Text('Defense (High-Low)'),
              ),
              const PopupMenuItem(
                value: SortOption.staminaDesc,
                child: Text('Stamina (High-Low)'),
              ),
            ],
          ),
        ],
      ),
      body: _displayedPokemon.isEmpty
          ? const Center(child: Text('No Pokémon found matching filters.'))
          : _viewMode == ViewMode.list
              ? ListView.builder(
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
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    childAspectRatio: 0.85,
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
    );
  }
}
