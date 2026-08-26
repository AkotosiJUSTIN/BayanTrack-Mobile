import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
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

  void _syncSuggestedLandmark(NewReportState state) {
    if (state.landmarkManuallyEdited) return;
    final suggested = state.streetLandmark ?? '';
    if (_streetLandmarkController.text == suggested) return;
    _streetLandmarkController.value = TextEditingValue(
      text: suggested,
      selection: TextSelection.collapsed(offset: suggested.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newReportControllerProvider);
    final controller = ref.read(newReportControllerProvider.notifier);
    _syncSuggestedLandmark(state);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newReport)),
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
                      l10n.stepOf(3, 4),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.reportDetails,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.describeReportIssue,
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
                              l10n.aiCategorize,
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
                    _buildSectionLabel(
                      theme,
                      '${l10n.reportTitle} (${l10n.optional})',
                    ),
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
                        hintText: l10n.briefTitle,
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (v) {
                        if (v != null && v.trim().isNotEmpty) {
                          return Validators.reportText(
                            v,
                            isRequired: false,
                            l10n: l10n,
                          );
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ===== DESCRIPTION =====
                    _buildSectionLabel(theme, '${l10n.reportDescription} *'),
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
                        hintText: l10n.descriptionDetailed,
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) =>
                          Validators.reportText(value, l10n: l10n),
                    ),
                    const SizedBox(height: 16),

                    // ===== IS HAPPENING NOW =====
                    SwitchListTile(
                      title: Text(l10n.isHappeningNow),
                      subtitle: Text(
                        l10n.incidentOngoingSubtitle,
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
                      l10n.locationDetails,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildSectionLabel(theme, '${l10n.selectCity} *'),
                    const SizedBox(height: 8),
                    ref
                        .watch(municipalitiesProvider)
                        .when(
                          data: (municipalities) =>
                              DropdownButtonFormField<String>(
                                initialValue:
                                    municipalities.any(
                                      (item) => item.id == state.municipalityId,
                                    )
                                    ? state.municipalityId
                                    : null,
                                decoration: InputDecoration(
                                  hintText: l10n.selectCity,
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
                                    SnackBar(
                                      content: Text(l10n.placeLocationPin),
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                },
                                validator: (value) => value == null
                                    ? l10n.pleaseSelectCity
                                    : null,
                              ),
                          loading: () => const LinearProgressIndicator(),
                          error: (error, stack) => Text(
                            l10n.cityMetadataUnavailable,
                            style: TextStyle(color: theme.colorScheme.error),
                          ),
                        ),
                    const SizedBox(height: 16),

                    // Barangay is derived from the authoritative map pin.
                    _buildSectionLabel(theme, l10n.barangay),
                    const SizedBox(height: 8),
                    InputDecorator(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.location_city_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.isResolvingBarangay
                          ? Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(l10n.gettingLocation),
                              ],
                            )
                          : Text(
                              state.barangay ?? l10n.barangaysUnavailable,
                              style: TextStyle(
                                color: state.barangay == null
                                    ? theme.hintColor
                                    : null,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Street / Landmark
                    _buildSectionLabel(theme, l10n.streetLandmark),
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
                        hintText: l10n.streetAddress,
                        prefixIcon: const Icon(Icons.place_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    if (state.isResolvingLandmark)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.gettingLocation,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    if (state.nearbyLandmarkSuggestions.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: state.nearbyLandmarkSuggestions
                              .map(
                                (suggestion) => ActionChip(
                                  avatar: const Icon(
                                    Icons.place_outlined,
                                    size: 16,
                                  ),
                                  label: Text(suggestion),
                                  onPressed: () {
                                    _streetLandmarkController.text = suggestion;
                                    controller.setStreetLandmark(suggestion);
                                    _checkFormValidity();
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    if (state.landmarkLookupError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          state.landmarkLookupError!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
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
                              l10n.aiDetectSeverity,
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
              child: Text(l10n.continueToReview),
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
