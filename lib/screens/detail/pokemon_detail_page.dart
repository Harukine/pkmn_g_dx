import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/constants/ui_constants.dart';
import '../../core/constants/type_colors.dart';
import '../../models/pokemon_entry.dart';
import '../../models/pokemon_form.dart';
import 'widgets/moves_section.dart';

import '../../services/pokemon_service.dart';
import '../../providers/pokemon_providers.dart';
import '../../widgets/common/pokemon_icon.dart';
import '../../core/utils/json_utils.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Detail page showing a Pokemon's information and all its forms
class PokemonDetailPage extends ConsumerStatefulWidget {
  final PokemonEntry entry;
  final String? initialFormId;

  const PokemonDetailPage({
    super.key,
    required this.entry,
    this.initialFormId,
  });

  @override
  ConsumerState<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends ConsumerState<PokemonDetailPage> {
  late PokemonForm _selectedForm;
  bool _isShiny = false;
  late List<PokemonForm> _sortedForms;

  static const _displayOrder = [
    FormType.normal,
    FormType.mega,
    FormType.primal,
    FormType.regional,
    FormType.shadow,
    FormType.purified,
    FormType.special,
    FormType.costume,
  ];

  @override
  void initState() {
    super.initState();
    
    // Sort forms: Grouped by _displayOrder, but Normal always first, 
    // and base "NORMAL" form first within its group. 
    // Otherwise preserves original data order.
    _sortedForms = List<PokemonForm>.from(widget.entry.forms);
    _sortedForms.sort((a, b) {
      if (a.formType == b.formType) {
        // Within the same group, prioritize the primary "Normal" form
        if (a.formType == FormType.normal) {
          final aIsPrimary = a.formId == null || a.formId == 'NORMAL' || a.formId == widget.entry.basePokemonId;
          final bIsPrimary = b.formId == null || b.formId == 'NORMAL' || b.formId == widget.entry.basePokemonId;
          if (aIsPrimary && !bIsPrimary) return -1;
          if (!aIsPrimary && bIsPrimary) return 1;
        }
        return 0; // Preserve data order
      }
      
      final aIndex = _displayOrder.indexOf(a.formType);
      final bIndex = _displayOrder.indexOf(b.formType);
      return aIndex.compareTo(bIndex);
    });

    // Start with the initial form if provided, otherwise find normal form
    if (widget.initialFormId != null) {
      try {
        _selectedForm = _sortedForms.firstWhere(
          (f) => f.formId == widget.initialFormId || f.formId == "${widget.entry.basePokemonId}_${widget.initialFormId}",
          orElse: () => _sortedForms.firstWhere(
            (f) => f.formType == FormType.normal,
            orElse: () => _sortedForms.first,
          ),
        );
      } catch (_) {
        _selectedForm = _sortedForms.firstWhere(
          (f) => f.formType == FormType.normal,
          orElse: () => _sortedForms.first,
        );
      }
    } else {
      // Default to the first form in our sorted list (which should be Normal)
      _selectedForm = _sortedForms.firstWhere(
        (f) => f.formType == FormType.normal,
        orElse: () => _sortedForms.first,
      );
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
    for (final form in _sortedForms) {
      groupedForms.putIfAbsent(form.formType, () => []).add(form);
    }

    final cp = _selectedForm.maxCp;

    final typeColor = TypeColors.getColorForType(_selectedForm.types.first);

    return Scaffold(
      backgroundColor: Color.alphaBlend(
        typeColor.withValues(alpha: 0.1),
        Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Stack(
        children: [
          
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
                  if (_selectedForm.shinyGoIconUrl != null)
                    IconButton(
                      icon: Icon(
                        _isShiny ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                        color: _isShiny ? Colors.amber : Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _isShiny = !_isShiny;
                        });
                      },
                    ),
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
                  height: 380,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // CP Display
                      Positioned(
                        top: 10,
                        child: Column(
                          children: [
                            Text(
                              widget.entry.name,
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  'CP',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.9),
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
                        bottom: 10,
                        child: Hero(
                          tag: '${_selectedForm.formId ?? ''}_${_isShiny ? 'shiny' : 'normal'}',
                          child: PokemonIcon(
                            goIconUrl: _isShiny ? _selectedForm.shinyGoIconUrl : _selectedForm.goIconUrl,
                            size: 220,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.alphaBlend(
                      typeColor.withValues(alpha: 0.05),
                      Theme.of(context).cardTheme.color!,
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  padding: const EdgeInsets.all(UIConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Types ──
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
                      const SizedBox(height: UIConstants.spacingMedium),

                      // ── Forms Picker (top, drives all stats below) ──
                      if (_sortedForms.length > 1)
                        _buildFormsPicker(context, groupedForms, _displayOrder),

                      const SizedBox(height: UIConstants.spacingLarge),

                      // ── Stats Bars (reactive to selected form) ──
                      _buildStatRow(context, 'Attack', _selectedForm.baseAttack, 500, Colors.red),
                      _buildStatRow(context, 'Defense', _selectedForm.baseDefense, 500, Colors.blue),
                      _buildStatRow(context, 'Stamina', _selectedForm.baseStamina, 500, Colors.green),
                    
                      // ── Moves ──
                      MovesSection(form: _selectedForm),

                      const SizedBox(height: UIConstants.spacingLarge),
                      _buildCpSection(context),

                      const Divider(color: Colors.white10),
                      const SizedBox(height: UIConstants.spacingMedium),

                      // ── Classification & Meta ──
                      _buildStatsSection(context),

                      // ── Evolution ──
                      _buildEvolutionSection(context),


                      const SizedBox(height: UIConstants.spacingLarge),
                      const SizedBox(height: 40), // Bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          
        ],
      ),
    );
  }

  /// Compact form picker shown at the top of the content card.
  /// All form types (including costumes) are included, grouped with labels.
  Widget _buildFormsPicker(
    BuildContext context,
    Map<FormType, List<PokemonForm>> groupedForms,
    List<FormType> displayOrder,
  ) {
    final relevantGroups = _displayOrder
        .where((t) => groupedForms.containsKey(t) && groupedForms[t]!.isNotEmpty)
        .toList();

    if (relevantGroups.isEmpty) return const SizedBox.shrink();

    // Flatten all forms for single-group case
    final allForms = relevantGroups.expand((t) => groupedForms[t]!).toList();
    final bool singleGroup = relevantGroups.length == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (singleGroup)
          _buildFormPillRow(context, allForms)
        else
          for (final type in relevantGroups) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                _pickerGroupLabel(type).toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 9,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildFormPillRow(context, groupedForms[type]!),
            const SizedBox(height: 8),
          ],
      ],
    );
  }

  /// Label used inside the picker for each group — more concise than displayName.
  String _pickerGroupLabel(FormType type) {
    switch (type) {
      case FormType.normal:
        return 'Standard';
      case FormType.mega:
        return 'Mega';
      case FormType.primal:
        return 'Primal';
      case FormType.regional:
        return 'Regional';
      case FormType.shadow:
        return 'Shadow';
      case FormType.purified:
        return 'Purified';
      case FormType.special:
        return 'Special';
      case FormType.costume:
        return 'Costume';
    }
  }

  Widget _buildCpSection(BuildContext context) {
    final cp20 = JsonUtils.calculateCpAtLevel(_selectedForm.baseAttack, _selectedForm.baseDefense, _selectedForm.baseStamina, 20);
    final cp25 = JsonUtils.calculateCpAtLevel(_selectedForm.baseAttack, _selectedForm.baseDefense, _selectedForm.baseStamina, 25);
    final cp50 = JsonUtils.calculateCpAtLevel(_selectedForm.baseAttack, _selectedForm.baseDefense, _selectedForm.baseStamina, 50);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COMBAT POWER (100% IV)'.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.4),
                letterSpacing: 1.2,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: UIConstants.spacingMedium),
        Row(
          children: [
            Expanded(child: _buildCpCard(context, 'Lvl 20', cp20, Colors.blueGrey)),
            const SizedBox(width: 8),
            Expanded(child: _buildCpCard(context, 'Lvl 25', cp25, Colors.blueGrey)),
            const SizedBox(width: 8),
            Expanded(child: _buildCpCard(context, 'Lvl 50', cp50, Colors.orangeAccent)),
          ],
        ),
      ],
    );
  }

  Widget _buildCpCard(BuildContext context, String label, int cp, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withValues(alpha: 0.5),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            cp.toString(),
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w900,
              fontFamily: 'RobotoMono',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormPillRow(BuildContext context, List<PokemonForm> forms) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: forms.map((f) {
          final isSelected = f == _selectedForm;
          final typeColor = f.types.isNotEmpty
              ? TypeColors.getColorForType(f.types.first)
              : Theme.of(context).colorScheme.primary;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _selectForm(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected
                      ? typeColor.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected
                        ? typeColor.withValues(alpha: 0.8)
                        : Colors.white.withValues(alpha: 0.12),
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: typeColor.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mini sprite
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CachedNetworkImage(
                        imageUrl: f.goIconUrl ?? '',
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const SizedBox.shrink(),
                        errorWidget: (context, url, error) => Icon(
                          Icons.catching_pokemon,
                          size: 18,
                          color: isSelected ? typeColor : Colors.white30,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      f.formName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? typeColor : Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }



  Widget _buildStatsSection(BuildContext context) {
    final chips = <Widget>[];

    // Class (Legendary, Mythical, Ultra Beast)
    if (_selectedForm.pokemonClass != null) {
      final String label;
      final Color color;
      final IconData icon;

      switch (_selectedForm.pokemonClass) {
        case 'POKEMON_CLASS_LEGENDARY':
          label = 'Legendary';
          color = Colors.amber;
          icon = Icons.workspace_premium;
          break;
        case 'POKEMON_CLASS_MYTHICAL':
          label = 'Mythical';
          color = Colors.purpleAccent;
          icon = Icons.auto_awesome;
          break;
        case 'POKEMON_CLASS_ULTRA_BEAST':
          label = 'Ultra Beast';
          color = Colors.redAccent;
          icon = Icons.dangerous;
          break;
        default:
          label = _selectedForm.pokemonClass!.replaceAll('POKEMON_CLASS_', '').replaceAll('_', ' ');
          color = Colors.blueGrey;
          icon = Icons.help_outline;
      }

      chips.add(_chip(
        context,
        icon: icon,
        label: label,
        color: color,
      ));
    }

    // Buddy distance
    if (_selectedForm.buddyDistance != null) {
      chips.add(_chip(
        context,
        icon: Icons.directions_walk,
        label: '${_selectedForm.buddyDistance} km buddy',
        color: Colors.teal.shade200,
      ));
    }

    // Shadow status
    if (_selectedForm.shadowData != null) {
      chips.add(_chip(
        context,
        icon: Icons.dark_mode,
        label: 'Shadow Capable',
        color: Colors.purple.shade300,
      ));
    }

    // Dynamax tier
    if (_selectedForm.dynamaxTier != null) {
      final tier = _selectedForm.dynamaxTier!.replaceAll('_', ' ');
      chips.add(_chip(
        context,
        icon: Icons.expand,
        label: 'Dynamax $tier',
        color: Colors.red.shade200,
      ));
    }

    // Tradable / Transferable flags
    if (!_selectedForm.isTradable) {
      chips.add(_chip(
        context,
        icon: Icons.block,
        label: 'Not Tradable',
        color: Colors.grey.shade400,
      ));
    }
    if (!_selectedForm.isTransferable) {
      chips.add(_chip(
        context,
        icon: Icons.lock,
        label: 'Not Transferable',
        color: Colors.grey.shade400,
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: UIConstants.spacingLarge),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips,
      ),
    );
  }

  Widget _buildEvolutionSection(BuildContext context) {
    final service = ref.read(pokemonServiceProvider);
    final stages = service.getEvolutionChain(_selectedForm.pokemonId, formId: _selectedForm.formId);

    if (stages.length <= 1) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: UIConstants.spacingLarge),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_tree_outlined, color: Colors.white.withValues(alpha: 0.7), size: 18),
              const SizedBox(width: 8),
              Text(
                'Evolution Family',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(stages.length, (index) {
                      final stage = stages[index];
                      return Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: stage.map((node) {
                              final isCurrent = node.entry.basePokemonId == widget.entry.basePokemonId && 
                                              (node.formId == null || node.formId == _selectedForm.formId);
                              return _buildEvolutionItem(context, node, isCurrent);
                            }).toList(),
                          ),
                          if (index < stages.length - 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                Icons.chevron_right,
                                color: Colors.white.withValues(alpha: 0.2),
                                size: 20,
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEvolutionItem(BuildContext context, EvolutionNode node, bool isCurrent) {
    return GestureDetector(
      onTap: isCurrent ? null : () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => PokemonDetailPage(
              entry: node.entry,
              initialFormId: node.formId,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
              );
              var scaleAnimation = Tween<double>(begin: 0.98, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );

              return FadeTransition(
                opacity: fadeAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isCurrent ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: isCurrent ? Border.all(color: Colors.white.withValues(alpha: 0.15)) : null,
        ),
        child: Column(
          children: [
            if (node.candyCost != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.orangeAccent),
                    const SizedBox(width: 4),
                    Text(
                      '${node.candyCost}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
            if (node.iconUrl != null)
              CachedNetworkImage(
                imageUrl: node.iconUrl!,
                width: 50,
                height: 50,
                placeholder: (context, url) => const SizedBox.shrink(),
                errorWidget: (context, url, error) => Icon(Icons.help_outline, color: Colors.white.withValues(alpha: 0.3), size: 30),
              )
            else
              const Icon(Icons.help_outline, color: Colors.white, size: 30),
            const SizedBox(height: 6),
            Text(
              node.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isCurrent ? Colors.white : Colors.white.withValues(alpha: 0.5),
                fontSize: 10,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context,
      {required IconData icon,
      required String label,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, int value, int max, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 75,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (value / max).clamp(0.0, 1.0),
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.7),
                          color,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 35,
            child: Text(
              '$value',
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
