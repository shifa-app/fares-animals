import 'package:animals/services/child_profile.dart';
import 'package:animals/services/progress_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('منع النجوم المكررة', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('إعادة النشاط نفسه لا تمنح نجمة جديدة', () async {
      expect(await ProgressStore.awardStarsOnce('animal_الأسد', 1), isTrue);
      expect(await ProgressStore.stars(), 1);
      // إعادة النشاط نفسه: بلا نجمة جديدة.
      expect(await ProgressStore.awardStarsOnce('animal_الأسد', 1), isFalse);
      expect(await ProgressStore.stars(), 1);
      expect(await ProgressStore.hasStarFor('animal_الأسد'), isTrue);
      expect(await ProgressStore.hasStarFor('animal_الفيل'), isFalse);
    });

    test('إنجازات مختلفة تمنح نجومها كل على حدة', () async {
      expect(await ProgressStore.awardStarsOnce('game_memory_win', 2), isTrue);
      expect(await ProgressStore.awardStarsOnce('diamond_level_3', 1), isTrue);
      expect(await ProgressStore.awardStarsOnce('game_memory_win', 2), isFalse);
      expect(await ProgressStore.awardStarsOnce('diamond_level_4', 1), isTrue);
      expect(await ProgressStore.stars(), 4);
    });

    test('سجل النجوم مستقل لكل طفل', () async {
      expect(await ProgressStore.awardStarsOnce('animal_الأسد', 1), isTrue);
      expect(await ProgressStore.stars(), 1);
      await ChildProfile.setCurrent('فهد');
      expect(await ProgressStore.stars(), 0);
      expect(await ProgressStore.awardStarsOnce('animal_الأسد', 1), isTrue);
      expect(await ProgressStore.stars(), 1);
      await ChildProfile.setCurrent('فارس');
      expect(await ProgressStore.stars(), 1);
      expect(await ProgressStore.awardStarsOnce('animal_الأسد', 1), isFalse);
    });

    test(
      'إعادة ضبط التقدم تمسح سجل النجوم فيستطيع الطفل كسبها من جديد',
      () async {
        expect(await ProgressStore.awardStarsOnce('animal_الأسد', 1), isTrue);
        await ProgressStore.resetAll();
        expect(await ProgressStore.stars(), 0);
        expect(await ProgressStore.hasStarFor('animal_الأسد'), isFalse);
        expect(await ProgressStore.awardStarsOnce('animal_الأسد', 1), isTrue);
        expect(await ProgressStore.stars(), 1);
      },
    );
  });
}
