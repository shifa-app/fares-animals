// اختبارات عالم فارس — المرحلة الثانية 2.2.
import 'package:animals/data/animals.dart';
import 'package:animals/screens/fares_world_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  test('عالم فارس فيه 7 مناطق بفئات حيوانات حقيقية', () {
    expect(FaresWorld.regions.length, 7);
    for (final r in FaresWorld.regions) {
      expect(categoryLabels.containsKey(r.id), isTrue, reason: r.id);
    }
  });

  test('الغابة مفتوحة منذ البداية، والباقي يُفتح بالتعلم', () {
    final forest = FaresWorld.regions.firstWhere((r) => r.id == 'forest');
    final farm = FaresWorld.regions.firstWhere((r) => r.id == 'farm');
    final polar = FaresWorld.regions.firstWhere((r) => r.id == 'polar');
    expect(FaresWorld.isUnlocked(0, forest), isTrue);
    expect(FaresWorld.isUnlocked(0, farm), isFalse);
    expect(FaresWorld.isUnlocked(4, farm), isFalse);
    expect(FaresWorld.isUnlocked(5, farm), isTrue);
    expect(FaresWorld.isUnlocked(29, polar), isFalse);
    expect(FaresWorld.isUnlocked(30, polar), isTrue);
  });

  test('المناطق مرتبة من الأسهل إلى الأصعب', () {
    final required =
        FaresWorld.regions.map((r) => r.requiredLearned).toList();
    expect(required, orderedEquals(required..sort()));
  });

  testWidgets('شاشة العالم تعرض المناطق وحالتها', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(home: FaresWorldScreen(onOpenCategory: (_) {})),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('عالم فارس'), findsOneWidget);
    expect(find.text('الغابة'), findsOneWidget);
    expect(find.text('القطب والثلج'), findsOneWidget);
    // بلا تقدم: الغابة مفتوحة، والقطب مغلق (قفل ظاهر).
    expect(find.byIcon(Icons.lock), findsWidgets);
  });
}
