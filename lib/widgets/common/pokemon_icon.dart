import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/ui_constants.dart';

/// Reusable Pokemon icon widget that handles image loading and fallback
class PokemonIcon extends StatelessWidget {
  final String? goIconUrl;
  final double size;
  final double borderRadius;
  final BoxFit fit;

  const PokemonIcon({
    super.key,
    this.goIconUrl,
    this.size = UIConstants.iconSizeList,
    this.borderRadius = UIConstants.borderRadiusIcon,
    this.fit = BoxFit.contain,
  });

  @override
 Widget build(BuildContext context) {
    final url = goIconUrl;

    if (url == null || url.isEmpty) {
      return Icon(
        Icons.catching_pokemon,
        size: size * 0.8,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: url,
        width: size,
        height: size,
        fit: fit,
        // Use memCache only on native to optimize memory; web handles this via browser cache
        memCacheWidth: kIsWeb ? null : (size * MediaQuery.of(context).devicePixelRatio).round(),
        memCacheHeight: kIsWeb ? null : (size * MediaQuery.of(context).devicePixelRatio).round(),
        placeholder: (context, url) => const SizedBox.shrink(),
        errorWidget: (context, url, error) {
          return Icon(
            Icons.catching_pokemon,
            size: size * 0.8,
          );
        },
      ),
    );
  }
}
