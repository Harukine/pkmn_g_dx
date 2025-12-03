import 'dart:math';
import 'package:flutter/material.dart';

import '../../core/constants/ui_constants.dart';
import '../../core/constants/type_colors.dart';
import '../../models/pokemon_entry.dart';
import '../../models/pokemon_form.dart';
import '../../widgets/pokemon/form_card.dart';
import 'widgets/moves_section.dart';
import 'widgets/evolution_chain_section.dart';
import '../../services/pokemon_service.dart';
import '../../widgets/common/pokemon_icon.dart';

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

    // Calculate CP
    final cp = ((_selectedForm.baseAttack *
            sqrt(_selectedForm.baseDefense).toInt() *
            sqrt(_selectedForm.baseStamina).toInt()) /
        10)
        .toInt();

    final typeColor = TypeColors.getColorForType(_selectedForm.types.first);

    return Scaffold(
      backgroundColor: typeColor,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  typeColor,
                  typeColor.withOpacity(0.6),
                  Colors.white,
                ],
                stops: const [0.0, 0.4, 0.5],
              ),
            ),
          ),
          
          // Content
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.star_border, color: Colors.white),
                    onPressed: () {
                      // TODO: Implement favorite
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // CP Display
                      Positioned(
                        top: 0,
                        child: Column(
                          children: [
                            Text(
                              widget.entry.name,
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  'CP',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$cp',
                                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Pokemon Image
                      Positioned(
                        bottom: 20,
                        child: Hero(
                          tag: _selectedForm.formId ?? '',
                          child: PokemonIcon(
                            goIconUrl: _selectedForm.goIconUrl,
                            size: 200,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.all(UIConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Types
                      Center(
                        child: Wrap(
                          spacing: 8,
                          children: _selectedForm.types
                              .map(
                                (t) => Chip(
                                  label: Text(
                                    t,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: TypeColors.getColorForType(t),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: UIConstants.spacingLarge),

                      // Stats Bars
                      _buildStatRow(context, 'Attack', _selectedForm.baseAttack, 300, Colors.red),
                      _buildStatRow(context, 'Defense', _selectedForm.baseDefense, 300, Colors.blue),
                      _buildStatRow(context, 'Stamina', _selectedForm.baseStamina, 300, Colors.green),
                      
                      const SizedBox(height: UIConstants.spacingLarge),
                      const Divider(),
                      const SizedBox(height: UIConstants.spacingMedium),

                      // Moves Section
                      MovesSection(form: _selectedForm),
                      const SizedBox(height: UIConstants.spacingLarge),

                      // Evolution Section
                      EvolutionChainSection(
                        form: _selectedForm,
                        onEvolutionTap: (evolution) async {
                          try {
                            if (evolution.evolutionId == widget.entry.basePokemonId) {
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
                      if (groupedForms.isNotEmpty) ...[
                        Text(
                          'Forms',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: UIConstants.spacingMedium),
                        for (final type in displayOrder)
                          if (groupedForms.containsKey(type) && groupedForms[type]!.isNotEmpty) ...[
                            Text(
                              type.displayName,
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: UIConstants.spacingSmall),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: groupedForms[type]!.map(
                                  (f) => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FormCard(
                                      form: f,
                                      isCostume: f.isCostume,
                                      isSelected: f == _selectedForm,
                                      onTap: () => _selectForm(f),
                                    ),
                                  ),
                                ).toList(),
                              ),
                            ),
                            const SizedBox(height: UIConstants.paddingMedium),
                          ],
                      ],
                      const SizedBox(height: 40), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // FAB for actions (Power Up / Evolve) - Visual only
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.extended(
              onPressed: () {},
              icon: const Icon(Icons.arrow_upward),
              label: const Text('POWER UP'),
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, int value, int max, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (value / max).clamp(0.0, 1.0),
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 40,
            child: Text(
              '$value',
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
