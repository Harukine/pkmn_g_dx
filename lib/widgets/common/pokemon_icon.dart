import 'package:flutter/material.dart';

import '../../core/constants/ui_constants.dart';

/// Reusable Pokemon icon widget that handles image loading and fallback
class PokemonIcon extends StatelessWidget {
  final String? goIconUrl;
  final String? spriteUrl;
  final double size;
  final double borderRadius;
  final BoxFit fit;

  const PokemonIcon({
    super.key,
    this.goIconUrl,
    this.spriteUrl,
    this.size = UIConstants.iconSizeList,
    this.borderRadius = UIConstants.borderRadiusIcon,
    this.fit = BoxFit.contain,
  });

  @override
 Widget build(BuildContext context) {
    // Prefer GO icon, fall back to sprite
    final url = (goIconUrl != null && goIconUrl!.isNotEmpty)
        ? goIconUrl
        : spriteUrl;

    if (url == null || url.isEmpty) {
      return Icon(
        Icons.catching_pokemon,
        size: size * 0.8,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Icon load failed: $error');
          return Icon(
            Icons.catching_pokemon,
            size: size * 0.8,
          );
        },
      ),
    );
  }
}
