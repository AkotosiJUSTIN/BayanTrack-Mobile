import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/theme/app_colors.dart';
import 'new_report_controller.dart';
import 'new_report_details_screen.dart';

/// Second step: Get location from GPS
class NewReportLocationScreen extends ConsumerStatefulWidget {
  const NewReportLocationScreen({super.key});

  @override
  ConsumerState<NewReportLocationScreen> createState() =>
      _NewReportLocationScreenState();
}

class _NewReportLocationScreenState
    extends ConsumerState<NewReportLocationScreen> {
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Location services are disabled. Please enable GPS.';
          _isLoading = false;
        });
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Location permission denied';
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _error =
              'Location permissions are permanently denied. '
              'Please enable them in Settings.';
          _isLoading = false;
        });
        return;
      }

      // Get current position with timeout
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 20),
          ),
        ).timeout(
          const Duration(seconds: 25),
          onTimeout: () => throw TimeoutException('Location request timed out'),
        );

        if (mounted) {
          setState(() {
            _currentPosition = position;
            _isLoading = false;
          });

          // Update controller with location string (required by backend)
          ref
              .read(newReportControllerProvider.notifier)
              .setLocation(
                latitude: position.latitude,
                longitude: position.longitude,
                location:
                    '${position.latitude.toStringAsFixed(6)}, '
                    '${position.longitude.toStringAsFixed(6)}',
              );
        }
      } on TimeoutException {
        if (mounted) {
          setState(() {
            _error = 'Location request timed out. Please try again.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to get location: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToDetails() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NewReportDetailsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newReportControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('New Report')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: 0.5,
            backgroundColor: isDark
                ? AppColors.darkBorder
                : AppColors.lightBorder,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),

          // Step title
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Step 2 of 4',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Location',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'We\'ll use your current location for the report',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Location preview
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildLocationContent(theme, isDark),
            ),
          ),

          // Retry button if error
          if (_error != null && !_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ),

          // Continue button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: state.hasLocation ? _navigateToDetails : null,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationContent(ThemeData theme, bool isDark) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text('Getting your location...', style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: AppColors.alertHigh),
            const SizedBox(height: 16),
            Text('Location Error', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _error!,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    if (_currentPosition != null) {
      return Column(
        children: [
          // Map placeholder
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Stack(
                children: [
                  // Simulated map background
                  Center(
                    child: Icon(
                      Icons.map_outlined,
                      size: 100,
                      color: isDark
                          ? AppColors.darkTextSecondary.withValues(alpha: 0.3)
                          : AppColors.lightTextSecondary.withValues(alpha: 0.3),
                    ),
                  ),
                  // Pin in center
                  Center(
                    child: Icon(
                      Icons.location_on,
                      size: 48,
                      color: AppColors.alertHigh,
                    ),
                  ),
                  // Location badge
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.my_location, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Current Location',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${_currentPosition!.latitude.toStringAsFixed(6)}, '
                                  '${_currentPosition!.longitude.toStringAsFixed(6)}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.check_circle, color: AppColors.success),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
