import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../core/constants/type_colors.dart';
import '../../../models/pokemon_entry.dart';
import '../../../widgets/common/pokemon_icon.dart';
import '../../../widgets/common/pokemon_icon.dart';

/// List tile widget for displaying a Pokemon in the list view
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
    // Calculate a pseudo-CP based on base stats for display
    final cp = ((entry.baseAttack *
            sqrt(entry.baseDefense).toInt() *
            sqrt(entry.baseStamina).toInt()) /
        10)
        .toInt();

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingMedium,
        vertical: 4,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              PokemonIcon(
                goIconUrl: entry.goIconUrl,
                size: 60,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'CP',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$cp',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      entry.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (entry.dexNumber != null)
                    Text(
                      '#${entry.dexNumber}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: entry.types
                        .map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: CircleAvatar(
                              radius: 6,
                              backgroundColor: TypeColors.getColorForType(t),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
