// محرك الألعاب الموحد (مكتبة الألعاب التعليمية P0):
// - جولات نقية قابلة للاختبار (بذرة ثابتة = نفس الجولات).
// - تعليمات صوتية لفارس المرشد عبر AppSound المركزي (بلا تداخل
//   مع مؤثرات اللعب)، تظهر تلقائياً في المرة الأولى فقط، وقابلة
//   للتخطي بنقرة، وقابلة لإعادة الاستماع من زر السماعة.
// - إكمال اللعبة يمنح نجمة واحدة فقط (بلا خصم أبداً) ويفتح وسامها.
// - إيقاف الأصوات والمؤقتات عند الخروج مسؤولية شاشة اللعبة
//   (dispose → GameEngine.stopAudio + إلغاء مؤقتاتها).
import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../data/animals.dart';
import '../data/letters.dart';
import 'app_sound.dart';
import 'badges.dart';
import 'progress_store.dart';

/// مستويات الصعوبة الأربعة المرتبطة بالمستويات العمرية.
/// الطفل حر في تجربة مستوى مختلف عن مستواه.
enum GameDifficulty { easy, medium, hard, expert }

extension GameDifficultyX on GameDifficulty {
  String get label => switch (this) {
    GameDifficulty.easy => 'سهل',
    GameDifficulty.medium => 'متوسط',
    GameDifficulty.hard => 'صعب',
    GameDifficulty.expert => 'خبير',
  };
}

/// جولة واحدة في أي لعبة: سؤال + خيارات + مواضع الإجابات الصحيحة.
/// [payload] يحمل بيانات العرض الخاصة باللعبة (لون، شكل، حيوان، ...).
/// [sequence] للألعاب الرقمية فقط (تسلسل فيه موضع ناقص null).
class GameRound {
  final String question;
  final List<String> options;
  final Set<int> correct;
  final String? payload;
  final List<int?>? sequence;
  const GameRound({
    required this.question,
    required this.options,
    required this.correct,
    this.payload,
    this.sequence,
  });

  bool get isSingleAnswer => correct.length == 1;
  int get correctIndex => correct.first;
}

/// حيوانات لعبة الظلال: رسوم ظلال أصلية بـ CustomPainter.
class ShadowAnimal {
  final String id;
  final String name;
  final String emoji;
  const ShadowAnimal(this.id, this.name, this.emoji);
}

const List<ShadowAnimal> shadowAnimals = [
  ShadowAnimal('lion', 'أسد', '🦁'),
  ShadowAnimal('elephant', 'فيل', '🐘'),
  ShadowAnimal('giraffe', 'زرافة', '🦒'),
  ShadowAnimal('rabbit', 'أرنب', '🐰'),
  ShadowAnimal('turtle', 'سلحفاة', '🐢'),
  ShadowAnimal('fish', 'سمكة', '🐟'),
  ShadowAnimal('bird', 'عصفور', '🐦'),
  ShadowAnimal('cat', 'قط', '🐱'),
];

/// ألوان لعبة صياد الألوان: مفتاح + لون + اسم عربي.
class GameColor {
  final String key;
  final Color color;
  final String name;
  const GameColor(this.key, this.color, this.name);
}

const List<GameColor> gameColors = [
  GameColor('red', Colors.red, 'الأحمر'),
  GameColor('blue', Colors.blue, 'الأزرق'),
  GameColor('green', Colors.green, 'الأخضر'),
  GameColor('yellow', Colors.amber, 'الأصفر'),
  GameColor('orange', Colors.orange, 'البرتقالي'),
  GameColor('purple', Colors.purple, 'البنفسجي'),
  GameColor('pink', Colors.pink, 'الوردي'),
  GameColor('brown', Colors.brown, 'البني'),
];

/// أشكال لعبة عالم الأشكال: مفتاح + اسم عربي.
const List<(String, String)> gameShapes = [
  ('circle', 'الدائرة'),
  ('square', 'المربع'),
  ('triangle', 'المثلث'),
  ('star', 'النجمة'),
  ('rectangle', 'المستطيل'),
  ('heart', 'القلب'),
  ('diamond', 'المعيّن'),
  ('oval', 'البيضاوي'),
];

class GameEngine {
  // ---------------- بناء الجولات (دوال نقية) ----------------

  /// G01 صائد الظلال: ظل حيوان + 4 أسماء، والإجابة اسم صاحب الظل.
  static List<GameRound> buildShadowRounds({int count = 5, int? seed}) {
    final rnd = Random(seed);
    final pool = shadowAnimals.toList()..shuffle(rnd);
    final rounds = <GameRound>[];
    for (var i = 0; i < count; i++) {
      final answer = pool[i % pool.length];
      final others = shadowAnimals.where((s) => s != answer).toList()
        ..shuffle(rnd);
      final options = [answer, others[0], others[1], others[2]]
          .map((s) => s.name)
          .toList()
        ..shuffle(rnd);
      rounds.add(
        GameRound(
          question: 'ما صاحب هذا الظل؟',
          options: options,
          correct: {options.indexOf(answer.name)},
          payload: answer.id,
        ),
      );
    }
    return rounds;
  }

