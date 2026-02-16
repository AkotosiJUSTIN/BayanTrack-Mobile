import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/entities/kyc_enums.dart';
import '../domain/entities/kyc_status.dart';
import 'kyc_controller.dart';
import 'kyc_form_screen.dart';

/// KYC Status Screen - shows current verification status
class KycStatusScreen extends ConsumerWidget {
  const KycStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kycStatusAsync = ref.watch(kycStatusControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC Verification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(kycStatusControllerProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: kycStatusAsync.when(
        data: (kycStatus) {
          if (kycStatus == null) {
            // No KYC submitted yet
            return _buildNoKycView(context, ref);
          }

          return _buildStatusView(context, ref, kycStatus);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(kycStatusControllerProvider.notifier).refresh();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoKycView(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 100,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 24),
            const Text(
              'Identity Verification',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Verify your identity to unlock all features and increase your account security.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KycFormScreen(),
                  ),
                );
                // Refresh status if form was submitted
                if (result == true) {
                  ref.read(kycStatusControllerProvider.notifier).refresh();
                }
              },
              icon: const Icon(Icons.assignment),
              label: const Text('Start Verification'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusView(
    BuildContext context,
    WidgetRef ref,
    KycStatusEntity kycStatus,
  ) {
    final statusColor = _getStatusColor(kycStatus.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getStatusIcon(kycStatus.status),
                        color: statusColor,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kycStatus.status.displayName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                            if (kycStatus.submittedAt != null)
                              Text(
                                'Submitted: ${_formatDateTime(kycStatus.submittedAt!)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(_getStatusMessage(kycStatus.status)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Rejection Reason (if rejected) - Modern Design
          if (kycStatus.rejectionReason != null &&
              kycStatus.rejectionReason!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.alertHigh.withValues(alpha: 0.15),
                    AppColors.alertHigh.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.alertHigh.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  // Header with icon and status
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.alertHigh.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.alertHigh.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.cancel_outlined,
                            color: AppColors.alertHigh,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Application Rejected',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.alertHigh,
                                ),
                              ),
                              if (kycStatus.resubmissionCount > 0)
                                Text(
                                  'Attempt ${kycStatus.resubmissionCount + 1} • Please review feedback',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.darkTextSecondary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Rejection reason with better formatting
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Feedback',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            kycStatus.rejectionReason!,
                            style: const TextStyle(fontSize: 15, height: 1.5),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Actionable steps
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Review the feedback and resubmit with corrected documents',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
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

          // Precheck Notes (only show for non-approved statuses)
          if (kycStatus.status != KycVerificationStatus.verified &&
              kycStatus.precheckNotes != null &&
              kycStatus.precheckNotes!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.alertMedium.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.alertMedium.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.alertMedium,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quality Check Notes',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.alertMedium,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          kycStatus.precheckNotes!,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Submitted Information
          const Text(
            'Submitted Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoRow('Full Name', kycStatus.fullName, context),
                  if (kycStatus.idType != null)
                    _buildInfoRow(
                      'ID Type',
                      kycStatus.idType!.displayName,
                      context,
                    ),
                  if (kycStatus.idNumber != null)
                    _buildInfoRow('ID Number', kycStatus.idNumber!, context),
                  if (kycStatus.dateOfBirth != null)
                    _buildInfoRow(
                      'Date of Birth',
                      _formatDateTime(kycStatus.dateOfBirth!),
                      context,
                    ),
                  if (kycStatus.resubmissionCount > 0)
                    _buildInfoRow(
                      'Resubmissions',
                      kycStatus.resubmissionCount.toString(),
                      context,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons - Enhanced Resubmit Button
          if (kycStatus.status.canResubmit)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => KycFormScreen(
                        isResubmission: true,
                        existingKyc: kycStatus,
                      ),
                    ),
                  );
                  // Refresh status if form was resubmitted
                  if (result == true) {
                    ref.read(kycStatusControllerProvider.notifier).refresh();
                  }
                },
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  kycStatus.resubmissionCount > 0
                      ? 'Resubmit Documents (Attempt ${kycStatus.resubmissionCount + 1})'
                      : 'Resubmit Documents',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(KycVerificationStatus status) {
    switch (status) {
      case KycVerificationStatus.verified:
        return AppColors.success;
      case KycVerificationStatus.pending:
        return AppColors.alertMedium;
      case KycVerificationStatus.rejected:
      case KycVerificationStatus.suspended:
        return AppColors.alertHigh;
      case KycVerificationStatus.resubmitRequested:
        return AppColors.alertMedium;
      case KycVerificationStatus.unverified:
        return AppColors.lightTextSecondary;
    }
  }

  IconData _getStatusIcon(KycVerificationStatus status) {
    switch (status) {
      case KycVerificationStatus.verified:
        return Icons.check_circle;
      case KycVerificationStatus.pending:
        return Icons.hourglass_empty;
      case KycVerificationStatus.rejected:
        return Icons.cancel;
      case KycVerificationStatus.resubmitRequested:
        return Icons.refresh;
      case KycVerificationStatus.suspended:
        return Icons.block;
      case KycVerificationStatus.unverified:
        return Icons.help_outline;
    }
  }

  String _getStatusMessage(KycVerificationStatus status) {
    switch (status) {
      case KycVerificationStatus.verified:
        return 'Your identity has been verified successfully!';
      case KycVerificationStatus.pending:
        return 'Your documents are being reviewed. This usually takes 1-3 business days.';
      case KycVerificationStatus.rejected:
        return 'Your submission was rejected. Please review the reason and resubmit.';
      case KycVerificationStatus.resubmitRequested:
        return 'Additional information is required. Please resubmit your documents.';
      case KycVerificationStatus.suspended:
        return 'Your account verification has been suspended. Please contact support.';
      case KycVerificationStatus.unverified:
        return 'Please submit your documents for verification.';
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
