// اختبارات النسخ الاحتياطي في ملف فعلي — المرحلة الثانية 2.8.
import 'dart:convert';
import 'dart:io';

import 'package:animals/services/backup_service.dart';
import 'package:animals/services/progress_store.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tempDir = await Directory.systemTemp.createTemp('fares-backup-test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall call) async {
            if (call.method == 'getApplicationDocumentsDirectory') {
              return tempDir.path;
            }
            return null;
          },
        );
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  test('حفظ ملف وإدراجه في القائمة ثم استعادته', () async {
    await ProgressStore.addStars(7);
    final file = await BackupService.saveToFile();
    expect(file.name, startsWith('fares-animals-backup-'));
    expect(file.size, greaterThan(0));
    final content = jsonDecode(await File(file.path).readAsString()) as Map;
    expect(content['format'], BackupService.formatId);
    expect(content['version'], BackupService.formatVersion);
    final list = await BackupService.listBackups();
    expect(list.map((b) => b.path), contains(file.path));

    // مسح التقدم ثم الاستعادة من الملف.
    SharedPreferences.setMockInitialValues(<String, Object>{});
    expect(await ProgressStore.stars(), 0);
    final result = await BackupService.restoreFromFile(file.path);
    expect(result.ok, isTrue);
    expect(await ProgressStore.stars(), 7);
  });

  test('ملف تالف يُرفض دون مساس بالبيانات', () async {
    await ProgressStore.addStars(3);
    final bad = File('${tempDir.path}/backups/bad.json')
      ..createSync(recursive: true)
      ..writeAsStringSync('هذا ليس JSON');
    final result = await BackupService.restoreFromFile(bad.path);
    expect(result.ok, isFalse);
    expect(await ProgressStore.stars(), 3);
  });

  test('إصدار غير متوافق يُرفض دون مساس بالبيانات', () async {
    await ProgressStore.addStars(3);
    final wrong = File('${tempDir.path}/backups/wrong.json')
      ..createSync(recursive: true)
      ..writeAsStringSync(
        jsonEncode({
          'format': BackupService.formatId,
          'version': 999,
          'data': {'c_فارس_stars_total': 100},
        }),
      );
    final result = await BackupService.restoreFromFile(wrong.path);
    expect(result.ok, isFalse);
    expect(await ProgressStore.stars(), 3);
  });

  test('حذف ملف نسخة يزيله من القائمة', () async {
    final file = await BackupService.saveToFile();
    expect(await BackupService.deleteBackup(file.path), isTrue);
    expect(await BackupService.listBackups(), isEmpty);
    expect(await File(file.path).exists(), isFalse);
  });

  test('استعادة ملف غير موجود تفشل برسالة واضحة', () async {
    final result = await BackupService.restoreFromFile(
      '${tempDir.path}/backups/nope.json',
    );
    expect(result.ok, isFalse);
    expect(result.error, isNotNull);
  });
}
