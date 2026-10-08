import 'dart:io';

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
    expect(workflow, contains('1000 + GITHUB_RUN_NUMBER'));
  });

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

  test('release signing cannot fall back to debug credentials', () {
    expect(gradle, contains('signingConfigs.getByName("release")'));
    expect(gradle, isNot(contains('signingConfigs.getByName("debug")')));
    expect(gradle, contains('gradle.taskGraph.whenReady'));
    expect(gradle, contains('it.name.endsWith("Release")'));
    expect(gradle, contains('signing.storeFile?.isFile == true'));
    expect(gradle, contains('"proguard-rules.pro"'));
  });
}
