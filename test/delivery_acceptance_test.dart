// بوابة تسليم 1.1.0: الشروط الستة المعتمدة في مكان واحد.
// كل شرط هنا تحقق من سلوك فعلي (لا من وجود كود)؛ التفاصيل الأعمق
// في ملفات الاختبار المخصصة لكل بند.
import 'package:animals/screens/home_screen.dart';
import 'package:animals/services/backup_service.dart';
import 'package:animals/services/badges.dart';
import 'package:animals/services/child_profile.dart';
import 'package:animals/services/levels.dart';
import 'package:animals/services/progress_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('شرط 1: الأقسام الأحد عشر', () {
    testWidgets('الرئيسية تعرض الأقسام الأحد عشر كلها', (tester) async {
      tester.view.physicalSize = const Size(800, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pump();
      await tester.pump();
      for (final label in [
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
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });
  });

  group('شرط 2: المستويات الأربعة', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('العمر نقطة بداية: 3 و4 و5 و6 و7 و8 و9 و10 إلى المستويات الأربعة',
        () {
      expect(LevelService.levelFromAge(3), AgeLevel.l34);
      expect(LevelService.levelFromAge(4), AgeLevel.l34);
      expect(LevelService.levelFromAge(5), AgeLevel.l56);
      expect(LevelService.levelFromAge(6), AgeLevel.l56);
      expect(LevelService.levelFromAge(7), AgeLevel.l78);
      expect(LevelService.levelFromAge(8), AgeLevel.l78);
      expect(LevelService.levelFromAge(9), AgeLevel.l910);
      expect(LevelService.levelFromAge(10), AgeLevel.l910);
    });

    test('لا صعود إلا بالإتقان، والوالد يعدّل المستوى بحرية', () async {
      expect(await LevelService.canAdvance('فارس'), isFalse);
      await LevelService.setLevel('فارس', AgeLevel.l910);
      expect(await LevelService.levelFor('فارس'), AgeLevel.l910);
    });
  });

  group('شرط 3: إدارة أكثر من طفل', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('إضافة طفل وتبديل الحالي وتقدم مستقل لكل طفل', () async {
      expect(await ChildProfile.children(), ['فارس', 'فهد']);
      expect(await ChildProfile.addChild('عمر'), isTrue);
      await ChildProfile.setCurrent('عمر');
      expect(await ChildProfile.currentChild(), 'عمر');
      await ProgressStore.awardStarsOnce('animal_الأسد', 1);
      expect(await ProgressStore.starsFor('عمر'), 1);
      expect(await ProgressStore.starsFor('فارس'), 0);
      expect(await ProgressStore.starsFor('فهد'), 0);
      // حذف طفل يبدّل الحالي ولا يمس تقدم الآخرين.
      await ChildProfile.setCurrent('فهد');
      await ChildProfile.removeChild('فهد');
      expect(await ChildProfile.children(), ['فارس', 'عمر']);
      expect(await ProgressStore.starsFor('عمر'), 1);
    });
  });

  group('شرط 4: حفظ التقدم', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('النجوم والتعلم والوضع الليلي تُقرأ من المخزن بعد كتابتها', () async {
      await ProgressStore.awardStarsOnce('animal_الأسد', 1);
      await ProgressStore.markLearned('الأسد');
      await ProgressStore.setNightMode(true);
      // قراءة جديدة من المخزن نفسه (كما بعد إغلاق التطبيق وإعادة فتحه).
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('c_فارس_stars_total'), 1);
      expect(prefs.getBool('c_فارس_learned_الأسد'), isTrue);
      // الوضع الليلي إعداد عام (مفتاح بلا بادئة طفل) في التطبيق.
      expect(prefs.getBool('night_mode'), isTrue);
      expect(await ProgressStore.stars(), 1);
      expect(await ProgressStore.isLearned('الأسد'), isTrue);
      expect(await ProgressStore.nightMode(), isTrue);
    });
  });

  group('شرط 5: النسخ الاحتياطي', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('تصدير ثم مسح ثم استعادة يعيد التقدم؛ والتالف يُرفض دون مساس',
        () async {
      await ProgressStore.awardStarsOnce('animal_الأسد', 1);
      await ProgressStore.markLearned('الأسد');
      final json = await BackupService.exportJson();
      expect(json, contains('fares-animals-backup'));

      await ProgressStore.resetAll();
      expect(await ProgressStore.stars(), 0);

      final broken = await BackupService.importJson('{ليس json');
      expect(broken.ok, isFalse);
      expect(await ProgressStore.stars(), 0);

      final result = await BackupService.importJson(json);
      expect(result.ok, isTrue);
      expect(await ProgressStore.stars(), 1);
      expect(await ProgressStore.isLearned('الأسد'), isTrue);
    });
  });

  group('شرط 6: لا تكرار للنجوم والأوسمة', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('إعادة النشاط نفسه لا تمنح نجمة ولا وساماً جديداً', () async {
      expect(await ProgressStore.awardStarsOnce('digger_level_1', 1), isTrue);
      expect(await ProgressStore.awardStarsOnce('digger_level_1', 1), isFalse);
      expect(await ProgressStore.stars(), 1);

      await ProgressStore.unlockBadge('digger');
      await ProgressStore.unlockBadge('digger');
      final badges = await ProgressStore.badges();
      expect(badges.where((b) => b == 'digger').length, 1);

      final unlocked = await unlockedBadges();
      expect(unlocked, contains('digger'));
      expect(await ProgressStore.stars(), 1);
    });
  });
}
