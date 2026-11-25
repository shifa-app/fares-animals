import 'package:animals/data/animals.dart';
import 'package:animals/services/app_sound.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// اختبارات مدير الصوت المركزي (AppSound).
///
/// ملاحظة: بيئة اختبار الوحدة بلا قنوات منصة حقيقية، فأي تشغيل فعلي
/// يفشل على مستوى المنصة ويُمسك داخل AppSound دون رمي استثناء.
/// ما يُختبر هنا هو العقد: لا نطق آلي عند غياب الصوت الحقيقي،
/// والإيقاف لا يعلّق، والـ Singleton واحد.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  const silentAnimal = Animal(
    nameAr: 'زرافة',
    nameEn: 'Giraffe',
    category: 'forest',
    imageUrl: 'https://example.com/giraffe.jpg',
    soundUrl: '',
    soundWord: 'همهمة!',
    home: 'تعيش في الغابة',
    food: 'تأكل أوراق الشجر',
    fact: 'الزرافة أطول حيوان.',
  );

  const soundingAnimal = Animal(
    nameAr: 'أسد',
    nameEn: 'Lion',
    category: 'forest',
    imageUrl: 'https://example.com/lion.jpg',
    soundUrl: 'https://example.com/lion-roar.mp3',
    soundWord: 'زئير!',
    home: 'يعيش في الغابة',
    food: 'يأكل اللحم',
    fact: 'الأسد ملك الغابة.',
  );

  group('AppSound singleton', () {
    test('instance is a single object', () {
      expect(identical(AppSound.instance, AppSound.instance), isTrue);
    });
  });

  group('playAnimalSound', () {
    test(
      'returns false for an animal without a real sound, without TTS',
      () async {
        // بلا صوت حقيقي: يجب أن يرجع false فوراً دون أي نطق آلي
        // لكلمة الصوت، ودون بدء أي تشغيل.
        final result = await AppSound.instance.playAnimalSound(silentAnimal);
        expect(result, isFalse);
        expect(AppSound.instance.isPlaying, isFalse);
      },
    );

    test(
      'returns false (no crash) when real playback cannot start here',
      () async {
        // في بيئة الاختبار بلا قنوات منصة، يفشل التشغيل الفعلي
        // فيُمسك الخطأ ويرجع false دون تعليق.
        final result = await AppSound.instance.playAnimalSound(soundingAnimal);
        expect(result, isFalse);
        expect(AppSound.instance.isPlaying, isFalse);
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );
  });

  group('stopAll', () {
    test('stops playback and clears the playing flag', () async {
      await AppSound.instance.playAnimalSound(silentAnimal);
      await AppSound.instance.stopAll();
      expect(AppSound.instance.isPlaying, isFalse);
      // استدعاء ثانٍ آمن أيضاً.
      await AppSound.instance.stopAll();
      expect(AppSound.instance.isPlaying, isFalse);
    });

    test('speak completes without throwing in this environment', () async {
      await AppSound.instance.speak('أحسنت يا بطل!');
      await AppSound.instance.stopAll();
      expect(AppSound.instance.isPlaying, isFalse);
    });
  });

  group('playUrl', () {
    test('unreachable url returns quickly without hanging the UI', () async {
      await AppSound.instance.playUrl(
        'https://invalid.example/no-such-sound.mp3',
      );
      expect(AppSound.instance.isPlaying, isFalse);
    }, timeout: const Timeout(Duration(seconds: 15)));
  });
}
