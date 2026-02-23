import 'dart:developer' as developer;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:weathernav/core/config/app_config.dart';

/// Enhanced application logger with structured logging and monitoring.
/// 
/// Provides different log levels with automatic Sentry integration
/// for production environments. Supports contextual information
/// and performance monitoring.
class AppLogger {
  /// Logs informational messages that highlight the progress of the application.
  /// 
  /// [message] - The log message
  /// [name] - Logger name/category for filtering (default: 'app')
  /// [error] - Optional error object to include
  /// [stackTrace] - Optional stack trace for context
  /// [data] - Additional structured data to include
  static void info(
    String message, {
    String name = 'app',
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) {
    _log(
      level: 800,
      message: message,
      name: name,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Logs potentially harmful situations that don't prevent the application
  /// from continuing to work.
  /// 
  /// [message] - The log message
  /// [name] - Logger name/category for filtering (default: 'app')
  /// [error] - Optional error object to include
  /// [stackTrace] - Optional stack trace for context
  /// [data] - Additional structured data to include
  static void warning(
    String message, {
    String name = 'app',
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) {
    _log(
      level: 900,
      message: message,
      name: name,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
    
    if (AppConfig.isProd && error != null) {
      Sentry.captureException(error, stackTrace: stackTrace);
    }
  }

  /// Logs error events that might still allow the application to continue running.
  /// 
  /// [message] - The log message
  /// [name] - Logger name/category for filtering (default: 'app')
  /// [error] - Optional error object to include
  /// [stackTrace] - Optional stack trace for context
  /// [data] - Additional structured data to include
  static void error(
    String message, {
    String name = 'app',
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) {
    _log(
      level: 1000,
      message: message,
      name: name,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
    
    if (AppConfig.isProd) {
      if (error != null) {
        Sentry.captureException(error, stackTrace: stackTrace);
      } else {
        Sentry.captureMessage(
          message,
          level: SentryLevel.error,
        );
      }
    }
  }

  /// Logs debug messages that are most useful for debugging.
  /// 
  /// These are only logged in debug mode to avoid performance overhead.
  /// 
  /// [message] - The log message
  /// [name] - Logger name/category for filtering (default: 'app')
  /// [error] - Optional error object to include
  /// [stackTrace] - Optional stack trace for context
  /// [data] - Additional structured data to include
  static void debug(
    String message, {
    String name = 'app',
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) {
    if (!AppConfig.isDebug) return;
    
    _log(
      level: 700,
      message: message,
      name: name,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// Logs performance metrics and timing information.
  /// 
  /// [operation] - Name of the operation being measured
  /// [duration] - Duration of the operation
  /// [name] - Logger name/category for filtering (default: 'performance')
  /// [data] - Additional performance data
  static void performance(
    String operation,
    Duration duration, {
    String name = 'performance',
    Map<String, Object?>? data,
  }) {
    final performanceData = <String, Object?>{
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      ...?data,
    };
    
    _log(
      level: 800,
      message: 'Performance: $operation completed in ${duration.inMilliseconds}ms',
      name: name,
      data: performanceData,
    );
    
    if (AppConfig.isProd && duration.inMilliseconds > 1000) {
      Sentry.addBreadcrumb(
        message: 'Slow operation detected',
        category: 'performance',
        level: SentryLevel.warning,
        data: performanceData,
      );
    }
  }

  /// Logs user actions for analytics and debugging.
  /// 
  /// [action] - Description of the user action
  /// [name] - Logger name/category for filtering (default: 'user_action')
  /// [data] - Additional context about the action
  static void userAction(
    String action, {
    String name = 'user_action',
    Map<String, Object?>? data,
  }) {
    _log(
      level: 800,
      message: 'User action: $action',
      name: name,
      data: {'action': action, ...?data},
    );
  }

  /// Internal logging method that handles all log formatting and output.
  static void _log({
    required int level,
    required String message,
    required String name,
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?>? data,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logData = <String, Object?>{
      'timestamp': timestamp,
      'level': _levelToString(level),
      'message': message,
      if (data != null) ...data,
    };
    
    final formattedMessage = data != null
        ? '$message | Data: ${data.toString()}'
        : message;
    
    developer.log(
      formattedMessage,
      name: name,
      time: DateTime.now(),
      level: level,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Converts numeric log level to string representation.
  static String _levelToString(int level) {
    switch (level) {
      case 700:
        return 'DEBUG';
      case 800:
        return 'INFO';
      case 900:
        return 'WARNING';
      case 1000:
        return 'ERROR';
      default:
        return 'UNKNOWN';
    }
  }

  /// Creates a performance measurement scope.
  /// 
  /// Usage:
  /// ```dart
  /// AppLogger.measure('database_query', () async {
  ///   // Your code here
  /// });
  /// ```
  static Future<T> measure<T>(
    String operation,
    Future<T> Function() operationFn, {
    String name = 'performance',
    Map<String, Object?>? data,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final result = await operationFn();
      stopwatch.stop();
      
      performance(
        operation,
        stopwatch.elapsed,
        name: name,
        data: {
          'success': true,
          ...?data,
        },
      );
      
      return result;
    } catch (error, stackTrace) {
      stopwatch.stop();
      
      performance(
        operation,
        stopwatch.elapsed,
        name: name,
        data: {
          'success': false,
          'error': error.toString(),
          ...?data,
        },
      );
      
      // Re-throw the original error
      rethrow;
    }
  }
}

/// Extension to maintain backward compatibility
class AppLogger {
  /// @deprecated Use [warning] instead
  static void warn(String message, {String name = 'app', Object? error, StackTrace? stackTrace}) {
    warning(message, name: name, error: error, stackTrace: stackTrace);
  }
}
