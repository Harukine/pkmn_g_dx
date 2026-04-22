import 'package:flutter/material.dart';
import '../../../core/constants/ui_constants.dart';

class PokemonListHeader extends StatefulWidget {
  final VoidCallback onFilterPressed;
  final VoidCallback onSortPressed;
  final VoidCallback onViewModePressed;
  final ValueChanged<String> onSearchChanged;
  final bool isGridView;

  const PokemonListHeader({
    super.key,
    required this.onFilterPressed,
    required this.onSortPressed,
    required this.onViewModePressed,
    required this.onSearchChanged,
    required this.isGridView,
  });

  @override
  State<PokemonListHeader> createState() => _PokemonListHeaderState();
}

class _PokemonListHeaderState extends State<PokemonListHeader> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 50, // Status bar padding
        left: UIConstants.paddingMedium,
        right: UIConstants.paddingMedium,
        bottom: UIConstants.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_isSearching) ...[
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search Pokémon...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: widget.onSearchChanged,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                  widget.onSearchChanged('');
                });
              },
            ),
          ] else ...[
            Text(
              'Pokémon',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.sort, color: Colors.white),
              onPressed: widget.onSortPressed,
            ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: widget.onFilterPressed,
            ),
            IconButton(
              icon: Icon(
                widget.isGridView ? Icons.view_list : Icons.grid_view,
                color: Colors.white,
              ),
              onPressed: widget.onViewModePressed,
            ),
          ],
        ],
      ),
    );
  }
}
