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

          // Rejection Reason (if rejected)
          if (kycStatus.rejectionReason != null &&
              kycStatus.rejectionReason!.isNotEmpty)
            Card(
              color: AppColors.alertHigh.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.alertHigh),
                        SizedBox(width: 8),
                        Text(
                          'Rejection Reason',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(kycStatus.rejectionReason!),
                  ],
                ),
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

          // Action Buttons
          if (kycStatus.status.canResubmit)
            SizedBox(
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
                icon: const Icon(Icons.refresh),
                label: Text(
                  kycStatus.resubmissionCount > 0
                      ? 'Resubmit KYC (Attempt ${kycStatus.resubmissionCount + 1})'
                      : 'Resubmit KYC',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
