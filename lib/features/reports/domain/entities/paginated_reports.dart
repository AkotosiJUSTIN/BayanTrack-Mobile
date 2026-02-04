import 'package:equatable/equatable.dart';
import 'report.dart';

/// Domain entity for paginated reports response.
class PaginatedReports extends Equatable {
  final List<Report> results;
  final int count;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const PaginatedReports({
    required this.results,
    this.count = 0,
    this.total = 0,
    this.page = 1,
    this.pageSize = 20,
    this.totalPages = 1,
  });

  /// Check if there are more pages
  bool get hasNextPage => page < totalPages;

  /// Check if this is the first page
  bool get isFirstPage => page == 1;

  /// Empty response
  static const empty = PaginatedReports(results: []);

  @override
  List<Object?> get props => [
    results,
    count,
    total,
    page,
    pageSize,
    totalPages,
  ];
}
