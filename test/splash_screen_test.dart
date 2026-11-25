import 'package:animals/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('الشاشة الافتتاحية تعرض صورة المستخدم 5 ثوانٍ', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      const MaterialApp(home: SplashScreen()),
    );
    await tester.pump();
    // الصورة ظاهرة، والرئيسية لم تظهر بعد.
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('أهلاً يا فارس!'), findsNothing);

    // بعد 4 ثوانٍ ما زالت الافتتاحية.
    await tester.pump(const Duration(seconds: 4));
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('أهلاً يا فارس!'), findsNothing);

    // بعد الثانية الخامسة تنتقل للرئيسية.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('أهلاً يا فارس!'), findsOneWidget);
  });
}
