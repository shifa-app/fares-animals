import 'package:animals/data/quran.dart';
import 'package:animals/screens/quran_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_tts'),
          (call) async => 1,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugin.csdcorp.com/speech_to_text'),
          null,
        );
  });

  Future<void> pumpDetail(WidgetTester tester) async {
    final surah = memorizeSurahs.firstWhere((s) => s.number == 108);
    await tester.pumpWidget(
      MaterialApp(home: MemorizationDetailScreen(surah: surah)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('tasmee mode shows the mic button and keeps manual save',
      (tester) async {
    await pumpDetail(tester);
    await tester.tap(find.text('وضع التسميع'));
    await tester.pumpAndSettle();
    expect(find.text('الآية 1 من 3'), findsOneWidget);
    expect(find.text('سمّع بصوتك 🎤'), findsOneWidget);
    expect(find.text('كررتها! التالية'), findsOneWidget);
    expect(find.text('استمع للآية'), findsOneWidget);
  });

  testWidgets('manual save button still advances without the mic',
      (tester) async {
    await pumpDetail(tester);
    await tester.tap(find.text('وضع التسميع'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('كررتها! التالية'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('كررتها! التالية'));
    await tester.pumpAndSettle();
    expect(find.text('الآية 2 من 3'), findsOneWidget);
    expect(find.text('سمّع بصوتك 🎤'), findsOneWidget);
  });

  testWidgets(
      'mic button never gets stuck when speech init is unavailable',
      (tester) async {
    // قناة speech_to_text ترد بأن التهيئة غير متاحة (إذن مرفوض
    // أو خدمة تعرف غير موجودة) — كما يحدث على جهاز حقيقي.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugin.csdcorp.com/speech_to_text'),
          (call) async {
            if (call.method == 'initialize') return false;
            return null;
          },
        );
    await pumpDetail(tester);
    await tester.tap(find.text('وضع التسميع'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('سمّع بصوتك 🎤'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('سمّع بصوتك 🎤'));
    await tester.pumpAndSettle();
    // رسالة واضحة، والزر ما زال «سمّع بصوتك» لا «أنا أسمعك...» —
    // أي لم يعلق في حالة الاستماع، والمسار اليدوي ما زال متاحاً.
    expect(find.textContaining('الميكروفون غير متاح'), findsOneWidget);
    expect(find.text('سمّع بصوتك 🎤'), findsOneWidget);
    expect(find.text('أنا أسمعك...'), findsNothing);
    expect(find.text('كررتها! التالية'), findsOneWidget);
  });
}
