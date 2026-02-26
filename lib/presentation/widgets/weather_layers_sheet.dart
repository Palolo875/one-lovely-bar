import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weathernav/l10n/l10n_ext.dart';
import 'package:weathernav/presentation/providers/profile_provider.dart';
import 'package:weathernav/presentation/providers/weather_layers_provider.dart';
import 'package:weathernav/presentation/widgets/app_snackbar.dart';

class WeatherLayersSheet extends ConsumerWidget {
  const WeatherLayersSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final layers = ref.watch(weatherLayersProvider);
    final notifier = ref.read(weatherLayersProvider.notifier);
    final profile = ref.watch(profileProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.weatherLayers,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l.max3Layers,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                final ok = notifier.resetToProfile(profile);
                if (!ok && context.mounted) {
                  AppSnackbar.error(context, l.resetLayersFailed);
                }
              },
              child: Text(l.resetToProfile),
            ),
          ),
          SwitchListTile(
            value: layers.enabled.contains(WeatherLayer.radar),
            onChanged: (_) {
              final ok = notifier.toggle(WeatherLayer.radar);
              if (!ok && context.mounted) {
                AppSnackbar.error(context, l.max3LayersError);
              }
            },
            title: Text(l.rainRadar),
            subtitle: Text(l.rainViewerSource),
          ),
          if (layers.enabled.contains(WeatherLayer.radar))
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              child: Row(
                children: [
                  Text(l.opacity),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Slider(
                      value:
                          (layers.opacity[WeatherLayer.radar] ?? 0.65)
                              .clamp(0.0, 1.0),
                      divisions: 10,
                      label:
                          '${((layers.opacity[WeatherLayer.radar] ?? 0.65) * 100).round()}%',
                      onChanged: (v) =>
                          notifier.setOpacity(WeatherLayer.radar, v),
                    ),
                  ),
                ],
              ),
            ),
          SwitchListTile(
            value: layers.enabled.contains(WeatherLayer.wind),
            onChanged: (_) {
              final ok = notifier.toggle(WeatherLayer.wind);
              if (!ok && context.mounted) {
                AppSnackbar.error(context, l.max3LayersError);
              }
            },
            title: Text(l.wind),
            subtitle: Text(l.windOverlaySubtitle),
          ),
          SwitchListTile(
            value: layers.enabled.contains(WeatherLayer.temperature),
            onChanged: (_) {
              final ok = notifier.toggle(WeatherLayer.temperature);
              if (!ok && context.mounted) {
                AppSnackbar.error(context, l.max3LayersError);
              }
            },
            title: Text(l.temperature),
            subtitle: Text(l.tempOverlaySubtitle),
          ),
        ],
      ),
    );
  }
}
