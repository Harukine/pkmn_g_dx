import 'dart:math';
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

  const PokemonListTile({
    super.key,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cp = ((entry.baseAttack *
                sqrt(entry.baseDefense).toInt() *
                sqrt(entry.baseStamina).toInt()) /
            10)
        .toInt();

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
        color: Colors.white,
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
                    color: typeColor.withOpacity(0.12),
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
                    children: [
                      Text(
                        entry.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: entry.types
                            .map((t) => _TypeChip(type: t))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                // Dex # + CP
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (entry.dexNumber != null)
                      Text(
                        '#${entry.dexNumber!.toString().padLeft(4, '0')}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'CP ',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextSpan(
                            text: '$cp',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
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
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
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
