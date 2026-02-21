import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/background/background_scheduler_factory.dart';
import 'presentation/providers/router_provider.dart';
import 'presentation/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');

  await Hive.openBox('trips');

  final scheduler = createBackgroundScheduler();
  await scheduler.init();

  runApp(
    const ProviderScope(
      child: WeatherNavApp(),
    ),
  );
}

class WeatherNavApp extends ConsumerWidget {
  const WeatherNavApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(appSettingsProvider);

    return MaterialApp.router(
      title: 'WeatherNav',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
