import 'package:flutter/material.dart';
import '../../../core/constants/ui_constants.dart';
import '../../../models/evolution.dart';
import '../../../models/pokemon_form.dart';

class EvolutionChainSection extends StatelessWidget {
  final PokemonForm form;
  final Function(Evolution) onEvolutionTap;

  const EvolutionChainSection({
    super.key,
    required this.form,
    required this.onEvolutionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (form.nextEvolutions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Evolutions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: UIConstants.spacingMedium),
        ...form.nextEvolutions.map((evo) {
          return Card(
            clipBehavior: Clip.hardEdge,
            margin: const EdgeInsets.only(bottom: UIConstants.spacingSmall),
            child: InkWell(
              onTap: () => onEvolutionTap(evo),
              child: Padding(
                padding: const EdgeInsets.all(UIConstants.paddingSmall),
                child: Row(
                children: [
                  const Icon(Icons.arrow_forward, size: 16),
                  const SizedBox(width: UIConstants.spacingSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          evo.evolutionId.toLowerCase().split('_').map((word) => word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '').join(' '),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (evo.formId != null && evo.formId != "${evo.evolutionId}_NORMAL")
                          Text(
                            evo.formId!.replaceAll('${evo.evolutionId}_', '').replaceAll('_', ' ').toLowerCase(),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  if (evo.candyCost > 0)
                    Chip(
                      label: Text('${evo.candyCost} Candy'),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Colors.orange.shade100,
                    ),
                  if (evo.itemRequirement != null) ...[
                    const SizedBox(width: 4),
                    Chip(
                      label: Text(evo.itemRequirement!.replaceAll('ITEM_', '').replaceAll('_', ' ').toLowerCase()),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Colors.blue.shade100,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }),
      ],
    );
  }
}
