import 'dart:io';

import 'package:bayantrack_mobile/features/app_updates/domain/app_version.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final workflow = File(
    '.github/workflows/android-release.yml',
  ).readAsStringSync();
  final gradle = File('android/app/build.gradle.kts').readAsStringSync();

  test('APK publishing is restricted to the trusted fork main branch', () {
    expect(workflow, contains('branches: [main]'));
    expect(workflow, contains('workflow_dispatch:'));
    expect(workflow, contains("'DvineConqueror/BayanTrack-Mobile'"));
    expect(workflow, contains("'refs/heads/main'"));
    expect(workflow, isNot(contains('pull_request')));
    expect(workflow, contains('persist-credentials: false'));
  });

  test('analysis and tests must pass before building and publishing', () {
    final analyze = workflow.indexOf('run: flutter analyze');
    final test = workflow.indexOf('run: flutter test');
    final build = workflow.indexOf('flutter build apk --release');
    final publish = workflow.indexOf('gh release create');
    expect(analyze, greaterThan(-1));
    expect(test, greaterThan(analyze));
    expect(build, greaterThan(test));
    expect(publish, greaterThan(build));
    expect(workflow, isNot(contains('continue-on-error')));
  });

  test('release APK targets the deployed API and has a checksum', () {
    expect(
      workflow,
      contains('BAYANTRACK_API_BASE_URL=https://api.bayantrack.app/api'),
    );
    expect(
      workflow,
      contains('BAYANTRACK_MEDIA_BASE_URL=https://api.bayantrack.app'),
    );
    expect(workflow, contains('sha256sum bayantrack.apk'));
    expect(workflow, contains('--target "\$GITHUB_SHA" --prerelease'));
    expect(workflow, contains('dart tool/release_version.dart'));
    expect(workflow, contains('--build-name="\$BUILD_NAME"'));
    expect(workflow, contains('--build-number="\$BUILD_NUMBER"'));
    expect(workflow, contains('gh release create "\$RELEASE_TAG"'));
    expect(gradle, contains('flutter.versionCode == 1'));
    expect(gradle, contains('System.currentTimeMillis() / 1000 - 1577836800'));
  });

  test(
    'release metadata uses the canonical pubspec name and current build epoch',
    () {
      final started = DateTime.now().toUtc();
      final cache = File(
        Platform.resolvedExecutable,
      ).parent.parent.parent.parent;
      final dart =
          '${cache.path}/dart-sdk/bin/dart${Platform.isWindows ? '.exe' : ''}';
      final result = Process.runSync(dart, ['tool/release_version.dart']);
      expect(result.exitCode, 0, reason: result.stderr.toString());
      final values = {
        for (final line in result.stdout.toString().trim().split('\n'))
          line.trim().split('=')[0]: line.trim().split('=')[1],
      };
      final identity = AppVersion.parse(
        '${values['BUILD_NAME']}+${values['BUILD_NUMBER']}',
      );
      expect(
        File('pubspec.yaml').readAsStringSync(),
        contains('version: ${identity.name}+'),
      );
      expect(values['RELEASE_TAG'], 'v$identity');
      final epoch = DateTime.utc(2020);
      expect(
        identity.build,
        inInclusiveRange(
          started.difference(epoch).inSeconds,
          DateTime.now().toUtc().difference(epoch).inSeconds,
        ),
      );
      expect(identity.build, greaterThan(1004));
      sleep(const Duration(seconds: 1));
      final retry = Process.runSync(dart, ['tool/release_version.dart']);
      expect(retry.exitCode, 0, reason: retry.stderr.toString());
      final retryTag = retry.stdout.toString().trim().split('\n').last;
      final retryVersion = AppVersion.parse(
        retryTag.substring('RELEASE_TAG=v'.length),
      );
      expect(retryVersion.build, greaterThan(identity.build));
    },
  );
  test('CI signing secrets match Gradle inputs and have cleanup', () {
    for (final name in [
      'ANDROID_KEYSTORE_PASSWORD',
      'ANDROID_KEY_ALIAS',
      'ANDROID_KEY_PASSWORD',
    ]) {
      expect(workflow, contains('secrets.$name'));
      expect(gradle, contains('"$name"'));
    }
    expect(workflow, contains('secrets.ANDROID_KEYSTORE_BASE64'));
    expect(gradle, contains('"ANDROID_KEYSTORE_PATH"'));
    expect(workflow, contains('if: always()'));
    expect(workflow, contains('umask 077'));
  });

  test('cold release builds have bounded time and visible progress', () {
    expect(workflow, contains('timeout-minutes: 90'));
    expect(
      workflow,
      contains('- name: Build signed APK\n        timeout-minutes: 60'),
    );
    expect(workflow, contains('flutter build apk --release --no-pub'));
    expect(workflow, contains('while sleep 60; do'));
    expect(workflow, contains('APK build still running:'));
    expect(
      workflow,
      contains('trap \'kill "\$heartbeat_pid" 2>/dev/null || true\' EXIT'),
    );
  });

  test('dependency cache excludes signing and project build files', () {
    final cache = workflow.substring(
      workflow.indexOf('- name: Cache build dependencies'),
      workflow.indexOf('- name: Install dependencies'),
    );
    expect(cache, contains('~/.pub-cache'));
    expect(cache, contains('~/.gradle/caches/modules-2'));
    expect(cache, contains('~/.gradle/wrapper'));
    expect(cache, contains("hashFiles('pubspec.lock'"));
    expect(cache, isNot(contains('runner.temp')));
    expect(cache, isNot(contains('secrets.')));
    expect(cache, isNot(contains('~/.gradle/caches\n')));
    expect(cache, isNot(contains('key.properties')));
    expect(cache, isNot(contains('.jks')));
  });

  test('release signing cannot fall back to debug credentials', () {
    expect(gradle, contains('signingConfigs.getByName("release")'));
    expect(gradle, isNot(contains('signingConfigs.getByName("debug")')));
    expect(gradle, contains('gradle.taskGraph.whenReady'));
    expect(gradle, contains('it.name.endsWith("Release")'));
    expect(gradle, contains('signing.storeFile?.isFile == true'));
    expect(gradle, contains('"proguard-rules.pro"'));
  });
}
