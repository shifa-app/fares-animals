// اختبارات المقارنة — المرحلة الثانية 2.5.
import 'package:animals/screens/compare_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('اختيار حيوانين يعرض جدول المقارنة بينهما', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CompareScreen()));
    await tester.pump();
    expect(find.text('اختر الحيوان الأول'), findsOneWidget);
    expect(find.text('اختر الحيوان الثاني'), findsOneWidget);
    // اختيار الأول: أسد.
    await tester.tap(find.text('اختر الحيوان الأول'));
    await tester.pumpAndSettle();
    expect(find.text('اختر حيواناً'), findsOneWidget);
    await tester.tap(find.text('أسد').first);
    await tester.pumpAndSettle();
    expect(find.text('اختر الحيوان الأول'), findsNothing);
    // اختيار الثاني: فيل.
    await tester.tap(find.text('اختر الحيوان الثاني'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('فيل').first);
    await tester.pumpAndSettle();
    // جدول المقارنة يظهر برؤوس الصفوف.
    expect(find.text('التصنيف العلمي'), findsOneWidget);
    expect(find.text('يتحرك'), findsOneWidget);
    expect(find.text('حجمه'), findsOneWidget);
    expect(find.text('أليف أم بري؟'), findsOneWidget);
    // كلا الحيوانين من الثدييات.
    expect(find.text('ثدييات'), findsWidgets);
  });
}
