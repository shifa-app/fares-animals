// الأوسمة: تعريفاتها وشروط فتحها من التقدم الفعلي — المرحلة الثانية 2.6.
// لا خصم أبداً: الوسام يُفتح بالإنجاز فقط، ولا يُسحب عند الخطأ.
// الشروط تُحسب من التقدم الحقيقي (لا من عداد منفصل) فيُفتح الوسام
// تلقائياً عند بلوغ الشرط، ويُحفظ في ProgressStore.
import 'package:material_ui/material_ui.dart';

import '../data/animals.dart';
import '../data/letters.dart';
import '../data/quran.dart';
import '../data/stories.dart';
import 'progress_store.dart';

class BadgeDef {
  final String id;
  final String label;
  final String requirement;
  final IconData icon;
  const BadgeDef({
    required this.id,
    required this.label,
    required this.requirement,
    required this.icon,
  });
}

const List<BadgeDef> badgeDefs = [
  BadgeDef(
    id: 'first_animal',
    label: 'أول حيوان',
    requirement: 'تعلّم أول حيوان',
    icon: Icons.pets,
  ),
  BadgeDef(
    id: 'ten_animals',
    label: '10 حيوانات',
    requirement: 'تعلّم 10 حيوانات',
    icon: Icons.emoji_events,
  ),
  BadgeDef(
    id: 'animal_explorer',
    label: 'مستكشف الحيوانات',
    requirement: 'تعلّم 25 حيواناً',
    icon: Icons.explore,
  ),
  BadgeDef(
    id: 'animal_expert',
    label: 'خبير الحيوانات',
    requirement: 'تعلّم 50 حيواناً',
    icon: Icons.school,
  ),
  BadgeDef(
    id: 'animal_master',
    label: 'سيد الحيوانات',
    requirement: 'تعلّم كل الحيوانات المئة',
    icon: Icons.star,
  ),
  BadgeDef(
    id: 'first_surah',
    label: 'أول سورة',
    requirement: 'احفظ أول سورة',
    icon: Icons.menu_book,
  ),
  BadgeDef(
    id: 'five_surahs',
    label: '5 سور',
    requirement: 'احفظ 5 سور',
    icon: Icons.library_books,
  ),
  BadgeDef(
    id: 'ten_surahs',
    label: '10 سور',
    requirement: 'احفظ 10 سور',
    icon: Icons.auto_stories,
  ),
  BadgeDef(
    id: 'story_reader',
    label: 'قارئ القصص',
    requirement: 'استمع إلى قصة',
    icon: Icons.bedtime,
  ),
  BadgeDef(
    id: 'story_lover',
    label: 'محب القصص',
    requirement: 'استمع إلى 4 قصص',
    icon: Icons.book,
  ),
  BadgeDef(
    id: 'story_master',
    label: 'سيد القصص',
    requirement: 'استمع إلى كل القصص الثماني',
    icon: Icons.collections_bookmark,
  ),
  BadgeDef(
    id: 'diamond_player',
    label: 'لاعب الماس',
    requirement: 'افتح المرحلة الثانية في لعبة الماس',
    icon: Icons.diamond,
  ),
  BadgeDef(
    id: 'diamond_champion',
    label: 'بطل الماس',
    requirement: 'افتح المرحلة الخامسة في لعبة الماس',
    icon: Icons.emoji_events,
  ),
  BadgeDef(
    id: 'digger',
    label: 'حفّار الماس',
    requirement: 'أكمل أول مرحلة في حفّار الماس',
    icon: Icons.terrain,
  ),
  BadgeDef(
    id: 'digger_master',
    label: 'حفّار محترف',
    requirement: 'أكمل المراحل الثماني في حفّار الماس',
    icon: Icons.emoji_events,
  ),
  BadgeDef(
    id: 'quiz_hero',
    label: 'بطل الاختبار',
    requirement: 'أكمل اختبار أي مجموعة',
    icon: Icons.quiz,
  ),
  BadgeDef(
    id: 'quiz_master',
    label: 'سيد الاختبارات',
    requirement: 'أكمل اختبارات 5 مجموعات',
    icon: Icons.psychology,
  ),
  BadgeDef(
    id: 'letter_star',
    label: 'نجم الحروف',
    requirement: 'تعلّم 20 حرفاً',
    icon: Icons.abc,
  ),
  BadgeDef(
    id: 'favorite_collector',
    label: 'جامع المفضلة',
    requirement: 'أضف 5 حيوانات إلى المفضلة',
    icon: Icons.favorite,
  ),
  BadgeDef(
    id: 'game_g01',
    label: 'صائد الظلال',
    requirement: 'أكمل لعبة صائد الظلال',
    icon: Icons.nightlight,
  ),
  BadgeDef(
    id: 'game_g02',
    label: 'واصل الحروف',
    requirement: 'أكمل لعبة وصّل الحروف والصور',
    icon: Icons.abc,
  ),
  BadgeDef(
    id: 'game_g03',
    label: 'صياد الألوان',
    requirement: 'أكمل لعبة صياد الألوان',
    icon: Icons.palette,
  ),
  BadgeDef(
    id: 'game_g04',
    label: 'عالم الأشكال',
    requirement: 'أكمل لعبة عالم الأشكال',
    icon: Icons.category,
  ),
  BadgeDef(
    id: 'game_g05',
    label: 'عداد فارس',
    requirement: 'أكمل لعبة عدّ مع فارس',
    icon: Icons.looks_one,
  ),
  BadgeDef(
    id: 'game_g06',
    label: 'محقق الأرقام',
    requirement: 'أكمل لعبة أكمل الرقم الناقص',
    icon: Icons.search,
  ),
  BadgeDef(
    id: 'game_g07',
    label: 'سيد الأحجية',
    requirement: 'أكمل لعبة أحجية الحيوانات',
    icon: Icons.extension,
  ),
];

