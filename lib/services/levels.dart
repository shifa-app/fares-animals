// نموذج المستويات العمرية — المرحلة الثانية 2.1.
// العمر نقطة بداية وليس قيداً: المستوى المحفوظ هو الحاكم، والانتقال
// إلى مستوى أعلى يكون بالإتقان فقط (نسبة إكمال 80% فأكثر)، ولا إجبار
// على الصعود أبداً. والوالدان يستطيعان تعديل المستوى بحرية من ركن
// الوالدين (البند 2.7). الإتقان يُحسب من تقدم الطفل الفعلي المحفوظ
// (حيوانات متعلمة، حروف، أرقام، سور محفوظة، قصص، مراحل ماس) —
// بلا أي خصم عند الخطأ، فالتعلم التدريجي والتشجيع هما الأساس.
import 'package:shared_preferences/shared_preferences.dart';

import '../data/animals.dart';
import '../data/letters.dart';
import '../data/quran.dart';
import '../data/stories.dart';
import 'child_profile.dart';
import 'progress_store.dart';

enum AgeLevel { l34, l56, l78, l910 }

extension AgeLevelInfo on AgeLevel {
  int get minAge {
    switch (this) {
      case AgeLevel.l34:
        return 3;
      case AgeLevel.l56:
        return 5;
      case AgeLevel.l78:
        return 7;
      case AgeLevel.l910:
        return 9;
    }
  }

  int get maxAge => minAge + 1;

  /// مثلاً «5–6 سنوات».
  String get label => '$minAge–$maxAge سنوات';

  String get title {
    switch (this) {
      case AgeLevel.l34:
        return 'المستكشف الصغير';
      case AgeLevel.l56:
        return 'المستكشف';
      case AgeLevel.l78:
        return 'العالم الصغير';
      case AgeLevel.l910:
        return 'الخبير الصغير';
    }
  }

  String get description {
    switch (this) {
      case AgeLevel.l34:
        return 'حيوانات وأصوات وأرقام صغيرة — تعلم باللعب';
      case AgeLevel.l56:
        return 'حروف وكلمات وأرقام وقرآن — التعلم الأساسي';
      case AgeLevel.l78:
        return 'قراءة ورياضيات وقصص — تعلم أعمق';
      case AgeLevel.l910:
        return 'موسوعة ومسابقات وقصص متقدمة — تحدٍّ أكبر';
    }
  }

  AgeLevel? get next =>
      this == AgeLevel.l910 ? null : AgeLevel.values[index + 1];
}

class LevelService {
  /// نسبة الإتقان المطلوبة للانتقال إلى المستوى الأعلى.
  static const double advanceThreshold = 0.8;

  static String _levelKey(String child) =>
      '${ChildProfile.keyPrefix(child)}level';

  /// المستوى المناسب لعمر ما. بلا عمر (null) يكون الافتراضي 5–6 سنوات
  /// (مستوى التطبيق الأصلي)، والأعمار خارج 3–10 تُقيَّد لأقرب مستوى.
  static AgeLevel levelFromAge(int? age) {
    if (age == null) return AgeLevel.l56;
    if (age <= 4) return AgeLevel.l34;
    if (age <= 6) return AgeLevel.l56;
    if (age <= 8) return AgeLevel.l78;
    return AgeLevel.l910;
  }

  /// مستوى الطفل الحالي: المحفوظ أولاً، وإلا المشتق من عمره.
  static Future<AgeLevel> levelFor(String child) async {
    final p = await SharedPreferences.getInstance();
    final stored = p.getInt(_levelKey(child));
    if (stored != null && stored >= 0 && stored < AgeLevel.values.length) {
      return AgeLevel.values[stored];
    }
    return levelFromAge(await ChildProfile.childAge(child));
  }

  /// تعديل الوالدين للمستوى بحرية (لا يشترط إتقاناً).
  static Future<void> setLevel(String child, AgeLevel level) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_levelKey(child), level.index);
  }

  /// نسبة إتقان الطفل لمستواه الحالي (0.0 – 1.0).
  static Future<double> mastery(String child) async {
    final level = await levelFor(child);
    final animalNames = animals.map((a) => a.nameAr).toList();
    switch (level) {
      case AgeLevel.l34:
        final a = await ProgressStore.learnedCountFor(child, animalNames);
        final n = await ProgressStore.religionCountFor(
            child, ['number_1', 'number_2', 'number_3', 'number_4', 'number_5']);
        return 0.5 * _frac(a, 10) + 0.5 * _frac(n, 5);
      case AgeLevel.l56:
        final ar = await ProgressStore.religionCountFor(
            child,
            arabicLetters
                .take(14)
                .map((l) => 'letter_ar_${l.letter}')
                .toList());
        final en = await ProgressStore.religionCountFor(
            child,
            englishLetters
                .take(13)
                .map((l) => 'letter_en_${l.letter}')
                .toList());
        final n = await ProgressStore.religionCountFor(
            child, numbers.map((x) => 'number_${x.value}').toList());
        final a = await ProgressStore.learnedCountFor(child, animalNames);
        return 0.25 * _frac(ar, 14) +
            0.25 * _frac(en, 13) +
            0.25 * _frac(n, 20) +
            0.25 * _frac(a, 25);
      case AgeLevel.l78:
        final a = await ProgressStore.learnedCountFor(child, animalNames);
        final q = await ProgressStore.religionCountFor(
            child,
            memorizeSurahs
                .take(5)
                .map((s) => 'memorize_${s.number}')
                .toList());
        final d = await ProgressStore.diamondUnlockedFor(child);
        final s = await ProgressStore.religionCountFor(
            child,
            bedtimeStories
                .take(4)
                .map((s) => 'story_bed_${s.title}')
                .toList());
        return 0.25 * _frac(a, 50) +
            0.25 * _frac(q, 5) +
            0.25 * _frac(d - 1, 2) +
            0.25 * _frac(s, 4);
      case AgeLevel.l910:
        final a = await ProgressStore.learnedCountFor(child, animalNames);
        final q = await ProgressStore.religionCountFor(
            child,
            memorizeSurahs
                .take(10)
                .map((s) => 'memorize_${s.number}')
                .toList());
        final d = await ProgressStore.diamondUnlockedFor(child);
        final s = await ProgressStore.religionCountFor(
            child,
            bedtimeStories.map((s) => 'story_bed_${s.title}').toList());
        return 0.25 * _frac(a, 75) +
            0.25 * _frac(q, 10) +
            0.25 * _frac(d - 1, 5) +
            0.25 * _frac(s, 8);
    }
  }

  /// هل يستحق الطفل الانتقال إلى المستوى الأعلى؟ (إتقان 80% فأكثر،
  /// وليس في أعلى مستوى).
  static Future<bool> canAdvance(String child) async {
    final level = await levelFor(child);
    if (level.next == null) return false;
    return (await mastery(child)) >= advanceThreshold;
  }

  /// يرفع مستوى الطفل إن استحق، ويرجع true؛ وإلا يرجع false
  /// ويبقى المستوى كما هو (بلا إجبار أبداً).
  static Future<bool> advance(String child) async {
    final level = await levelFor(child);
    final next = level.next;
    if (next == null) return false;
    if ((await mastery(child)) < advanceThreshold) return false;
    await setLevel(child, next);
    return true;
  }

  static double _frac(int done, int total) =>
      total <= 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
}
