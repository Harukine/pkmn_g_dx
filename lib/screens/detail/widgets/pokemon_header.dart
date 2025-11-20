import 'package:flutter/material.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../models/pokemon_entry.dart';
import '../../../models/pokemon_form.dart';
import '../../../widgets/common/pokemon_icon.dart';

/// Header widget for Pokemon detail page
class PokemonHeader extends StatelessWidget {
  final PokemonEntry entry;
  final PokemonForm selectedForm;

  const PokemonHeader({
    super.key,
    required this.entry,
    required this.selectedForm,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PokemonIcon(
          goIconUrl: selectedForm.goIconUrl,
          spriteUrl: selectedForm.spriteUrl,
          size: UIConstants.iconSizeDetailHeader,
          borderRadius: UIConstants.borderRadiusHeader,
        ),
        const SizedBox(width: UIConstants.spacingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (selectedForm.formName != 'Normal')
                Text(
                  selectedForm.formName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              if (entry.dexNumber != null)
                Text(
                  '#${entry.dexNumber}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: UIConstants.spacingSmall),
              Wrap(
                spacing: 6,
                children: selectedForm.types
                    .map(
                      (t) => Chip(
                        label: Text(t),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: UIConstants.spacingMedium),
              Text(
                'Stats: '
                'ATK ${selectedForm.baseAttack} • '
                'DEF ${selectedForm.baseDefense} • '
                'STA ${selectedForm.baseStamina}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
