// اختبارات شاشة الرياضيات — المرحلة الثانية 2.2.
import 'package:animals/screens/math_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('شاشة الرياضيات تعرض الأرقام ولعبة العدّ', (tester) async {
    var numbersTapped = false;
    var countingTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: MathScreen(
          onNumbers: () => numbersTapped = true,
          onCounting: () => countingTapped = true,
        ),
      ),
    );
    await tester.pump();
    expect(find.text('الرياضيات'), findsOneWidget);
    expect(find.text('الأرقام 1 - 20'), findsOneWidget);
    expect(find.text('لعبة العدّ'), findsOneWidget);
    await tester.tap(find.text('الأرقام 1 - 20'));
    await tester.tap(find.text('لعبة العدّ'));
    expect(numbersTapped, isTrue);
    expect(countingTapped, isTrue);
  });
}
