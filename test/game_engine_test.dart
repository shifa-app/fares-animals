// محرك الألعاب: بناء الجولات نقيةً، والتعليمات للمرة الأولى فقط،
// والإكمال بنجمة واحدة بلا خصم وبلا تكرار.
import 'package:animals/data/animals.dart';
import 'package:animals/data/letters.dart';
import 'package:animals/services/badges.dart';
import 'package:animals/services/game_engine.dart';
import 'package:animals/services/progress_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  group('G01 shadow rounds', () {
    test('5 rounds, 4 unique options, correct is the shadow owner', () {
      final rounds = GameEngine.buildShadowRounds(count: 5, seed: 7);
      expect(rounds.length, 5);
      for (final r in rounds) {
        expect(r.options.length, 4);
        expect(r.options.toSet().length, 4);
        expect(r.isSingleAnswer, true);
        final owner = shadowAnimals.firstWhere((s) => s.id == r.payload);
        expect(r.options[r.correctIndex], owner.name);
        expect(r.question, 'ما صاحب هذا الظل؟');
      }
    });

    test('same seed gives same rounds', () {
      final a = GameEngine.buildShadowRounds(count: 5, seed: 42);
      final b = GameEngine.buildShadowRounds(count: 5, seed: 42);
      expect(
        a.map((r) => '${r.payload}:${r.options}').toList(),
        b.map((r) => '${r.payload}:${r.options}').toList(),
      );
    });
  });

  group('G02 letter rounds', () {
    test('correct animal starts with the shown letter', () {
      final rounds = GameEngine.buildLetterRounds(count: 5, seed: 3);
      expect(rounds.length, 5);
      for (final r in rounds) {
        expect(r.options.length, 4);
        expect(r.options.toSet().length, 4);
        final letter = arabicLetters.firstWhere((l) => l.letter == r.payload);
        expect(r.options[r.correctIndex], letter.animalName);
      }
    });
  });

  group('G03 color rounds', () {
    test('9 dots with exactly 3 of the target color', () {
      final rounds = GameEngine.buildColorRounds(count: 5, seed: 11);
      expect(rounds.length, 5);
      for (final r in rounds) {
        expect(r.options.length, 9);
        expect(r.correct.length, 3);
        for (final i in r.correct) {
          expect(r.options[i], r.payload);
        }
        expect(
          gameColors.map((c) => c.key).toSet(),
          containsAll(r.options.toSet()),
        );
      }
    });
  });

  group('G04 shape rounds', () {
    test('correct shape matches the payload', () {
      final rounds = GameEngine.buildShapeRounds(count: 5, seed: 5);
      expect(rounds.length, 5);
      for (final r in rounds) {
        expect(r.options.length, 4);
        expect(r.options.toSet().length, 4);
        // الخيارات أسماء عربية (لا مفاتيح إنجليزية) يراها الطفل.
        expect(
          r.options[r.correctIndex],
          gameShapes
              .firstWhere((s) => s.$1 == r.payload)
              .$2,
        );
        expect(gameShapes.map((s) => s.$1), contains(r.payload));
        expect(
          gameShapes.map((s) => s.$1).toSet().intersection(r.options.toSet()),
          isEmpty,
        );
      }
    });
  });

  group('G05 counting rounds', () {
    test('options contain the target count within the max', () {
      final rounds = GameEngine.buildCountingRounds(max: 5, count: 5, seed: 9);
      expect(rounds.length, 5);
      for (final r in rounds) {
        expect(r.options.length, 3);
        expect(r.options.toSet().length, 3);
        final target = int.parse(r.options[r.correctIndex]);
        expect(target, inInclusiveRange(1, 5));
        expect(
          animals.map((a) => a.nameAr),
          contains(r.payload),
        );
      }
    });
  });

  group('G06 missing number rounds', () {
    test('sequence of 5 with one middle gap; options hold the answer', () {
      final rounds = GameEngine.buildMissingNumberRounds(
        difficulty: GameDifficulty.easy,
        count: 5,
        seed: 13,
      );
      expect(rounds.length, 5);
      for (final r in rounds) {
        final seq = r.sequence!;
        expect(seq.length, 5);
        expect(seq.where((v) => v == null).length, 1);
        expect(seq.first, isNotNull);
        expect(seq.last, isNotNull);
        final missing = seq.indexWhere((v) => v == null);
        final answer = int.parse(r.options[r.correctIndex]);
        // التسلسل بخطوة 1 في المستوى السهل.
        expect(answer, seq[missing - 1]! + 1);
        expect(r.options.length, 3);
      }
    });

    test('hard rounds stay valid (step 2-3, maybe descending)', () {
      final rounds = GameEngine.buildMissingNumberRounds(
        difficulty: GameDifficulty.hard,
        count: 5,
        seed: 17,
      );
      expect(rounds.length, 5);
      for (final r in rounds) {
        final seq = r.sequence!;
        expect(seq.where((v) => v == null).length, 1);
        final known = seq.whereType<int>().toList();
        expect(known.every((v) => v >= 1), true);
      }
    });

    test('every difficulty returns exactly the requested rounds', () {
      for (final difficulty in GameDifficulty.values) {
        for (var seed = 1; seed <= 5; seed++) {
          final rounds = GameEngine.buildMissingNumberRounds(
            difficulty: difficulty,
            count: 5,
            seed: seed,
          );
          expect(
            rounds.length,
            5,
            reason: '$difficulty seed $seed',
          );
          for (final r in rounds) {
            expect(
              r.sequence!.whereType<int>().every((v) => v >= 1),
              true,
              reason: '$difficulty seed $seed',
            );
          }
        }
      }
    });
  });

  group('G07 puzzle rounds', () {
    test('2x2 grid, 3 piece options, correct is the missing piece', () {
      final rounds = GameEngine.buildPuzzleRounds(
        difficulty: GameDifficulty.easy,
        count: 4,
        seed: 19,
      );
      expect(rounds.length, 4);
      for (final r in rounds) {
        expect(r.options.length, 3);
        final parts = r.payload!.split(':');
        expect(parts.length, 3);
        expect(parts[1], '2'); // شبكة 2×2 في السهل
        expect(r.options[r.correctIndex], '${parts[0]}:${parts[2]}');
        expect(
          animals.map((a) => a.nameAr),
          contains(parts[0]),
        );
      }
    });

    test('hard uses a 3x3 grid', () {
      final rounds = GameEngine.buildPuzzleRounds(
        difficulty: GameDifficulty.hard,
        count: 4,
        seed: 23,
      );
      expect(rounds.length, 4);
      for (final r in rounds) {
        expect(r.payload!.split(':')[1], '3');
      }
    });
  });

  group('guide and completion', () {
    test('guide shows first time only, then never again', () async {
      expect(await GameEngine.shouldShowGuide('g01'), true);
      await GameEngine.markGuideShown('g01');
      expect(await GameEngine.shouldShowGuide('g01'), false);
      // لعبة أخرى لم تُعرض بعد.
      expect(await GameEngine.shouldShowGuide('g02'), true);
    });

    test('completing a game awards one star once and unlocks its badge',
        () async {
      await GameEngine.completeGame('g01');
      expect(await ProgressStore.hasStarFor('game_g01'), true);
      expect(await ProgressStore.stars(), 1);
      expect(await unlockedBadges(), contains('game_g01'));
      // إعادة الإكمال لا تمنح نجوماً جديدة.
      await GameEngine.completeGame('g01');
      expect(await ProgressStore.stars(), 1);
    });
  });
}
