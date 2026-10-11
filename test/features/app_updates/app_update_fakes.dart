import 'package:bayantrack_mobile/features/app_updates/data/app_update_repository.dart';
import 'package:bayantrack_mobile/features/app_updates/domain/app_version.dart';
import 'package:dio/dio.dart';

class FakeAppUpdateRepository extends AppUpdateRepository {
  FakeAppUpdateRepository() : super(Dio());

  AppVersion installed = AppVersion('1.0.0', 1004);
  AppVersion latest = AppVersion('1.0.0', 1004);
  Future<AppVersion>? nextLatest;
  bool unavailable = false;
  int checks = 0;

  @override
  Future<AppVersion> installedVersion() async => installed;

  @override
  Future<AppVersion> latestVersion() async {
    checks++;
    if (unavailable) throw StateError('Unavailable');
    return nextLatest ?? latest;
  }
}

Map<String, Object?> apkRelease(
  String tag, {
  String name = 'BayanTrack Android',
  bool draft = false,
  bool prerelease = false,
  String assetState = 'uploaded',
  int size = 100,
}) => {
  'tag_name': tag,
  'name': name,
  'draft': draft,
  'prerelease': prerelease,
  'assets': [
    {'name': 'bayantrack.apk', 'state': assetState, 'size': size},
  ],
};
