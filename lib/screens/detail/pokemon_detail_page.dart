import 'package:flutter/material.dart';

import '../../core/constants/ui_constants.dart';
import '../../models/pokemon_entry.dart';
import '../../models/pokemon_form.dart';
import '../../widgets/pokemon/form_card.dart';
import 'widgets/pokemon_header.dart';

/// Detail page showing a Pokemon's information and all its forms
class PokemonDetailPage extends StatefulWidget {
  final PokemonEntry entry;

  const PokemonDetailPage({
    super.key,
    required this.entry,
  });

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  late PokemonForm _selectedForm;

  @override
  void initState() {
    super.initState();
    // Start with the first form (default form)
    _selectedForm = widget.entry.forms.first;
  }

  void _selectForm(PokemonForm form) {
    setState(() {
      _selectedForm = form;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Group forms by type
    final Map<FormType, List<PokemonForm>> groupedForms = {};
    for (final form in widget.entry.forms) {
      groupedForms.putIfAbsent(form.formType, () => []).add(form);
    }

    // Define display order
    const displayOrder = [
      FormType.normal,
      FormType.mega,
      FormType.primal,
      FormType.regional,
      FormType.shadow,
      FormType.purified,
      FormType.special,
      FormType.costume,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and basic info - shows selected form
            PokemonHeader(
              entry: widget.entry,
              selectedForm: _selectedForm,
            ),
            const SizedBox(height: UIConstants.spacingLarge),
            
            // Forms section
            Text(
              'Forms',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: UIConstants.spacingMedium),
            
            Expanded(
              child: ListView(
                children: [
                  for (final type in displayOrder)
                    if (groupedForms.containsKey(type) && groupedForms[type]!.isNotEmpty) ...[
                      Text(
                        type.displayName,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingSmall),
                      ...groupedForms[type]!.map(
                        (f) => FormCard(
                          form: f,
                          isCostume: f.isCostume,
                          isSelected: f == _selectedForm,
                          onTap: () => _selectForm(f),
                        ),
                      ),
                      const SizedBox(height: UIConstants.paddingMedium),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
