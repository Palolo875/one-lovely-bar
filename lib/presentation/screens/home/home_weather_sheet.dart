import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:weathernav/core/logging/app_logger.dart';
import 'package:weathernav/domain/failures/app_failure.dart';
import 'package:weathernav/domain/models/user_profile.dart';
import 'package:weathernav/domain/models/weather_condition.dart';
import 'package:weathernav/presentation/providers/cache_repository_provider.dart';
import 'package:weathernav/presentation/providers/settings_repository_provider.dart';

class HomePersistentWeatherSheet extends ConsumerWidget {
  const HomePersistentWeatherSheet({
    super.key,
    required this.currentWeather,
    required this.forecast,
    required this.profile,
    required this.center,
  });

  final AsyncValue<WeatherCondition> currentWeather;
  final AsyncValue<List<WeatherCondition>> forecast;
  final UserProfile profile;
  final LatLng center;

  String _hhmm(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _dmy(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/$m';
  }

  IconData _iconForCode(int code) {
    if (code == 0) return LucideIcons.sun;
    if (code < 3) return LucideIcons.cloudSun;
    if (code < 50) return LucideIcons.cloud;
    if (code < 70) return LucideIcons.cloudRain;
    return LucideIcons.cloudLightning;
  }

  String _conditionLabel(int code) {
    if (code == 0) return 'Ciel clair';
    if (code < 3) return 'Peu nuageux';
    if (code < 50) return 'Nuageux';
    if (code < 70) return 'Pluie';
    return 'Orage';
  }

  List<WeatherCondition> _nextHours(List<WeatherCondition> items, int hours) {
    final now = DateTime.now();
    final future = items
        .where((e) => e.timestamp.isAfter(now.subtract(const Duration(minutes: 1))))
        .toList();
    future.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    if (future.length <= hours) return future;
    return future.take(hours).toList();
  }

  List<WeatherCondition> _dailySummary(List<WeatherCondition> items) {
    final byDay = <String, List<WeatherCondition>>{};
    for (final e in items) {
      final key = '${e.timestamp.year}-${e.timestamp.month}-${e.timestamp.day}';
      (byDay[key] ??= []).add(e);
    }

    final days = byDay.values.toList();
    days.sort((a, b) => a.first.timestamp.compareTo(b.first.timestamp));

    final out = <WeatherCondition>[];
    for (final day in days) {
      day.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final best = day.firstWhere(
        (e) => e.timestamp.hour == 12,
        orElse: () => day[day.length ~/ 2],
      );
      out.add(best);
      if (out.length >= 7) break;
    }
    return out;
  }

  Widget _metricTile(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime? cachedAt;
    try {
      final cache = ref.watch(cacheRepositoryProvider);
      final settings = ref.watch(settingsRepositoryProvider);
      final key =
          'wx_current:${center.latitude.toStringAsFixed(3)},${center.longitude.toStringAsFixed(3)}';
      final raw = cache.get<Object?>(key) ?? settings.get<Object?>(key);
      if (raw is Map && raw['ts'] is int) {
        cachedAt = DateTime.fromMillisecondsSinceEpoch(raw['ts'] as int);
      }
    } catch (e, st) {
      AppLogger.warn(
        'Home: cachedAt parse failed',
        name: 'home',
        error: e,
        stackTrace: st,
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.14,
      minChildSize: 0.14,
      maxChildSize: 0.90,
      snap: true,
      snapSizes: const [0.14, 0.48, 0.90],
      builder: (context, scrollController) {
        return Material(
          elevation: 12,
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              currentWeather.when(
                data: (w) {
                  final icon = _iconForCode(w.weatherCode);
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        icon,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${w.temperature.round()}°',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                    fontSize: 72,
                                    height: 0.9,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _conditionLabel(w.weatherCode),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Vent ${w.windSpeed.round()} km/h',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Text(_hhmm(w.timestamp),
                          style: Theme.of(context).textTheme.bodySmall),
                      if (cachedAt != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 10, top: 2),
                          child: Text(
                            'Cache: ${_hhmm(cachedAt)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: Colors.grey),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const SizedBox(
                  height: 28,
                  child: Center(child: LinearProgressIndicator(minHeight: 2)),
                ),
                error: (err, st) {
                  final msg =
                      err is AppFailure ? err.message : 'Météo indisponible';
                  return Row(
                    children: [
                      const Icon(LucideIcons.alertTriangle, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(msg, overflow: TextOverflow.ellipsis)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              _WeatherMetricsRow(
                currentWeather: currentWeather,
                forecast: forecast,
                metricTile: _metricTile,
              ),
              const SizedBox(height: 18),
              Text(
                'Prochaines 24h',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              forecast.when(
                data: (items) {
                  final hours = _nextHours(items, 24);
                  if (hours.isEmpty) {
                    return const Text('Prévisions indisponibles.');
                  }
                  return SizedBox(
                    height: 92,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: hours.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final h = hours[i];
                        return Container(
                          width: 76,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_hhmm(h.timestamp),
                                  style:
                                      Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 6),
                              Icon(_iconForCode(h.weatherCode), size: 18),
                              const SizedBox(height: 6),
                              Text(
                                '${h.temperature.round()}°',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
                error: (err, st) {
                  final msg = err is AppFailure
                      ? err.message
                      : 'Prévisions indisponibles';
                  return Text(msg);
                },
              ),
              const SizedBox(height: 18),
              Text(
                'Prévisions 7 jours',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              forecast.when(
                data: (items) {
                  final daily = _dailySummary(items);
                  if (daily.isEmpty) {
                    return const Text('Prévisions indisponibles.');
                  }
                  return Column(
                    children: [
                      for (final d in daily)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(_iconForCode(d.weatherCode)),
                          title: Text(_dmy(d.timestamp)),
                          trailing: Text('${d.temperature.round()}°'),
                        ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 18),
              Text(
                'Pour votre profil',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              currentWeather.when(
                data: (w) {
                  final line = profile.type == ProfileType.cyclist
                      ? 'Vent: ${w.windSpeed.round()} km/h (utile pour l’effort / vent de face)'
                      : profile.type == ProfileType.driver
                          ? 'Précip.: ${w.precipitation.toStringAsFixed(1)} mm (adhérence / visibilité)'
                          : 'Vent: ${w.windSpeed.round()} km/h • UV: ${w.uvIndex?.toStringAsFixed(0) ?? '—'}';
                  return Text(line,
                      style: Theme.of(context).textTheme.bodyLarge);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WeatherMetricsRow extends StatelessWidget {
  const _WeatherMetricsRow({
    required this.currentWeather,
    required this.forecast,
    required this.metricTile,
  });

  final AsyncValue<WeatherCondition> currentWeather;
  final AsyncValue<List<WeatherCondition>> forecast;
  final Widget Function(BuildContext context, String label, String value)
      metricTile;

  WeatherCondition? _nearestForecast(List<WeatherCondition> list) {
    if (list.isEmpty) return null;
    final now = DateTime.now();
    var best = list.first;
    var bestDelta = best.timestamp.difference(now).inMinutes.abs();
    for (final e in list) {
      final d = e.timestamp.difference(now).inMinutes.abs();
      if (d < bestDelta) {
        best = e;
        bestDelta = d;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    return currentWeather.when(
      data: (w) {
        return forecast.when(
          data: (list) {
            final near = _nearestForecast(list);
            final visibility = w.visibility ?? near?.visibility;
            final uv = w.uvIndex ?? near?.uvIndex;

            String visText;
            if (visibility == null) {
              visText = '—';
            } else if (visibility >= 10000) {
              visText = '${(visibility / 1000).toStringAsFixed(0)} km';
            } else {
              visText = '${visibility.toStringAsFixed(0)} m';
            }

            final uvText = uv == null ? '—' : uv.toStringAsFixed(0);

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: metricTile(
                        context,
                        'Temp.',
                        '${w.temperature.round()}°',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: metricTile(
                        context,
                        'Vent',
                        '${w.windSpeed.round()} km/h',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: metricTile(context, 'Visib.', visText)),
                    const SizedBox(width: 12),
                    Expanded(child: metricTile(context, 'UV', uvText)),
                  ],
                ),
              ],
            );
          },
          loading: () {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: metricTile(
                        context,
                        'Temp.',
                        '${w.temperature.round()}°',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: metricTile(
                        context,
                        'Vent',
                        '${w.windSpeed.round()} km/h',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: metricTile(context, 'Visib.', '—')),
                    const SizedBox(width: 12),
                    Expanded(child: metricTile(context, 'UV', '—')),
                  ],
                ),
              ],
            );
          },
          error: (_, __) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: metricTile(
                        context,
                        'Temp.',
                        '${w.temperature.round()}°',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: metricTile(
                        context,
                        'Vent',
                        '${w.windSpeed.round()} km/h',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: metricTile(context, 'Visib.', '—')),
                    const SizedBox(width: 12),
                    Expanded(child: metricTile(context, 'UV', '—')),
                  ],
                ),
              ],
            );
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
