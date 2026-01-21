import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Placeholder widget for map view.
/// Shows a styled placeholder until real map integration in later phase.
class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      ),
      child: Stack(
        children: [
          // Grid pattern to simulate map
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              childAspectRatio: 1,
            ),
            itemCount: 64,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                            .withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
              );
            },
          ),

          // Sample markers
          Positioned(
            top: 100,
            left: 80,
            child: _buildMarker(AppColors.alertHigh),
          ),
          Positioned(
            top: 150,
            left: 150,
            child: _buildMarker(AppColors.alertMedium),
          ),
          Positioned(
            top: 200,
            left: 100,
            child: _buildMarker(AppColors.alertLow),
          ),
          Positioned(
            top: 180,
            right: 100,
            child: _buildMarker(AppColors.alertHigh),
          ),
          Positioned(
            bottom: 150,
            left: 120,
            child: _buildMarker(AppColors.alertHigh),
          ),

          // Center overlay text
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_outlined, size: 48, color: AppColors.primary),
                  const SizedBox(height: 12),
                  Text('Map View', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Interactive map coming soon',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarker(Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.location_on, color: Colors.white, size: 14),
    );
  }
}
