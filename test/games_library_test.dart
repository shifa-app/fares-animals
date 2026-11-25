// مكتبة الألعاب: الألعاب الجديدة (P0 السبع + P1 الست) مربوطة في
// قسم «الألعاب» وتفتح شاشاتها من أزرارها، مع بقاء الألعاب الأربع القديمة.
import 'package:animals/screens/games_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_tts'),
          (MethodCall call) async => 1,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_tts'),
          null,
        );
  });

  Future<void> pumpLibrary(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: GamesScreen()));
    await tester.pumpAndSettle();
  }

  Future<void> openGame(WidgetTester tester, String label) async {
    final button = find.text(label);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  testWidgets('all seven new games are listed beside the four old ones',
      (tester) async {
    await pumpLibrary(tester);
    for (final label in [
      'خمّن الصوت',
      'خمّن الصورة',
      'لعبة الذاكرة',
      'أكل الماس 💎',
      'صائد الظلال',
      'وصّل الحروف والصور',
      'صياد الألوان',
      'عالم الأشكال',
      'عدّ مع فارس',
      'أكمل الرقم الناقص',
      'أحجية الحيوانات',
      'حفّار الماس ⛏️',
      'رسام الحيوانات',
      'مطبخ فارس',
      'أجزاء الحيوان',
      'اكتشف العلاقة',
      'ماذا يحتاج الحيوان؟',
      'المس واكتشف',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
    expect(find.text('ألعاب جديدة 🎮'), findsOneWidget);
  });

  testWidgets('tapping a new game opens its screen', (tester) async {
    await pumpLibrary(tester);
    await openGame(tester, 'صائد الظلال');
    expect(find.textContaining('صائد الظلال — الجولة 1 من 5'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await openGame(tester, 'عدّ مع فارس');
    expect(find.textContaining('عدّ مع فارس — الجولة 1 من 5'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await openGame(tester, 'أحجية الحيوانات');
    expect(
      find.textContaining('أحجية الحيوانات — الجولة 1 من 5'),
      findsOneWidget,
    );
    await tester.pageBack();
    await tester.pumpAndSettle();

    await openGame(tester, 'مطبخ فارس');
    expect(find.textContaining('مطبخ فارس — الجولة 1 من 5'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await openGame(tester, 'المس واكتشف');
    expect(find.textContaining('المس واكتشف — الجولة 1 من 5'), findsOneWidget);
  });
}
