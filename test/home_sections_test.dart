// اختبارات الرئيسية الأحد عشر — المرحلة الثانية 2.2.
import 'package:animals/screens/home_screen.dart';
import 'package:animals/services/progress_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sections = [
    'الحيوانات',
    'القرآن',
    'الحروف والكلمات',
    'الرياضيات',
    'التعلم الديني',
    'القصص',
    'الألعاب',
    'عالم فارس',
    'نجومي وإنجازاتي',
    'الرسم والتلوين',
    'ركن الوالدين',
  ];

  testWidgets('الرئيسية تعرض الأقسام الأحد عشر كلها', (tester) async {
    // شاشة اختبار طويلة لتظهر الشبكة كلها دون تمرير
    // (6 صفوف × ~376 بكسل + بطاقة الترحيب ≈ 2600 بكسل).
    tester.view.physicalSize = const Size(800, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump();
    await tester.pump();
    for (final label in sections) {
      expect(find.text(label), findsOneWidget, reason: 'القسم مفقود: $label');
    }
    // بطاقة الترحيب تعرض المستوى الافتراضي لفارس (5–6 سنوات).
    expect(find.textContaining('المستوى:'), findsOneWidget);
    expect(find.textContaining('5–6 سنوات'), findsOneWidget);
  });

  testWidgets('آخر الأنشطة تظهر في الرئيسية بعد التعلم', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await ProgressStore.markLearned('أسد');
    await ProgressStore.markReligion('number_3');
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump();
    await tester.pump();
    expect(find.text('آخر أنشطتك'), findsOneWidget);
    expect(find.text('تعلّمت أسد'), findsOneWidget);
    expect(find.text('تعلّم الرقم 3'), findsOneWidget);
  });

  testWidgets('زر التعليمات الصوتية موجود في الرئيسية', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pump();
    expect(find.byIcon(Icons.volume_up), findsOneWidget);
  });
}
