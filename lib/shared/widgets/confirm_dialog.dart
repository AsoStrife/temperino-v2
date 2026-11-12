import 'package:flutter/material.dart';

/// Material 3 confirmation dialog. Returns `true` only on explicit confirm.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Conferma',
  String cancelLabel = 'Annulla',
  bool destructive = false,
  IconData? icon,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return AlertDialog(
        icon: Icon(
          icon ??
              (destructive
                  ? Icons.delete_outline_rounded
                  : Icons.help_outline_rounded),
          color: destructive ? scheme.error : scheme.primary,
        ),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(64, 48),
              backgroundColor: destructive ? scheme.error : null,
              foregroundColor: destructive ? scheme.onError : null,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
