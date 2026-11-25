import 'package:animals/app_version.dart';
import 'package:animals/widgets/app_footer.dart';
import 'package:animals/services/child_profile.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('الفوتر الصغير يعرض الحقوق والإهداء', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(bottomNavigationBar: AppFooter.small()),
      ),
    );
    await tester.pump();
    expect(find.text('جميع الحقوق محفوظة © فارس والحيوانات'), findsOneWidget);
    expect(
      find.text('إهداء إلى ابني حبيبي فارس اسامة ابراهيم عبدالحكيم'),
      findsOneWidget,
    );
    expect(find.text('الإصدار $appVersion'), findsOneWidget);
  });

  testWidgets('الفوتر يتبع الطفل الحالي', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await ChildProfile.setCurrent('فهد');
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(bottomNavigationBar: AppFooter.small()),
      ),
    );
    await tester.pump();
    expect(find.text('إهداء إلى ابني حبيبي فهد'), findsOneWidget);
  });

  testWidgets('الفوتر الكبير يعرض الإهداء بخط أكبر', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    const dedicationText =
        'إهداء إلى ابني حبيبي فارس اسامة ابراهيم عبدالحكيم';
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(bottomNavigationBar: AppFooter.big()),
      ),
    );
    await tester.pump();
    final bigSize = tester
        .widget<Text>(find.text(dedicationText))
        .style!
        .fontSize!;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(bottomNavigationBar: AppFooter.small()),
      ),
    );
    await tester.pump();
    final smallSize = tester
        .widget<Text>(find.text(dedicationText))
        .style!
        .fontSize!;
    expect(bigSize, greaterThan(smallSize));
    expect(find.text('جميع الحقوق محفوظة © فارس والحيوانات'), findsOneWidget);
    expect(find.text('الإصدار $appVersion'), findsOneWidget);
  });
}
