// اختبارات التصنيف العلمي — المرحلة الثانية 2.4.
import 'package:animals/data/animal_science.dart';
import 'package:animals/data/animals.dart';
import 'package:animals/screens/animals_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('كل حيوان من المئة له بيانات علمية كاملة وصالحة', () {
    expect(animalScience.length, animals.length);
    expect(animalScience.keys.toSet(), animals.map((a) => a.nameAr).toSet());
    for (final entry in animalScience.entries) {
      final s = entry.value;
      expect(s.movement.trim(), isNotEmpty, reason: entry.key);
      expect(s.lifespan.trim(), isNotEmpty, reason: entry.key);
      expect(animalSizes, contains(s.size), reason: entry.key);
      expect(animalDiets, contains(s.diet), reason: entry.key);
    }
  });

  test('أعداد الفئات العلمية كما هو متوقع', () {
    int count(SciClass c) =>
        animalScience.values.where((s) => s.sciClass == c).length;
    expect(count(SciClass.mammal), 45);
    expect(count(SciClass.bird), 26);
    expect(count(SciClass.fish), 5);
    expect(count(SciClass.reptile), 6);
    expect(count(SciClass.amphibian), 1);
    expect(count(SciClass.insect), 8);
    expect(count(SciClass.arachnid), 2);
    expect(count(SciClass.invertebrate), 7);
  });

  test('تصحيحات علمية معروفة: الحوت ثديي، والبطريق طائر، والضفدع برمائي', () {
    expect(animalScience['حوت']!.sciClass, SciClass.mammal);
    expect(animalScience['دولفين']!.sciClass, SciClass.mammal);
    expect(animalScience['فقمة']!.sciClass, SciClass.mammal);
    expect(animalScience['بطريق']!.sciClass, SciClass.bird);
    expect(animalScience['نعامة']!.sciClass, SciClass.bird);
    expect(animalScience['ضفدع']!.sciClass, SciClass.amphibian);
    expect(animalScience['سلحفاة بحرية']!.sciClass, SciClass.reptile);
    expect(animalScience['عنكبوت']!.sciClass, SciClass.arachnid);
    expect(animalScience['عقرب']!.sciClass, SciClass.arachnid);
    expect(animalScience['نحلة']!.sciClass, SciClass.insect);
    expect(animalScience['فراشة']!.sciClass, SciClass.insect);
    expect(animalScience['أخطبوط']!.sciClass, SciClass.invertebrate);
    expect(animalScience['سلطعون']!.sciClass, SciClass.invertebrate);
    expect(animalScience['قنديل البحر']!.sciClass, SciClass.invertebrate);
    expect(animalScience['ثعبان البحر']!.sciClass, SciClass.fish);
    expect(animalScience['حصان البحر']!.sciClass, SciClass.fish);
  });

  test('فئة «الزواحف والحشرات» القديمة تنقسم إلى 5 فئات علمية صحيحة', () {
    final old = animals.where((a) => a.category == 'reptiles').toList();
    expect(old.length, 16);
    final classes =
        old.map((a) => animalScience[a.nameAr]!.sciClass).toSet();
    expect(classes, {
      SciClass.reptile,
      SciClass.amphibian,
      SciClass.insect,
      SciClass.arachnid,
      SciClass.invertebrate,
    });
  });

  testWidgets('شاشة الحيوانات تبدّل بين البيئة والتصنيف العلمي', (tester) async {
    tester.view.physicalSize = const Size(2200, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(const MaterialApp(home: AnimalsScreen()));
    await tester.pump();
    await tester.pump();
    expect(find.text('حسب البيئة'), findsOneWidget);
    expect(find.text('حسب التصنيف العلمي'), findsOneWidget);
    // الوضع الافتراضي: فئات بيئية.
    expect(find.text('حيوانات الغابة'), findsOneWidget);
    // التبديل إلى التصنيف العلمي يعرض الفئات العلمية بأعدادها.
    await tester.tap(find.text('حسب التصنيف العلمي'));
    await tester.pump();
    expect(find.text('ثدييات (45)'), findsOneWidget);
    expect(find.text('طيور (26)'), findsOneWidget);
    // تصفية الثدييات: الأسد ظاهر، والعصفور مختفٍ.
    await tester.tap(find.text('ثدييات (45)'));
    await tester.pump();
    expect(find.text('أسد'), findsWidgets);
    expect(find.text('عصفور'), findsNothing);
    // مرّر شريط الفئات أفقياً لتظهر آخر الفئات.
    await tester.drag(find.byType(ListView).first, const Offset(-1200, 0));
    await tester.pump();
    expect(find.text('لافقاريات (7)'), findsOneWidget);
  });

  testWidgets('صفحة الحيوان تعرض بطاقة التصنيف العلمي', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final whale = animals.firstWhere((a) => a.nameAr == 'حوت');
    await tester.pumpWidget(MaterialApp(home: AnimalDetailScreen(animal: whale)));
    await tester.pump();
    await tester.pump();
    expect(find.text('تصنيفه العلمي: ثدييات'), findsOneWidget);
    expect(find.textContaining('تلد صغارها'), findsOneWidget);
    expect(find.text('يتحرك: يسبح'), findsOneWidget);
    expect(find.text('بري'), findsOneWidget);
    expect(find.text('آكل أسماك'), findsOneWidget);
  });
}
