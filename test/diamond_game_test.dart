import 'package:animals/data/diamond_levels.dart';
import 'package:animals/services/child_profile.dart';
import 'package:animals/services/progress_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('diamondLevels', () {
    test('عشر مراحل', () {
      expect(diamondLevels.length, 10);
    });

    test('الهدف يكبر والوقت يقل مع المراحل', () {
      for (var i = 0; i < diamondLevels.length; i++) {
        final lv = diamondLevels[i];
        expect(lv.level, i + 1);
        expect(lv.target, 5 + i);
        expect(lv.seconds, 32 - i);
      }
      expect(diamondLevel(1).target, 5);
      expect(diamondLevel(10).target, 14);
      expect(diamondLevel(1).seconds, 32);
      expect(diamondLevel(10).seconds, 23);
    });

    test('الماسة تختفي أسرع في المراحل المتقدمة، بحد أدنى 2.75 ث', () {
      expect(diamondLevel(1).despawnSeconds, 5.0);
      expect(diamondLevel(10).despawnSeconds, 2.75);
      for (final lv in diamondLevels) {
        expect(lv.despawnSeconds, greaterThanOrEqualTo(2.75));
      }
    });

    test('عدد الماسات معاً يزيد مع المراحل', () {
      expect(diamondLevel(1).maxDiamonds, 1);
      expect(diamondLevel(5).maxDiamonds, 1);
      expect(diamondLevel(6).maxDiamonds, 2);
      expect(diamondLevel(10).maxDiamonds, 2);
    });

    test('حيوان لكل مرحلة', () {
      expect(diamondAnimals.length, 10);
      expect(diamondAnimals.first, '🦁');
    });
  });

  group('ProgressStore diamond', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('تبدأ بالمرحلة 1 وتفتح التالية فقط', () async {
      expect(await ProgressStore.diamondUnlocked(), 1);
      await ProgressStore.unlockDiamondLevel(2);
      expect(await ProgressStore.diamondUnlocked(), 2);
      await ProgressStore.unlockDiamondLevel(2);
      expect(await ProgressStore.diamondUnlocked(), 2);
    });

    test('أفضل نتيجة مستقلة لكل طفل وكل مرحلة', () async {
      await ProgressStore.saveDiamondBest(1, 5);
      await ProgressStore.saveDiamondBest(1, 3); // الأقل لا يمحو الأعلى
      expect(await ProgressStore.diamondBest(1), 5);
      expect(await ProgressStore.diamondBest(2), 0);
      await ChildProfile.setCurrent('فهد');
      expect(await ProgressStore.diamondBest(1), 0);
      expect(await ProgressStore.diamondUnlocked(), 1);
    });
  });
}
