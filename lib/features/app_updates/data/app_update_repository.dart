import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../domain/app_version.dart';

const appReleasesUrl =
    'https://github.com/DvineConqueror/BayanTrack-Mobile/releases';
const _releasesApi =
    'https://api.github.com/repos/DvineConqueror/BayanTrack-Mobile/releases';

class AppUpdateRepository {
  AppUpdateRepository(this._dio);

  final Dio _dio;

  Future<AppVersion> installedVersion() async {
    final info = await PackageInfo.fromPlatform();
    return AppVersion(info.version, int.parse(info.buildNumber));
  }

  Future<AppVersion> latestVersion() async {
    final response = await _dio.get<List<dynamic>>(
      _releasesApi,
      queryParameters: {'per_page': 100},
    );
    return latestPublishedVersion(response.data);
  }

  static AppVersion latestPublishedVersion(Object? data) {
    if (data is! List) {
      throw const FormatException('Release list unavailable.');
    }
    AppVersion? latest;
    for (final entry in data) {
      if (entry is! Map || entry['draft'] != false) continue;
      final assets = entry['assets'];
      if (assets is! List ||
          !assets.any(
            (asset) =>
                asset is Map &&
                asset['name'] == 'bayantrack.apk' &&
                asset['state'] == 'uploaded' &&
                asset['size'] is int &&
                (asset['size'] as int) > 0,
          )) {
        continue;
      }
      final tag = entry['tag_name'];
      AppVersion version;
      if (tag is String && tag.startsWith('v')) {
        version = AppVersion.parse(tag.substring(1));
      } else {
        // Compatibility with APKs published before canonical version tags.
        final name = entry['name'];
        final legacy = name is String
            ? RegExp(
                r'^BayanTrack Android(?: build | \u2014 Beta Build )(\d+)$',
              ).firstMatch(name)
            : null;
        if (tag is! String ||
            !RegExp(r'^dev-\d+-\d+$').hasMatch(tag) ||
            legacy == null) {
          throw const FormatException('Release version unavailable.');
        }
        version = AppVersion('1.0.0', int.parse(legacy[1]!));
      }
      if (latest == null || version.compareTo(latest) > 0) latest = version;
    }
    if (latest == null) {
      throw const FormatException('No published APK available.');
    }
    return latest;
  }
}
