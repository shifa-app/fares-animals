// حفّار الماس: اختبارات المحرك النقي + شاشة اللعب.
// حلول المراحل الثماني موثقة هنا حركةً حركة؛ إن تغيرت خريطة
// فكسرت حلها، فشل هذا الاختبار فوراً.
import 'package:animals/data/digger_levels.dart';
import 'package:animals/screens/games/digger_game.dart';
import 'package:animals/services/digger_engine.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('digger engine', () {
    test('parses level 1: 9x7 grid, 3 diamonds, player at (1,1)', () {
      final s = DiggerEngine.parse(diggerLevels[0]);
      expect(s.rows, 9);
      expect(s.cols, 7);
      expect(s.total, 3);
      expect(s.playerRow, 1);
      expect(s.playerCol, 1);
      expect(s.collected, 0);
      expect(s.completed, isFalse);
    });

    test('every level has 9 rows of 7 cells and a player and an exit', () {
      for (final lv in diggerLevels) {
        expect(lv.rows.length, 9, reason: 'level ${lv.number}');
        for (final line in lv.rows) {
          expect(line.length, 7, reason: 'level ${lv.number}');
        }
        final flat = lv.rows.join();
        expect(flat.contains('P'), isTrue, reason: 'level ${lv.number}');
        expect(flat.contains('E'), isTrue, reason: 'level ${lv.number}');
        expect(lv.diamondCount, greaterThan(0), reason: 'level ${lv.number}');
      }
    });

    test('moving right digs dirt and leaves an empty cell', () {
      final s = DiggerEngine.parse(diggerLevels[0]);
      expect(DiggerEngine.move(s, DiggerDirection.right), isTrue);
      expect((s.playerRow, s.playerCol), (1, 2));
      expect(s.cellAt(1, 2), DiggerCell.empty);
    });

    test('moving into a rock or a hedgehog is blocked', () {
      final s = DiggerEngine.parse(diggerLevels[2]); // الصخرة الأولى
      // الأرنب بجانب الصخرة مباشرة.
      s.playerRow = 3;
      s.playerCol = 2;
      expect(DiggerEngine.move(s, DiggerDirection.right), isFalse);
      expect((s.playerRow, s.playerCol), (3, 2));

      final s2 = DiggerEngine.parse(diggerLevels[3]); // القنفذ النائم
      s2.playerRow = 2;
      s2.playerCol = 1;
      expect(DiggerEngine.move(s2, DiggerDirection.down), isFalse);
      expect((s2.playerRow, s2.playerCol), (2, 1));
    });

    test('moving outside the grid is blocked', () {
      final s = DiggerEngine.parse(diggerLevels[0]);
      s.playerRow = 0;
      s.playerCol = 0;
      expect(DiggerEngine.move(s, DiggerDirection.up), isFalse);
      expect(DiggerEngine.move(s, DiggerDirection.left), isFalse);
    });

    test('collecting a diamond counts it; exit stays locked until all', () {
      final s = DiggerEngine.parse(diggerLevels[0]);
      expect(DiggerEngine.move(s, DiggerDirection.right), isTrue);
      expect(DiggerEngine.move(s, DiggerDirection.right), isTrue);
      expect(s.collected, 1);
      expect(s.exitOpen, isFalse);
      // الباب مغلق: الأرنب بجانبه ولا يدخله.
      s.playerRow = 7;
      s.playerCol = 2;
      expect(DiggerEngine.move(s, DiggerDirection.left), isFalse);
      expect(s.completed, isFalse);
      // بعد جمع كل الماس يفتح الباب.
      s.collected = s.total;
      expect(DiggerEngine.move(s, DiggerDirection.left), isTrue);
      expect(s.completed, isTrue);
    });

    test('a rock falls when the dirt below it is dug, but never onto the rabbit',
        () {
      final s = DiggerEngine.parse(diggerLevels[2]); // الصخرة الأولى
      expect(s.cellAt(3, 3), DiggerCell.rock);
      // الأرنب تحت الصخرة مباشرة بعد حفر (4,3).
      s.playerRow = 4;
      s.playerCol = 2;
      expect(DiggerEngine.move(s, DiggerDirection.right), isTrue);
      // الصخرة بقيت مكانها لأن الأرنب أسفلها.
      expect(s.cellAt(3, 3), DiggerCell.rock);
      // الأرنب يبتعد فتسقط الصخرة إلى (4,3).
      expect(DiggerEngine.move(s, DiggerDirection.left), isTrue);
      expect(s.cellAt(4, 3), DiggerCell.rock);
      expect(s.cellAt(3, 3), DiggerCell.empty);
    });

    test('every level is solvable with its documented solution', () {
      const solutions = <List<DiggerDirection>>[
        // 1 أول حفرة
        [
          DiggerDirection.right,
          DiggerDirection.right,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.left,
          DiggerDirection.left,
          DiggerDirection.down,
        ],
        // 2 طريق متعرج
        [
          DiggerDirection.right,
          DiggerDirection.right,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.left,
          DiggerDirection.left,
          DiggerDirection.down,
          DiggerDirection.down,
        ],
        // 3 الصخرة الأولى
        [
          DiggerDirection.right,
          DiggerDirection.right,
          DiggerDirection.down,
          DiggerDirection.left,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.right,
          DiggerDirection.left,
          DiggerDirection.down,
          DiggerDirection.right,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.left,
          DiggerDirection.left,
        ],
        // 4 القنفذ النائم
        [
          DiggerDirection.right,
          DiggerDirection.right,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.left,
          DiggerDirection.left,
          DiggerDirection.down,
        ],
        // 5 سقوط الصخرة
        [
          DiggerDirection.right,
          DiggerDirection.right,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.left,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.right,
          DiggerDirection.left,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.right,
          DiggerDirection.left,
          DiggerDirection.left,
        ],
        // 6 القنفذ والصخرة
        [
          DiggerDirection.right,
          DiggerDirection.right,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.left,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.right,
          DiggerDirection.left,
          DiggerDirection.left,
          DiggerDirection.down,
          DiggerDirection.down,
        ],
        // 7 متاهة صغيرة
        [
          DiggerDirection.right,
          DiggerDirection.right,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.left,
          DiggerDirection.left,
          DiggerDirection.right,
          DiggerDirection.right,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.left,
          DiggerDirection.left,
        ],
        // 8 التحدي الأخير
        [
          DiggerDirection.right,
          DiggerDirection.right,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.down,
          DiggerDirection.left,
          DiggerDirection.left,
          DiggerDirection.down,
          DiggerDirection.right,
          DiggerDirection.right,
          DiggerDirection.down,
          DiggerDirection.left,
          DiggerDirection.left,
        ],
      ];
      expect(solutions.length, diggerLevels.length);
      for (var i = 0; i < diggerLevels.length; i++) {
        final lv = diggerLevels[i];
        final s = DiggerEngine.parse(lv);
        for (var j = 0; j < solutions[i].length; j++) {
          expect(
            DiggerEngine.move(s, solutions[i][j]),
            isTrue,
            reason: 'level ${lv.number} move $j (${solutions[i][j]})',
          );
        }
        expect(s.completed, isTrue, reason: 'level ${lv.number}');
        expect(
          s.collected,
          lv.diamondCount,
          reason: 'level ${lv.number}',
        );
      }
    });
  });

  group('digger screens', () {
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
          .setMockMethodCallHandler(
            const MethodChannel('flutter_tts'),
            null,
          );
    });

    Future<void> pumpSelect(WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(home: DiggerLevelSelectScreen()),
      );
      await tester.pumpAndSettle();
    }

    Future<void> tapArrow(
      WidgetTester tester,
      IconData icon,
    ) async {
      await tester.tap(find.byIcon(icon));
      // المؤقت الدوري يمنع pumpAndSettle؛ ضغطة واحدة تكفي للحركة.
      await tester.pump();
    }

    testWidgets('level select lists 8 levels; only the first is open',
        (tester) async {
      await pumpSelect(tester);
      expect(find.text('حفّار الماس ⛏️'), findsOneWidget);
      expect(find.text('أول حفرة'), findsOneWidget);
      expect(find.text('التحدي الأخير'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsNWidgets(7));
    });

    testWidgets('restart button resets the level immediately',
        (tester) async {
      await pumpSelect(tester);
      await tester.tap(find.text('المرحلة 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('فهمت، لنبدأ!'));
      await tester.pump();
      expect(find.text('إعادة المرحلة'), findsOneWidget);
      // جمع ماسة أولاً ثم إعادة المرحلة.
      await tapArrow(tester, Icons.keyboard_arrow_right);
      await tapArrow(tester, Icons.keyboard_arrow_right);
      expect(find.text('💎 1 / 3'), findsOneWidget);
      await tester.tap(find.text('إعادة المرحلة'));
      await tester.pump();
      expect(find.text('💎 0 / 3'), findsOneWidget);
      expect(find.text('⏱ 120 ث'), findsOneWidget);
      expect(find.text('🐰'), findsOneWidget);
    });

    testWidgets('playing level 1: arrows dig and collect, exit completes',
        (tester) async {
      await pumpSelect(tester);
      await tester.tap(find.text('المرحلة 1'));
      await tester.pumpAndSettle();
      expect(
        find.text('المرحلة 1 ⛏️ — أول حفرة'),
        findsOneWidget,
      );
      expect(find.text('💎 0 / 3'), findsOneWidget);
      expect(find.text('⏱ 120 ث'), findsOneWidget);
      expect(find.text('🐰'), findsOneWidget);
      // بطاقة التعليمات أول مرة: تخطيها.
      await tester.tap(find.text('فهمت، لنبدأ!'));
      await tester.pump();
      // يمين، يمين: جمع أول ماسة.
      await tapArrow(tester, Icons.keyboard_arrow_right);
      await tapArrow(tester, Icons.keyboard_arrow_right);
      expect(find.text('💎 1 / 3'), findsOneWidget);
      // بقية الحل: أسفل ×5، يسار ×2، أسفل.
      for (var i = 0; i < 5; i++) {
        await tapArrow(tester, Icons.keyboard_arrow_down);
      }
      await tapArrow(tester, Icons.keyboard_arrow_left);
      await tapArrow(tester, Icons.keyboard_arrow_left);
      await tapArrow(tester, Icons.keyboard_arrow_down);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('رائع! 🎉'), findsOneWidget);
      // الانتقال للمرحلة التالية.
      await tester.tap(find.text('المرحلة التالية'));
      await tester.pumpAndSettle();
      expect(
        find.text('المرحلة 2 ⛏️ — طريق متعرج'),
        findsOneWidget,
      );
    });

    testWidgets('finishing level 1 marks it with a star on the select screen',
        (tester) async {
      await pumpSelect(tester);
      await tester.tap(find.text('المرحلة 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('فهمت، لنبدأ!'));
      await tester.pump();
      const moves = [
        Icons.keyboard_arrow_right,
        Icons.keyboard_arrow_right,
        Icons.keyboard_arrow_down,
        Icons.keyboard_arrow_down,
        Icons.keyboard_arrow_down,
        Icons.keyboard_arrow_down,
        Icons.keyboard_arrow_down,
        Icons.keyboard_arrow_left,
        Icons.keyboard_arrow_left,
        Icons.keyboard_arrow_down,
      ];
      for (final icon in moves) {
        await tapArrow(tester, icon);
      }
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('رائع! 🎉'), findsOneWidget);
      await tester.tap(find.text('حسناً'));
      await tester.pumpAndSettle();
      expect(find.text('حفّار الماس ⛏️'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('المرحلة 2'), findsOneWidget);
    });
  });
}
