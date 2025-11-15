import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedAppImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;
  final IconData placeholderIcon;

  const CachedAppImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.fit = BoxFit.cover,
    this.placeholderIcon = Icons.fastfood,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildPlaceholder() {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Icon(
          placeholderIcon,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
      );
    }

    if (imageUrl == null || imageUrl!.isEmpty) {
      return buildPlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => buildPlaceholder(),
        errorWidget: (context, url, error) => buildPlaceholder(),
      ),
    );
  }
}