  /// G02 وصّل الحروف والصور: حرف + 4 صور حيوانات، والإجابة
  /// الحيوان الذي يبدأ اسمه بالحرف.
  static List<GameRound> buildLetterRounds({int count = 5, int? seed}) {
    final rnd = Random(seed);
    final pool = arabicLetters
        .where((l) => l.animalName != null)
        .toList()
      ..shuffle(rnd);
    final rounds = <GameRound>[];
    for (var i = 0; i < count; i++) {
      final letter = pool[i % pool.length];
      final answer = letter.animalName!;
      final others = animals
          .where((a) => a.nameAr != answer)
          .map((a) => a.nameAr)
          .toList()
        ..shuffle(rnd);
      final options = [answer, others[0], others[1], others[2]]
        ..shuffle(rnd);
      rounds.add(
        GameRound(
          question: 'أي حيوان يبدأ بحرف ${letter.letter}؟',
          options: options,
          correct: {options.indexOf(answer)},
          payload: letter.letter,
        ),
      );
    }
    return rounds;
  }

  /// G03 صياد الألوان: 9 نقاط ملونة فيها 3 من اللون المطلوب؛
  /// على الطفل اصطياد النقاط الثلاث (بلا خصم عند الخطأ).
  static List<GameRound> buildColorRounds({int count = 5, int? seed}) {
    final rnd = Random(seed);
    final targets = gameColors.toList()..shuffle(rnd);
    final rounds = <GameRound>[];
    for (var i = 0; i < count; i++) {
      final target = targets[i % targets.length];
      final others = gameColors.where((c) => c != target).toList()
        ..shuffle(rnd);
      final dots = [
        target.key,
        target.key,
        target.key,
        others[0].key,
        others[1].key,
        others[2].key,
        others[3].key,
        others[4].key,
        others[5].key,
      ]..shuffle(rnd);
      final correct = {
        for (var j = 0; j < dots.length; j++)
          if (dots[j] == target.key) j,
      };
      rounds.add(
        GameRound(
          question: 'اصطد اللون ${target.name}!',
          options: dots,
          correct: correct,
          payload: target.key,
        ),
      );
    }
    return rounds;
  }

  /// G04 عالم الأشكال: اسم شكل + 4 أشكال مرسومة، والإجابة الشكل المطلوب.
  static List<GameRound> buildShapeRounds({int count = 5, int? seed}) {
    final rnd = Random(seed);
    final pool = gameShapes.toList()..shuffle(rnd);
    final rounds = <GameRound>[];
    for (var i = 0; i < count; i++) {
      final answer = pool[i % pool.length];
      final others = gameShapes.where((s) => s != answer).toList()
        ..shuffle(rnd);
      final options = [answer, others[0], others[1], others[2]]
          .map((s) => s.$2)
          .toList()
        ..shuffle(rnd);
      rounds.add(
        GameRound(
          question: 'ما هذا الشكل؟',
          options: options,
          correct: {options.indexOf(answer.$2)},
          payload: answer.$1,
        ),
      );
    }
    return rounds;
  }

  /// G05 عدّ مع فارس: عدّ الحيوانات الظاهرة واختر العدد الصحيح.
  /// [max] سقف العدّ حسب المستوى (5 / 10 / 20).
  static List<GameRound> buildCountingRounds({
    int max = 10,
    int count = 5,
    int? seed,
  }) {
    final rnd = Random(seed);
    final rounds = <GameRound>[];
    for (var i = 0; i < count; i++) {
      final target = rnd.nextInt(max) + 1;
      final animal = animals[rnd.nextInt(animals.length)];
      final opts = {target};
      while (opts.length < 3) {
        final v = target + rnd.nextInt(5) - 2;
        if (v >= 1 && v <= max) opts.add(v);
      }
      final options = opts.map((v) => '$v').toList()..shuffle(rnd);
      rounds.add(
        GameRound(
          question: 'كم عدد الحيوانات؟',
          options: options,
          correct: {options.indexOf('$target')},
          payload: animal.nameAr,
        ),
      );
    }
    return rounds;
  }

