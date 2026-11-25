// اختبارات الأوسمة — المرحلة الثانية 2.6.
import 'package:animals/data/animals.dart';
import 'package:animals/data/letters.dart';
import 'package:animals/screens/stars_screen.dart';
import 'package:animals/services/badges.dart';
import 'package:animals/services/progress_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('بلا تقدم لا أوسمة مفتوحة', () async {
    expect(await unlockedBadges(), isEmpty);
    expect(await completedQuizCount(), 0);
  });

  test('تعلم 10 حيوانات يفتح أول وسامين فقط', () async {
    for (final a in animals.take(10)) {
      await ProgressStore.markLearned(a.nameAr);
    }
    final unlocked = await unlockedBadges();
    expect(unlocked, contains('first_animal'));
    expect(unlocked, contains('ten_animals'));
    expect(unlocked, isNot(contains('animal_explorer')));
  });

  test('حفظ سورة يفتح وسام أول سورة', () async {
    await ProgressStore.markReligion('memorize_1');
    expect(await unlockedBadges(), contains('first_surah'));
  });

  test('فتح مرحلة الماس الثانية يفتح وسام لاعب الماس', () async {
    await ProgressStore.unlockDiamondLevel(2);
    final unlocked = await unlockedBadges();
    expect(unlocked, contains('diamond_player'));
    expect(unlocked, isNot(contains('diamond_champion')));
    await ProgressStore.unlockDiamondLevel(5);
    expect(await unlockedBadges(), contains('diamond_champion'));
  });

  test('إكمال اختبار مجموعة يفتح وسام بطل الاختبار', () async {
    await ProgressStore.awardStarsOnce('quiz_forest', 1);
    expect(await completedQuizCount(), 1);
    final unlocked = await unlockedBadges();
    expect(unlocked, contains('quiz_hero'));
    expect(unlocked, isNot(contains('quiz_master')));
  });

  test('تعلم 20 حرفاً يفتح وسام نجم الحروف', () async {
    // أول 14 حرفاً عربياً و6 إنجليزية من القوائم الفعلية.
    for (final e in arabicLetters.take(14)) {
      await ProgressStore.markReligion('letter_ar_${e.letter}');
    }
    for (final e in englishLetters.take(6)) {
      await ProgressStore.markReligion('letter_en_${e.letter}');
    }
    expect(await unlockedBadges(), contains('letter_star'));
  });

  test('5 حيوانات مفضلة تفتح وسام جامع المفضلة', () async {
    for (final a in animals.take(5)) {
      await ProgressStore.toggleFavorite(a.nameAr);
    }
    expect(await unlockedBadges(), contains('favorite_collector'));
  });

  test('تعلم المئة كلها يفتح وسام سيد الحيوانات', () async {
    for (final a in animals) {
      await ProgressStore.markLearned(a.nameAr);
    }
    expect(await unlockedBadges(), contains('animal_master'));
  });

  testWidgets('شاشة نجومي تعرض المستوى والمهارات والأوسمة وسجل التعلم',
      (tester) async {
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await ProgressStore.markLearned('أسد');
    await ProgressStore.awardStarsOnce('animal_أسد', 1);
    await tester.pumpWidget(const MaterialApp(home: StarsScreen()));
    await tester.pump();
    await tester.pump();
    expect(find.text('نجومي وإنجازاتي'), findsOneWidget);
    expect(find.text('نجومي: 1'), findsOneWidget);
    expect(find.textContaining('مستواي: المستكشف'), findsOneWidget);
    expect(find.textContaining('الحيوانات: 1 من 100'), findsOneWidget);
    expect(find.textContaining('الاختبارات: 0 من 15'), findsOneWidget);
    expect(find.text('أول حيوان'), findsOneWidget);
    expect(find.text('تعلّم 10 حيوانات'), findsOneWidget);
    expect(find.text('تعلّمت أسد'), findsOneWidget);
  });
}
