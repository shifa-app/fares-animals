// شاشتا G01 وG02: العرض، وبطاقة التعليمات القابلة للتخطي،
// والضغط على خيار (بلا ضغط على أزرار الصوت في الاختبارات).
import 'package:animals/data/letters.dart';
import 'package:animals/screens/games/color_game.dart';
import 'package:animals/screens/games/letter_game.dart';
import 'package:animals/screens/games/missing_number_game.dart';
import 'package:animals/screens/games/puzzle_game.dart';
import 'package:animals/screens/games/shadow_game.dart';
import 'package:animals/screens/games/shape_game.dart';
import 'package:animals/screens/learn_screen.dart';
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
    // النطق الآلي (TTS) بلا منصة حقيقية في الاختبارات: ردّ فوري
    // على كل استدعاء حتى يكمل مسار التشجيع والتعليمات دون تعليق.
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

  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: screen));
    await tester.pumpAndSettle();
  }

  group('shadow game (G01)', () {
    testWidgets('shows the shadow, 4 options and the guide card',
        (tester) async {
      await pumpScreen(tester, const ShadowGameScreen());
      expect(find.textContaining('صائد الظلال'), findsWidgets);
      expect(find.text('ما صاحب هذا الظل؟'), findsOneWidget);
      // بطاقة التعليمات تظهر في المرة الأولى.
      expect(find.text('فهمت، لنبدأ!'), findsOneWidget);
      // 4 أزرار خيارات (أسماء الحيوانات مع إيموجي).
      expect(find.byType(ElevatedButton), findsNWidgets(5)); // 4 + زر البطاقة
      // ظل مرسوم بـ CustomPainter.
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is CustomPaint &&
              (w.painter is ShadowPainter || w.foregroundPainter is ShadowPainter),
        ),
        findsOneWidget,
      );
    });

    testWidgets('dismissing the guide hides it; tapping an option responds',
        (tester) async {
      await pumpScreen(tester, const ShadowGameScreen());
      await tester.tap(find.text('فهمت، لنبدأ!'));
      await tester.pumpAndSettle();
      expect(find.text('فهمت، لنبدأ!'), findsNothing);
      // اضغط أول خيار: إما رسالة «حاول مرة أخرى» أو الانتقال للجولة 2.
      final options = find.byType(ElevatedButton);
      await tester.tap(options.first);
      // تقدّم صريح بالوقت: إجابة صحيحة تنتظر ثانية قبل الجولة التالية.
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(
        tester.any(find.text('حاول مرة أخرى يا بطل!')) ||
            tester.any(find.textContaining('الجولة 2 من 5')),
        isTrue,
      );
    });
  });

  group('letter game (G02)', () {
    testWidgets('shows a big letter and 4 animal pictures', (tester) async {
      await pumpScreen(tester, const LetterGameScreen());
      expect(find.textContaining('وصّل الحروف والصور'), findsWidgets);
      expect(find.text('أي حيوان يبدأ بهذا الحرف؟'), findsOneWidget);
      expect(find.text('فهمت، لنبدأ!'), findsOneWidget);
      // الحرف الكبير (خط 100).
      final bigTexts = tester
          .widgetList<Text>(find.byType(Text))
          .where((t) => t.style?.fontSize == 100)
          .toList();
      expect(bigTexts.length, 1);
      // 4 صور حيوانات (أزرار InkWell داخل شبكة الخيارات فقط،
      // بلا أزرار الأيقونات والبطاقات الأخرى في الشاشة).
      expect(
        find.descendant(
          of: find.byType(GridView),
          matching: find.byType(InkWell),
        ),
        findsNWidgets(4),
      );
    });

    testWidgets('tapping the animal starting with the letter advances',
        (tester) async {
      await pumpScreen(tester, const LetterGameScreen());
      final bigLetter = tester
          .widgetList<Text>(find.byType(Text))
          .firstWhere((t) => t.style?.fontSize == 100)
          .data!;
      final animalName = arabicLetters
          .firstWhere((l) => l.letter == bigLetter)
          .animalName!;
      await tester.tap(find.text(animalName));
      // تقدّم صريح بالوقت: إجابة صحيحة تنتظر ثانية قبل الجولة التالية.
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.textContaining('الجولة 2 من 5'), findsOneWidget);
    });
  });

  group('color game (G03)', () {
    testWidgets('shows 9 dots; catching the 3 target dots advances',
        (tester) async {
      await pumpScreen(tester, const ColorGameScreen());
      expect(find.textContaining('صياد الألوان'), findsWidgets);
      expect(find.textContaining('اصطد اللون'), findsWidgets);
      expect(
        find.descendant(
          of: find.byType(GridView),
          matching: find.byType(GestureDetector),
        ),
        findsNWidgets(9),
      );

      // اللون المطلوب من نص السؤال، والنقاط الثلاث بلونه.
      final question = tester
          .widgetList<Text>(find.byType(Text))
          .firstWhere((t) => (t.data ?? '').startsWith('اصطد اللون'))
          .data!;
      final targetName = question
          .replaceFirst('اصطد اللون ', '')
          .replaceFirst('!', '');
      final targetColor =
          gameColors.firstWhere((c) => c.name == targetName).color;
      for (var caught = 0; caught < 3; caught++) {
        final dots = tester
            .widgetList<Container>(find.byType(Container))
            .where(
              (c) =>
                  c.decoration is BoxDecoration &&
                  (c.decoration as BoxDecoration).shape ==
                      BoxShape.circle &&
                  (c.decoration as BoxDecoration).color == targetColor,
            )
            .toList();
        expect(dots.length, 3 - caught, reason: 'target dots left');
        await tester.tap(find.byWidget(dots.first));
        await tester.pump(const Duration(milliseconds: 300));
      }
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.textContaining('الجولة 2 من 5'), findsOneWidget);
    });
  });

  group('shape game (G04)', () {
    testWidgets('shows a painted shape and 4 names; correct tap advances',
        (tester) async {
      await pumpScreen(tester, const ShapeGameScreen());
      expect(find.textContaining('عالم الأشكال'), findsWidgets);
      // الشكل المعروض (CustomPaint بـ ShapePainter) وأسماؤه الأربعة.
      final painters = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((c) => c.painter)
          .whereType<ShapePainter>()
          .toList();
      expect(painters.length, 1);
      final shapeName =
          gameShapes.firstWhere((s) => s.$1 == painters.first.shape).$2;
      expect(
        find.descendant(
          of: find.byType(GridView),
          matching: find.byType(ElevatedButton),
        ),
        findsNWidgets(4),
      );
      await tester.tap(find.text(shapeName));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.textContaining('الجولة 2 من 5'), findsOneWidget);
    });
  });

  group('counting game (G05)', () {
    testWidgets('shows the animal count and 3 options; correct tap advances',
        (tester) async {
      await pumpScreen(tester, const CountingGameScreen());
      expect(find.textContaining('عدّ مع فارس'), findsWidgets);
      expect(find.text('سهل (حتى 5)'), findsOneWidget);
      expect(find.text('متوسط (حتى 10)'), findsOneWidget);
      expect(find.text('صعب (حتى 20)'), findsOneWidget);
      // الخيارات الثلاثة (خط 32)؛ واحد منها صحيح — نجرّبها حتى تتقدم الجولة.
      final options = tester
          .widgetList<Text>(find.byType(Text))
          .where((t) => t.style?.fontSize == 32)
          .map((t) => t.data ?? '')
          .toList();
      expect(options.length, 3);
      for (final o in options) {
        if (tester.any(find.textContaining('الجولة 2 من 5'))) break;
        await tester.tap(find.text(o));
        await tester.pump(const Duration(seconds: 2));
      }
      await tester.pumpAndSettle();
      expect(find.textContaining('الجولة 2 من 5'), findsOneWidget);
    });

    testWidgets('easy level limits the options to 5', (tester) async {
      await pumpScreen(tester, const CountingGameScreen());
      await tester.tap(find.text('سهل (حتى 5)'));
      await tester.pumpAndSettle();
      expect(find.textContaining('الجولة 1 من 5'), findsOneWidget);
      final options = tester
          .widgetList<Text>(find.byType(Text))
          .where((t) => t.style?.fontSize == 32)
          .map((t) => int.parse(t.data ?? '0'))
          .toList();
      expect(options.length, 3);
      expect(options.every((v) => v >= 1 && v <= 5), isTrue);
    });
  });

  group('missing number game (G06)', () {
    testWidgets('shows a sequence with one gap; correct tap advances',
        (tester) async {
      await pumpScreen(tester, const MissingNumberGameScreen());
      expect(find.textContaining('أكمل الرقم الناقص'), findsWidgets);
      expect(find.text('سهل'), findsOneWidget);
      expect(find.text('خبير'), findsOneWidget);
      // خانات التسلسل (خط 36): 4 أعداد + علامة استفهام.
      final seqTexts = tester
          .widgetList<Text>(find.byType(Text))
          .where((t) => t.style?.fontSize == 36)
          .map((t) => t.data ?? '')
          .toList();
      expect(seqTexts.length, 5);
      expect(seqTexts, contains('؟'));
      final seq = seqTexts
          .map((s) => s == '؟' ? null : int.parse(s))
          .toList();
      final missing = seq.indexOf(null);
      var step = 0;
      for (var i = 0; i < seq.length - 1; i++) {
        if (seq[i] != null && seq[i + 1] != null) {
          step = seq[i + 1]! - seq[i]!;
          break;
        }
      }
      final answer = seq[missing - 1]! + step;
      await tester.tap(find.text('$answer'));
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.textContaining('الجولة 2 من 5'), findsOneWidget);
    });

    testWidgets('expert level restarts the game', (tester) async {
      await pumpScreen(tester, const MissingNumberGameScreen());
      await tester.tap(find.text('خبير'));
      await tester.pumpAndSettle();
      expect(find.textContaining('الجولة 1 من 5'), findsOneWidget);
      expect(find.text('؟'), findsOneWidget);
    });
  });

  group('puzzle game (G07)', () {
    testWidgets('shows a board with one missing cell; correct piece advances',
        (tester) async {
      await pumpScreen(tester, const PuzzleGameScreen());
      expect(find.textContaining('أحجية الحيوانات'), findsWidgets);
      expect(find.text('أكمل الصورة! ما القطعة الناقصة؟'), findsOneWidget);
      expect(find.text('؟'), findsOneWidget);
      expect(find.text('سهل'), findsOneWidget);
      expect(find.text('صعب'), findsOneWidget);
      // القطع الثلاث المرشحة: صور داخل أزرار (قطع اللوحة ليست داخل أزرار).
      // الضغط على الزر نفسه لا على الصورة (الصورة المقصوصة أكبر من
      // مساحتها الظاهرة فقد يقع مركزها خارج منطقة الضغط).
      final buttons = find.ancestor(
        of: find.byType(Image),
        matching: find.byType(ElevatedButton),
      );
      expect(buttons, findsNWidgets(3));
      for (var i = 0; i < 3; i++) {
        if (tester.any(find.textContaining('الجولة 2 من 5'))) break;
        await tester.tap(buttons.at(i));
        await tester.pump(const Duration(seconds: 2));
      }
      await tester.pumpAndSettle();
      expect(find.textContaining('الجولة 2 من 5'), findsOneWidget);
    });

    testWidgets('hard level shows a 3x3 board', (tester) async {
      await pumpScreen(tester, const PuzzleGameScreen());
      await tester.tap(find.text('صعب'));
      await tester.pumpAndSettle();
      expect(find.textContaining('الجولة 1 من 5'), findsOneWidget);
      // لوحة 3×3 فيها 9 خلايا: 8 قطع صور + خلية ناقصة واحدة.
      final boardPieces = find.descendant(
        of: find.byType(GridView),
        matching: find.byType(Image),
      );
      expect(boardPieces, findsNWidgets(8));
      expect(find.text('؟'), findsOneWidget);
    });
  });

  group('game painters', () {
    testWidgets('all shadow animals and all shapes paint without errors',
        (tester) async {
      for (final s in shadowAnimals) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomPaint(
                painter: ShadowPainter(s.id),
                size: const Size(200, 200),
              ),
            ),
          ),
        );
        await tester.pump();
      }
      for (final shape in gameShapes) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomPaint(
                painter: ShapePainter(shape: shape.$1, color: Colors.red),
                size: const Size(200, 200),
              ),
            ),
          ),
        );
        await tester.pump();
      }
    });
  });
}
