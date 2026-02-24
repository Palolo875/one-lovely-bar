import 'package:flutter/material.dart';
import 'package:weathernav/core/theme/app_tokens.dart';

class AppSurface extends StatelessWidget {
  const AppSurface({
    required this.child,
    super.key,
    this.padding,
    this.borderRadius,
    this.color,
    this.border,
    this.boxShadow,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? color;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? scheme.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadii.md),
        border: border,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}
