import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:weathernav/l10n/l10n_ext.dart';
import 'package:weathernav/domain/models/poi.dart';
import 'package:weathernav/presentation/providers/poi_provider.dart';
import 'package:weathernav/presentation/widgets/app_toggle_pill.dart';

class PoiFilterSheet extends ConsumerWidget {
  const PoiFilterSheet({required this.center, super.key});
  final LatLng center;

  String _poiLabel(BuildContext context, PoiCategory c) {
    final l = context.l10n;
    return switch (c) {
      PoiCategory.shelter => l.shelter,
      PoiCategory.hut => l.hut,
      PoiCategory.weatherStation => l.weatherStation,
      PoiCategory.port => l.port,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final filter = ref.watch(poiFilterProvider);
    final notifier = ref.read(poiFilterProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.pointsOfInterest,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            value: filter.enabled,
            onChanged: (_) => notifier.toggleEnabled(),
            title: Text(l.showPois),
            subtitle: Text(l.poiSource),
          ),
          if (filter.enabled) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PoiCategory.values.map((c) {
                final selected = filter.categories.contains(c);
                return AppTogglePill(
                  selected: selected,
                  onPressed: () => notifier.toggleCategory(c),
                  child: Text(_poiLabel(context, c)),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(l.radius),
                const SizedBox(width: 12),
                Expanded(
                  child: Slider(
                    value: filter.radiusMeters
                        .toDouble()
                        .clamp(500.0, 10000.0),
                    min: 500,
                    max: 10000,
                    divisions: 19,
                    label: '${filter.radiusMeters} m',
                    onChanged: (v) => notifier.setRadius(v.round()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${l.centerTarget}: ${center.latitude.toStringAsFixed(4)}, ${center.longitude.toStringAsFixed(4)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
