import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../core/constants/type_colors.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/pokemon_entry.dart';
import '../../../core/constants/move_type_data.dart';
import '../../../widgets/common/pokemon_icon.dart';
import '../../../providers/pokemon_providers.dart';

/// Minimalist list tile — white card on dark bg.
/// Type shown as small colored chips. CP number is the hero value.
class PokemonListTile extends ConsumerWidget {
  final PokemonEntry entry;
  final VoidCallback onTap;
  final bool showStats;
  final bool showMoves;

  const PokemonListTile({
    super.key,
    required this.entry,
    required this.onTap,
    this.showStats = true,
    this.showMoves = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moveStatsAsync = ref.watch(moveStatsProvider);
    final moveStats = moveStatsAsync.value ?? {};

    final cp = entry.maxCp;

    final typeColor = entry.types.isNotEmpty 
        ? TypeColors.getColorForType(entry.types.first) 
        : AppColors.pokedexRed;

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.paddingMedium,
          vertical: 3,
        ),
        child: Material(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Pokémon icon with subtle type-tinted background
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: PokemonIcon(
                        goIconUrl: entry.goIconUrl,
                        size: 50,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name + type chips
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entry.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: entry.types
                              .map((t) => _TypeChip(type: t))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  

                  
                  if (showStats) ...[
                    const SizedBox(width: 16),
                    // Stats Triplet Row (Option C)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _StatItem(label: 'ATK', value: entry.baseAttack, color: Colors.orangeAccent),
                          _buildStatDivider(context),
                          _StatItem(label: 'DEF', value: entry.baseDefense, color: Colors.blueAccent),
                          _buildStatDivider(context),
                          _StatItem(label: 'STA', value: entry.baseStamina, color: Colors.greenAccent),
                        ],
                      ),
                    ),
                  ],
                  
                  if (showMoves) ...[
                    const SizedBox(width: 24),
                    // Best Moves Section (Option A)
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'BEST MOVES',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (entry.defaultForm?.bestQuickMove != null)
                                _MoveBadge(
                                  name: entry.defaultForm!.bestQuickMoveName ?? entry.defaultForm!.bestQuickMove!,
                                  isFast: true,
                                  typeColor: _getMoveColor(entry.defaultForm!.bestQuickMove, moveStats, typeColor),
                                  isElite: entry.defaultForm!.eliteQuickMoves.contains(entry.defaultForm!.bestQuickMove),
                                ),
                              if (entry.defaultForm?.bestQuickMove != null && 
                                  entry.defaultForm?.bestCinematicMove != null)
                                const SizedBox(width: 6),
                              if (entry.defaultForm?.bestCinematicMove != null)
                                _MoveBadge(
                                  name: entry.defaultForm!.bestCinematicMoveName ?? entry.defaultForm!.bestCinematicMove!,
                                  isFast: false,
                                  typeColor: _getMoveColor(entry.defaultForm!.bestCinematicMove, moveStats, typeColor),
                                  isElite: entry.defaultForm!.eliteCinematicMoves.contains(entry.defaultForm!.bestCinematicMove),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(width: 12),
                  // Dex # + CP
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (entry.dexNumber != null)
                        Text(
                          '#${entry.dexNumber!.toString().padLeft(4, '0')}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            letterSpacing: 0.3,
                          ),
                        ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'CP ',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            TextSpan(
                              text: '$cp',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.onSurface,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getMoveColor(String? moveId, Map<String, dynamic> moveStats, Color typeColor) {
    if (moveId == null) return typeColor;
    
    // 1. Try moveStatsProvider (dynamic data)
    final stats = moveStats[moveId];
    if (stats != null && stats['type'] != null) {
      return TypeColors.getColorForType(stats['type']);
    }
    
    // 2. Try MoveTypeData (hardcoded fallback)
    final moveType = MoveTypeData.getMoveType(moveId);
    if (moveType != null) {
      return TypeColors.getColorForType(moveType);
    }
    
    // 3. Try with/without _FAST suffix
    final altId = moveId.endsWith('_FAST') ? moveId.replaceFirst('_FAST', '') : '${moveId}_FAST';
    final altStats = moveStats[altId] ?? {'type': MoveTypeData.getMoveType(altId)};
    if (altStats != null && altStats['type'] != null) {
      return TypeColors.getColorForType(altStats['type']);
    }
    
    return typeColor;
  }

  Widget _buildStatDivider(BuildContext context) {
    return Container(
      height: 20,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String type;
  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = TypeColors.getColorForType(type);
    return Container(
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            color: color.withValues(alpha: 0.8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
            fontFamily: 'Courier', // Monospaced for technical feel
          ),
        ),
      ],
    );
  }
}
class _MoveBadge extends StatelessWidget {
  final String name;
  final bool isFast;
  final Color typeColor;
  final bool isElite;

  const _MoveBadge({
    required this.name,
    required this.isFast,
    required this.typeColor,
    this.isElite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isElite 
            ? Colors.amber.withValues(alpha: 0.15) 
            : typeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isElite 
              ? Colors.amber.withValues(alpha: 0.6) 
              : typeColor.withValues(alpha: 0.2),
          width: isElite ? 1.0 : 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isElite) ...[
            const Icon(
              Icons.star_rounded,
              size: 10,
              color: Colors.amber,
            ),
            const SizedBox(width: 3),
          ],
          Icon(
            isFast ? Icons.bolt_rounded : Icons.auto_awesome_rounded,
            size: 10,
            color: isElite ? Colors.amber : typeColor.withValues(alpha: 0.8),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
