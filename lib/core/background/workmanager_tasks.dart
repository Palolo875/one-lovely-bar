import 'package:workmanager/workmanager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../logging/app_logger.dart';
import '../network/dio_factory.dart';

class WorkmanagerTasks {
  static const weatherRefreshTask = 'weathernav_weather_refresh';
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();

    await Hive.initFlutter();
    await Hive.openBox('settings');

    final settings = Hive.box('settings');

    // Best-effort refresh: we ping RainViewer and Open-Meteo for cached locations.
    final dio = createAppDio(enableLogging: false);

    if (task == WorkmanagerTasks.weatherRefreshTask) {
      try {
        final resp = await dio.get('https://api.rainviewer.com/public/weather-maps.json');
        final data = resp.data;
        if (data is Map<String, dynamic>) {
          final radar = data['radar'];
          if (radar is Map<String, dynamic>) {
            final past = radar['past'];
            if (past is List && past.isNotEmpty) {
              final last = past.last;
              if (last is Map<String, dynamic>) {
                final time = last['time'];
                if (time is num) {
                  settings.put('rainviewer_latest_time', {
                    'ts': DateTime.now().millisecondsSinceEpoch,
                    'time': time.toInt(),
                  });
                }
              }
            }
          }
        }
      } catch (e, st) {
        AppLogger.warn('Background refresh: RainViewer ping failed', name: 'background', error: e, stackTrace: st);
      }

      final keys = settings.keys.map((k) => k.toString()).toList();

      for (final key in keys) {
        if (key.startsWith('wx_current:')) {
          final latLng = key.substring('wx_current:'.length);
          final parts = latLng.split(',');
          if (parts.length != 2) continue;
          final lat = double.tryParse(parts[0]);
          final lng = double.tryParse(parts[1]);
          if (lat == null || lng == null) continue;

          try {
            final resp = await dio.get(
              'https://api.open-meteo.com/v1/forecast',
              queryParameters: {
                'latitude': lat,
                'longitude': lng,
                'current_weather': true,
                'hourly': 'temperature_2m,precipitation,windspeed_10m,winddirection_10m,weathercode',
              },
            );

            final data = resp.data;
            if (data is Map && data['current_weather'] is Map) {
              final current = Map<String, dynamic>.from(data['current_weather'] as Map);
              final payload = {
                'temperature': (current['temperature'] as num).toDouble(),
                'precipitation': 0.0,
                'windSpeed': (current['windspeed'] as num).toDouble(),
                'windDirection': (current['winddirection'] as num).toDouble(),
                'weatherCode': (current['weathercode'] as num).toInt(),
                'timestamp': current['time']?.toString(),
              };

              settings.put(key, {
                'ts': DateTime.now().millisecondsSinceEpoch,
                'data': payload,
              });
            }
          } catch (e, st) {
            AppLogger.warn('Background refresh: Open-Meteo current update failed', name: 'background', error: e, stackTrace: st);
          }
        }

        if (key.startsWith('wx_forecast:')) {
          // key format: wx_forecast:<days>:<lat>,<lng>
          final rest = key.substring('wx_forecast:'.length);
          final idx = rest.indexOf(':');
          if (idx <= 0) continue;
          final daysStr = rest.substring(0, idx);
          final latLng = rest.substring(idx + 1);
          final days = int.tryParse(daysStr);
          final parts = latLng.split(',');
          if (days == null || parts.length != 2) continue;
          final lat = double.tryParse(parts[0]);
          final lng = double.tryParse(parts[1]);
          if (lat == null || lng == null) continue;

          try {
            final resp = await dio.get(
              'https://api.open-meteo.com/v1/forecast',
              queryParameters: {
                'latitude': lat,
                'longitude': lng,
                'hourly': 'temperature_2m,precipitation,windspeed_10m,winddirection_10m,weathercode,visibility,uv_index,cloudcover',
                'forecast_days': days,
              },
            );

            final data = resp.data;
            if (data is Map && data['hourly'] is Map) {
              final hourly = Map<String, dynamic>.from(data['hourly'] as Map);
              final times = hourly['time'];
              if (times is List) {
                final out = <Map<String, dynamic>>[];
                for (int i = 0; i < times.length; i++) {
                  out.add({
                    'temperature': (hourly['temperature_2m'][i] as num).toDouble(),
                    'precipitation': (hourly['precipitation'][i] as num).toDouble(),
                    'windSpeed': (hourly['windspeed_10m'][i] as num).toDouble(),
                    'windDirection': (hourly['winddirection_10m'][i] as num).toDouble(),
                    'weatherCode': (hourly['weathercode'][i] as num).toInt(),
                    'timestamp': times[i].toString(),
                    'visibility': (hourly['visibility'][i] as num).toDouble(),
                    'uvIndex': (hourly['uv_index'][i] as num).toDouble(),
                    'cloudCover': (hourly['cloudcover'][i] as num).toDouble(),
                  });
                }

                settings.put(key, {
                  'ts': DateTime.now().millisecondsSinceEpoch,
                  'data': out,
                });
              }
            }
          } catch (e, st) {
            AppLogger.warn('Background refresh: Open-Meteo forecast update failed', name: 'background', error: e, stackTrace: st);
          }
        }
      }
    }

    return Future.value(true);
  });
}
