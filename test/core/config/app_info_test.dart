import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:qaddy/core/config/app_info.dart';

void main() {
  test('the version Settings shows is the one in pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version:\s*(\S+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1);

    expect(version, '$appVersion+$appBuild');
    expect(appVersionLabel, '$appVersion ($appBuild)');
  });
}
