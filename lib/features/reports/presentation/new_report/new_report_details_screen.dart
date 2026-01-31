import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/report_models.dart';
import 'new_report_controller.dart';
import 'new_report_review_screen.dart';

/// Third step: Enter report details (category, incident type, description, severity)
class NewReportDetailsScreen extends ConsumerStatefulWidget {
  const NewReportDetailsScreen({super.key});

  @override
  ConsumerState<NewReportDetailsScreen> createState() =>
      _NewReportDetailsScreenState();
}

class _NewReportDetailsScreenState
    extends ConsumerState<NewReportDetailsScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _streetLandmarkController = TextEditingController();
  final _peopleAffectedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize from state if user navigates back
    final state = ref.read(newReportControllerProvider);
    _titleController.text = state.title ?? '';
    _descriptionController.text = state.description;
    _streetLandmarkController.text = state.streetLandmark ?? '';
    if (state.peopleAffected != null) {
      _peopleAffectedController.text = state.peopleAffected.toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _streetLandmarkController.dispose();
    _peopleAffectedController.dispose();
    super.dispose();
  }

  void _navigateToReview() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NewReportReviewScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newReportControllerProvider);
    final controller = ref.read(newReportControllerProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('New Report')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: 0.75,
            backgroundColor: isDark
                ? AppColors.darkBorder
                : AppColors.lightBorder,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step title
                  Text(
                    'Step 3 of 4',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Report Details',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Describe the issue you\'re reporting',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===== CATEGORY DROPDOWN =====
                  _buildSectionLabel(theme, 'Category *'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ReportCategory>(
                    value: state.category,
                    decoration: const InputDecoration(
                      hintText: 'Select a category',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: ReportCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category.displayName),
                      );
                    }).toList(),
                    onChanged: (value) => controller.setCategory(value),
                  ),
                  const SizedBox(height: 16),

                  // ===== INCIDENT TYPE DROPDOWN =====
                  if (state.category != null) ...[
                    _buildSectionLabel(theme, 'Incident Type'),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<IncidentType>(
                      // Only use value if it exists in available types
                      value: state.incidentType != null && 
                             state.availableIncidentTypes.contains(state.incidentType)
                          ? state.incidentType 
                          : null,
                      decoration: const InputDecoration(
                        hintText: 'Select incident type',
                        prefixIcon: Icon(Icons.report_outlined),
                      ),
                      items: state.availableIncidentTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.displayName),
                        );
                      }).toList(),
                      onChanged: (value) => controller.setIncidentType(value),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ===== TITLE (OPTIONAL) =====
                  _buildSectionLabel(theme, 'Title (Optional)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    maxLength: 200,
                    textInputAction: TextInputAction.next,
                    onChanged: controller.setTitle,
                    decoration: InputDecoration(
                      hintText: 'Brief title for your report',
                      prefixIcon: const Icon(Icons.title),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ===== DESCRIPTION =====
                  _buildSectionLabel(theme, 'Description *'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 5,
                    maxLength: 5000,
                    textInputAction: TextInputAction.newline,
                    onChanged: controller.setDescription,
                    decoration: InputDecoration(
                      hintText:
                          'Describe the issue in detail...\n\nInclude any relevant information that might help resolve it.',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ===== IS HAPPENING NOW =====
                  SwitchListTile(
                    title: const Text('Is this happening right now?'),
                    subtitle: Text(
                      'Mark if this incident is ongoing',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    value: state.isHappeningNow,
                    onChanged: controller.setIsHappeningNow,
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),

                  // ===== LOCATION SECTION =====
                  Text(
                    'Location Details',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Zone Dropdown
                  _buildSectionLabel(theme, 'Zone *'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: state.zone,
                    decoration: InputDecoration(
                      hintText: 'Select zone',
                      prefixIcon: const Icon(Icons.location_city_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: List.generate(10, (index) {
                      final zoneNumber = index + 1;
                      return DropdownMenuItem(
                        value: 'Zone $zoneNumber',
                        child: Text('Zone $zoneNumber'),
                      );
                    }),
                    onChanged: (value) => controller.setZone(value),
                  ),
                  const SizedBox(height: 16),

                  // Street / Landmark
                  _buildSectionLabel(theme, 'Street / Landmark'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _streetLandmarkController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: controller.setStreetLandmark,
                    decoration: InputDecoration(
                      hintText: 'Street address or nearby landmark',
                      prefixIcon: const Icon(Icons.place_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ===== SEVERITY SECTION =====
                  Text(
                    'Severity & Impact',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Severity Level
                  _buildSectionLabel(theme, 'Severity Level'),
                  const SizedBox(height: 8),
                  SegmentedButton<SeverityLevel>(
                    segments: SeverityLevel.values.map((level) {
                      return ButtonSegment(
                        value: level,
                        label: Text(level.displayName),
                        icon: Icon(_getSeverityIcon(level)),
                      );
                    }).toList(),
                    selected: {state.severity},
                    onSelectionChanged: (selected) {
                      controller.setSeverity(selected.first);
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return _getSeverityColor(state.severity).withOpacity(0.2);
                        }
                        return null;
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // People Affected
                  _buildSectionLabel(theme, 'Estimated People Affected'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _peopleAffectedController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    onChanged: (value) {
                      final count = int.tryParse(value);
                      controller.setPeopleAffected(count);
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter number (optional)',
                      prefixIcon: const Icon(Icons.people_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Is Emergency
                  SwitchListTile(
                    title: const Text('Is this an emergency?'),
                    subtitle: Text(
                      'Requires immediate attention',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    value: state.isEmergency,
                    onChanged: controller.setIsEmergency,
                    activeColor: AppColors.alertHigh,
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  if (state.isEmergency)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: AppColors.alertHigh.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.alertHigh.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: AppColors.alertHigh),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Emergency reports are prioritized and flagged for immediate review.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Continue button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: state.hasDetails && state.hasCategory ? _navigateToReview : null,
              child: const Text('Continue to Review'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(ThemeData theme, String label) {
    return Text(
      label,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  IconData _getSeverityIcon(SeverityLevel level) {
    return switch (level) {
      SeverityLevel.low => Icons.info_outline,
      SeverityLevel.medium => Icons.warning_amber_outlined,
      SeverityLevel.high => Icons.error_outline,
      SeverityLevel.critical => Icons.dangerous_outlined,
    };
  }

  Color _getSeverityColor(SeverityLevel level) {
    return switch (level) {
      SeverityLevel.low => AppColors.success,
      SeverityLevel.medium => AppColors.alertMedium,
      SeverityLevel.high => AppColors.alertHigh,
      SeverityLevel.critical => Colors.red.shade900,
    };
  }
}
