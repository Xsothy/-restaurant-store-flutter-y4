import 'package:flutter/material.dart';

class SnackbarHelper {
  static OverlayEntry? _currentEntry;

  static void showTopToast(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    // Remove any existing toast
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context, rootOverlay: true);
    if (overlay == null) return;

    final theme = Theme.of(context);
    final backgroundColor =
        isError ? theme.colorScheme.error : theme.colorScheme.primary;

    final entry = OverlayEntry(
      builder: (ctx) {
        final padding = MediaQuery.of(ctx).padding;
        return Positioned(
          top: padding.top + 16,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );

    _currentEntry = entry;
    overlay.insert(entry);

    Future.delayed(const Duration(seconds: 3), () {
      if (_currentEntry == entry) {
        _currentEntry?.remove();
        _currentEntry = null;
      }
    });
  }
}

