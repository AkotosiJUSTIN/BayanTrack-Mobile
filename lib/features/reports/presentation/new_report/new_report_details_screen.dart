import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/barangays_provider.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _streetLandmarkController = TextEditingController();
  static final _addressInputRegex = RegExp(r"[A-Za-z0-9\s,.'#/()-]");
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Initialize from state if user navigates back
    final state = ref.read(newReportControllerProvider);
    _titleController.text = state.title ?? '';
    _descriptionController.text = state.description;
    _streetLandmarkController.text = state.streetLandmark ?? '';
    // Check initial validity
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFormValidity();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _streetLandmarkController.dispose();
    super.dispose();
  }

  void _navigateToReview() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const NewReportReviewScreen()));
  }

  void _checkFormValidity() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
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
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
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

                    // ===== AI AUTO-CATEGORIZATION INFO =====
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'AI will automatically categorize your report',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ===== TITLE (OPTIONAL) =====
                    _buildSectionLabel(theme, 'Title (Optional)'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      maxLength: 200,
                      textInputAction: TextInputAction.next,
                      onChanged: (v) {
                        controller.setTitle(v);
                        _checkFormValidity();
                      },
                      decoration: InputDecoration(
                        hintText: 'Brief title for your report',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) {
                        if (v != null && v.trim().isNotEmpty) {
                          return Validators.reportText(v, isRequired: false);
                        }
                        return null;
                      },
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
                      onChanged: (v) {
                        controller.setDescription(v);
                        _checkFormValidity();
                      },
                      decoration: InputDecoration(
                        hintText:
                            'Describe the issue in detail...\n\nInclude any relevant information that might help resolve it.',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: Validators.reportText,
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
                      activeThumbColor: AppColors.primary,
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

                    _buildSectionLabel(theme, 'Municipality *'),
                    const SizedBox(height: 8),
                    ref
                        .watch(municipalitiesProvider)
                        .when(
                          data: (municipalities) => DropdownButtonFormField<String>(
                            initialValue:
                                municipalities.any(
                                  (item) => item.id == state.municipalityId,
                                )
                                ? state.municipalityId
                                : null,
                            decoration: InputDecoration(
                              hintText: 'Select municipality',
                              prefixIcon: const Icon(Icons.location_city),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: municipalities
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item.id,
                                    child: Text(
                                      '${item.name}, ${item.province}',
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              final selected = municipalities.firstWhere(
                                (item) => item.id == value,
                              );
                              controller.setMunicipality(
                                id: selected.id,
                                name: selected.name,
                                province: selected.province,
                              );
                              _streetLandmarkController.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Place a location pin for the selected municipality.',
                                  ),
                                ),
                              );
                              Navigator.of(context).pop();
                            },
                            validator: (value) => value == null
                                ? 'Please select a municipality'
                                : null,
                          ),
                          loading: () => const LinearProgressIndicator(),
                          error: (error, stack) => Text(
                            'Municipality metadata is unavailable.',
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                    const SizedBox(height: 16),

                    // Barangay Dropdown (stores the stable ID)
                    _buildSectionLabel(theme, 'Barangay *'),
                    const SizedBox(height: 8),
                    Consumer(
                      builder: (context, ref, child) {
                        final barangaysAsync = ref.watch(
                          municipalityBarangaysProvider(state.municipalityId),
                        );

                        return barangaysAsync.when(
                          data: (barangays) => DropdownButtonFormField<String>(
                            initialValue:
                                barangays.any(
                                  (item) => item.id == state.barangayId,
                                )
                                ? state.barangayId
                                : null,
                            decoration: InputDecoration(
                              hintText: 'Select barangay',
                              prefixIcon: const Icon(
                                Icons.location_city_outlined,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: barangays.map((barangay) {
                              return DropdownMenuItem(
                                value: barangay.id,
                                child: Text(barangay.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              final selected = barangays.firstWhere(
                                (item) => item.id == value,
                              );
                              controller.setBarangay(
                                id: selected.id,
                                name: selected.name,
                              );
                              _checkFormValidity();
                            },
                            validator: (value) => value == null
                                ? 'Please select a barangay'
                                : null,
                          ),
                          loading: () => DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              hintText: 'Loading barangays...',
                              prefixIcon: const Icon(
                                Icons.location_city_outlined,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: const [],
                            onChanged: null,
                          ),
                          error: (error, stack) => DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              hintText:
                                  state.municipalityId == defaultMunicipalityId
                                  ? 'Using bundled Urdaneta barangays'
                                  : 'Barangays unavailable for this municipality',
                              prefixIcon: const Icon(
                                Icons.location_city_outlined,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                            items: const [],
                            onChanged: null,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Street / Landmark
                    _buildSectionLabel(theme, 'Street / Landmark'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _streetLandmarkController,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(_addressInputRegex),
                        LengthLimitingTextInputFormatter(255),
                      ],
                      onChanged: (v) {
                        controller.setStreetLandmark(v);
                        _checkFormValidity();
                      },
                      decoration: InputDecoration(
                        hintText: 'Street address or nearby landmark',
                        prefixIcon: const Icon(Icons.place_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ===== AI PRIORITIZATION INFO =====
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'AI will automatically detect severity and urgency from your description',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Continue button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: (state.hasDetails && _isFormValid)
                  ? _navigateToReview
                  : null,
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
      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
