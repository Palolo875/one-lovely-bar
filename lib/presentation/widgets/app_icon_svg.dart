import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIconSvg extends StatelessWidget {
  const AppIconSvg(
    this.assetName, {
    super.key,
    this.size = 20,
    this.color,
    this.semanticLabel,
  });

  final String assetName;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.onSurface;

    return SvgPicture.asset(
      assetName,
      width: size,
      height: size,
      semanticsLabel: semanticLabel,
      colorFilter: ColorFilter.mode(effectiveColor, BlendMode.srcIn),
    );
  }
}
