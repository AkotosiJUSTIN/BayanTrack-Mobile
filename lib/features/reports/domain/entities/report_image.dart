import 'package:equatable/equatable.dart';

/// Domain entity for a report image.
class ReportImage extends Equatable {
  final String id;
  final String url;
  final String? reportId;
  final String? userId;
  final bool isPrimary;
  final int? width;
  final int? height;
  final DateTime? createdAt;

  const ReportImage({
    required this.id,
    required this.url,
    this.reportId,
    this.userId,
    this.isPrimary = false,
    this.width,
    this.height,
    this.createdAt,
  });

  @override
  List<Object?> get props => [id, url, reportId, isPrimary];

  @override
  String toString() => 'ReportImage($id, $url, primary: $isPrimary)';
}
