import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pubspec version matches the latest changelog version', () {
    final pubspecLines = File('pubspec.yaml').readAsLinesSync();
    final changelogLines = File('CHANGELOG.md').readAsLinesSync();

    final pubspecVersion = pubspecLines
        .firstWhere((line) => line.startsWith('version:'))
        .substring('version:'.length)
        .trim()
        .split('+')
        .first;
    final versionHeading = changelogLines.firstWhere(
      (line) => line.startsWith('## [') && line.contains(']'),
    );
    final changelogVersion = versionHeading.substring(
      '## ['.length,
      versionHeading.indexOf(']'),
    );

    expect(changelogVersion, pubspecVersion);
  });
}
