import 'package:flutter/material.dart';
// Import generated localizations once flutter gen-l10n is run
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:weathernav/core/background/background_scheduler_factory.dart';
import 'package:weathernav/core/config/app_config.dart';
import 'package:weathernav/core/storage/cache_maintenance.dart';
import 'package:weathernav/core/theme/app_theme.dart';
import 'package:weathernav/presentation/providers/router_provider.dart';
import 'package:weathernav/presentation/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');

  await Hive.openBox('cache');
  await purgeCacheBox(Hive.box('cache'));

  await Hive.openBox('trips');

  final scheduler = createBackgroundScheduler();
  await scheduler.init();

  await SentryFlutter.init(
    (options) {
      options.dsn = AppConfig.sentryDsn;
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      options.tracesSampleRate = AppConfig.isProd ? 0.2 : 0.0;
      options.environment = AppConfig.currentEnvironment.name;
    },
    appRunner: () => runApp(
      const ProviderScope(
        child: WeatherNavApp(),
      ),
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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', ''),
        Locale('en', ''),
      ],
    );
  }
}
