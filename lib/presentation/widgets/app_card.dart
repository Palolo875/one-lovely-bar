import 'package:flutter/material.dart';

import 'package:weathernav/core/theme/app_tokens.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child, super.key,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = borderRadius ?? AppRadii.md;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? scheme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? scheme.outlineVariant,
        ),
        boxShadow: AppShadows.soft(Theme.of(context).shadowColor),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(12),
        child: child,
      ),
    );
  }
}
