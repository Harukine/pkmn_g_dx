import 'package:flutter/material.dart';
import '../../../core/constants/ui_constants.dart';

class PokemonListHeader extends StatelessWidget {
  final VoidCallback onFilterPressed;
  final VoidCallback onSortPressed;
  final VoidCallback onViewModePressed;
  final bool isGridView;

  const PokemonListHeader({
    super.key,
    required this.onFilterPressed,
    required this.onSortPressed,
    required this.onViewModePressed,
    required this.isGridView,
  });

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
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: Icon(
              isGridView ? Icons.view_list : Icons.grid_view,
              color: Colors.white,
            ),
            onPressed: onViewModePressed,
          ),
        ],
      ),
    );
  }
}
