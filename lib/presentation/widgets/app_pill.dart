import 'package:flutter/material.dart';

import 'package:weathernav/core/theme/app_tokens.dart';

class AppPill extends StatelessWidget {
  const AppPill({
    required this.child, super.key,
    this.backgroundColor,
    this.borderColor,
    this.padding,
  });

  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? scheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: borderColor ?? scheme.outlineVariant,
        ),
      ),
      child: child,
    );
  }
}
