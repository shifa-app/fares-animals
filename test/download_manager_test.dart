// مدير التنزيل المسبق (2.0-beta): تنزيل كل الصور والأصوات،
// تخطي المنزَّل، فشل ملف لا يوقف الباقي، حذف كامل،
// وبطاقة ركن الوالدين.
import 'dart:io';

import 'package:animals/data/animals.dart';
import 'package:animals/services/download_manager.dart';
import 'package:animals/widgets/offline_downloads_card.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late int fetchCount;
  late String failUrl;

  Future<List<int>> fakeFetcher(Uri uri) async {
    fetchCount++;
    if (uri.toString() == failUrl) throw const HttpException('nope');
    return [1, 2, 3, 4];
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    tempDir = await Directory.systemTemp.createTemp('fares-offline-test');
    fetchCount = 0;
    failUrl = '';
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

  DownloadManager manager() => DownloadManager(fetcher: fakeFetcher);

  test('fileNameFor is stable, distinct and keeps known extensions', () {
    final url = animals.first.imageUrl;
    expect(DownloadManager.fileNameFor(url, 'img'), DownloadManager.fileNameFor(url, 'img'));
    expect(
      DownloadManager.fileNameFor(url, 'img'),
      isNot(DownloadManager.fileNameFor(animals[1].imageUrl, 'img')),
    );
    expect(DownloadManager.fileNameFor(url, 'img'), endsWith('.jpg'));
    final sound = animals.firstWhere((a) => a.hasRealSound).soundUrl;
    expect(DownloadManager.fileNameFor(sound, 'snd'), endsWith('.mp3'));
    expect(
      DownloadManager.fileNameFor('https://example.com/x', 'snd'),
      endsWith('.mp3'),
    );
  });

  test('downloadAll downloads every image and real sound', () async {
    final m = manager();
    expect(DownloadManager.totalItems, 173);
    final report = await m.downloadAll();
    expect(report.failed, 0);
    expect(report.done, 173);
    expect(fetchCount, 173);
    final status = await m.status();
    expect(status.downloaded, 173);
    expect(status.isComplete, isTrue);
    expect(status.bytes, greaterThan(0));
    // ملفات فعلية على القرص + مسارات محلية محلولة.
    final imgPath = m.localImagePath(animals.first.imageUrl);
    expect(imgPath, isNotNull);
    expect(await File(imgPath!).exists(), isTrue);
    final soundAnimal = animals.firstWhere((a) => a.hasRealSound);
    final sndPath = m.localSoundPath(soundAnimal.soundUrl);
    expect(sndPath, isNotNull);
    expect(await File(sndPath!).exists(), isTrue);
    // الحيوان الصامت بلا مسار محلي.
    final silent = animals.firstWhere((a) => !a.hasRealSound);
    expect(m.localSoundPath(silent.soundUrl), isNull);
  });

  test('second downloadAll skips everything already downloaded', () async {
    final m = manager();
    await m.downloadAll();
    fetchCount = 0;
    final report = await m.downloadAll();
    expect(fetchCount, 0);
    expect(report.done, 173);
    expect(report.failed, 0);
  });

  test('one failing file does not stop the rest', () async {
    failUrl = animals[3].imageUrl;
    final m = manager();
    final report = await m.downloadAll();
    expect(report.failed, 1);
    expect(report.done, 172);
    expect(m.isDownloaded(failUrl), isFalse);
    expect(m.isDownloaded(animals[4].imageUrl), isTrue);
  });

  test('deleteAll removes files and clears the index', () async {
    final m = manager();
    await m.downloadAll();
    await m.deleteAll();
    final status = await m.status();
    expect(status.downloaded, 0);
    expect(status.bytes, 0);
    expect(await Directory('${tempDir.path}/offline').exists(), isFalse);
    expect(m.localImagePath(animals.first.imageUrl), isNull);
  });

  test('init prunes prefs entries whose file is gone', () async {
    final url = animals.first.imageUrl;
    SharedPreferences.setMockInitialValues(<String, Object>{
      'offline_downloaded': [url],
    });
    final m = manager();
    await m.init();
    expect(m.isDownloaded(url), isFalse);
  });

  testWidgets('offline card downloads from the parents card button',
      (tester) async {
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: OfflineDownloadsCard(manager: manager()),
          ),
        ),
      ),
    );
    // فحص الحالة الأولي غير متزامن (قناة path_provider + تفضيلات)؛
    // pumpAndSettle وحده لا يقدّمه دائماً في هذا المسار.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('التنزيل المسبق'), findsOneWidget);
    expect(find.text('لم يُنزَّل شيء بعد.'), findsOneWidget);
    await tester.tap(find.text('حمّل الصور والأصوات'));
    // التنزيل 173 ملفاً؛ كل ضغطة pump تقدّم المهام الدقيقة
    // (الجلب الوهمي + الكتابة المتزامنة) وتعيد رسم التقدم.
    for (var i = 0; i < 300; i++) {
      await tester.pump(const Duration(milliseconds: 50));
      if (find.textContaining('اكتمل التنزيل!').evaluate().isNotEmpty) break;
    }
    expect(find.textContaining('اكتمل التنزيل!'), findsOneWidget);
    expect(find.textContaining('تم تنزيل 173 من 173'), findsOneWidget);
  });
}
