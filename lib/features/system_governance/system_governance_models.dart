class LegalTranslation {
  const LegalTranslation({
    required this.title,
    required this.terms,
    required this.privacy,
  });

  final String title;
  final String terms;
  final String privacy;

  String get content => '$terms\n\n$privacy';
}

class PublishedTerms {
  const PublishedTerms({
    required this.versionId,
    required this.checksum,
    required this.translations,
  });

  final String versionId;
  final String checksum;
  final Map<String, LegalTranslation> translations;

  factory PublishedTerms.fromJson(Map<String, dynamic> json) {
    final version = json['version_id'];
    final checksum = json['checksum'];
    final raw = json['translations'];
    if (version is! String ||
        version.isEmpty ||
        checksum is! String ||
        checksum.isEmpty ||
        raw is! Map) {
      throw const FormatException('Published terms are unavailable.');
    }
    final translations = <String, LegalTranslation>{};
    for (final language in ['en', 'fil']) {
      final entry = raw[language];
      if (entry is! Map ||
          entry['title'] is! String ||
          entry['terms'] is! String ||
          entry['privacy'] is! String ||
          (entry['title'] as String).trim().isEmpty ||
          (entry['terms'] as String).trim().isEmpty ||
          (entry['privacy'] as String).trim().isEmpty) {
        throw const FormatException('Published translation is unavailable.');
      }
      translations[language] = LegalTranslation(
        title: entry['title'] as String,
        terms: entry['terms'] as String,
        privacy: entry['privacy'] as String,
      );
    }
    return PublishedTerms(
      versionId: version,
      checksum: checksum,
      translations: Map.unmodifiable(translations),
    );
  }

  LegalTranslation translation(String language) =>
      translations[language] ?? translations['en']!;

  Map<String, String> consent(String language) => {
    'terms_version_id': versionId,
    'terms_checksum': checksum,
    'terms_language': language == 'fil' ? 'fil' : 'en',
  };
}

class SystemGovernanceState {
  const SystemGovernanceState({
    required this.maintenanceEnabled,
    required this.maintenanceMessage,
    required this.termsAcceptanceRequired,
    this.latestTermsVersion,
    this.acceptedTermsVersion,
  });

  final bool maintenanceEnabled;
  final String maintenanceMessage;
  final bool termsAcceptanceRequired;
  final String? latestTermsVersion;
  final String? acceptedTermsVersion;

  factory SystemGovernanceState.fromJson(Map<String, dynamic> json) {
    final maintenance = json['maintenance'];
    if (maintenance is! Map ||
        maintenance['enabled'] is! bool ||
        maintenance['message'] is! String ||
        json['terms_acceptance_required'] is! bool ||
        (json['latest_terms_version'] != null &&
            json['latest_terms_version'] is! String) ||
        (json['accepted_terms_version'] != null &&
            json['accepted_terms_version'] is! String)) {
      throw const FormatException('System status is unavailable.');
    }
    return SystemGovernanceState(
      maintenanceEnabled: maintenance['enabled'] as bool,
      maintenanceMessage: maintenance['message'] as String,
      termsAcceptanceRequired: json['terms_acceptance_required'] == true,
      latestTermsVersion: json['latest_terms_version'] as String?,
      acceptedTermsVersion: json['accepted_terms_version'] as String?,
    );
  }

  bool permitsMutation({required bool isEmergency}) =>
      isEmergency || (!maintenanceEnabled && !termsAcceptanceRequired);
}
