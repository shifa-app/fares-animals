// تصدير واستعادة تقدم الأطفال (النجوم والتعلّم والأوسمة والإعدادات).
// النسخة نص JSON واحد ينسخه الوالد ويحفظه في مكان آمن،
// ويعيد لصقه هنا لاستعادة التقدم بعد حذف التطبيق أو على جهاز آخر.
// يعمل دون إنترنت ولا يرسل أي بيانات لأي خادم.
// المرحلة الثانية 2.8: النسخة تُحفظ أيضاً في ملف JSON فعلي داخل
// التطبيق (قابل للحفظ والمشاركة)، وتُستعاد منه بعد تحقق كامل
// من السلامة وتوافق الإصدار قبل استبدال أي بيانات.
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ملف نسخة احتياطية محفوظ في مجلد النسخ داخل التطبيق.
class BackupFile {
  const BackupFile({
    required this.path,
    required this.name,
    required this.size,
    required this.modified,
  });

  final String path;
  final String name;
  final int size;
  final DateTime modified;

  /// الاسم المختصر للعرض (التاريخ والوقت فقط).
  String get label {
    final short = name
        .replaceFirst('fares-animals-backup-', '')
        .replaceFirst('.json', '')
        .replaceAll('T', ' ')
        .replaceAll('-', '/');
    return short;
  }

  String get sizeLabel => '${(size / 1024).toStringAsFixed(1)} ك.ب';
}

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

  // ---------------- النسخ الاحتياطي في ملف فعلي (2.8) ----------------

  static Future<Directory> _backupDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/backups');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  static Future<BackupFile> _toBackupFile(File file) async {
    final stat = await file.stat();
    final name = file.path.split('/').last;
    return BackupFile(
      path: file.path,
      name: name,
      size: stat.size,
      modified: stat.modified,
    );
  }

  /// يحفظ نسخة احتياطية في ملف JSON فعلي داخل التطبيق.
  static Future<BackupFile> saveToFile() async {
    final json = await exportJson();
    final dir = await _backupDir();
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-');
    final file = File('${dir.path}/fares-animals-backup-$stamp.json');
    await file.writeAsString(json);
    return _toBackupFile(file);
  }

  /// قائمة ملفات النسخ المحفوظة، الأحدث أولاً.
  static Future<List<BackupFile>> listBackups() async {
    final dir = await _backupDir();
    final files = <File>[];
    await for (final e in dir.list()) {
      if (e is File && e.path.endsWith('.json')) files.add(e);
    }
    files.sort((a, b) => b.path.compareTo(a.path));
    final out = <BackupFile>[];
    for (final f in files) {
      out.add(await _toBackupFile(f));
    }
    return out;
  }

  /// يستعيد نسخة من ملف. التحقق من السلامة والإصدار يتم داخل
  /// importJson قبل كتابة أي قيمة — فملف تالف أو من إصدار آخر
  /// أو من تطبيق آخر يُرفض دون مساس بالبيانات الحالية.
  static Future<BackupRestoreResult> restoreFromFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      return BackupRestoreResult.failure('ملف النسخة غير موجود.');
    }
    String text;
    try {
      text = await file.readAsString();
    } catch (_) {
      return BackupRestoreResult.failure('تعذّر قراءة ملف النسخة.');
    }
    return importJson(text);
  }

  /// يحذف ملف نسخة احتياطية. يرجع false عند الفشل.
  static Future<bool> deleteBackup(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
      return true;
    } catch (_) {
      return false;
    }
  }
}
