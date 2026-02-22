import 'dart:developer' as developer;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:weathernav/core/config/app_config.dart';

class AppLogger {
  static void info(String message, {String name = 'app', Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: name,
      error: error,
      stackTrace: stackTrace,
      level: 800,
    );
  }

  static void warn(String message, {String name = 'app', Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: name,
      error: error,
      stackTrace: stackTrace,
      level: 900,
    );
    if (AppConfig.isProd && error != null) {
      Sentry.captureException(error, stackTrace: stackTrace);
    }
  }

  static void error(String message, {String name = 'app', Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: name,
      error: error,
      stackTrace: stackTrace,
      level: 1000,
    );
    if (AppConfig.isProd) {
      if (error != null) {
        Sentry.captureException(error, stackTrace: stackTrace);
      } else {
        Sentry.captureMessage(message, level: SentryLevel.error);
      }
    }
  }
}
