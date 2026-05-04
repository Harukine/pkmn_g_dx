import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../core/constants/type_colors.dart';
import '../../../core/constants/move_type_data.dart';
import '../../../models/pokemon_form.dart';
import '../../../providers/pokemon_providers.dart';

class MovesSection extends ConsumerWidget {
  final PokemonForm form;

  const MovesSection({super.key, required this.form});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moveStatsAsync = ref.watch(moveStatsProvider);
    final moveStats = moveStatsAsync.value ?? {};

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
          _buildMoveCategory(context, 'Quick Moves', form.quickMoves, form.eliteQuickMoves, moveStats),
          const SizedBox(height: UIConstants.spacingMedium),
        ],
        if (form.cinematicMoves.isNotEmpty) ...[
          _buildMoveCategory(context, 'Charged Moves', form.cinematicMoves, form.eliteCinematicMoves, moveStats),
        ],
      ],
    );
  }

  Widget _buildMoveCategory(
    BuildContext context,
    String title,
    List<String> moves,
    List<String> eliteMoves,
    Map<String, dynamic> moveStats,
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
            return _MoveChip(
              moveId: move,
              isElite: eliteMoves.contains(move),
              isReassigned: form.reassignedMoves.contains(move),
              moveStats: moveStats[move],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _MoveChip extends StatelessWidget {
  final String moveId;
  final bool isElite;
  final bool isReassigned;
  final Map<String, dynamic>? moveStats;

  const _MoveChip({
    required this.moveId,
    required this.isElite,
    required this.isReassigned,
    this.moveStats,
  });

  @override
  Widget build(BuildContext context) {
    // Use MoveTypeData which now handles fallback logic
    final moveType = moveStats?['type'] ?? MoveTypeData.getMoveType(moveId);
    
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
            MoveTypeData.displayName(moveId),
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: (isElite || isReassigned) ? 1.0 : 0.9),
              fontWeight: (isElite || isReassigned) ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
