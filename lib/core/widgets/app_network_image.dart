import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../theme/app_theme.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholderIcon = Icons.movie,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData placeholderIcon;

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return _boxed(_placeholder());
    }

    return _boxed(
      CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _placeholder(
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: AppTheme.accent,
          ),
        ),
        errorWidget: (context, url, error) =>
            _placeholder(icon: Icons.broken_image),
      ),
    );
  }

  Widget _boxed(Widget child) {
    if (width != null || height != null) return child;
    return SizedBox.expand(child: child);
  }

  Widget _placeholder({Widget? child, IconData icon = Icons.movie}) {
    return Container(
      width: width,
      height: height,
      color: AppTheme.surfaceHigh,
      alignment: Alignment.center,
      child: child ?? Icon(icon, color: AppTheme.textMuted),
    );
  }
}

class MovieImage extends StatelessWidget {
  const MovieImage({
    super.key,
    required this.path,
    required this.size,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String? path;
  final String size;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return AppNetworkImage(
      url: AppConfig.imageUrl(path, size),
      width: width,
      height: height,
      fit: fit,
    );
  }
}
