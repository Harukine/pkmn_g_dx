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
    final allMoves = {...moves, ...eliteMoves}.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
        ),
        const SizedBox(height: UIConstants.spacingSmall),
        Wrap(
          spacing: UIConstants.spacingSmall,
          runSpacing: UIConstants.spacingSmall,
          children: allMoves.map((move) {
            final isElite = eliteMoves.contains(move);
            final isReassigned = form.reassignedMoves.contains(move);
            
            final moveType = MoveTypeData.getMoveType(move);
            final typeColor = moveType != null 
                ? TypeColors.getColorForType(moveType)
                : Colors.grey;
            
            final borderColor = isElite 
                ? Colors.amber.withValues(alpha: 0.6)
                : (isReassigned ? Colors.cyan.withValues(alpha: 0.6) : typeColor.withValues(alpha: 0.3));
            
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: borderColor,
                  width: (isElite || isReassigned) ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isElite) ...[
                    const Icon(Icons.star, size: 10, color: Colors.amber),
                    const SizedBox(width: 4),
                  ] else if (isReassigned) ...[
                    const Icon(Icons.auto_awesome, size: 10, color: Colors.cyanAccent),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    MoveTypeData.displayName(move),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: (isElite || isReassigned) ? 1.0 : 0.9),
                      fontWeight: (isElite || isReassigned) ? FontWeight.bold : FontWeight.w500,
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
