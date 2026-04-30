import 'package:flutter/material.dart';
import '../../../core/constants/type_colors.dart';
import '../../../core/constants/generation_colors.dart';
import '../../../models/filter_options.dart';
import '../../../models/pokemon_form.dart';

class FilterWidget extends StatefulWidget {
  final FilterOptions currentFilters;
  final Function(FilterOptions) onApply;

  const FilterWidget({
    super.key,
    required this.currentFilters,
    required this.onApply,
  });

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  late Set<String> _selectedTypes;
  late Set<int> _selectedGenerations;
  late Set<FormType> _selectedFormTypes;
  late Set<String> _selectedClasses;
  late RangeValues _attackRange;
  late RangeValues _defenseRange;
  late RangeValues _staminaRange;

  // Constants for stats
  static const double _maxStat = 500.0;

  final List<String> _allTypes = [
    'Normal', 'Fire', 'Water', 'Grass', 'Electric', 'Ice', 'Fighting',
    'Poison', 'Ground', 'Flying', 'Psychic', 'Bug', 'Rock', 'Ghost',
    'Dragon', 'Steel', 'Dark', 'Fairy'
  ];

  @override
  void initState() {
    super.initState();
    _selectedTypes = Set.from(widget.currentFilters.types);
    _selectedGenerations = Set.from(widget.currentFilters.generations);
    _selectedFormTypes = Set.from(widget.currentFilters.formTypes);
    _selectedClasses = Set.from(widget.currentFilters.pokemonClasses);
    _attackRange = widget.currentFilters.attackRange ?? const RangeValues(0, _maxStat);
    _defenseRange = widget.currentFilters.defenseRange ?? const RangeValues(0, _maxStat);
    _staminaRange = widget.currentFilters.staminaRange ?? const RangeValues(0, _maxStat);
  }

  void _apply() {
    final filters = FilterOptions(
      types: _selectedTypes,
      generations: _selectedGenerations,
      formTypes: _selectedFormTypes,
      pokemonClasses: _selectedClasses,
      attackRange: _attackRange == const RangeValues(0, _maxStat) ? null : _attackRange,
      defenseRange: _defenseRange == const RangeValues(0, _maxStat) ? null : _defenseRange,
      staminaRange: _staminaRange == const RangeValues(0, _maxStat) ? null : _staminaRange,
    );
    widget.onApply(filters);
  }

  void _reset() {
    setState(() {
      _selectedTypes.clear();
      _selectedGenerations.clear();
      _selectedFormTypes.clear();
      _selectedClasses.clear();
      _attackRange = const RangeValues(0, _maxStat);
      _defenseRange = const RangeValues(0, _maxStat);
      _staminaRange = const RangeValues(0, _maxStat);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _reset,
                      child: const Text('Reset'),
                    ),
                    Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _apply();
                        Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSectionTitle('Types'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allTypes.map((type) {
                        final isSelected = _selectedTypes.contains(type);
                        final typeColor = TypeColors.getColorForType(type);
                        return FilterChip(
                          label: Text(
                            type,
                            style: TextStyle(
                              color: isSelected ? Colors.white : typeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: typeColor,
                          checkmarkColor: Colors.white,
                          backgroundColor: Theme.of(context).cardTheme.color,
                          side: BorderSide(color: typeColor),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedTypes.add(type);
                              } else {
                                _selectedTypes.remove(type);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Generations'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: List.generate(9, (index) => index + 1).map((gen) {
                        final isSelected = _selectedGenerations.contains(gen);
                        final gradientColors = GenerationColors.getGradient(gen);
                        
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedGenerations.remove(gen);
                              } else {
                                _selectedGenerations.add(gen);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: gradientColors,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: isSelected ? null : Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(4),
                              border: isSelected
                                  ? null
                                  : Border.all(color: Theme.of(context).dividerColor),
                            ),
                            child: Text(
                              'Gen $gen',
                              style: TextStyle(
                                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Form Types'),
                    Wrap(
                      spacing: 8,
                      children: FormType.values.map((type) {
                        return FilterChip(
                          label: Text(type.displayName),
                          selected: _selectedFormTypes.contains(type),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedFormTypes.add(type);
                              } else {
                                _selectedFormTypes.remove(type);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Pokemon Class'),
                    Wrap(
                      spacing: 8,
                      children: ['Normal', 'Legendary', 'Mythical', 'Ultra Beast'].map((cls) {
                        final isSelected = _selectedClasses.contains(cls);
                        Color color;
                        switch (cls) {
                          case 'Legendary': color = Colors.amber; break;
                          case 'Mythical': color = Colors.purpleAccent; break;
                          case 'Ultra Beast': color = Colors.redAccent; break;
                          default: color = Colors.blueGrey;
                        }
                        return FilterChip(
                          label: Text(cls),
                          selected: isSelected,
                          selectedColor: color.withValues(alpha: 0.8),
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : color,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedClasses.add(cls);
                              } else {
                                _selectedClasses.remove(cls);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Stats'),
                    _buildRangeSlider('Attack', _attackRange, (val) => setState(() => _attackRange = val)),
                    _buildRangeSlider('Defense', _defenseRange, (val) => setState(() => _defenseRange = val)),
                    _buildRangeSlider('Stamina', _staminaRange, (val) => setState(() => _staminaRange = val)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildRangeSlider(String label, RangeValues values, ValueChanged<RangeValues> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${values.start.round()} - ${values.end.round()}',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        RangeSlider(
          values: values,
          min: 0,
          max: _maxStat,
          divisions: 50,
          labels: RangeLabels(
            values.start.round().toString(),
            values.end.round().toString(),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
