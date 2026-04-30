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
          'Evolutions'.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        '${evo.candyCost} Candy',
                        style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (evo.itemRequirement != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        evo.itemRequirement!.replaceAll('ITEM_', '').replaceAll('_', ' ').toLowerCase(),
                        style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
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
