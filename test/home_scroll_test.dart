// اختبارات إصلاح الشاشة الرئيسية — ملاحظة المراجعة 1 في 2.0.0:
// بطاقة الترحيب والفوتر كانا يضغطان الصفحة فلا تظهر الأقسام،
// والتمرير كان يعمل فقط داخل منطقة الشبكة.
import 'package:animals/screens/home_screen.dart';
import 'package:animals/widgets/app_footer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpHome(WidgetTester tester) async {
    // منفذ هاتف قصير (800×1400) حتى تكون الأقسام الأخيرة تحت الطية.
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump();
    await tester.pump();
    expect(tester.takeException(), isNull);
  }

  testWidgets('بطاقة الترحيب بمقاس ثابت 136 ولا تتمدد', (tester) async {
    await pumpHome(tester);
    final card = find.byType(Card).first;
    expect(card, findsOneWidget);
    final box = find.ancestor(of: card, matching: find.byType(SizedBox));
    expect(tester.getSize(box).height, 136);
    expect(tester.takeException(), isNull);
  });

  testWidgets('الصف الأول من الأقسام ظاهر عند الفتح الأولى', (tester) async {
    await pumpHome(tester);
    expect(find.text('الحيوانات').hitTestable(), findsOneWidget);
    expect(find.text('القرآن').hitTestable(), findsOneWidget);
  });

  testWidgets('السحب على بطاقة الترحيب يمرّر الصفحة ويُظهر آخر الأقسام', (
    tester,
  ) async {
    await pumpHome(tester);
    // آخر الأقسام تحت الطية عند الفتح الأولى.
    expect(find.text('ركن الوالدين').hitTestable(), findsNothing);
    // السحب على بطاقة الترحيب نفسها (لا على الشبكة) يمرّر الصفحة.
    await tester.drag(find.byType(Card).first, const Offset(0, -800));
    await tester.pumpAndSettle();
    // صف أوسط صار ظاهراً بعد سحبة البطاقة.
    expect(find.text('القصص').hitTestable(), findsOneWidget);
    // أكمل التمرير من منتصف الشاشة حتى يظهر آخر قسم.
    await tester.dragFrom(const Offset(400, 700), const Offset(0, -800));
    await tester.pumpAndSettle();
    expect(find.text('ركن الوالدين').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('الفوتر يظهر في نهاية الصفحة الممرَّرة', (tester) async {
    await pumpHome(tester);
    // find.text (لا textContaining) حتى لا يطابق النص وRichText معاً،
    // وتحديد Scrollable الصفحة صراحة (الأول في الشجرة) لأن الشبكة
    // تنشئ Scrollable خاصاً بها رغم NeverScrollableScrollPhysics.
    await tester.scrollUntilVisible(
      find.text(appVersionLine),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(appVersionLine), findsOneWidget);
  });
}
