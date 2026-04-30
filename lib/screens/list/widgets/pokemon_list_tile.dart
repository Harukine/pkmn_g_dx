import 'package:flutter/material.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../core/constants/type_colors.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/pokemon_entry.dart';
import '../../../widgets/common/pokemon_icon.dart';

/// Minimalist list tile — white card on dark bg.
/// Type shown as small colored chips. CP number is the hero value.
class PokemonListTile extends StatelessWidget {
  final PokemonEntry entry;
  final VoidCallback onTap;
  final bool showStats;
  final bool showMoves;

  const PokemonListTile({
    super.key,
    required this.entry,
    required this.onTap,
    this.showStats = false,
    this.showMoves = false,
  });

  @override
  Widget build(BuildContext context) {
    final cp = entry.maxCp;

    final primaryType = entry.types.isNotEmpty ? entry.types.first : null;
    final typeColor = primaryType != null
        ? TypeColors.getColorForType(primaryType)
        : AppColors.pokedexRed;

    return Padding(
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
                  // Central Stats Section (Vertical Column)
                  SizedBox(
                    width: 90,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _MiniStat(label: 'ATK', value: entry.baseAttack, color: Colors.orangeAccent),
                        _MiniStat(label: 'DEF', value: entry.baseDefense, color: Colors.blueAccent),
                        _MiniStat(label: 'STA', value: entry.baseStamina, color: Colors.greenAccent),
                      ],
                    ),
                  ),
                ],
                
                if (showMoves) ...[
                  const SizedBox(width: 24),
                  // Moves Preview Column
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'MOVE SETS',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.defaultForm?.quickMoves.join(' • ') ?? 'No data',
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.defaultForm?.cinematicMoves.join(' • ') ?? '',
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
class _MiniStat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const double maxStatValue = 450.0;
    const double fullBarWidth = 70.0;
    final double barWidth = (value / maxStatValue).clamp(0.0, 1.0) * fullBarWidth;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
                  fontFamily: 'Courier', // Monospaced for technical feel
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Stack(
            children: [
              // Background track
              Container(
                width: fullBarWidth,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              // Glowing progress bar
              Container(
                width: barWidth,
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color.withValues(alpha: 0.7),
                      color,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 6,
                      spreadRadius: -1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
