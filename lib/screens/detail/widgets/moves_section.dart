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
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white.withOpacity(0.5),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
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
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isElite 
                    ? Colors.amber.withOpacity(0.15)
                    : typeColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isElite 
                      ? Colors.amber.withOpacity(0.3)
                      : typeColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isElite) ...[
                    const Icon(Icons.star, size: 10, color: Colors.amber),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    move.replaceAll('_FAST', '')
                        .replaceAll('_', ' ')
                        .toLowerCase().split(' ')
                        .map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
                        .join(' '),
                    style: TextStyle(
                      fontSize: 12,
                      color: isElite ? Colors.amber : Colors.white.withOpacity(0.9),
                      fontWeight: isElite ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