/// معرّفات ألعاب P0 السبع (لمفاتيح النجوم والأوسمة).
const List<String> gameIds = ['g01', 'g02', 'g03', 'g04', 'g05', 'g06', 'g07'];

/// مفاتيح مجموعات الاختبار (بيئية 7 + علمية 8 = 15).
const List<String> quizGroupKeys = [
  'forest',
  'farm',
  'birds',
  'sea',
  'reptiles',
  'desert',
  'polar',
  'mammal',
  'bird',
  'fish',
  'reptile',
  'amphibian',
  'insect',
  'arachnid',
  'invertebrate',
];

/// عدد اختبارات المجموعات المكتملة (نجمة الاختبار لكل مجموعة).
Future<int> completedQuizCount() async {
  var count = 0;
  for (final key in quizGroupKeys) {
    if (await ProgressStore.hasStarFor('quiz_$key')) count++;
  }
  return count;
}

/// عدد اختبارات المجموعات المكتملة لطفل محدد.
Future<int> completedQuizCountFor(String child) async {
  var count = 0;
  for (final key in quizGroupKeys) {
    if (await ProgressStore.hasStarForChild(child, 'quiz_$key')) count++;
  }
  return count;
}

/// الأوسمة المفتوحة من التقدم الفعلي للطفل الحالي.
/// تُحفظ الأوسمة الجديدة في ProgressStore عند فتحها.
Future<Set<String>> unlockedBadges() async {
  final learned = await ProgressStore.learnedCount(
    animals.map((a) => a.nameAr).toList(),
  );
  final memorized = await ProgressStore.religionCount([
    for (final ms in memorizeSurahs) 'memorize_${ms.number}',
  ]);
  final bed = await ProgressStore.religionCount(
    bedtimeStories.map((st) => 'story_bed_${st.title}').toList(),
  );
  final diamond = await ProgressStore.diamondUnlocked();
  final quizzes = await completedQuizCount();
  final letters = await ProgressStore.religionCount([
    ...arabicLetters.map((e) => 'letter_ar_${e.letter}'),
    ...englishLetters.map((e) => 'letter_en_${e.letter}'),
  ]);
  final favorites = (await ProgressStore.favorites()).length;

  final unlocked = <String>{};
  if (learned >= 1) unlocked.add('first_animal');
  if (learned >= 10) unlocked.add('ten_animals');
  if (learned >= 25) unlocked.add('animal_explorer');
  if (learned >= 50) unlocked.add('animal_expert');
  if (learned >= 100) unlocked.add('animal_master');
  if (memorized >= 1) unlocked.add('first_surah');
  if (memorized >= 5) unlocked.add('five_surahs');
  if (memorized >= 10) unlocked.add('ten_surahs');
  if (bed >= 1) unlocked.add('story_reader');
  if (bed >= 4) unlocked.add('story_lover');
  if (bed >= 8) unlocked.add('story_master');
  if (diamond >= 2) unlocked.add('diamond_player');
  if (diamond >= 5) unlocked.add('diamond_champion');
  if (await ProgressStore.hasStarFor('digger_level_1')) {
    unlocked.add('digger');
  }
  var diggerDone = true;
  for (var i = 1; i <= 8; i++) {
    if (!await ProgressStore.hasStarFor('digger_level_$i')) {
      diggerDone = false;
      break;
    }
  }
  if (diggerDone) unlocked.add('digger_master');
  if (quizzes >= 1) unlocked.add('quiz_hero');
  if (quizzes >= 5) unlocked.add('quiz_master');
  if (letters >= 20) unlocked.add('letter_star');
  if (favorites >= 5) unlocked.add('favorite_collector');
  for (final gameId in gameIds) {
    if (await ProgressStore.hasStarFor('game_$gameId')) {
      unlocked.add('game_$gameId');
    }
  }

  for (final id in unlocked) {
    await ProgressStore.unlockBadge(id);
  }
  return unlocked;
}
