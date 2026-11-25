// اختبارات نموذج المستويات العمرية — المرحلة الثانية 2.1.
import 'package:animals/data/animals.dart';
import 'package:animals/data/letters.dart';
import 'package:animals/services/child_profile.dart';
import 'package:animals/services/levels.dart';
import 'package:animals/services/progress_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('levelFromAge يشتق المستوى الصحيح من العمر', () {
    expect(LevelService.levelFromAge(3), AgeLevel.l34);
    expect(LevelService.levelFromAge(4), AgeLevel.l34);
    expect(LevelService.levelFromAge(5), AgeLevel.l56);
    expect(LevelService.levelFromAge(6), AgeLevel.l56);
    expect(LevelService.levelFromAge(7), AgeLevel.l78);
    expect(LevelService.levelFromAge(8), AgeLevel.l78);
    expect(LevelService.levelFromAge(9), AgeLevel.l910);
    expect(LevelService.levelFromAge(10), AgeLevel.l910);
    expect(LevelService.levelFromAge(null), AgeLevel.l56);
    expect(LevelService.levelFromAge(2), AgeLevel.l34);
    expect(LevelService.levelFromAge(11), AgeLevel.l910);
  });

  test('مستوى فارس الافتراضي 5–6 سنوات (عمره 5)', () async {
    expect(await ChildProfile.childAge('فارس'), 5);
    expect(await LevelService.levelFor('فارس'), AgeLevel.l56);
  });

  test('طفل بلا عمر محدد يبدأ من 5–6 سنوات', () async {
    expect(await ChildProfile.childAge('فهد'), isNull);
    expect(await LevelService.levelFor('فهد'), AgeLevel.l56);
  });

  test('الإتقان صفر لطفل جديد، والصعود مرفوض', () async {
    await ChildProfile.setChildAge('صغير', 3);
    expect(await LevelService.mastery('صغير'), 0.0);
    expect(await LevelService.canAdvance('صغير'), isFalse);
    expect(await LevelService.advance('صغير'), isFalse);
    expect(await LevelService.levelFor('صغير'), AgeLevel.l34);
  });

  test('الإتقان يرتفع مع التقدم، والصعود يتم عند 80%', () async {
    await ChildProfile.setChildAge('صغير', 3);
    await ChildProfile.setCurrent('صغير');
    // 5 حيوانات = 25% من إتقان 3–4 سنوات.
    for (final a in animals.take(5)) {
      await ProgressStore.markLearned(a.nameAr);
    }
    expect(await LevelService.mastery('صغير'), closeTo(0.25, 0.001));
    expect(await LevelService.canAdvance('صغير'), isFalse);
    // الأرقام 1–5 = 50% إضافية -> 75%، ما زال أقل من 80%.
    for (var i = 1; i <= 5; i++) {
      await ProgressStore.markReligion('number_$i');
    }
    expect(await LevelService.mastery('صغير'), closeTo(0.75, 0.001));
    expect(await LevelService.advance('صغير'), isFalse);
    expect(await LevelService.levelFor('صغير'), AgeLevel.l34);
    // 5 حيوانات أخرى -> 100%، فيستحق الصعود.
    for (final a in animals.skip(5).take(5)) {
      await ProgressStore.markLearned(a.nameAr);
    }
    expect(await LevelService.mastery('صغير'), closeTo(1.0, 0.001));
    expect(await LevelService.canAdvance('صغير'), isTrue);
    expect(await LevelService.advance('صغير'), isTrue);
    expect(await LevelService.levelFor('صغير'), AgeLevel.l56);
  });

  test('إتقان مستوى 5–6 سنوات يكتمل بكل مكوناته', () async {
    await ChildProfile.setCurrent('فارس');
    for (final l in arabicLetters.take(14)) {
      await ProgressStore.markReligion('letter_ar_${l.letter}');
    }
    for (final l in englishLetters.take(13)) {
      await ProgressStore.markReligion('letter_en_${l.letter}');
    }
    for (final n in numbers) {
      await ProgressStore.markReligion('number_${n.value}');
    }
    for (final a in animals.take(25)) {
      await ProgressStore.markLearned(a.nameAr);
    }
    expect(await LevelService.mastery('فارس'), closeTo(1.0, 0.001));
    expect(await LevelService.canAdvance('فارس'), isTrue);
  });

  test('الوالد يعدل المستوى بحرية دون شرط إتقان', () async {
    await LevelService.setLevel('فارس', AgeLevel.l910);
    expect(await LevelService.levelFor('فارس'), AgeLevel.l910);
    // في أعلى مستوى لا صعود أصلاً.
    expect(await LevelService.canAdvance('فارس'), isFalse);
    expect(await LevelService.advance('فارس'), isFalse);
  });

  test('مستوى كل طفل مستقل عن الآخر', () async {
    await ChildProfile.setChildAge('صغير', 3);
    await LevelService.setLevel('صغير', AgeLevel.l78);
    expect(await LevelService.levelFor('صغير'), AgeLevel.l78);
    expect(await LevelService.levelFor('فارس'), AgeLevel.l56);
  });
}
