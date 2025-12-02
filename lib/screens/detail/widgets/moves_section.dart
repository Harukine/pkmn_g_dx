import 'package:flutter/material.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/constants/type_colors.dart';
import '../../../core/constants/move_type_data.dart';
import '../../../models/pokemon_form.dart';

class MovesSection extends StatelessWidget {
  final PokemonForm form;

  const MovesSection({super.key, required this.form});

  @override
  Widget build(BuildContext context) {
    if (form.quickMoves.isEmpty && form.cinematicMoves.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Moves',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: UIConstants.spacingMedium),
        if (form.quickMoves.isNotEmpty) ...[
          _buildMoveCategory(context, 'Quick Moves', form.quickMoves, form.eliteQuickMoves),
          const SizedBox(height: UIConstants.spacingMedium),
        ],
        if (form.cinematicMoves.isNotEmpty) ...[
          _buildMoveCategory(context, 'Charged Moves', form.cinematicMoves, form.eliteCinematicMoves),
        ],
      ],
    );
  }

  Widget _buildMoveCategory(
    BuildContext context,
    String title,
    List<String> moves,
    List<String> eliteMoves,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
              ),
        ),
        const SizedBox(height: UIConstants.spacingSmall),
        Wrap(
          spacing: UIConstants.spacingSmall,
          runSpacing: UIConstants.spacingSmall,
          children: moves.map((move) {
            final isElite = eliteMoves.contains(move);
            final moveType = MoveTypeData.getMoveType(move);
            final typeColor = moveType != null 
                ? TypeColors.getColorForType(moveType)
                : Colors.grey;
            
            return Chip(
              label: Text(
                move.replaceAll('_FAST', '')
                    .replaceAll('_', ' ')
                    .toLowerCase().split(' ')
                    .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
                    .join(' '),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: isElite 
                  ? Colors.amber.shade800 
                  : typeColor,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            );
          }).toList(),
        ),
      ],
    );
  }
}
