import 'package:flutter/material.dart';

import 'package:weathernav/presentation/widgets/app_pill.dart';

class AppTogglePill extends StatelessWidget {
  const AppTogglePill({
    required this.selected, required this.onPressed, required this.child, super.key,
  });

  final bool selected;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(999),
      child: AppPill(
        backgroundColor:
            selected ? scheme.primary.withValues(alpha: 0.14) : scheme.surface,
        borderColor: selected
            ? scheme.primary.withValues(alpha: 0.28)
            : scheme.outlineVariant,
        child: DefaultTextStyle.merge(
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
          child: IconTheme.merge(
            data: IconThemeData(
              size: 16,
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
