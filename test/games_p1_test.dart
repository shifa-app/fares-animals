// ألعاب P1 الست (G08–G13): محرك الجولات + شاشات اللعب +
// الأوسمة الجديدة.
import 'package:animals/data/animals.dart';
import 'package:animals/screens/games/coloring_game.dart';
import 'package:animals/screens/games/kitchen_game.dart';
import 'package:animals/screens/games/needs_game.dart';
import 'package:animals/screens/games/parts_game.dart';
import 'package:animals/screens/games/relation_game.dart';
import 'package:animals/screens/games/touch_game.dart';
import 'package:animals/services/badges.dart';
import 'package:animals/services/game_engine.dart';
import 'package:animals/widgets/game_painters.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_tts'),
          (MethodCall call) async => 1,
        );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter_tts'), null);
  });

  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pumpAndSettle();
  }

  /// جرّب خيارات الشبكة واحداً واحداً حتى تتقدم اللعبة للجولة 2.
  Future<void> tapUntilRound2(
    WidgetTester tester,
    Finder options,
  ) async {
    for (var i = 0; i < 9; i++) {
      if (find.textContaining('الجولة 2 من 5').evaluate().isNotEmpty) return;
      final count = options.evaluate().length;
      if (i >= count) return;
      await tester.tap(options.at(i));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    }
  }

  group('kitchen engine (G09)', () {
    test('5 rounds, correct options are the meal ingredients', () {
      final rounds = GameEngine.buildKitchenRounds(
        difficulty: GameDifficulty.easy,
        count: 5,
        seed: 7,
      );
      expect(rounds.length, 5);
      for (final r in rounds) {
        expect(r.options.length, 5);
        expect(r.options.toSet().length, 5);
        expect(r.correct.length, greaterThanOrEqualTo(3));
        final meal = kitchenMeals.firstWhere((m) => m.name == r.payload);
        for (final i in r.correct) {
          expect(meal.ingredients, contains(r.options[i]));
        }
      }
    });

    test('expert rounds have 8 options', () {
      final rounds = GameEngine.buildKitchenRounds(
        difficulty: GameDifficulty.expert,
        count: 5,
        seed: 3,
      );
      for (final r in rounds) {
        expect(r.options.length, 8);
      }
    });
  });

  group('kitchen game (G09) widget', () {
    testWidgets('shows the meal and its food options', (tester) async {
      await pumpScreen(tester, const KitchenGameScreen());
      expect(find.textContaining('مطبخ فارس — الجولة 1 من 5'), findsOneWidget);
      expect(find.text('فهمت، لنبدأ!'), findsOneWidget);
      expect(find.text('ما مكونات الوجبة؟'), findsOneWidget);
      final options = find.descendant(
        of: find.byType(GridView),
        matching: find.byType(ElevatedButton),
      );
      expect(options.evaluate().length, 5);
    });

    testWidgets('catching all ingredients advances to round 2',
        (tester) async {
      await pumpScreen(tester, const KitchenGameScreen());
      await tester.tap(find.text('فهمت، لنبدأ!'));
      await tester.pumpAndSettle();
      final options = find.descendant(
        of: find.byType(GridView),
        matching: find.byType(ElevatedButton),
      );
      await tapUntilRound2(tester, options);
      expect(find.textContaining('الجولة 2 من 5'), findsOneWidget);
    });
  });

  group('parts engine (G10)', () {
    test('5 rounds, 4 part names, correct matches the payload part', () {
      final rounds = GameEngine.buildPartsRounds(count: 5, seed: 11);
      expect(rounds.length, 5);
      for (final r in rounds) {
        expect(r.options.length, 4);
        expect(r.options.toSet(), animalParts.map((p) => p.name).toSet());
        final key = r.payload!.split(':').last;
        final part = animalParts.firstWhere((p) => p.key == key);
        expect(r.options[r.correctIndex], part.name);
        expect(r.question, contains(part.name));
      }
    });
  });

  group('parts game (G10) widget', () {
    testWidgets('shows the animal, the question and 4 part buttons',
        (tester) async {
      await pumpScreen(tester, const PartsGameScreen());
      expect(find.textContaining('أجزاء الحيوان — الجولة 1 من 5'), findsOneWidget);
      expect(find.text('فهمت، لنبدأ!'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              w.data != null &&
              w.data!.startsWith('اضغط على «'),
        ),
        findsOneWidget,
      );
      expect(find.byType(ElevatedButton), findsNWidgets(5)); // 4 + زر البطاقة
    });

    testWidgets('tapping the asked part advances to round 2',
        (tester) async {
      await pumpScreen(tester, const PartsGameScreen());
      await tester.tap(find.text('فهمت، لنبدأ!'));
      await tester.pumpAndSettle();
      final question = tester
          .widget<Text>(
            find.byWidgetPredicate(
              (w) =>
                  w is Text &&
                  w.data != null &&
                  w.data!.startsWith('اضغط على «'),
            ),
          )
          .data!;
      final partName = RegExp(r'«(.+)»').firstMatch(question)!.group(1)!;
      await tester.tap(find.widgetWithText(ElevatedButton, partName));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.textContaining('الجولة 2 من 5'), findsOneWidget);
    });
  });

  group('relation engine (G11)', () {
    test('correct option is the animal home or food', () {
      final rounds = GameEngine.buildRelationRounds(
        difficulty: GameDifficulty.easy,
        count: 5,
        seed: 5,
      );
      expect(rounds.length, 5);
      for (final r in rounds) {
        expect(r.options.length, 3);
        expect(r.options.toSet().length, 3);
        final animal = animals.firstWhere((a) => a.nameAr == r.payload);
        final answer = r.question.startsWith('أين يعيش')
            ? animal.home
            : animal.food;
        expect(r.options[r.correctIndex], answer);
      }
    });

    test('hard rounds have 4 options', () {
      final rounds = GameEngine.buildRelationRounds(
        difficulty: GameDifficulty.hard,
        count: 5,
        seed: 5,
      );
      for (final r in rounds) {
        expect(r.options.length, 4);
      }
    });
  });

  group('relation game (G11) widget', () {
    testWidgets('shows the question and its options', (tester) async {
      await pumpScreen(tester, const RelationGameScreen());
      expect(find.textContaining('اكتشف العلاقة — الجولة 1 من 5'), findsOneWidget);
      expect(find.text('فهمت، لنبدأ!'), findsOneWidget);
      expect(find.text('اكتشف العلاقة!'), findsOneWidget);
    });

    testWidgets('tapping the related answer advances to round 2',
        (tester) async {
      await pumpScreen(tester, const RelationGameScreen());
      await tester.tap(find.text('فهمت، لنبدأ!'));
      await tester.pumpAndSettle();
      final question = tester
          .widget<Text>(
            find.textContaining(RegExp(r'أين يعيش|ماذا يأكل')),
          )
          .data!;
      final isHome = question.startsWith('أين يعيش');
      final name = RegExp(r'(أين يعيش|ماذا يأكل) (.+)؟')
          .firstMatch(question)!
          .group(2)!;
      final animal = animals.firstWhere((a) => a.nameAr == name);
      final answer = isHome ? animal.home : animal.food;
      await tester.tap(find.widgetWithText(ElevatedButton, answer));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.textContaining('الجولة 2 من 5'), findsOneWidget);
    });
  });

  group('needs engine (G12)', () {
    test('correct option is the scenario need', () {
      final rounds = GameEngine.buildNeedsRounds(count: 5, seed: 9);
      expect(rounds.length, 5);
      for (final r in rounds) {
        expect(r.options.length, 3);
        expect(r.options.toSet().length, 3);
        expect(r.options, everyElement(isIn(animalNeedNames)));
        final scenario = animalNeeds.firstWhere((n) => n.animal == r.payload);
        expect(r.options[r.correctIndex], scenario.need);
        expect(r.question, scenario.situation);
      }
    });
  });

  group('needs game (G12) widget', () {
    testWidgets('shows the scenario and need options', (tester) async {
      await pumpScreen(tester, const NeedsGameScreen());
      expect(
        find.textContaining('ماذا يحتاج الحيوان؟ — الجولة 1 من 5'),
        findsOneWidget,
      );
      expect(find.text('فهمت، لنبدأ!'), findsOneWidget);
    });

    testWidgets('tapping the right need advances to round 2',
        (tester) async {
      await pumpScreen(tester, const NeedsGameScreen());
      await tester.tap(find.text('فهمت، لنبدأ!'));
      await tester.pumpAndSettle();
      final scenario = animalNeeds.firstWhere(
        (n) => find.text(n.situation).evaluate().isNotEmpty,
      );
      await tester.tap(find.widgetWithText(ElevatedButton, scenario.need));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.textContaining('الجولة 2 من 5'), findsOneWidget);
    });
  });

  group('touch engine (G13)', () {
    test('easy 4 options, hard 9, correct is the named animal', () {
      final easy = GameEngine.buildTouchRounds(
        difficulty: GameDifficulty.easy,
        count: 5,
        seed: 4,
      );
      final hard = GameEngine.buildTouchRounds(
        difficulty: GameDifficulty.hard,
        count: 5,
        seed: 4,
      );
      for (final r in easy) {
        expect(r.options.length, 4);
        expect(r.options[r.correctIndex], r.payload);
        expect(r.question, 'المس ${r.payload}!');
      }
      for (final r in hard) {
        expect(r.options.length, 9);
        expect(r.options.toSet().length, 9);
      }
    });
  });

  group('touch game (G13) widget', () {
    testWidgets('shows the voice instruction and 4 pictures',
        (tester) async {
      await pumpScreen(tester, const TouchGameScreen());
      expect(find.textContaining('المس واكتشف — الجولة 1 من 5'), findsOneWidget);
      expect(find.text('فهمت، لنبدأ!'), findsOneWidget);
      expect(find.textContaining('المس '), findsWidgets);
      final cells = find.descendant(
        of: find.byType(GridView),
        matching: find.byType(InkWell),
      );
      expect(cells.evaluate().length, 4);
    });

    testWidgets('tapping pictures until the right one advances to round 2',
        (tester) async {
      await pumpScreen(tester, const TouchGameScreen());
      await tester.tap(find.text('فهمت، لنبدأ!'));
      await tester.pumpAndSettle();
      final cells = find.descendant(
        of: find.byType(GridView),
        matching: find.byType(InkWell),
      );
      await tapUntilRound2(tester, cells);
      expect(find.textContaining('الجولة 2 من 5'), findsOneWidget);
    });
  });

  group('coloring game (G08) widget', () {
    testWidgets('shows 8 coloring pages and the guide card', (tester) async {
      await pumpScreen(tester, const ColoringGameScreen());
      expect(find.text('رسام الحيوانات'), findsWidgets);
      expect(find.text('فهمت، لنبدأ!'), findsOneWidget);
      expect(find.text('اختر حيواناً لتلوينه:'), findsOneWidget);
      for (final name in ['أسد', 'فيل', 'زرافة', 'أرنب', 'سلحفاة', 'سمكة', 'عصفور', 'قط']) {
        expect(find.text(name), findsOneWidget, reason: name);
      }
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is CustomPaint && w.painter is ColoringPainter,
        ),
        findsNWidgets(8),
      );
    });

    testWidgets('tapping a page opens the coloring canvas', (tester) async {
      await pumpScreen(tester, const ColoringGameScreen());
      await tester.tap(find.text('أسد'));
      await tester.pumpAndSettle();
      expect(find.textContaining('لوّن الـ أسد'), findsOneWidget);
      expect(find.byTooltip('حفظ في معرضي'), findsOneWidget);
      expect(find.byTooltip('مسح اللوحة'), findsOneWidget);
      expect(find.byTooltip('رجوع'), findsOneWidget);
    });
  });

  group('P1 badges', () {
    test('six new badges and game ids g08..g13', () {
      for (final id in ['g08', 'g09', 'g10', 'g11', 'g12', 'g13']) {
        expect(gameIds, contains(id));
        expect(
          badgeDefs.any((b) => b.id == 'game_$id'),
          isTrue,
          reason: id,
        );
      }
      expect(gameIds.length, 13);
      expect(badgeDefs.length, 32);
    });
  });
}
