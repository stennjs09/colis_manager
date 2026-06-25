import 'package:flutter/material.dart';
import 'package:colis_manager/core/theme/app_theme.dart';

class SnackBarHelper {
  static void showError(BuildContext context, String message) {
    _show(context, message, AppTheme.statusNonLivre);
  }

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, AppTheme.statusLivre);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, AppTheme.accentAerien);
  }

  static void showUndo(
    BuildContext context,
    String message,
    VoidCallback onUndo,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Annuler',
          textColor: Colors.white,
          onPressed: onUndo,
        ),
      ),
    );
  }

  static void _show(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void Function(BuildContext, String) get onError => showError;
  static void Function(BuildContext, String) get onSuccess => showSuccess;
}
