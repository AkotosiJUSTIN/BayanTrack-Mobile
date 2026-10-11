import 'dart:io';

import 'package:bayantrack_mobile/features/app_updates/domain/app_version.dart';

void main() {
  final match = RegExp(
    r'^version: ([0-9]+\.[0-9]+\.[0-9]+)\+[0-9]+\s*$',
    multiLine: true,
  ).firstMatch(File('pubspec.yaml').readAsStringSync());
  if (match == null) throw const FormatException('Missing canonical version.');
  // shortcut: second-level identities; serialize builds starting within one second.
  final build = DateTime.now().toUtc().difference(DateTime.utc(2020)).inSeconds;
  final version = AppVersion(match[1]!, build);
  stdout.writeln('BUILD_NAME=${version.name}');
  stdout.writeln('BUILD_NUMBER=${version.build}');
  stdout.writeln('RELEASE_TAG=v$version');
}
