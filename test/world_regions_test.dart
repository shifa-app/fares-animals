// تعميق «عالم فارس» (2.0-beta): محتوى المناطق السبع +
// شاشة المنطقة (وصف + حقيقة + حيواناتها + مغامرة 3 مشاهد).
import 'package:animals/data/world_regions.dart';
import 'package:animals/screens/fares_world_screen.dart';
import 'package:animals/screens/region_detail_screen.dart';
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
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), null);
  });

  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pumpAndSettle();
  }

  test('every region has a description, a fun fact and 3 scenes', () {
    expect(worldRegionContents.length, 7);
    for (final region in FaresWorld.regions) {
      final content = contentForRegion(region.id);
      expect(content, isNotNull, reason: region.id);
      expect(content!.description.isNotEmpty, isTrue, reason: region.id);
      expect(content.funFact.isNotEmpty, isTrue, reason: region.id);
      expect(content.adventure.length, 3, reason: region.id);
      for (final scene in content.adventure) {
        expect(scene.isNotEmpty, isTrue, reason: region.id);
        expect(scene, contains('فارس'), reason: region.id);
      }
    }
  });

  testWidgets('region detail shows description, fact, animals and adventure',
      (tester) async {
    final region = FaresWorld.regions.first; // الغابة
    await pumpScreen(
      tester,
      RegionDetailScreen(region: region, onOpenCategory: (_) {}),
    );
    expect(find.text('الغابة'), findsWidgets);
    expect(find.textContaining('الغابة بيت كبير'), findsOneWidget);
    expect(find.textContaining('حقيقة ممتعة'), findsOneWidget);
    expect(
      find.text('تعلمت 0 من 19 حيواناً في هذه المنطقة'),
      findsOneWidget,
    );
    expect(find.text('مغامرة فارس 🚀'), findsOneWidget);
    expect(find.textContaining('ذهب فارس إلى الغابة'), findsOneWidget);
    expect(find.text('المشهد 1 من 3'), findsOneWidget);
    expect(find.text('شاهد كل حيوانات الغابة'), findsOneWidget);
  });

  testWidgets('adventure next button moves to scene 2', (tester) async {
    final region = FaresWorld.regions.first;
    await pumpScreen(
      tester,
      RegionDetailScreen(region: region, onOpenCategory: (_) {}),
    );
    await tester.tap(find.text('التالي'));
    await tester.pumpAndSettle();
    expect(find.text('المشهد 2 من 3'), findsOneWidget);
    expect(find.textContaining('قابل فارس قرداً صغيراً'), findsOneWidget);
  });

  testWidgets('tapping an unlocked region opens its detail screen',
      (tester) async {
    await pumpScreen(
      tester,
      FaresWorldScreen(onOpenCategory: (_) {}),
    );
    await tester.tap(find.text('الغابة'));
    await tester.pumpAndSettle();
    expect(find.text('مغامرة فارس 🚀'), findsOneWidget);
    expect(find.textContaining('الغابة بيت كبير'), findsOneWidget);
  });
}
