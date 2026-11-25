// لعبة أكل الماس 💎: مراحلها العشر — الهدف والوقت وسرعة اختفاء الماسة
// وعدد الماسات الظاهرة معاً. التدرج لطيف لعمر 5 سنوات دون إحباط:
// الهدف يكبر ببطء (+1 كل مرحلة)، والوقت يقل ببطء (-1 ث كل مرحلة)،
// والماسة تختفي أبطأ مما كان مخططاً (من 5 ث إلى 2.75 ث كحد أدنى).

class DiamondLevel {
  final int level;
  final int target;
  final int seconds;
  final double despawnSeconds;
  final int maxDiamonds;
  const DiamondLevel({
    required this.level,
    required this.target,
    required this.seconds,
    required this.despawnSeconds,
    required this.maxDiamonds,
  });
}

/// المراحل العشر: الهدف 5 ثم +1 كل مرحلة، الوقت 32 ث ثم -1 كل مرحلة،
/// والاختفاء 5 ث ثم -0.25 كل مرحلة (بحد أدنى 2.75 ث).
List<DiamondLevel> get diamondLevels => List.generate(10, (i) {
  final level = i + 1;
  final despawn = 5.0 - i * 0.25;
  return DiamondLevel(
    level: level,
    target: 5 + i,
    seconds: 32 - i,
    despawnSeconds: despawn < 2.75 ? 2.75 : despawn,
    maxDiamonds: 1 + i ~/ 5,
  );
});

DiamondLevel diamondLevel(int level) => diamondLevels[level - 1];

/// حيوانات الساحة: واحد لكل مرحلة، والطفل يبدّل بينها بالضغط عليها.
const List<String> diamondAnimals = [
  '🦁',
  '🐱',
  '🐶',
  '🐰',
  '🐵',
  '🐼',
  '🐻',
  '🐘',
  '🦊',
  '🐸',
];
