import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/background/background_scheduler_factory.dart';
import 'presentation/providers/router_provider.dart';
import 'presentation/providers/settings_provider.dart';

// Import generated localizations once flutter gen-l10n is run
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');

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
