import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIllustrationSvg extends StatelessWidget {
  const AppIllustrationSvg(
    this.assetName, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.semanticLabel,
    this.allowRecolor = false,
    this.color,
  });

  final String assetName;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? semanticLabel;

  /// By default we preserve multi-color illustrations.
  /// Turn this on only for monochrome illustration assets.
  final bool allowRecolor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.onSurface;

    return SvgPicture.asset(
      assetName,
      width: width,
      height: height,
      fit: fit,
      semanticsLabel: semanticLabel,
      colorFilter: allowRecolor
          ? ColorFilter.mode(effectiveColor, BlendMode.srcIn)
          : null,
    );
  }
}
