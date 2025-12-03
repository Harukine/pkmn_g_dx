import 'package:flutter/material.dart';

import '../../core/constants/ui_constants.dart';
import '../../models/pokemon_form.dart';
import '../common/pokemon_icon.dart';
import '../common/pokemon_icon.dart';

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
    // Shorten label if it's too long
    String label = form.formName;
    if (isCostume && label.length > 10) {
      label = '${label.substring(0, 8)}...';
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            PokemonIcon(
              goIconUrl: form.goIconUrl,
              size: 60,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
