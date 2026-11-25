// شروط الاستخدام: النص المعتمد محلياً، والفتح من ركن الوالدين
// بعد تجاوز بوابة الوالدين، وظهور بيانات المطور والمالك والبريد.
import 'dart:io';

import 'package:animals/data/terms.dart';
import 'package:animals/screens/parents_screen.dart';
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
    tempDir = await Directory.systemTemp.createTemp('fares-terms-test');
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

  group('terms text (offline, local)', () {
    test('contains all 8 sections, the date and the contact details', () {
      expect(termsFullText, contains('شروط الاستخدام العامة'));
      expect(termsFullText, contains('25 نوفمبر 2026'));
      for (final heading in [
        '1. طبيعة التطبيق والغرض منه',
        '2. إشراف ولي الأمر وركن الوالدين',
        '3. الاستخدام المسموح والقيود',
        '4. الخصوصية وحفظ البيانات محلياً',
        '5. حقوق الملكية الفكرية',
        '6. التحديثات وتعديل المحتوى',
        '7. حدود المسؤولية',
        '8. التواصل والاستفسارات',
      ]) {
        expect(termsFullText, contains(heading), reason: heading);
      }
      expect(termsFullText, contains('ABO FARES'));
      expect(termsFullText, contains('OSSAMA ABDELHAKIM'));
      expect(termsFullText, contains('abofares62022@gmail.com'));
      expect(termsDeveloper, 'ABO FARES');
      expect(termsOwner, 'OSSAMA ABDELHAKIM');
      expect(termsEmail, 'abofares62022@gmail.com');
    });
  });

  group('terms screen from the parents section', () {
    testWidgets(
        'gate, then settings, then the terms page shows developer, owner and email',
        (tester) async {
      tester.view.physicalSize = const Size(800, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(home: ParentsGateScreen()),
      );
      await tester.pumpAndSettle();

      // تجاوز بوابة الوالدين: قراءة السؤال الحسابي وحلّه.
      final question = tester
          .widgetList<Text>(find.byType(Text))
          .firstWhere((t) => t.style?.fontSize == 48)
          .data!;
      final match = RegExp(r'(\d+) \+ (\d+)').firstMatch(question)!;
      final answer =
          int.parse(match.group(1)!) + int.parse(match.group(2)!);
      await tester.enterText(find.byType(TextField), '$answer');
      await tester.tap(find.text('دخول'));
      await tester.pumpAndSettle();

      expect(find.text('إعدادات الوالدين'), findsOneWidget);

      // زر «شروط الاستخدام» داخل ركن الوالدين.
      final termsButton =
          find.widgetWithText(ElevatedButton, 'شروط الاستخدام');
      expect(termsButton, findsOneWidget);
      await tester.ensureVisible(termsButton);
      await tester.tap(termsButton);
      await tester.pumpAndSettle();

      // صفحة الشروط تعرض بيانات المطور والمالك وبريد التواصل.
      expect(find.textContaining('شروط الاستخدام'), findsWidgets);
      expect(find.textContaining('ABO FARES'), findsWidgets);
      expect(find.textContaining('OSSAMA ABDELHAKIM'), findsWidgets);
      expect(find.textContaining('abofares62022@gmail.com'), findsOneWidget);
      expect(find.textContaining('25 نوفمبر 2026'), findsWidgets);
    });
  });
}
