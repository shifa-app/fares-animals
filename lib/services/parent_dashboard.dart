// بيانات لوحة تحكم الوالدين — المرحلة الثانية 2.7.
// تقدم كل مهارة لطفل محدد، وتصنيف المهارات إلى متقنة وتحتاج مراجعة.
// تُستخدم في ركن الوالدين، وتُختبر وحدة اختبار دون واجهة.
import '../data/animals.dart';
import '../data/letters.dart';
import '../data/quran.dart';
import '../data/religion.dart';
import '../data/stories.dart';
import 'badges.dart';
import 'progress_store.dart';

/// تقدم المهارات التسع لطفل: الاسم ← (المنجز، الإجمالي).
Future<Map<String, (int, int)>> skillProgress(String child) async {
  final learned = await ProgressStore.learnedCountFor(
    child,
    animals.map((a) => a.nameAr).toList(),
  );
  final memorized = await ProgressStore.religionCountFor(child, [
    for (final ms in memorizeSurahs) 'memorize_${ms.number}',
  ]);
  final arLetters = await ProgressStore.religionCountFor(
    child,
    arabicLetters.map((e) => 'letter_ar_${e.letter}').toList(),
  );
  final enLetters = await ProgressStore.religionCountFor(
    child,
    englishLetters.map((e) => 'letter_en_${e.letter}').toList(),
  );
  final nums = await ProgressStore.religionCountFor(
    child,
    numbers.map((e) => 'number_${e.value}').toList(),
  );
  final bed = await ProgressStore.religionCountFor(
    child,
    bedtimeStories.map((st) => 'story_bed_${st.title}').toList(),
  );
  final din = await ProgressStore.religionCountFor(child, [
    ...allahNames.keys.map((k) => 'name_$k'),
    ...stories.map((st) => 'story_${st.title}'),
    ...manners.keys.map((k) => 'manner_$k'),
  ]);
  final diamond = await ProgressStore.diamondUnlockedFor(child);
  final quizzes = await completedQuizCountFor(child);
  return {
    'الحيوانات': (learned, animals.length),
    'القرآن': (memorized, memorizeSurahs.length),
    'الحروف العربية': (arLetters, arabicLetters.length),
    'الحروف الإنجليزية': (enLetters, englishLetters.length),
    'الأرقام': (nums, numbers.length),
    'قصص قبل النوم': (bed, bedtimeStories.length),
    'التعلم الديني': (din, allahNames.length + stories.length + manners.length),
    'مراحل الماس': (diamond, 10),
    'الاختبارات': (quizzes, quizGroupKeys.length),
  };
}

/// المهارات المتقنة: إتقان 80% فأكثر.
List<String> masteredSkills(Map<String, (int, int)> skills) =>
    skills.entries
        .where((e) => e.value.$2 > 0 && e.value.$1 / e.value.$2 >= 0.8)
        .map((e) => e.key)
        .toList();

/// المهارات التي تحتاج مراجعة: إتقان أقل من 50%.
List<String> reviewSkills(Map<String, (int, int)> skills) =>
    skills.entries
        .where((e) => e.value.$2 > 0 && e.value.$1 / e.value.$2 < 0.5)
        .map((e) => e.key)
        .toList();
