import 'package:flutter/material.dart';

/// Centralized loading overlay widget with optional progress tracking.
/// Use this across all screens for consistent loading states.
///
/// Usage:
/// ```dart
/// // Indeterminate loading
/// LoadingOverlay(message: 'Loading...')
///
/// // With progress
/// LoadingOverlay(message: 'Uploading...', progress: 0.75)
///
/// // As a Stack overlay
/// Stack(children: [
///   MainContent(),
///   if (isLoading) const LoadingOverlay(),
/// ])
/// ```
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final double? progress; // 0.0 to 1.0, null for indeterminate

  const LoadingOverlay({
    super.key,
    this.message,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (progress != null)
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                    ),
                  )
                else
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (progress != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${(progress! * 100).toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
