// اختبارات وقت الاستخدام — المرحلة الثانية 2.7.
import 'package:animals/services/screen_time.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('الحد الافتراضي بلا حد، والقيم المسموحة فقط تُحفظ', () async {
    expect(await ScreenTime.limitMinutes('فارس'), 0);
    await ScreenTime.setLimitMinutes('فارس', 30);
    expect(await ScreenTime.limitMinutes('فارس'), 30);
    await ScreenTime.setLimitMinutes('فارس', 99);
    expect(await ScreenTime.limitMinutes('فارس'), 0);
  });

  test('تسجيل الدقائق يتراكم في اليوم نفسه', () async {
    await ScreenTime.recordMinutes('فارس', 10);
    await ScreenTime.recordMinutes('فارس', 5);
    expect(await ScreenTime.minutesToday('فارس'), 15);
    expect(await ScreenTime.minutesToday('فهد'), 0);
  });

  test('المتبقي والبلوغ يُحسبان من الحد والاستخدام', () async {
    await ScreenTime.setLimitMinutes('فارس', 30);
    expect(await ScreenTime.remainingMinutes('فارس'), 30);
    expect(await ScreenTime.limitReached('فارس'), isFalse);
    await ScreenTime.recordMinutes('فارس', 30);
    expect(await ScreenTime.remainingMinutes('فارس'), 0);
    expect(await ScreenTime.limitReached('فارس'), isTrue);
    await ScreenTime.recordMinutes('فارس', 10);
    expect(await ScreenTime.remainingMinutes('فارس'), 0);
  });

  test('بلا حد لا بلوغ أبداً', () async {
    await ScreenTime.recordMinutes('فارس', 500);
    expect(await ScreenTime.remainingMinutes('فارس'), isNull);
    expect(await ScreenTime.limitReached('فارس'), isFalse);
  });

  test('تذكير الراحة يُسجل مرة واحدة في اليوم', () async {
    expect(await ScreenTime.restRemindedToday('فارس'), isFalse);
    await ScreenTime.markRestReminded('فارس');
    expect(await ScreenTime.restRemindedToday('فارس'), isTrue);
    expect(await ScreenTime.restRemindedToday('فهد'), isFalse);
  });
}
