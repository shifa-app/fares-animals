// قصص الخمس دقائق: نصوص كاملة بالتشكيل، 550–700 كلمة في 6–8 مشاهد،
// بطلها الطفل النشط، ومشغل المشاهد في شاشة التفاصيل.
import 'package:animals/data/stories.dart';
import 'package:animals/screens/stories_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('five-minute stories data', () {
    final five = bedtimeStories.where((s) => s.isFiveMinute).toList();

    test('exactly 5 five-minute stories', () {
      expect(five.length, 5);
      expect(bedtimeStories.length, 13);
    });

    test('each story: 6-8 scenes and 550-700 words', () {
      for (final st in five) {
        expect(
          st.scenes.length,
          inInclusiveRange(6, 8),
          reason: st.title,
        );
        expect(
          st.wordCount,
          inInclusiveRange(550, 700),
          reason: '${st.title}: ${st.wordCount} words',
        );
      }
    });

    test('each story: personalized with a value and scenes with icons', () {
      const knownIcons = {
        'moon',
        'star',
        'bug',
        'garden',
        'heart',
        'sun',
        'bed',
        'bee',
        'ball',
        'bear',
        'chat',
        'hands',
        'flower',
        'water',
        'gift',
        'bird',
        'food',
        'tree',
        'music',
        'key',
        'turtle',
        'think',
        'give',
        'chest',
        'owl',
        'family',
      };
      const values = {'الشجاعة', 'الصدق', 'بر الوالدين', 'الرحمة بالحيوان', 'الأمانة'};
      expect(five.map((s) => s.value).toSet(), values);
      for (final st in five) {
        expect(st.personalized, true, reason: st.title);
        expect(st.title, contains('{name}'), reason: st.title);
        expect(st.value, isNotNull);
        expect(st.moral.isNotEmpty, true);
        for (final scene in st.scenes) {
          expect(scene.text.isNotEmpty, true);
          expect(knownIcons, contains(scene.icon), reason: scene.icon);
        }
      }
    });

    test('title and scenes use the active child name', () {
      final st = five.first;
      expect(st.titleFor('فهد'), contains('فهد'));
      expect(st.titleFor('فهد'), isNot(contains('{name}')));
      expect(st.titleFor('فارس'), contains('فارس'));
      final firstScene = st.sceneTextFor(0, 'فهد');
      expect(firstScene, contains('فهد'));
      expect(firstScene, isNot(contains('{name}')));
      // المفتاح المستقر للتقدم يستخدم العنوان القالب لا الاسم المخصص.
      expect(st.title, contains('{name}'));
    });
  });

  group('five-minute story scene player', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    Future<void> pumpDetail(WidgetTester tester, BedtimeStory st) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      tester.view.physicalSize = const Size(800, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(home: BedtimeStoryDetailScreen(story: st)),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows scene 1, audio bar and pinned buttons',
        (tester) async {
      final st = bedtimeStories.firstWhere((s) => s.isFiveMinute);
      await pumpDetail(tester, st);
      expect(find.text('المشهد 1 من 8'), findsOneWidget);
      expect(find.text('المشهد التالي'), findsOneWidget);
      expect(find.text('المشهد السابق'), findsOneWidget);
      expect(find.textContaining('المتبقي تقديراً'), findsOneWidget);
      expect(find.text('اسمع الحدوتة'), findsOneWidget);
      expect(find.text('سمعتها'), findsOneWidget);
      expect(find.text('ماذا تعلمنا اليوم؟'), findsNothing);
    });

    testWidgets('next scene advances; last scene shows the lesson card',
        (tester) async {
      final st = bedtimeStories.firstWhere((s) => s.isFiveMinute);
      await pumpDetail(tester, st);
      await tester.tap(find.text('المشهد التالي'));
      await tester.pumpAndSettle();
      expect(find.text('المشهد 2 من 8'), findsOneWidget);
      for (var i = 0; i < 6; i++) {
        await tester.tap(find.text('المشهد التالي'));
        await tester.pumpAndSettle();
      }
      expect(find.text('المشهد 8 من 8'), findsOneWidget);
      expect(find.text('ماذا تعلمنا اليوم؟'), findsOneWidget);
      expect(find.text(st.moral), findsOneWidget);
    });
  });
}
