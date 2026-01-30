import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import 'new_report_controller.dart';
import 'new_report_review_screen.dart';

/// Third step: Enter report details (description, category)
class NewReportDetailsScreen extends ConsumerStatefulWidget {
  const NewReportDetailsScreen({super.key});

  @override
  ConsumerState<NewReportDetailsScreen> createState() =>
      _NewReportDetailsScreenState();
}

class _NewReportDetailsScreenState
    extends ConsumerState<NewReportDetailsScreen> {
  final _descriptionController = TextEditingController();
  final _zoneController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Initialize from state if user navigates back
    final state = ref.read(newReportControllerProvider);
    _descriptionController.text = state.description;
    _zoneController.text = state.zone;
    _selectedCategory = state.category;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _zoneController.dispose();
    super.dispose();
  }

  void _onDescriptionChanged(String value) {
    ref.read(newReportControllerProvider.notifier).setDescription(value);
  }

  void _onZoneChanged(String value) {
    ref.read(newReportControllerProvider.notifier).setZone(value);
  }

  void _onCategoryChanged(String? value) {
    setState(() {
      _selectedCategory = value;
    });
    ref.read(newReportControllerProvider.notifier).setCategory(value);
  }

  void _navigateToReview() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NewReportReviewScreen()));
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
                    'Details',
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
                  const SizedBox(height: 32),

                  // Category dropdown
                  Text(
                    'Category',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      hintText: 'Select a category',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: reportCategories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: _onCategoryChanged,
                  ),
                  const SizedBox(height: 24),

                  // Zone field (required)
                  Text(
                    'Zone *',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _zoneController,
                    textInputAction: TextInputAction.next,
                    onChanged: _onZoneChanged,
                    decoration: InputDecoration(
                      hintText: 'Enter zone name',
                      prefixIcon: const Icon(Icons.location_city_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description field
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 6,
                    maxLength: 500,
                    textInputAction: TextInputAction.done,
                    onChanged: _onDescriptionChanged,
                    decoration: InputDecoration(
                      hintText:
                          'Describe the issue in detail...\n\nInclude any relevant information that might help resolve it.',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
              onPressed: state.hasDetails ? _navigateToReview : null,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}
