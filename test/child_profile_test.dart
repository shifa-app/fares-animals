import 'package:animals/services/child_profile.dart';
import 'package:animals/services/progress_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ChildProfile', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('الافتراضي: فارس، والقائمة فارس وفهد', () async {
      expect(await ChildProfile.currentChild(), 'فارس');
      expect(await ChildProfile.children(), ['فارس', 'فهد']);
    });

    test('إضافة طفل وتبديله يحفظان', () async {
      expect(await ChildProfile.addChild('عمر'), isTrue);
      expect(await ChildProfile.addChild('عمر'), isFalse); // مكرر
      expect(await ChildProfile.addChild('  '), isFalse); // فارغ
      await ChildProfile.setCurrent('عمر');
      expect(await ChildProfile.currentChild(), 'عمر');
      expect(await ChildProfile.children(), ['فارس', 'فهد', 'عمر']);
    });

    test('العنوان والإهداء حسب الطفل', () {
      expect(ChildProfile.appTitleFor('فهد'), 'فهد والحيوانات');
      expect(
        ChildProfile.dedicationFor('فارس'),
        'إهداء إلى ابني حبيبي فارس اسامة ابراهيم عبدالحكيم',
      );
      expect(ChildProfile.dedicationFor('فهد'), 'إهداء إلى ابني حبيبي فهد');
    });

    test('حذف طفل يمسح تقدمه ويبدّل الحالي إن لزم', () async {
      await ChildProfile.setCurrent('فهد');
      await ProgressStore.addStars(4);
      await ChildProfile.removeChild('فهد');
      expect(await ChildProfile.children(), ['فارس']);
      expect(await ChildProfile.currentChild(), 'فارس');
      // تقدم فهد المحذوف ذهب؛ وتقدم فارس ما زال صفراً.
      expect(await ProgressStore.stars(), 0);
    });

    test('لا يُحذف الطفل الوحيد', () async {
      await ChildProfile.removeChild('فهد');
      await ChildProfile.removeChild('فارس');
      expect(await ChildProfile.children(), ['فارس']);
    });
  });

  group('ProgressStore per child', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('نجوم مستقلة لكل طفل', () async {
      await ProgressStore.addStars(3); // فارس
      await ChildProfile.setCurrent('فهد');
      expect(await ProgressStore.stars(), 0);
      await ProgressStore.addStars(2); // فهد
      await ChildProfile.setCurrent('فارس');
      expect(await ProgressStore.stars(), 3);
      await ChildProfile.setCurrent('فهد');
      expect(await ProgressStore.stars(), 2);
    });

    test('تعلّم مستقل لكل طفل', () async {
      await ProgressStore.markLearned('أسد'); // فارس
      await ChildProfile.setCurrent('فهد');
      expect(await ProgressStore.isLearned('أسد'), isFalse);
      expect(await ProgressStore.learnedCount(['أسد', 'نمر']), 0);
    });

    test('ترحيل تقدم النسخة القديمة إلى فارس', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'stars_total': 7,
        'learned_أسد': true,
        'badges_unlocked': <String>['first_animal'],
      });
      await ChildProfile.migrateLegacyProgress();
      expect(await ProgressStore.stars(), 7);
      expect(await ProgressStore.isLearned('أسد'), isTrue);
      expect(await ProgressStore.badges(), {'first_animal'});
      // فهد لا يرث تقدم فارس.
      await ChildProfile.setCurrent('فهد');
      expect(await ProgressStore.stars(), 0);
    });

    test('إعادة الضبط تمسح الطفل الحالي فقط', () async {
      await ProgressStore.addStars(5); // فارس
      await ChildProfile.setCurrent('فهد');
      await ProgressStore.addStars(2); // فهد
      await ProgressStore.resetAll();
      expect(await ProgressStore.stars(), 0);
      await ChildProfile.setCurrent('فارس');
      expect(await ProgressStore.stars(), 5);
    });
  });
}
