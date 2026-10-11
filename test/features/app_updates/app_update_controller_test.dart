import 'dart:async';

import 'package:bayantrack_mobile/core/providers/theme_provider.dart';
import 'package:bayantrack_mobile/features/app_updates/data/app_update_repository.dart';
import 'package:bayantrack_mobile/features/app_updates/domain/app_version.dart';
import 'package:bayantrack_mobile/features/app_updates/presentation/app_update_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_update_fakes.dart';

Future<ProviderContainer> containerFor(
  FakeAppUpdateRepository repository, {
  String? cached,
}) async {
  SharedPreferences.setMockInitialValues({
    'app_update_latest_release_v1': ?cached,
  });
  final preferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPrefsProvider.overrideWithValue(preferences),
      appUpdateRepositoryProvider.overrideWithValue(repository),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('compares semantic components numerically, then Android builds', () {
    expect(
      AppVersion('1.10.0', 1).compareTo(AppVersion('1.9.0', 999)),
      greaterThan(0),
    );
    expect(
      AppVersion('1.0.1', 1).compareTo(AppVersion('1.0.0', 999)),
      greaterThan(0),
    );
    expect(
      AppVersion('1.0.0', 1004).compareTo(AppVersion('1.0.0', 1005)),
      lessThan(0),
    );
    expect(AppVersion.parse('1.0.0+1004').toString(), '1.0.0+1004');
    for (final invalid in ['1.0', 'v1.0.0+3', '1.0.0+0', '01.0.0+3']) {
      expect(() => AppVersion.parse(invalid), throwsFormatException);
    }
    expect(() => AppVersion('1.0.0', 2100000001), throwsFormatException);
  });

  test(
    'release parser includes prereleases, skips drafts and partial APKs',
    () {
      final version = AppUpdateRepository.latestPublishedVersion([
        apkRelease('v1.0.0+1008', draft: true),
        apkRelease('v1.0.0+1007', assetState: 'new'),
        apkRelease('v1.0.0+1006', size: 0),
        apkRelease('v1.0.0+1005', prerelease: true),
        apkRelease('v1.0.0+1004'),
      ]);
      expect(version.toString(), '1.0.0+1005');
    },
  );

  test('release ordering cannot downgrade the selected version', () {
    final version = AppUpdateRepository.latestPublishedVersion([
      apkRelease('v1.0.0+2'),
      apkRelease('v1.1.0+4'),
      apkRelease('v1.0.0+10'),
    ]);
    expect(version.toString(), '1.1.0+4');
  });

  test('legacy published Android titles remain compatible', () {
    for (final title in [
      'BayanTrack Android build 1004',
      'BayanTrack Android \u2014 Beta Build 1004',
    ]) {
      final version = AppUpdateRepository.latestPublishedVersion([
        apkRelease('dev-38115445431-1', name: title),
      ]);
      expect(version.toString(), '1.0.0+1004');
    }
  });

  test('unknown, empty, or malformed releases never prove app is current', () {
    for (final data in [
      null,
      {},
      [],
      [apkRelease('not-a-version')],
      [apkRelease('v1.0.0')],
      [apkRelease('v1.0.0+0')],
      [apkRelease('v1.0.0+2', draft: true)],
    ]) {
      expect(
        () => AppUpdateRepository.latestPublishedVersion(data),
        throwsFormatException,
      );
    }
  });

  test(
    'repository reads the actual installed package and public release API',
    () async {
      PackageInfo.setMockInitialValues(
        appName: 'BayanTrack',
        packageName: 'com.example.bayantrack_mobile',
        version: '1.0.0',
        buildNumber: '1004',
        buildSignature: '',
      );
      final dio = Dio();
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            expect(options.uri.host, 'api.github.com');
            expect(options.queryParameters, {'per_page': 100});
            expect(options.headers.containsKey('Authorization'), isFalse);
            handler.resolve(
              Response(
                requestOptions: options,
                data: [apkRelease('v1.0.0+1005')],
                statusCode: 200,
              ),
            );
          },
        ),
      );
      final repository = AppUpdateRepository(dio);
      expect((await repository.installedVersion()).toString(), '1.0.0+1004');
      expect((await repository.latestVersion()).toString(), '1.0.0+1005');
    },
  );

  test('newer release persists the requirement across app restarts', () async {
    final repository = FakeAppUpdateRepository()
      ..latest = AppVersion('1.0.0', 1005);
    final container = await containerFor(repository);
    await container.read(appUpdateProvider.notifier).check();
    expect(container.read(appUpdateProvider).requiresUpdate, isTrue);
    final preferences = container.read(sharedPrefsProvider);
    expect(preferences.getString('app_update_latest_release_v1'), '1.0.0+1005');

    final restarted = ProviderContainer(
      overrides: [
        sharedPrefsProvider.overrideWithValue(preferences),
        appUpdateRepositoryProvider.overrideWithValue(
          repository..unavailable = true,
        ),
      ],
    );
    addTearDown(restarted.dispose);
    await restarted.read(appUpdateProvider.notifier).check();
    expect(restarted.read(appUpdateProvider).requiresUpdate, isTrue);
    expect(restarted.read(appUpdateProvider).failed, isTrue);
  });

  test('first-check failure is unknown, not a false current status', () async {
    final container = await containerFor(
      FakeAppUpdateRepository()..unavailable = true,
    );
    await container.read(appUpdateProvider.notifier).check();
    final state = container.read(appUpdateProvider);
    expect(state.failed, isTrue);
    expect(state.checked, isFalse);
    expect(state.requiresUpdate, isFalse);
    expect(state.checking, isFalse);
  });

  test(
    'cached requirement stays active during a delayed retry and rollback',
    () async {
      final pending = Completer<AppVersion>();
      final repository = FakeAppUpdateRepository()..nextLatest = pending.future;
      final container = await containerFor(repository, cached: '1.0.0+1005');
      final checking = container.read(appUpdateProvider.notifier).check();
      await Future<void>.delayed(Duration.zero);
      expect(container.read(appUpdateProvider).checking, isTrue);
      expect(container.read(appUpdateProvider).requiresUpdate, isTrue);
      pending.complete(AppVersion('1.0.0', 1004));
      await checking;
      expect(container.read(appUpdateProvider).requiresUpdate, isTrue);
    },
  );

  test(
    'equal or newer installed version passes without a downgrade prompt',
    () async {
      for (final installed in [1004, 1005]) {
        final container = await containerFor(
          FakeAppUpdateRepository()..installed = AppVersion('1.0.0', installed),
        );
        await container.read(appUpdateProvider.notifier).check();
        expect(container.read(appUpdateProvider).requiresUpdate, isFalse);
        expect(container.read(appUpdateProvider).checked, isTrue);
        expect(container.read(appUpdateProvider).failed, isFalse);
      }
    },
  );

  test(
    'corrupt cache can recover and concurrent checks make one request',
    () async {
      final pending = Completer<AppVersion>();
      final repository = FakeAppUpdateRepository()..nextLatest = pending.future;
      final container = await containerFor(repository, cached: 'corrupt');
      final controller = container.read(appUpdateProvider.notifier);
      final checks = [controller.check(), controller.check()];
      await Future<void>.delayed(Duration.zero);
      expect(repository.checks, 1);
      pending.complete(AppVersion('1.0.0', 1004));
      await Future.wait(checks);
      expect(container.read(appUpdateProvider).checked, isTrue);
    },
  );
}
