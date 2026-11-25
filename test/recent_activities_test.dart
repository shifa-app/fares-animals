// اختبارات آخر الأنشطة — المرحلة الثانية 2.2.
import 'package:animals/services/progress_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('التسجيل يحتفظ بآخر 4 أنشطة فقط، الأحدث أولاً', () async {
    await ProgressStore.logActivity('نشاط 1');
    await ProgressStore.logActivity('نشاط 2');
    await ProgressStore.logActivity('نشاط 3');
    await ProgressStore.logActivity('نشاط 4');
    await ProgressStore.logActivity('نشاط 5');
    final recent = await ProgressStore.recentActivities();
    expect(recent.length, 4);
    expect(recent.first, 'نشاط 5');
    expect(recent.last, 'نشاط 2');
  });

  test('النشاط المتكرر متتالياً لا يُسجل مرتين', () async {
    await ProgressStore.logActivity('تعلّمت أسد');
    await ProgressStore.logActivity('تعلّمت أسد');
    expect((await ProgressStore.recentActivities()).length, 1);
  });

  test('تعلم حيوان أو حرف أو رقم يُسجل تلقائياً بوصف عربي', () async {
    await ProgressStore.markLearned('أسد');
    await ProgressStore.markReligion('number_3');
    await ProgressStore.markReligion('letter_ar_ب');
    await ProgressStore.markReligion('memorize_1');
    final recent = await ProgressStore.recentActivities();
    expect(recent, contains('تعلّمت أسد'));
    expect(recent, contains('تعلّم الرقم 3'));
    expect(recent, contains('تعلّم الحرف ب'));
    expect(recent, contains('حفظ سورة الفاتحة'));
  });

  test('إعادة ضبط التقدم تمسح آخر الأنشطة أيضاً', () async {
    await ProgressStore.logActivity('نشاط');
    await ProgressStore.resetAll();
    expect(await ProgressStore.recentActivities(), isEmpty);
  });
}
