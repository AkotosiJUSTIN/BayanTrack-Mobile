import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

enum ToastType { success, error, warning, info }

class AppToast {
  AppToast._();

  static void success(BuildContext context, String message) {
    _show(context, message, ToastType.success);
  }

  static void error(BuildContext context, String message) {
    _show(
      context,
      message,
      ToastType.error,
      duration: const Duration(seconds: 5),
    );
  }

  static void warning(BuildContext context, String message) {
    _show(
      context,
      message,
      ToastType.warning,
      duration: const Duration(seconds: 4),
    );
  }

  static void info(BuildContext context, String message) {
    _show(context, message, ToastType.info);
  }

  static void _show(
    BuildContext context,
    String message,
    ToastType type, {
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.removeCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: duration,
        backgroundColor: _backgroundColor(type),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static Color _backgroundColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return AppColors.success;
      case ToastType.error:
        return AppColors.alertHigh;
      case ToastType.warning:
        return AppColors.alertMedium;
      case ToastType.info:
        return AppColors.primary;
    }
  }
}
