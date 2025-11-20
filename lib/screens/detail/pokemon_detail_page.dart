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
    // Separate costume forms from battle forms
    final nonCostumeForms = widget.entry.forms.where((f) => !f.isCostume).toList();
    final costumeForms = widget.entry.forms.where((f) => f.isCostume).toList();

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
                  // Battle forms (default, regional, mega, etc.)
                  if (nonCostumeForms.isNotEmpty) ...[
                    Text(
                      'Battle forms',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: UIConstants.spacingSmall),
                    ...nonCostumeForms.map(
                      (f) => FormCard(
                        form: f,
                        isSelected: f == _selectedForm,
                        onTap: () => _selectForm(f),
                      ),
                    ),
                    const SizedBox(height: UIConstants.paddingMedium),
                  ],
                  
                  // Costume forms
                  if (costumeForms.isNotEmpty) ...[
                    Text(
                      'Costume forms',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: UIConstants.spacingSmall),
                    ...costumeForms.map(
                      (f) => FormCard(
                        form: f,
                        isCostume: true,
                        isSelected: f == _selectedForm,
                        onTap: () => _selectForm(f),
                      ),
                    ),
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
