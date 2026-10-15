import 'package:equatable/equatable.dart';

/// Domain entity for a report image.
class ReportImage extends Equatable {
  final String id;
  final String url;
  final String? caption;
  final String? reportId;
  final String? userId;
  final bool isPrimary;

  /// Distinguishes how this image relates to the report.
  ///
  /// Known values: `'evidence'` (default), `'signature'`, `'document'`.
  /// Null means the record pre-dates the purpose field — treat as evidence.
  final String? purpose;

  final int? width;
  final int? height;
  final DateTime? createdAt;

  const ReportImage({
    required this.id,
    required this.url,
    this.caption,
    this.reportId,
    this.userId,
    this.isPrimary = false,
    this.purpose,
    this.width,
    this.height,
    this.createdAt,
  });

  /// True when this image is a closure e-signature rather than a report photo.
  bool get isSignature => purpose == 'signature';

  @override
  List<Object?> get props => [id, url, caption, reportId, isPrimary, purpose];

  @override
  String toString() =>
      'ReportImage($id, $url, primary: $isPrimary, purpose: $purpose)';
}
