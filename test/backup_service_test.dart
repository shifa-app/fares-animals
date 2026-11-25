import 'package:animals/services/backup_service.dart';
import 'package:animals/services/child_profile.dart';
import 'package:animals/services/progress_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('تصدير واستعادة تقدم الأطفال', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('جولة كاملة: تصدير ثم مسح ثم استعادة يعيد كل القيم', () async {
      // تقدّم حقيقي لطفلين.
      await ProgressStore.awardStarsOnce('animal_الأسد', 1);
      await ProgressStore.markLearned('الأسد');
      await ProgressStore.markReligion('letter_ar_ب');
      await ProgressStore.unlockBadge('first_animal');
      await ProgressStore.saveDiamondBest(2, 9);
      await ChildProfile.setCurrent('فهد');
      await ProgressStore.awardStarsOnce('animal_الفيل', 1);

      final json = await BackupService.exportJson();
      expect(json, contains('fares-animals-backup'));

      // مسح كل شيء كما بعد حذف التطبيق وإعادة تثبيته.
      final prefs = await SharedPreferences.getInstance();
      for (final k in prefs.getKeys().toList()) {
        await prefs.remove(k);
      }
      expect(await ProgressStore.stars(), 0);

      // الاستعادة.
      final result = await BackupService.importJson(json);
      expect(result.ok, isTrue);
      expect(result.restored, greaterThan(5));

      // فارس عاد تقدّمه كاملاً.
      await ChildProfile.setCurrent('فارس');
      expect(await ProgressStore.stars(), 1);
      expect(await ProgressStore.isLearned('الأسد'), isTrue);
      expect(await ProgressStore.isReligion('letter_ar_ب'), isTrue);
      expect(await ProgressStore.badges(), contains('first_animal'));
      expect(await ProgressStore.diamondBest(2), 9);
      // فهد أيضاً.
      await ChildProfile.setCurrent('فهد');
      expect(await ProgressStore.stars(), 1);
    });

    test('نص فارغ أو JSON تالف أو صيغة غريبة تُرفض برسالة واضحة', () async {
      final empty = await BackupService.importJson('   ');
      expect(empty.ok, isFalse);
      expect(empty.error, isNotNull);

      final broken = await BackupService.importJson('{ليس json');
      expect(broken.ok, isFalse);

      final foreign = await BackupService.importJson(
        '{"format":"other-app","version":1,"data":{}}',
      );
      expect(foreign.ok, isFalse);
      expect(foreign.error, contains('ليست نسخة احتياطية'));

      final noData = await BackupService.importJson(
        '{"format":"fares-animals-backup","version":1,"data":{}}',
      );
      expect(noData.ok, isFalse);
    });

    test('الاستعادة دمج آمن: لا تمسح قيماً غير موجودة في النسخة', () async {
      await ProgressStore.awardStarsOnce('animal_الأسد', 1);
      final json = await BackupService.exportJson();
      // تقدّم جديد بعد التصدير.
      await ProgressStore.awardStarsOnce('animal_الفيل', 1);
      expect(await ProgressStore.stars(), 2);

      final result = await BackupService.importJson(json);
      expect(result.ok, isTrue);
      // نجمة الفيل (بعد التصدير) بقيت؛ الاستعادة لم تمسحها.
      expect(await ProgressStore.stars(), 2);
      expect(await ProgressStore.hasStarFor('animal_الفيل'), isTrue);
    });
  });
}
