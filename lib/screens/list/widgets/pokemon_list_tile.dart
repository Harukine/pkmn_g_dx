import 'package:flutter/material.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../models/pokemon_entry.dart';
import '../../../widgets/common/pokemon_icon.dart';
import '../../detail/widgets/stats_row.dart';

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
    final formsCount = entry.forms.length;
    final formLabel = formsCount > 1 ? '$formsCount forms' : '$formsCount form';

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: UIConstants.paddingMedium,
        vertical: 6,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: PokemonIcon(
          goIconUrl: entry.goIconUrl,
          size: UIConstants.iconSizeList,
        ),
        title: Text(entry.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              children: entry.types
                  .map(
                    (t) => Chip(
                      label: Text(t),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: UIConstants.spacingSmall),
            StatsRow(
              attack: entry.baseAttack,
              defense: entry.baseDefense,
              stamina: entry.baseStamina,
              formLabel: formLabel,
            ),
            if (entry.hasCostumeForms)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  'Includes costume forms',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
