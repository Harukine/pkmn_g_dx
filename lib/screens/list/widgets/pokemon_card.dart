import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../models/pokemon_entry.dart';
import '../../../widgets/common/pokemon_icon.dart';

/// Compact card widget for grid view showing Pokemon icon and name
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
    // Calculate a pseudo-CP based on base stats for display
    final cp = ((entry.baseAttack *
            sqrt(entry.baseDefense).toInt() *
            sqrt(entry.baseStamina).toInt()) /
        10)
        .toInt();

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            // Background gradient based on type? Or just white/light grey
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey[100]!,
                  ],
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final iconSize = min(constraints.maxWidth * 0.75, 120.0);
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                    child: PokemonIcon(
                      goIconUrl: entry.goIconUrl,
                      size: iconSize,
                    ),
                  ),
                );
              },
            ),
            Positioned(
              top: 4,
              left: 4,
              child: Text(
                'CP $cp',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                color: Colors.black.withOpacity(0.05),
                child: Text(
                  entry.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (entry.hasCostumeForms)
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  Icons.checkroom,
                  size: 14,
                  color: Colors.purple,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
