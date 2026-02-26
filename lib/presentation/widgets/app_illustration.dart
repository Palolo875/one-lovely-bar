import 'package:flutter/material.dart';
import 'package:weathernav/presentation/widgets/app_illustration_painters.dart';
import 'package:weathernav/presentation/widgets/app_illustration_kind.dart';
import 'package:weathernav/presentation/widgets/app_illustration_svg.dart';

class AppIllustration extends StatelessWidget {
  const AppIllustration({
    super.key,
    this.assetName,
    this.kind,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.semanticLabel,
  }) : assert(
         assetName != null || kind != null,
         'Either assetName or kind must be provided.',
       );

  final String? assetName;
  final AppIllustrationKind? kind;
  final double? width;
  final double? height;
  final BoxFit fit;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (assetName != null) {
      return AppIllustrationSvg(
        assetName!,
        width: width,
        height: height,
        fit: fit,
        semanticLabel: semanticLabel,
      );
    }

    return CustomPaint(
      size: Size(width ?? 160, height ?? 160),
      painter: AppIllustrationPainter(
        kind: kind!,
        scheme: Theme.of(context).colorScheme,
      ),
    );
  }
}
