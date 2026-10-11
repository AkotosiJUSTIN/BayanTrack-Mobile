import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/providers/theme_provider.dart';
import '../data/app_update_repository.dart';
import '../domain/app_version.dart';

const _cachedReleaseKey = 'app_update_latest_release_v1';

final appUpdateRepositoryProvider = Provider<AppUpdateRepository>((ref) {
  // GitHub must never receive the application's authentication interceptor.
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      followRedirects: false,
      headers: {
        'Accept': 'application/vnd.github+json',
        'User-Agent': 'BayanTrack-Mobile',
      },
    ),
  );
  ref.onDispose(() => dio.close(force: true));
  return AppUpdateRepository(dio);
});

final openAppReleasesProvider = Provider<Future<bool> Function()>((ref) {
  return () => launchUrl(
    Uri.parse(appReleasesUrl),
    mode: LaunchMode.externalApplication,
  );
});

class AppUpdateState {
  const AppUpdateState({
    this.installed,
    this.latest,
    this.checking = false,
    this.checked = false,
    this.failed = false,
  });

  final AppVersion? installed;
  final AppVersion? latest;
  final bool checking;
  final bool checked;
  final bool failed;

  bool get requiresUpdate =>
      installed != null && latest != null && installed!.compareTo(latest!) < 0;
}

final appUpdateProvider = NotifierProvider<AppUpdateController, AppUpdateState>(
  AppUpdateController.new,
);

class AppUpdateController extends Notifier<AppUpdateState> {
  Future<void>? _inFlight;

  @override
  AppUpdateState build() {
    final cached = ref.watch(sharedPrefsProvider).getString(_cachedReleaseKey);
    AppVersion? latest;
    if (cached != null) {
      try {
        latest = AppVersion.parse(cached);
      } on FormatException {
        // A corrupt local cache cannot establish an update requirement.
      }
    }
    return AppUpdateState(latest: latest);
  }

  Future<void> check() => _inFlight ??= _check().whenComplete(() {
    _inFlight = null;
  });

  Future<void> _check() async {
    var installed = state.installed;
    var latest = state.latest;
    state = AppUpdateState(
      installed: installed,
      latest: latest,
      checking: true,
    );
    try {
      final repository = ref.read(appUpdateRepositoryProvider);
      installed ??= await repository.installedVersion();
      if (!ref.mounted) return;
      state = AppUpdateState(
        installed: installed,
        latest: latest,
        checking: true,
      );
      final published = await repository.latestVersion();
      if (!ref.mounted) return;
      if (latest == null || published.compareTo(latest) > 0) {
        latest = published;
      }
      state = AppUpdateState(
        installed: installed,
        latest: latest,
        checked: true,
      );
      final saved = await ref
          .read(sharedPrefsProvider)
          .setString(_cachedReleaseKey, latest.toString());
      if (!saved) throw StateError('Release cache could not be saved.');
    } catch (_) {
      if (!ref.mounted) return;
      state = AppUpdateState(
        installed: installed,
        latest: latest,
        failed: true,
      );
    }
  }
}
