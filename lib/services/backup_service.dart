// تصدير واستعادة تقدم الأطفال (النجوم والتعلّم والأوسمة والإعدادات).
// النسخة نص JSON واحد ينسخه الوالد ويحفظه في مكان آمن،
// ويعيد لصقه هنا لاستعادة التقدم بعد حذف التطبيق أو على جهاز آخر.
// يعمل دون إنترنت ولا يرسل أي بيانات لأي خادم.
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class BackupRestoreResult {
  const BackupRestoreResult._({
    required this.ok,
    this.restored = 0,
    this.error,
  });

  factory BackupRestoreResult.success(int restored) =>
      BackupRestoreResult._(ok: true, restored: restored);

  factory BackupRestoreResult.failure(String error) =>
      BackupRestoreResult._(ok: false, error: error);

  final bool ok;

  /// عدد القيم التي استُعيدت فعلاً.
  final int restored;

  /// رسالة الخطأ عند الفشل (عربية مبسطة).
  final String? error;
}

class BackupService {
  static const formatId = 'fares-animals-backup';
  static const formatVersion = 1;

  /// يصدّر كل بيانات التطبيق المحفوظة (تقدم كل الأطفال والإعدادات)
  /// في نص JSON واحد.
  static Future<String> exportJson() async {
    final p = await SharedPreferences.getInstance();
    final data = <String, Object?>{};
    for (final k in p.getKeys()) {
      final v = p.get(k);
      if (v is int ||
          v is double ||
          v is bool ||
          v is String ||
          v is List<String>) {
        data[k] = v;
      }
    }
    return jsonEncode({
      'format': formatId,
      'version': formatVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'data': data,
    });
  }

  /// يستعيد نسخة احتياطية من نص JSON.
  /// يكتب القيم الموجودة في النسخة فوق القيم الحالية،
  /// ويترك أي قيمة غير موجودة في النسخة كما هي،
  /// والقيم التراكمية (النجوم وأفضل نتائج الماس والمراحل المفتوحة
  /// والأوسمة) لا تتراجع أبداً عن التقدم الحالي (دمج آمن، بلا حذف).
  static Future<BackupRestoreResult> importJson(String jsonText) async {
    final trimmed = jsonText.trim();
    if (trimmed.isEmpty) {
      return BackupRestoreResult.failure('الصق نص النسخة الاحتياطية أولاً.');
    }
    Object? parsed;
    try {
      parsed = jsonDecode(trimmed);
    } on FormatException {
      return BackupRestoreResult.failure(
        'النص الملصوق ليس نسخة احتياطية صالحة. تأكد من نسخ النص كاملاً.',
      );
    }
    if (parsed is! Map ||
        parsed['format'] != formatId ||
        parsed['version'] != formatVersion ||
        parsed['data'] is! Map) {
      return BackupRestoreResult.failure(
        'هذه ليست نسخة احتياطية من تطبيق «فارس والحيوانات».',
      );
    }
    final data = parsed['data'] as Map;
    final p = await SharedPreferences.getInstance();
    var restored = 0;
    for (final entry in data.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      // دمج آمن: القيم التراكمية لا تتراجع أبداً عن التقدم الحالي —
      // استعادة نسخة قديمة فوق تقدّم أحدث لا تمسح ما كسبه الطفل بعدها.
      if (value is int && key.endsWith('stars_total')) {
        final current = p.getInt(key) ?? 0;
        await p.setInt(key, value > current ? value : current);
      } else if (value is int &&
          (key.contains('diamond_best_') || key.endsWith('diamond_unlocked'))) {
        final current = p.getInt(key) ?? 0;
        await p.setInt(key, value > current ? value : current);
      } else if (value is List && key.endsWith('badges_unlocked')) {
        final current = (p.getStringList(key) ?? <String>[]).toSet()
          ..addAll(value.map((e) => e.toString()));
        await p.setStringList(key, current.toList());
      } else if (value is int) {
        await p.setInt(key, value);
      } else if (value is double) {
        await p.setDouble(key, value);
      } else if (value is bool) {
        await p.setBool(key, value);
      } else if (value is String) {
        await p.setString(key, value);
      } else if (value is List) {
        await p.setStringList(key, value.map((e) => e.toString()).toList());
      } else {
        continue;
      }
      restored++;
    }
    if (restored == 0) {
      return BackupRestoreResult.failure(
        'النسخة فارغة: لا توجد قيم لاستعادتها.',
      );
    }
    return BackupRestoreResult.success(restored);
  }
}
