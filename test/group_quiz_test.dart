// اختبارات اختبار المجموعة — المرحلة الثانية 2.5.
import 'package:animals/data/animals.dart';
import 'package:animals/screens/group_quiz_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final forest = animals.where((a) => a.category == 'forest').toList();

  test('بناء الأسئلة: 5 أسئلة، 3 خيارات لكل سؤال، والصحيح ضمنها', () {
    final questions = buildQuizQuestions(forest, seed: 7);
    expect(questions.length, 5);
    for (final q in questions) {
      expect(q.options.length, 3);
      expect(q.options.toSet().length, 3);
      expect(q.options, contains(q.correct));
      expect(forest.map((a) => a.nameAr), contains(q.animal.nameAr));
      if (q.kind == 'sound') {
        expect(q.animal.hasRealSound, isTrue);
      }
    }
  });

  test('أسئلة الصوت مقصورة على أصحاب الصوت الحقيقي', () {
    // مجموعة بلا أصوات حقيقية: لا أسئلة صوت إطلاقاً.
    final silent = animals.where((a) => !a.hasRealSound).take(10).toList();
    final questions = buildQuizQuestions(silent, seed: 3);
    expect(questions.where((q) => q.kind == 'sound'), isEmpty);
  });

  test('مجموعة أقل من 3 حيوانات بلا اختبار', () {
    expect(buildQuizQuestions(forest.take(2).toList()), isEmpty);
    expect(buildQuizQuestions([]), isEmpty);
  });

  testWidgets('الإجابة الصحيحة عن كل الأسئلة تصل إلى النتيجة 5/5', (tester) async {
    // شاشة اختبار طويلة لتظهر كل الخيارات دون تمرير.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues(<String, Object>{});
    const seed = 7;
    final expected = buildQuizQuestions(forest, seed: seed);
    await tester.pumpWidget(
      MaterialApp(
        home: GroupQuizScreen(
          groupKey: 'forest',
          groupLabel: 'حيوانات الغابة',
          animals: forest,
          seed: seed,
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    for (var i = 0; i < expected.length; i++) {
      await tester.tap(find.text(expected[i].correct).first);
      await tester.pump();
      await tester.tap(
        find.text(i + 1 >= expected.length ? 'النتيجة' : 'السؤال التالي'),
      );
      await tester.pumpAndSettle();
    }
    expect(find.text('أحسنت يا بطل!'), findsOneWidget);
    expect(find.text('أجبت عن 5 من 5 أسئلة'), findsOneWidget);
    expect(find.text('حصلت على نجمة جديدة!'), findsOneWidget);
  });
}