  /// G06 أكمل الرقم الناقص: تسلسل من 5 أعداد فيه موضع ناقص واحد.
  static List<GameRound> buildMissingNumberRounds({
    GameDifficulty difficulty = GameDifficulty.easy,
    int count = 5,
    int? seed,
  }) {
    final rnd = Random(seed);
    final rounds = <GameRound>[];
    for (var i = 0; i < count; i++) {
      final step = switch (difficulty) {
        GameDifficulty.easy => 1,
        GameDifficulty.medium => rnd.nextBool() ? 1 : 2,
        GameDifficulty.hard => rnd.nextInt(2) + 2,
        GameDifficulty.expert => rnd.nextInt(3) + 2,
      };
      final maxStart = switch (difficulty) {
        GameDifficulty.easy => 6,
        GameDifficulty.medium => 10,
        GameDifficulty.hard => 15,
        GameDifficulty.expert => 20,
      };
      final start = rnd.nextInt(maxStart) + 1;
      var descending =
          difficulty.index >= GameDifficulty.hard.index && rnd.nextBool();
      // تنازلي لا ينزل تحت 1 أبداً: إن كان سيتجاوز الصفر نقلبه تصاعدياً
      // (بدل تخطي الجولة — وإلا نقص عدد الجولات عن المطلوب).
      if (descending && start - 4 * step < 1) descending = false;
      final seq = List<int>.generate(
        5,
        (j) => descending ? start - j * step : start + j * step,
      );
      final missing = rnd.nextInt(3) + 1; // ليس الأول ولا الأخير
      final answer = seq[missing];
      // المشتتات: من نطاق واسع حول الإجابة (لا من جيرانها المباشرين،
      // لأن جيران الرقم الناقص في تسلسل بخطوة 1 كلهم داخل التسلسل
      // نفسه — فالحلقة العشوائية كانت تدور بلا نهاية).
      final candidates = <int>[];
      for (var v = answer - 5; v <= answer + 5; v++) {
        if (v >= 1 && v != answer && !seq.contains(v)) candidates.add(v);
      }
      candidates.shuffle(rnd);
      final options = ['$answer', '${candidates[0]}', '${candidates[1]}']
        ..shuffle(rnd);
      final shown = List<int?>.from(seq)..[missing] = null;
      rounds.add(
        GameRound(
          question: 'ما الرقم الناقص؟',
          options: options,
          correct: {options.indexOf('$answer')},
          sequence: shown,
        ),
      );
    }
    return rounds;
  }

  /// G07 أحجية الحيوانات: صورة مقسمة (2×2 أو 3×3) وقطعة ناقصة؛
  /// على الطفل اختيار القطعة الصحيحة من 3 قطع.
  /// الخيارات بصيغة «اسم الحيوان:رقم الخلية»، والحمولة
  /// «اسم الحيوان:حجم الشبكة:الخلية الناقصة».
  static List<GameRound> buildPuzzleRounds({
    GameDifficulty difficulty = GameDifficulty.easy,
    int count = 4,
    int? seed,
  }) {
    final rnd = Random(seed);
    final grid = difficulty.index >= GameDifficulty.hard.index ? 3 : 2;
    final cells = grid * grid;
    final pool = animals.toList()..shuffle(rnd);
    final rounds = <GameRound>[];
    for (var i = 0; i < count; i++) {
      final animal = pool[i % pool.length];
      final missing = rnd.nextInt(cells);
      final others = animals.where((a) => a != animal).toList()
        ..shuffle(rnd);
      final options = [
        '${animal.nameAr}:$missing',
        '${others[0].nameAr}:$missing',
        '${others[1].nameAr}:$missing',
      ]..shuffle(rnd);
      rounds.add(
        GameRound(
          question: 'أكمل الصورة! ما القطعة الناقصة؟',
          options: options,
          correct: {options.indexOf('${animal.nameAr}:$missing')},
          payload: '${animal.nameAr}:$grid:$missing',
        ),
      );
    }
    return rounds;
  }

  // ---------------- تعليمات فارس المرشد ----------------

  /// هل تظهر التعليمات تلقائياً؟ (المرة الأولى فقط لكل لعبة ولكل طفل).
  static Future<bool> shouldShowGuide(String gameId) async {
    return !(await ProgressStore.isReligion('guide_$gameId'));
  }

  static Future<void> markGuideShown(String gameId) async {
    await ProgressStore.markReligion('guide_$gameId');
  }

  /// نطق التعليمات عبر المدير المركزي (يوقف أي صوت آخر أولاً).
  static Future<void> speakGuide(String text) =>
      AppSound.instance.speak(text);

  /// إيقاف كل الأصوات فوراً (عند الخروج من اللعبة).
  static Future<void> stopAudio() => AppSound.instance.stopAll();

  // ---------------- الإكمال والنجوم ----------------

  /// إكمال اللعبة: نجمة واحدة لأول مرة فقط + فتح وسام اللعبة.
  /// لا خصم أبداً، وإعادة اللعب لا تمنح نجوماً جديدة.
  static Future<void> completeGame(String gameId) async {
    await ProgressStore.awardStarsOnce('game_$gameId', 1);
    await unlockedBadges();
  }
}
