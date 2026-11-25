// اختبارات لوحة تحكم الوالدين — المرحلة الثانية 2.7.
import 'dart:io';

import 'package:animals/screens/parents_screen.dart';
import 'package:animals/services/child_profile.dart';
import 'package:animals/services/parent_dashboard.dart';
import 'package:animals/services/progress_store.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    // ركن الوالدين يقرأ مجلد النسخ عند الفتح — مجلد مؤقت للاختبار.
    tempDir = await Directory.systemTemp.createTemp('fares-parents-test');
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

  test('تقدم المهارات يُحسب لطفل محدد دون تبديل الحالي', () async {
    await ChildProfile.setCurrent('فارس');
    await ProgressStore.markLearned('أسد');
    final skills = await skillProgress('فارس');
    expect(skills['الحيوانات'], (1, 100));
    expect(skills['القرآن'], (0, 21));
    final other = await skillProgress('فهد');
    expect(other['الحيوانات'], (0, 100));
  });

  test('المهارات المتقنة 80% فأكثر، والمراجعة أقل من 50%', () {
    const skills = <String, (int, int)>{
      'الحيوانات': (90, 100),
      'القرآن': (5, 21),
      'الأرقام': (20, 20),
    };
    expect(masteredSkills(skills), ['الحيوانات', 'الأرقام']);
    expect(reviewSkills(skills), ['القرآن']);
  });

  test('إدارة الأطفال: إضافة وحذف وعمر', () async {
    expect(await ChildProfile.addChild('عمر'), isTrue);
    expect(await ChildProfile.addChild('عمر'), isFalse);
    expect(await ChildProfile.children(), contains('عمر'));
    await ChildProfile.setChildAge('عمر', 7);
    expect(await ChildProfile.childAge('عمر'), 7);
    await ChildProfile.clearChildAge('عمر');
    expect(await ChildProfile.childAge('عمر'), isNull);
    await ChildProfile.removeChild('عمر');
    expect(await ChildProfile.children(), isNot(contains('عمر')));
  });

  testWidgets('ركن الوالدين يعرض إدارة الأطفال والمهارات ووقت الاستخدام',
      (tester) async {
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: ParentsSettingsScreen()));
    await tester.pumpAndSettle();
    expect(find.text('إدارة الأطفال'), findsOneWidget);
    expect(find.text('متابعة المهارات'), findsOneWidget);
    expect(find.text('وقت الاستخدام'), findsOneWidget);
    expect(find.text('الوضع الليلي لقصص قبل النوم'), findsOneWidget);
    expect(find.text('فارس'), findsWidgets);
    expect(find.text('فهد'), findsWidgets);
    expect(find.text('المستكشف'), findsWidgets);
    expect(find.text('5 سنوات'), findsOneWidget);
    expect(find.textContaining('الحيوانات: 0 من 100'), findsOneWidget);
  });

  testWidgets('إضافة طفل جديد من لوحة الوالدين', (tester) async {
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: ParentsSettingsScreen()));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'عمر');
    await tester.tap(find.text('إضافة'));
    await tester.pumpAndSettle();
    expect(find.text('أُضيف الطفل عمر بنجاح.'), findsOneWidget);
    expect(find.text('عمر'), findsWidgets);
  });
}
