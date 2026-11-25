// اختبارات شاشة الرسم — المرحلة الثانية 2.2.
import 'package:animals/screens/drawing_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('شاشة الرسم تعرض اللوحة والألوان والأدوات', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DrawingScreen()));
    await tester.pump();
    expect(find.text('الرسم والتلوين'), findsOneWidget);
    expect(find.text('رفيع'), findsOneWidget);
    expect(find.text('وسط'), findsOneWidget);
    expect(find.text('سميك'), findsOneWidget);
    expect(find.text('ممحاة'), findsOneWidget);
    expect(find.byIcon(Icons.save), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
  });

  testWidgets('حفظ لوحة فارغة يطلب من الطفل الرسم أولاً', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DrawingScreen()));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.save));
    await tester.pump();
    expect(find.text('ارسم شيئاً أولاً!'), findsOneWidget);
  });
}
