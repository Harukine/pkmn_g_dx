import 'package:flutter/material.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../core/constants/type_colors.dart';
import '../../../models/pokemon_entry.dart';
import '../../../models/pokemon_form.dart';
import '../../../widgets/common/pokemon_icon.dart';

/// Header widget for Pokemon detail page
class PokemonHeader extends StatefulWidget {
  final PokemonEntry entry;
  final PokemonForm selectedForm;

  const PokemonHeader({
    super.key,
    required this.entry,
    required this.selectedForm,
  });

  @override
  State<PokemonHeader> createState() => _PokemonHeaderState();
}

class _PokemonHeaderState extends State<PokemonHeader> {
  bool _isShiny = false;

  @override
  void didUpdateWidget(PokemonHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedForm != oldWidget.selectedForm) {
      _isShiny = false; // Reset shiny state when form changes
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconUrl = _isShiny
        ? widget.selectedForm.shinyGoIconUrl
        : widget.selectedForm.goIconUrl;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            PokemonIcon(
              goIconUrl: iconUrl,
              size: UIConstants.iconSizeDetailHeader,
              borderRadius: UIConstants.borderRadiusHeader,
            ),
            if (widget.selectedForm.shinyGoIconUrl != null)
              Positioned(
                top: 4,
                right: 4,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isShiny = !_isShiny;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _isShiny 
                            ? Colors.yellow.withValues(alpha: 0.8) 
                            : Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.star,
                        size: 20,
                        color: _isShiny ? Colors.orange : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: UIConstants.spacingMedium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.entry.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (widget.selectedForm.formName != 'Normal')
                Text(
                  widget.selectedForm.formName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              if (widget.entry.dexNumber != null)
                Text(
                  '#${widget.entry.dexNumber}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: UIConstants.spacingSmall),
              Wrap(
                spacing: 6,
                children: widget.selectedForm.types
                    .map(
                      (t) => Chip(
                        label: Text(
                          t,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        backgroundColor: TypeColors.getColorForType(t),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: UIConstants.spacingMedium),
              Text(
                'Stats: '
                'ATK ${widget.selectedForm.baseAttack} • '
                'DEF ${widget.selectedForm.baseDefense} • '
                'STA ${widget.selectedForm.baseStamina}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
