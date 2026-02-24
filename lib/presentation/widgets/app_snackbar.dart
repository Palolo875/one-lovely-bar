import 'package:flutter/material.dart';

class AppSnackbar {
  static void show(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        action: action,
      ),
    );
  }

  static void success(BuildContext context, String message) {
    show(context, message);
  }

  static void error(BuildContext context, String message) {
    show(
      context,
      message,
      backgroundColor: Theme.of(context).colorScheme.error,
    );
  }

  static void errorAction(
    BuildContext context,
    String message, {
    required SnackBarAction action,
  }) {
    show(
      context,
      message,
      backgroundColor: Theme.of(context).colorScheme.error,
      action: action,
    );
  }
}
