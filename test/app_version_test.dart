// حارس الإصدار الموحد: رقم الإصدار في الفوتر يجب أن يطابق
// versionName في pubspec.yaml — فإن رُفع الإصدار ونُسي الثابت
// فشل هذا الاختبار فوراً.
import 'dart:io';

import 'package:animals/app_version.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('appVersion matches the versionName in pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(
      r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+',
      multiLine: true,
    ).firstMatch(pubspec);
    expect(
      match,
      isNotNull,
      reason: 'pubspec.yaml must declare version: X.Y.Z+N',
    );
    expect(appVersion, match!.group(1));
  });
}
