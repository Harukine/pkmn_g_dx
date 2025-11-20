import 'package:flutter/material.dart';

import '../../services/pokemon_service.dart';
import '../../models/pokemon_entry.dart';
import '../detail/pokemon_detail_page.dart';
import 'widgets/pokemon_list_tile.dart';

/// Main list page displaying all Pokemon
class PokemonListPage extends StatefulWidget {
  const PokemonListPage({super.key});

  @override
  State<PokemonListPage> createState() => _PokemonListPageState();
}

class _PokemonListPageState extends State<PokemonListPage> {
  final _pokemonService = PokemonService.instance;
  List<PokemonEntry> _pokemonList = [];
  bool _loading = true;
  SortOption _currentSort = SortOption.idAsc;

  @override
  void initState() {
    super.initState();
    _loadPokemon();
  }

  Future<void> _loadPokemon() async {
    try {
      final pokemonList = await _pokemonService.loadPokemon();
      setState(() {
        _pokemonList = _pokemonService.sortPokemon(pokemonList, _currentSort);
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading Pokémon: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  void _sortList(SortOption newSort) {
    setState(() {
      _currentSort = newSort;
      _pokemonList = _pokemonService.sortPokemon(_pokemonList, newSort);
    });
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
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _pokemonList.length,
        itemBuilder: (context, index) {
          final entry = _pokemonList[index];
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
      ),
    );
  }
}
