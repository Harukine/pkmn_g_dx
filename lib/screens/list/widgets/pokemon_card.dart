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
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.paddingSmall),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PokemonIcon(
                goIconUrl: entry.goIconUrl,
                size: 80,
              ),
              const SizedBox(height: UIConstants.spacingSmall),
              Text(
                entry.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (entry.dexNumber != null)
                Text(
                  '#${entry.dexNumber}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
