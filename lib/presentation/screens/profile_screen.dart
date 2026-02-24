import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weathernav/core/logging/app_logger.dart';
import 'package:weathernav/core/theme/app_tokens.dart';
import 'package:weathernav/domain/models/user_profile.dart';
import 'package:weathernav/presentation/providers/alert_thresholds_provider.dart';
import 'package:weathernav/presentation/providers/offline_zones_provider.dart';
import 'package:weathernav/presentation/providers/settings_provider.dart';
import 'package:weathernav/presentation/providers/weather_layers_provider.dart';
import 'package:weathernav/presentation/providers/profile_provider.dart';
import 'package:weathernav/presentation/providers/map_style_provider.dart';
import 'package:weathernav/presentation/widgets/app_loading_indicator.dart';
import 'package:weathernav/presentation/widgets/app_state_message.dart';
import 'package:weathernav/presentation/widgets/app_snackbar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppSettingsState settings = ref.watch(appSettingsProvider);
    final AppSettingsNotifier settingsNotifier = ref.read(
      appSettingsProvider.notifier,
    );
    final WeatherLayersState layers = ref.watch(weatherLayersProvider);
    final WeatherLayersNotifier layersNotifier = ref.read(
      weatherLayersProvider.notifier,
    );
    final UserProfile profile = ref.watch(profileProvider);
    final AlertThresholdsState alertThresholds = ref.watch(
      alertThresholdsProvider,
    );
    final AlertThresholdsNotifier alertThresholdsNotifier = ref.read(
      alertThresholdsProvider.notifier,
    );
    final AsyncValue<OfflineZonesState> offlineZonesAsync = ref.watch(
      offlineZonesProvider,
    );
    final OfflineZonesNotifier offlineZonesNotifier = ref.read(
      offlineZonesProvider.notifier,
    );
    final MapStyleState mapStyle = ref.watch(mapStyleProvider);
    final MapStyleNotifier mapStyleNotifier = ref.read(
      mapStyleProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Profil & paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: ListTile(
              leading: const Icon(LucideIcons.user),
              title: Text(profile.name),
              subtitle: const Text('Profil actif'),
              onTap: () {
                showModalBottomSheet<void>(
                  context: context,
                  builder: (_) => const _ProfilePickerSheet(),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Apparence',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: settings.themeMode,
                  onChanged: (v) {
                    unawaited(
                      settingsNotifier.setThemeMode(v ?? ThemeMode.system),
                    );
                  },
                  title: const Text('Automatique'),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: settings.themeMode,
                  onChanged: (v) {
                    unawaited(
                      settingsNotifier.setThemeMode(v ?? ThemeMode.system),
                    );
                  },
                  title: const Text('Clair'),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: settings.themeMode,
                  onChanged: (v) {
                    unawaited(
                      settingsNotifier.setThemeMode(v ?? ThemeMode.system),
                    );
                  },
                  title: const Text('Sombre'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Unités',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.gauge),
                  title: const Text('Vitesse'),
                  subtitle: Text(settings.speedUnit),
                  onTap: () => _pickOne(
                    context,
                    title: 'Vitesse',
                    current: settings.speedUnit,
                    values: const ['km/h', 'm/s'],
                    onSelected: settingsNotifier.setSpeedUnit,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(LucideIcons.thermometer),
                  title: const Text('Température'),
                  subtitle: Text(settings.tempUnit),
                  onTap: () => _pickOne(
                    context,
                    title: 'Température',
                    current: settings.tempUnit,
                    values: const ['°C', '°F'],
                    onSelected: settingsNotifier.setTempUnit,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(LucideIcons.ruler),
                  title: const Text('Distance'),
                  subtitle: Text(settings.distanceUnit),
                  onTap: () => _pickOne(
                    context,
                    title: 'Distance',
                    current: settings.distanceUnit,
                    values: const ['km', 'miles'],
                    onSelected: settingsNotifier.setDistanceUnit,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Carte',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Column(
              children: [
                RadioListTile<MapStyleSource>(
                  value: MapStyleSource.openFreeMap,
                  groupValue: mapStyle.source,
                  onChanged: (v) {
                    unawaited(
                      mapStyleNotifier.setSource(
                        v ?? MapStyleSource.openFreeMap,
                      ),
                    );
                  },
                  title: const Text('OpenFreeMap (par défaut)'),
                  subtitle: const Text('Pas de SLA — fallback recommandé'),
                ),
                const Divider(height: 1),
                RadioListTile<MapStyleSource>(
                  value: MapStyleSource.cartoPositron,
                  groupValue: mapStyle.source,
                  onChanged: (v) {
                    unawaited(
                      mapStyleNotifier.setSource(
                        v ?? MapStyleSource.openFreeMap,
                      ),
                    );
                  },
                  title: const Text('Carto Positron (fallback)'),
                ),
                const Divider(height: 1),
                RadioListTile<MapStyleSource>(
                  value: MapStyleSource.stamenToner,
                  groupValue: mapStyle.source,
                  onChanged: (v) {
                    unawaited(
                      mapStyleNotifier.setSource(
                        v ?? MapStyleSource.openFreeMap,
                      ),
                    );
                  },
                  title: const Text('Stamen Toner (fallback)'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Couches météo',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Column(
              children: [
                if (layers.enabled.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 14,
                      bottom: 6,
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.gripVertical, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Ordre des couches actives',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ReorderableListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    onReorder: (oldIndex, newIndex) {
                      final enabledOrdered = layers.order
                          .where(layers.enabled.contains)
                          .toList();
                      var targetIndex = newIndex;
                      if (targetIndex > oldIndex) {
                        targetIndex -= 1;
                      }
                      if (oldIndex < 0 || oldIndex >= enabledOrdered.length) {
                        return;
                      }
                      final layer = enabledOrdered[oldIndex];
                      layersNotifier.moveLayer(layer, targetIndex);
                    },
                    children: [
                      for (final l in layers.order.where(
                        layers.enabled.contains,
                      ))
                        ListTile(
                          key: ValueKey('layer-order-${l.name}'),
                          leading: ReorderableDragStartListener(
                            index: layers.order
                                .where(layers.enabled.contains)
                                .toList()
                                .indexOf(l),
                            child: const Icon(LucideIcons.gripVertical),
                          ),
                          title: Text(l.name),
                          subtitle: const Text('Actif'),
                        ),
                    ],
                  ),
                  const Divider(height: 1),
                ],
                for (final l in WeatherLayer.values) ...[
                  SwitchListTile(
                    value: layers.enabled.contains(l),
                    onChanged: (_) {
                      final isEnabled = layers.enabled.contains(l);
                      if (!isEnabled &&
                          layers.enabled.length >=
                              WeatherLayersNotifier.maxEnabled) {
                        AppSnackbar.error(
                          context,
                          'Maximum 3 couches actives.',
                        );
                        return;
                      }

                      layersNotifier.toggle(l);
                    },
                    title: Text(l.name),
                    subtitle: l == WeatherLayer.radar
                        ? const Text('Opacité réglable')
                        : null,
                  ),
                  if (l == WeatherLayer.radar &&
                      layers.enabled.contains(WeatherLayer.radar))
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        bottom: 8,
                      ),
                      child: Row(
                        children: [
                          const Text('Opacité'),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Slider(
                              value:
                                  (layers.opacity[WeatherLayer.radar] ?? 0.65)
                                      .clamp(0.0, 1.0)
                                      .toDouble(),
                              max: WeatherLayersNotifier.maxOpacity,
                              divisions: 10,
                              label:
                                  '${((layers.opacity[WeatherLayer.radar] ?? 0.65) * 100).round()}%',
                              onChanged: (v) => layersNotifier.setOpacity(
                                WeatherLayer.radar,
                                v,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Divider(height: 1),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Alertes météo',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ThresholdSlider(
                    title: 'Pluie (mm/h)',
                    value: alertThresholds.values['precipitation_mm'] ?? 1.0,
                    min: 0,
                    max: 10,
                    onChanged: (v) =>
                        alertThresholdsNotifier.setValue('precipitation_mm', v),
                  ),
                  const SizedBox(height: 10),
                  _ThresholdSlider(
                    title: 'Vent (km/h)',
                    value: alertThresholds.values['wind_kmh'] ?? 35.0,
                    min: 0,
                    max: 120,
                    onChanged: (v) =>
                        alertThresholdsNotifier.setValue('wind_kmh', v),
                  ),
                  const SizedBox(height: 10),
                  _ThresholdSlider(
                    title: 'Temp. basse (°C)',
                    value: alertThresholds.values['temp_low_c'] ?? -2.0,
                    min: -20,
                    max: 10,
                    onChanged: (v) =>
                        alertThresholdsNotifier.setValue('temp_low_c', v),
                  ),
                  const SizedBox(height: 10),
                  _ThresholdSlider(
                    title: 'Temp. haute (°C)',
                    value: alertThresholds.values['temp_high_c'] ?? 35.0,
                    min: 10,
                    max: 50,
                    onChanged: (v) =>
                        alertThresholdsNotifier.setValue('temp_high_c', v),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        unawaited(alertThresholdsNotifier.resetDefaults());
                      },
                      icon: const Icon(LucideIcons.rotateCcw),
                      label: const Text('Réinitialiser'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Zones hors-ligne (MVP)',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(LucideIcons.download),
                  title: const Text('Ajouter une zone'),
                  subtitle: const Text('Centre + rayon (persistance locale)'),
                  onTap: () async {
                    final pos = await _bestEffortCurrentPosition();
                    if (!context.mounted) return;
                    final created =
                        await showModalBottomSheet<OfflineZoneCreateRequest>(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => _AddOfflineZoneSheet(initial: pos),
                        );
                    if (created == null) return;

                    final success = await offlineZonesNotifier.add(
                      name: created.name,
                      lat: created.lat,
                      lng: created.lng,
                      radiusKm: created.radiusKm,
                    );

                    if (!success && context.mounted) {
                      AppSnackbar.error(
                        context,
                        'Paramètres invalides pour la zone hors-ligne.',
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                offlineZonesAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: AppLoadingIndicator(size: 32)),
                  ),
                  error: (error, stack) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Erreur: ${error}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            offlineZonesNotifier.clearError();
                            offlineZonesNotifier.refresh();
                          },
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                  data: (state) {
                    final offlineZones = state.zones;
                    final isLoading = state.isLoading;

                    return Column(
                      children: [
                        if (offlineZones.isEmpty)
                          const AppStateMessage(
                            icon: LucideIcons.map,
                            title: 'Aucune zone configurée',
                            message:
                                'Ajoute une zone hors-ligne pour préparer ton trajet sans réseau.',
                            dense: true,
                          )
                        else
                          ...offlineZones.map(
                            (z) => Column(
                              children: [
                                ListTile(
                                  leading: isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: AppLoadingIndicator(
                                            size: 24,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(LucideIcons.map),
                                  title: Text(z.name),
                                  subtitle: Text(
                                    '${z.radiusKm.toStringAsFixed(1)} km • ${z.lat.toStringAsFixed(3)}, ${z.lng.toStringAsFixed(3)}',
                                  ),
                                  trailing: IconButton(
                                    onPressed: isLoading
                                        ? null
                                        : () async {
                                            final success =
                                                await offlineZonesNotifier
                                                    .remove(z.id);
                                            if (!success && context.mounted) {
                                              AppSnackbar.error(
                                                context,
                                                'Échec de la suppression de la zone.',
                                              );
                                            }
                                          },
                                    icon: const Icon(LucideIcons.trash2),
                                  ),
                                ),
                                const Divider(height: 1),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Historique'),
            subtitle: const Text('Trajets sauvegardés'),
            onTap: () => context.push('/history'),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: const ListTile(
              leading: Icon(LucideIcons.shield),
              title: Text('Vie privée'),
              subtitle: Text('Aucune collecte additionnelle (MVP).'),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _pickOne(
  BuildContext context, {
  required String title,
  required String current,
  required List<String> values,
  required Future<void> Function(String) onSelected,
}) async {
  final selected = await showModalBottomSheet<String>(
    context: context,
    builder: (context) {
      return SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            for (final v in values)
              RadioListTile<String>(
                value: v,
                groupValue: current,
                onChanged: (val) => Navigator.of(context).pop(val),
                title: Text(v),
              ),
          ],
        ),
      );
    },
  );
  if (selected == null) return;
  await onSelected(selected);
}

class _ProfilePickerSheet extends ConsumerWidget {
  const _ProfilePickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(profileProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profil principal',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ProfileType.values.map((t) {
                final sel = active.type == t;
                return ChoiceChip(
                  selected: sel,
                  label: Text(t.name),
                  onSelected: (_) {
                    ref.read(profileProvider.notifier).setProfileByType(t);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThresholdSlider extends StatelessWidget {
  const _ThresholdSlider({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });
  final String title;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value.clamp(min, max).toDouble(),
                min: min,
                max: max,
                divisions: 20,
                label: value.toStringAsFixed(1),
                onChanged: onChanged,
              ),
            ),
            SizedBox(
              width: 56,
              child: Text(value.toStringAsFixed(1), textAlign: TextAlign.end),
            ),
          ],
        ),
      ],
    );
  }
}

class OfflineZoneCreateRequest {
  const OfflineZoneCreateRequest({
    required this.name,
    required this.lat,
    required this.lng,
    required this.radiusKm,
  });
  final String name;
  final double lat;
  final double lng;
  final double radiusKm;
}

class _InitialPos {
  const _InitialPos(this.lat, this.lng);
  final double lat;
  final double lng;
}

Future<_InitialPos?> _bestEffortCurrentPosition() async {
  try {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever)
      return null;
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );
    return _InitialPos(pos.latitude, pos.longitude);
  } catch (e, st) {
    AppLogger.warn(
      'Profile: bestEffortCurrentPosition failed',
      name: 'profile',
      error: e,
      stackTrace: st,
    );
    return null;
  }
}

class _AddOfflineZoneSheet extends StatefulWidget {
  const _AddOfflineZoneSheet({required this.initial});
  final _InitialPos? initial;

  @override
  State<_AddOfflineZoneSheet> createState() => _AddOfflineZoneSheetState();
}

class _AddOfflineZoneSheetState extends State<_AddOfflineZoneSheet> {
  late final TextEditingController _name;
  late final TextEditingController _lat;
  late final TextEditingController _lng;
  double _radiusKm = 15;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: 'Zone offline');
    _lat = TextEditingController(
      text: (widget.initial?.lat ?? 48.8566).toStringAsFixed(6),
    );
    _lng = TextEditingController(
      text: (widget.initial?.lng ?? 2.3522).toStringAsFixed(6),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _lat.dispose();
    _lng.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Nouvelle zone',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nom'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _lat,
                    decoration: const InputDecoration(labelText: 'Latitude'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _lng,
                    decoration: const InputDecoration(labelText: 'Longitude'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Rayon: ${_radiusKm.toStringAsFixed(0)} km',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            Slider(
              value: _radiusKm,
              min: 5,
              max: 100,
              divisions: 19,
              label: '${_radiusKm.toStringAsFixed(0)} km',
              onChanged: (v) => setState(() => _radiusKm = v),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                final name = _name.text.trim().isEmpty
                    ? 'Zone offline'
                    : _name.text.trim();
                final lat = double.tryParse(_lat.text.trim());
                final lng = double.tryParse(_lng.text.trim());
                if (lat == null || lng == null) {
                  Navigator.of(context).pop();
                  return;
                }
                Navigator.of(context).pop(
                  OfflineZoneCreateRequest(
                    name: name,
                    lat: lat,
                    lng: lng,
                    radiusKm: _radiusKm,
                  ),
                );
              },
              icon: const Icon(LucideIcons.plus),
              label: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}
