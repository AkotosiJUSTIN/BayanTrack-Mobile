import 'dart:convert';
import 'package:flutter/services.dart';

/// The v1 shared emergency vocabulary, supplied by form options or bundled offline.
class EmergencyCatalog {
  const EmergencyCatalog(this.types);
  final List<EmergencyType> types;

  static Future<EmergencyCatalog> bundled() async => EmergencyCatalog.fromJson(
    jsonDecode(
          await rootBundle.loadString(
            'assets/emergency_catalog.json',
            cache: false,
          ),
        )
        as Map<String, dynamic>,
  );

  factory EmergencyCatalog.fromJson(Map<String, dynamic> json) {
    if (json['version'] != 1 || json['version'] is! int) {
      throw const FormatException('Unsupported emergency catalog');
    }
    final types = (json['types'] as List)
        .map((value) {
          final item = Map<String, dynamic>.from(value as Map);
          return EmergencyType(
            item['key'] as String,
            item['label'] as String,
            item['label_fil'] as String,
            item['category_key'] as String?,
            (item['situations'] as List)
                .map((value) {
                  final situation = Map<String, dynamic>.from(value as Map);
                  return EmergencySituation(
                    situation['key'] as String,
                    situation['label'] as String,
                    situation['label_fil'] as String,
                  );
                })
                .toList(growable: false),
          );
        })
        .toList(growable: false);
    if (types.isEmpty || types.any((type) => type.situations.isEmpty)) {
      throw const FormatException('Empty emergency catalog');
    }
    return EmergencyCatalog(types);
  }
}

class EmergencyType {
  const EmergencyType(
    this.key,
    this.label,
    this.labelFil,
    this.categoryKey,
    this.situations,
  );
  final String key;
  final String label;
  final String labelFil;
  final String? categoryKey;
  final List<EmergencySituation> situations;
  String localized(bool filipino) => filipino ? labelFil : label;
}

class EmergencySituation {
  const EmergencySituation(this.key, this.label, this.labelFil);
  final String key;
  final String label;
  final String labelFil;
  String localized(bool filipino) => filipino ? labelFil : label;
}

Map<String, dynamic> emergencyContext({
  required EmergencyType type,
  required EmergencySituation situation,
  required String danger,
  String notes = '',
}) => {
  'version': 1,
  'type_key': type.key,
  'situation_key': situation.key,
  'immediate_danger': danger,
  if (notes.trim().isNotEmpty) 'notes': notes.trim(),
};

String emergencySummary(
  EmergencyType type,
  EmergencySituation situation,
  String danger,
  String notes,
) {
  final dangerLabel = switch (danger) {
    'yes' => 'Yes',
    'no' => 'No',
    _ => 'Not sure',
  };
  final summary =
      '${type.label}: ${situation.label}.\nInjury or immediate danger: $dangerLabel.';
  return notes.trim().isEmpty ? summary : '$summary\nNotes: ${notes.trim()}';
}

const emergencyDetailsPrefix = '\n\nAdditional details:\n';
int emergencyDetailsRemaining(String original) =>
    (500 - original.runes.length - emergencyDetailsPrefix.runes.length).clamp(
      0,
      500,
    );
String appendEmergencyDetails(String original, String details) =>
    '$original$emergencyDetailsPrefix${details.trim()}';
