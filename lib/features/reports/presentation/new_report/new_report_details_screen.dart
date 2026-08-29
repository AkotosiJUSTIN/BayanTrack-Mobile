import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/presentation/widgets/app_toast.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/barangays_provider.dart';
import 'new_report_controller.dart';
import 'new_report_review_screen.dart';
import 'report_flow_widgets.dart';

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
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newReport)),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReportFlowProgress(step: 3, total: 4),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.only(bottom: 24),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ReportFlowHeader(
                        title: l10n.reportDetails,
                        guidance: l10n.describeReportIssue,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Semantics(
                              container: true,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: scheme.primary.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: scheme.primary.withValues(
                                      alpha: 0.18,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: scheme.primary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        '${l10n.aiCategorize}. ${l10n.aiDetectSeverity}.',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(height: 1.35),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ReportFlowSection(
                              title: l10n.reportDescription,
                              icon: Icons.edit_note_outlined,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildSectionLabel(
                                    theme,
                                    l10n.reportTitle,
                                    optional: true,
                                  ),
                                  const SizedBox(height: 8),
                                  Semantics(
                                    container: true,
                                    label:
                                        '${l10n.reportTitle}, ${l10n.optional}',
                                    child: TextFormField(
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
                                  ),
                                  const SizedBox(height: 16),
                                  _buildSectionLabel(
                                    theme,
                                    l10n.reportDescription,
                                    isRequired: true,
                                  ),
                                  const SizedBox(height: 8),
                                  Semantics(
                                    container: true,
                                    label:
                                        '${l10n.reportDescription}, ${l10n.requiredShort}',
                                    child: TextFormField(
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
                                      ),
                                      validator: (value) =>
                                          Validators.reportText(
                                            value,
                                            l10n: l10n,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SwitchListTile(
                                    title: Text(l10n.isHappeningNow),
                                    subtitle: Text(
                                      l10n.incidentOngoingSubtitle,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                    ),
                                    value: state.isHappeningNow,
                                    onChanged: controller.setIsHappeningNow,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ReportFlowSection(
                              title: l10n.locationDetails,
                              icon: Icons.location_on_outlined,
                              description: l10n.selectLocationDescription,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildSectionLabel(
                                    theme,
                                    l10n.selectCity,
                                    isRequired: true,
                                  ),
                                  const SizedBox(height: 8),
                                  ref
                                      .watch(municipalitiesProvider)
                                      .when(
                                        data: (municipalities) =>
                                            DropdownButtonFormField<String>(
                                              initialValue:
                                                  municipalities.any(
                                                    (item) =>
                                                        item.id ==
                                                        state.municipalityId,
                                                  )
                                                  ? state.municipalityId
                                                  : null,
                                              isExpanded: true,
                                              decoration: InputDecoration(
                                                labelText: l10n.selectCity,
                                                prefixIcon: const Icon(
                                                  Icons.location_city_outlined,
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
                                                final selected = municipalities
                                                    .firstWhere(
                                                      (item) =>
                                                          item.id == value,
                                                    );
                                                controller.setMunicipality(
                                                  id: selected.id,
                                                  name: selected.name,
                                                  province: selected.province,
                                                );
                                                _streetLandmarkController
                                                    .clear();
                                                AppToast.info(
                                                  context,
                                                  l10n.placeLocationPin,
                                                );
                                                Navigator.of(context).pop();
                                              },
                                              validator: (value) =>
                                                  value == null
                                                  ? l10n.pleaseSelectCity
                                                  : null,
                                            ),
                                        loading: () =>
                                            const LinearProgressIndicator(),
                                        error: (error, stack) => Text(
                                          l10n.cityMetadataUnavailable,
                                          style: TextStyle(color: scheme.error),
                                        ),
                                      ),
                                  const SizedBox(height: 16),
                                  _buildSectionLabel(theme, l10n.barangay),
                                  const SizedBox(height: 8),
                                  Semantics(
                                    container: true,
                                    label:
                                        '${l10n.barangay}: ${state.barangay ?? l10n.barangaysUnavailable}',
                                    child: InputDecorator(
                                      decoration: const InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.location_city_outlined,
                                        ),
                                      ),
                                      child: state.isResolvingBarangay
                                          ? Row(
                                              children: [
                                                SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(l10n.gettingLocation),
                                              ],
                                            )
                                          : Text(
                                              state.barangay ??
                                                  l10n.barangaysUnavailable,
                                              style: TextStyle(
                                                color: state.barangay == null
                                                    ? scheme.onSurfaceVariant
                                                    : null,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildSectionLabel(
                                    theme,
                                    l10n.streetLandmark,
                                    optional: true,
                                  ),
                                  const SizedBox(height: 8),
                                  Semantics(
                                    container: true,
                                    label:
                                        '${l10n.streetLandmark}, ${l10n.optional}',
                                    child: TextFormField(
                                      controller: _streetLandmarkController,
                                      textInputAction: TextInputAction.next,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          _addressInputRegex,
                                        ),
                                        LengthLimitingTextInputFormatter(255),
                                      ],
                                      onChanged: (v) {
                                        controller.setStreetLandmark(v);
                                        _checkFormValidity();
                                      },
                                      decoration: InputDecoration(
                                        hintText: l10n.streetAddress,
                                        prefixIcon: const Icon(
                                          Icons.place_outlined,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (state.isResolvingLandmark)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
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
                                  if (state
                                      .nearbyLandmarkSuggestions
                                      .isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: state
                                            .nearbyLandmarkSuggestions
                                            .map(
                                              (suggestion) => ActionChip(
                                                avatar: const Icon(
                                                  Icons.place_outlined,
                                                  size: 16,
                                                ),
                                                label: Text(suggestion),
                                                onPressed: () {
                                                  _streetLandmarkController
                                                          .text =
                                                      suggestion;
                                                  controller.setStreetLandmark(
                                                    suggestion,
                                                  );
                                                  _checkFormValidity();
                                                },
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  if (state.landmarkLookupError != null)
                                    Semantics(
                                      container: true,
                                      liveRegion: true,
                                      label:
                                          '${l10n.error}: ${state.landmarkLookupError}',
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          state.landmarkLookupError!,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: scheme.onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                    ),
                                ],
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
            ReportFlowBottomBar(
              child: ElevatedButton(
                onPressed: (state.hasDetails && _isFormValid)
                    ? _navigateToReview
                    : null,
                child: Text(l10n.continueToReview),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(
    ThemeData theme,
    String label, {
    bool isRequired = false,
    bool optional = false,
  }) {
    final l10n = AppLocalizations.of(context);
    final marker = isRequired
        ? l10n.requiredShort
        : optional
        ? l10n.optional
        : null;
    return Semantics(
      label: marker == null ? label : '$label, $marker',
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (marker != null)
            Text(
              marker,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isRequired
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}
