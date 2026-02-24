import 'package:flutter/material.dart';

import 'package:weathernav/core/theme/app_tokens.dart';

class AppStateMessage extends StatelessWidget {
  const AppStateMessage({
    required this.icon, required this.title, required this.message, super.key,
    this.iconColor,
    this.action,
    this.dense = false,
  });

  final IconData icon;
  final Color? iconColor;
  final String title;
  final String message;
  final Widget? action;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final padding = dense ? AppSpacing.lg : AppSpacing.xl;
    final iconSize = dense ? 28.0 : 44.0;
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: dense ? FontWeight.w700 : FontWeight.w800,
    );

    return Center(
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? scheme.onSurfaceVariant,
            ),
            SizedBox(height: dense ? AppSpacing.md : AppSpacing.lg),
            Text(title, style: titleStyle, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
