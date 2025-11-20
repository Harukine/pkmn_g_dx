import 'package:flutter/material.dart';

import '../../core/constants/ui_constants.dart';
import '../../models/pokemon_form.dart';
import '../common/pokemon_icon.dart';
import '../../screens/detail/widgets/stats_row.dart';

/// Card widget to display a Pokemon form variant
class FormCard extends StatelessWidget {
  final PokemonForm form;
  final bool isCostume;
  final bool isSelected;
  final VoidCallback? onTap;

  const FormCard({
    super.key,
    required this.form,
    this.isCostume = false,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = isCostume ? '${form.formName} (Costume)' : form.formName;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: UIConstants.spacingSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusCard),
        side: isSelected
            ? BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              )
            : BorderSide.none,
      ),
      child: ListTile(
        leading: PokemonIcon(
          goIconUrl: form.goIconUrl,
          size: UIConstants.iconSizeFormCard,
          fit: BoxFit.cover,
        ),
        title: Text(label),
        subtitle: StatsRow(
          attack: form.baseAttack,
          defense: form.baseDefense,
          stamina: form.baseStamina,
        ),
        onTap: onTap,
      ),
    );
  }
}
