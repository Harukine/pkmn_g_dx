import 'package:flutter/material.dart';

import '../../core/constants/ui_constants.dart';
import '../../models/pokemon_entry.dart';
import '../../models/pokemon_form.dart';
import '../../widgets/pokemon/form_card.dart';
import 'widgets/pokemon_header.dart';
import 'widgets/moves_section.dart';
import 'widgets/evolution_chain_section.dart';
import '../../services/pokemon_service.dart';

/// Detail page showing a Pokemon's information and all its forms
class PokemonDetailPage extends StatefulWidget {
  final PokemonEntry entry;
  final String? initialFormId;

  const PokemonDetailPage({
    super.key,
    required this.entry,
    this.initialFormId,
  });

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  late PokemonForm _selectedForm;

  @override
  void initState() {
    super.initState();
    // Start with the initial form if provided, otherwise default
    if (widget.initialFormId != null) {
      try {
        _selectedForm = widget.entry.forms.firstWhere(
          (f) => f.formId == widget.initialFormId || f.formId == "${widget.entry.basePokemonId}_${widget.initialFormId}",
          orElse: () => widget.entry.forms.first,
        );
      } catch (_) {
        _selectedForm = widget.entry.forms.first;
      }
    } else {
      _selectedForm = widget.entry.forms.first;
    }
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
        child: ListView(
          children: [

            // Header with icon and basic info - shows selected form
            PokemonHeader(
              entry: widget.entry,
              selectedForm: _selectedForm,
            ),
            const SizedBox(height: UIConstants.spacingLarge),

            // Moves Section
            MovesSection(form: _selectedForm),
            const SizedBox(height: UIConstants.spacingLarge),

            // Evolution Section
            EvolutionChainSection(
              form: _selectedForm,
              onEvolutionTap: (evolution) async {
                try {
                  // Check if target is the same Pokemon (different form)
                  if (evolution.evolutionId == widget.entry.basePokemonId) {
                     // Just switch form if we have the form ID
                     if (evolution.formId != null) {
                       final targetForm = widget.entry.forms.firstWhere(
                         (f) => f.formId == evolution.formId,
                         orElse: () => _selectedForm,
                       );
                       if (targetForm != _selectedForm) {
                         _selectForm(targetForm);
                         return;
                       }
                     }
                  }

                  // TODO: Ideally we should have a cached list or a provider
                  final allPokemon = await PokemonService.instance.loadPokemon();
                  final targetPokemon = allPokemon.firstWhere(
                    (p) => p.basePokemonId == evolution.evolutionId,
                    orElse: () => throw Exception('Pokemon not found'),
                  );
                  
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PokemonDetailPage(
                          entry: targetPokemon,
                          initialFormId: evolution.formId,
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not load evolution: $e')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: UIConstants.spacingLarge),
            
            // Forms section
            Text(
              'Forms',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: UIConstants.spacingMedium),
            
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
    );
  }
}
