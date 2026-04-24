import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';

/// A themed, responsive app header for the Pokémon list.
/// Toggles between title-mode and inline search bar.
class PokemonListHeader extends StatefulWidget {
  final VoidCallback onFilterPressed;
  final VoidCallback onSortPressed;
  final VoidCallback onViewModePressed;
  final ValueChanged<String> onSearchChanged;
  final bool isGridView;

  const PokemonListHeader({
    super.key,
    required this.onFilterPressed,
    required this.onSortPressed,
    required this.onViewModePressed,
    required this.onSearchChanged,
    required this.isGridView,
  });

  @override
  State<PokemonListHeader> createState() => _PokemonListHeaderState();
}

class _PokemonListHeaderState extends State<PokemonListHeader>
    with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _isSearching = true);
    _animController.forward();
  }

  void _closeSearch() {
    _animController.reverse().then((_) {
      setState(() {
        _isSearching = false;
        _searchController.clear();
        widget.onSearchChanged('');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(16, top + 12, 8, 12),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _isSearching ? _buildSearchBar() : _buildTitleRow(),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      key: const ValueKey('title'),
      children: [
        // Pokédex-red accent dot
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(right: 8),
          decoration: const BoxDecoration(
            color: AppColors.pokedexRed,
            shape: BoxShape.circle,
          ),
        ),
        Text(
          'Pokédex',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const Spacer(),
        _HeaderIconBtn(icon: Icons.search_rounded, onTap: _openSearch),
        _HeaderIconBtn(icon: Icons.sort_rounded, onTap: widget.onSortPressed),
        _HeaderIconBtn(icon: Icons.tune_rounded, onTap: widget.onFilterPressed),
        _HeaderIconBtn(
          icon: widget.isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
          onTap: widget.onViewModePressed,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      key: const ValueKey('search'),
      children: [
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: AppColors.textOnDarkDim, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    style: const TextStyle(
                      color: AppColors.textOnDark,
                      fontSize: 15,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Name or Pokédex number…',
                      hintStyle: TextStyle(color: AppColors.textOnDarkDim, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: widget.onSearchChanged,
                  ),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: _closeSearch,
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, color: AppColors.textOnDark, size: 22),
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      splashRadius: 20,
    );
  }
}
