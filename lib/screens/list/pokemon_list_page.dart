import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/themes/app_theme.dart';
import '../../services/pokemon_service.dart';
import '../../models/filter_options.dart';
import '../../providers/pokemon_providers.dart';
import '../detail/pokemon_detail_page.dart';
import 'widgets/pokemon_list_tile.dart';
import 'widgets/pokemon_card.dart';
import 'widgets/filter_widget.dart';
import 'widgets/pokemon_list_header.dart';

enum ViewMode { list, grid }

/// Main list page displaying all Pokemon
class PokemonListPage extends ConsumerStatefulWidget {
  const PokemonListPage({super.key});

  @override
  ConsumerState<PokemonListPage> createState() => _PokemonListPageState();
}

class _PokemonListPageState extends ConsumerState<PokemonListPage> {
  ViewMode _viewMode = ViewMode.list;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _openFilterDialog(FilterOptions currentFilters) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterWidget(
        currentFilters: currentFilters,
        onApply: (filters) {
          ref.read(filterOptionsProvider.notifier).state = filters;
        },
      ),
    );
  }

  void _showSortMenu(SortOption currentSort) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
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
                _buildSortItem('ID', SortOption.idAsc, SortOption.idDesc, currentSort, defaultIsAscending: true),
                _buildSortItem('Name', SortOption.nameAsc, SortOption.nameDesc, currentSort, defaultIsAscending: true),
                _buildSortItem('CP', SortOption.maxCpDesc, SortOption.maxCpAsc, currentSort, defaultIsAscending: false),
                _buildSortItem('Attack', SortOption.attackDesc, SortOption.attackAsc, currentSort, defaultIsAscending: false),
                _buildSortItem('Defense', SortOption.defenseDesc, SortOption.defenseAsc, currentSort, defaultIsAscending: false),
                _buildSortItem('HP', SortOption.staminaDesc, SortOption.staminaAsc, currentSort, defaultIsAscending: false),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortItem(String label, SortOption defaultOption, SortOption alternateOption, SortOption currentSort, {required bool defaultIsAscending}) {
    final isSelected = currentSort == defaultOption || currentSort == alternateOption;
    
    IconData? trailingIcon;
    if (isSelected) {
      bool isCurrentlyAscending = (currentSort == defaultOption) ? defaultIsAscending : !defaultIsAscending;
      trailingIcon = isCurrentlyAscending ? Icons.arrow_upward : Icons.arrow_downward;
    }

    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: isSelected ? Icon(trailingIcon, color: AppColors.pokedexRed) : null,
      onTap: () {
        if (currentSort == defaultOption) {
          ref.read(sortOptionProvider.notifier).state = alternateOption;
        } else {
          ref.read(sortOptionProvider.notifier).state = defaultOption;
        }
        Navigator.pop(context);
      },
    );
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataAsync = ref.watch(pokemonDataProvider);
    final displayedPokemon = ref.watch(filteredPokemonProvider);
    final currentFilters = ref.watch(filterOptionsProvider);
    final currentSort = ref.watch(sortOptionProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: dataAsync.when(
        loading: () => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.pokedexRed),
              const SizedBox(height: 16),
              Text(
                'Loading Pokédex…',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Text('Error loading Pokédex: $err', style: const TextStyle(color: Colors.red)),
        ),
        data: (_) {
          final list = displayedPokemon.value ?? [];
          final screenWidth = MediaQuery.of(context).size.width;
          final bool showStats = screenWidth > 550;
          final bool showMoves = screenWidth > 800;
          
          return Column(
            children: [
              PokemonListHeader(
                onFilterPressed: () => _openFilterDialog(currentFilters),
                onSortPressed: () => _showSortMenu(currentSort),
                onViewModePressed: () {
                  setState(() {
                    _viewMode = _viewMode == ViewMode.list ? ViewMode.grid : ViewMode.list;
                  });
                },
                onSearchChanged: _onSearchChanged,
                isGridView: _viewMode == ViewMode.grid,
              ),
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search_off_rounded, color: AppColors.textOnDarkDim, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              'No Pokémon found',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try adjusting your search or filters',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      )
                    : _viewMode == ViewMode.list
                        ? ListView.builder(
                            padding: const EdgeInsets.only(top: 8, bottom: 24),
                            itemCount: list.length,
                            prototypeItem: list.isNotEmpty 
                                ? PokemonListTile(
                                    entry: list.first, 
                                    onTap: () {},
                                    showStats: showStats,
                                    showMoves: showMoves,
                                  ) 
                                : const SizedBox(height: 82),
                            itemBuilder: (context, index) {
                              final entry = list[index];
                              return PokemonListTile(
                                entry: entry,
                                showStats: showStats,
                                showMoves: showMoves,
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
                                  bottom: 24,
                                ),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  mainAxisExtent: 220,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),
                                itemCount: list.length,
                                itemBuilder: (context, index) {
                                  final entry = list[index];
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
          );
        },
      ),
    );
  }
}
