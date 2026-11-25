// مدير التنزيل المسبق — المرحلة الثالثة (2.0-beta):
// ينزّل صور الحيوانات وأصواتها مرة واحدة إلى ذاكرة الهاتف،
// فتعمل الصور والأصوات دون إنترنت. صوت القرآن يبقى بثاً
// (571 ملفاً — خارج نطاق هذا البند).
// - أسماء الملفات من بصمة FNV-1a مستقرة للرابط (لا hashCode Dart
//   غير المستقر عبر التشغيلات) مع لاحقة الرابط الأصلية إن وُجدت.
// - المُجلب قابل للحقن في الاختبارات (بلا شبكة حقيقية).
// - فشل ملف واحد لا يوقف الباقي.
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/animals.dart';

typedef DownloadFetcher = Future<List<int>> Function(Uri uri);

class OfflineStatus {
  final int downloaded;
  final int total;
  final int bytes;
  const OfflineStatus({
    required this.downloaded,
    required this.total,
    required this.bytes,
  });

  bool get isComplete => downloaded >= total && total > 0;

  String get sizeLabel {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} ك.ب';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} م.ب';
  }
}

class DownloadReport {
  final int done;
  final int failed;
  final int total;
  const DownloadReport({
    required this.done,
    required this.failed,
    required this.total,
  });
}

class DownloadManager {
  static const String _prefsKey = 'offline_downloaded';
  static const List<String> _knownExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'mp3',
    'ogg',
    'wav',
    'oga',
  ];

  final DownloadFetcher _fetcher;
  DownloadManager({DownloadFetcher? fetcher})
    : _fetcher = fetcher ?? _defaultFetcher;

  static final DownloadManager instance = DownloadManager();

  final Set<String> _downloaded = {};
  String? _docsPath;
  bool _initialized = false;

  /// كل العناصر القابلة للتنزيل: 100 صورة + أصوات الحيوانات الحقيقية،
  /// بلا تكرار (الكلب والهاسكي يتشاركان ملف dog_barking.ogg نفسه
  /// فينزَّل مرة واحدة — المجموع 173 لا 174).
  static int get totalItems => _items.length;

  static List<(String, String)> get _items {
    final seen = <String>{};
    final out = <(String, String)>[];
    for (final a in animals) {
      if (seen.add(a.imageUrl)) out.add((a.imageUrl, 'img'));
    }
    for (final a in animals.where((a) => a.hasRealSound)) {
      if (seen.add(a.soundUrl)) out.add((a.soundUrl, 'snd'));
    }
    return out;
  }

  static Future<List<int>> _defaultFetcher(Uri uri) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.getUrl(uri).timeout(
        const Duration(seconds: 15),
      );
      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      if (response.statusCode != 200) {
        throw HttpException('HTTP ${response.statusCode} for $uri');
      }
      final bytes = <int>[];
      await for (final chunk in response) {
        bytes.addAll(chunk);
      }
      return bytes;
    } finally {
      client.close(force: true);
    }
  }

  /// بصمة FNV-1a مستقرة للرابط (64 بت).
  static String fileNameFor(String url, String kind) {
    var hash = 0xcbf29ce484222325;
    for (final c in url.codeUnits) {
      hash ^= c;
      hash = (hash * 0x100000001b3) & 0xFFFFFFFFFFFFFFFF;
    }
    return '${hash.toRadixString(16)}.${_extensionOf(url, kind)}';
  }

  static String _extensionOf(String url, String kind) {
    final path = Uri.tryParse(url)?.path ?? '';
    final ext = path.contains('.')
        ? path.split('.').last.toLowerCase()
        : '';
    if (_knownExtensions.contains(ext)) return ext;
    return kind == 'img' ? 'jpg' : 'mp3';
  }

  Future<void> init() async {
    if (_initialized) return;
    final docs = await getApplicationDocumentsDirectory();
    _docsPath = docs.path;
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_prefsKey) ?? [];
    // تقليم الإدخالات التي حُذف ملفها من القرص.
    for (final url in saved) {
      final kind = _kindOf(url);
      if (kind == null) continue;
      final file = File('$_docsPath/offline/$kind/${fileNameFor(url, kind)}');
      if (file.existsSync()) _downloaded.add(url);
    }
    _initialized = true;
  }

  String? _kindOf(String url) {
    for (final (u, kind) in _items) {
      if (u == url) return kind;
    }
    return null;
  }

  bool isDownloaded(String url) => _downloaded.contains(url);

  /// مسار الملف المحلي (متزامن بعد init) أو null إن لم يُنزَّل بعد.
  String? localPathFor(String url, String kind) {
    if (!isDownloaded(url) || _docsPath == null) return null;
    return '$_docsPath/offline/$kind/${fileNameFor(url, kind)}';
  }

  String? localImagePath(String url) => localPathFor(url, 'img');

  String? localSoundPath(String url) => localPathFor(url, 'snd');

  Future<OfflineStatus> status() async {
    await init();
    // قراءة الحجم بمزامنة (existsSync/listSync): القنوات المنصّية
    // تُقدَّم في اختبارات الودجت، أما عمليات dart:io غير المتزامنة
    // فلا تحصل على دورة حدث أثناء pump() فتعلق البطاقة.
    var bytes = 0;
    if (_docsPath != null) {
      final dir = Directory('$_docsPath/offline');
      if (dir.existsSync()) {
        for (final e in dir.listSync(recursive: true)) {
          if (e is File) bytes += e.lengthSync();
        }
      }
    }
    return OfflineStatus(
      downloaded: _downloaded.length,
      total: totalItems,
      bytes: bytes,
    );
  }

  Future<DownloadReport> downloadAll({
    void Function(int done, int total)? onProgress,
  }) async {
    await init();
    final items = _items;
    var done = 0;
    var failed = 0;
    for (final (url, kind) in items) {
      if (isDownloaded(url)) {
        done++;
        onProgress?.call(done, items.length);
        continue;
      }
      try {
        final bytes = await _fetcher(Uri.parse(url));
        // كتابة متزامنة قصداً: عمليات dart:io غير المتزامنة لا تُكمل
        // داخل منطقة الاختبار الوهمية، فتعلق البطاقة؛ والكتابة
        // المتزامنة لملف صغير سريعة، وبين كل ملف وآخر فجوة
        // الشبكة (await _fetcher) فيبقى التطبيق مستجيباً.
        final dir = Directory('$_docsPath/offline/$kind');
        dir.createSync(recursive: true);
        File('${dir.path}/${fileNameFor(url, kind)}')
            .writeAsBytesSync(bytes);
        _downloaded.add(url);
        done++;
      } catch (_) {
        failed++;
      }
      onProgress?.call(done, items.length);
    }
    await _savePrefs();
    return DownloadReport(done: done, failed: failed, total: items.length);
  }

  Future<void> deleteAll() async {
    await init();
    if (_docsPath != null) {
      final dir = Directory('$_docsPath/offline');
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    }
    _downloaded.clear();
    await _savePrefs();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _downloaded.toList());
  }
}
