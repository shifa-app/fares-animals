// اختبارات المفضلة — المرحلة الثانية 2.5.
import 'package:animals/services/child_profile.dart';
import 'package:animals/services/progress_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('تبديل المفضلة يضيف ثم يزيل الحيوان', () async {
    expect(await ProgressStore.isFavorite('أسد'), isFalse);
    expect(await ProgressStore.toggleFavorite('أسد'), isTrue);
    expect(await ProgressStore.isFavorite('أسد'), isTrue);
    expect(await ProgressStore.favorites(), ['أسد']);
    expect(await ProgressStore.toggleFavorite('أسد'), isFalse);
    expect(await ProgressStore.isFavorite('أسد'), isFalse);
    expect(await ProgressStore.favorites(), isEmpty);
  });

  test('المفضلة مستقلة لكل طفل', () async {
    await ChildProfile.setCurrent('فارس');
    await ProgressStore.toggleFavorite('أسد');
    await ChildProfile.setCurrent('فهد');
    expect(await ProgressStore.isFavorite('أسد'), isFalse);
    await ProgressStore.toggleFavorite('فيل');
    expect(await ProgressStore.favorites(), ['فيل']);
    await ChildProfile.setCurrent('فارس');
    expect(await ProgressStore.favorites(), ['أسد']);
  });

  test('إعادة ضبط التقدم تمسح المفضلة أيضاً', () async {
    await ProgressStore.toggleFavorite('أسد');
    await ProgressStore.resetAll();
    expect(await ProgressStore.favorites(), isEmpty);
  });
}
