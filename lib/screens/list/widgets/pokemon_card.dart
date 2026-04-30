import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/constants/type_colors.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/pokemon_entry.dart';
import '../../../widgets/common/pokemon_icon.dart';

/// Responsive grid card — solid type-tinted background, top strip, large icon, name + dex#.
class PokemonCard extends StatelessWidget {
  final PokemonEntry entry;
  final VoidCallback onTap;

  const PokemonCard({
    super.key,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryType = entry.types.isNotEmpty ? entry.types.first : null;
    final typeColor = primaryType != null
        ? TypeColors.getColorForType(primaryType)
        : AppColors.pokedexRed;

    return Material(
      color: typeColor.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Type-colored strip at top (4px)
                Container(height: 4, color: typeColor),

                // Icon area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 6, 4, 2),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final size = min(constraints.maxWidth * 0.78, 112.0);
                        return Center(
                          child: PokemonIcon(
                            goIconUrl: entry.goIconUrl,
                            size: size,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Name + dex number
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
                  child: Column(
                    children: [
                      Text(
                        entry.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (entry.dexNumber != null)
                        Text(
                          '#${entry.dexNumber!.toString().padLeft(4, '0')}',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            letterSpacing: 0.3,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Costume badge — overlaid at top-right
            if (entry.hasCostumeForms)
              Positioned(
                top: 8,
                right: 5,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.checkroom_rounded,
                    size: 11,
                    color: Colors.purpleAccent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
