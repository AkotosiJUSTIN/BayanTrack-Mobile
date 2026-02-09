import 'package:equatable/equatable.dart';

/// A single option item for KYC form dropdowns.
class KycOptionItem extends Equatable {
  final String value;
  final String label;

  const KycOptionItem({required this.value, required this.label});

  @override
  List<Object?> get props => [value, label];
}

/// Domain entity for KYC form configuration options.
///
/// Contains available options for ID types, sex, and civil status dropdowns.
class KycFormOptions extends Equatable {
  final List<KycOptionItem> idTypes;
  final List<KycOptionItem> sexOptions;
  final List<KycOptionItem> civilStatuses;

  const KycFormOptions({
    this.idTypes = const [],
    this.sexOptions = const [],
    this.civilStatuses = const [],
  });

  /// Empty form options.
  static const empty = KycFormOptions();

  @override
  List<Object?> get props => [idTypes, sexOptions, civilStatuses];
}
