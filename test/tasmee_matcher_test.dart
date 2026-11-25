import 'package:animals/services/tasmee_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeAyahText', () {
    test('strips tashkeel and Uthmani small marks', () {
      expect(normalizeAyahText('سَبِّحِ ٱسۡمَ رَبِّكَ'), 'سبح اسم ربك');
      expect(normalizeAyahText('وَٱلۡعَـٰدِیَـٰتِ'), 'والعاديات');
      expect(normalizeAyahText('ضَبۡحࣰا'), 'ضبحا');
    });

    test('unifies alef, yeh and teh marbuta', () {
      expect(normalizeAyahText('ٱلَّذِی'), 'الذي');
      // الألف الفوقية هنا هي الألف نفسها: إله = ا ل ا ه.
      expect(normalizeAyahText('إِلَـٰهِ'), 'الاه');
      expect(normalizeAyahText('ٱلۡحَیَوٰةَ'), 'الحيواه');
      // الألف الفوقية بعد المقصورة زائدة: إلى = ا ل ي.
      expect(normalizeAyahText('إِلَىٰ'), 'الي');
    });

    test('removes ornaments and zero-width chars', () {
      expect(normalizeAyahText('۞ أَفَلَا یَعۡلَمُ'), 'افلا يعلم');
      // الألف الفوقية بعد الراء هي الألف: صراط.
      expect(normalizeAyahText('صِرَ ٰ⁠طَ'), 'صراط');
    });
  });

  group('matchRecitation', () {
    const ayah = 'قُلۡ هُوَ ٱللَّهُ أَحَدٌ';

    test('exact recitation scores 1.0', () {
      final r = matchRecitation('قل هو الله أحد', ayah);
      expect(r.score, 1.0);
      expect(r.isGood, isTrue);
      expect(r.firstMismatchIndex, -1);
    });

    test('recitation without tashkeel matches the Uthmani text', () {
      final r = matchRecitation('سبح اسم ربك الاعلى', 'سَبِّحِ ٱسۡمَ رَبِّكَ ٱلۡأَعۡلَى');
      expect(r.score, 1.0);
      expect(r.isGood, isTrue);
    });

    test('one missing word still passes when the rest is right', () {
      // الآية 4 كلمات؛ نسيان كلمة واحدة = 0.75 فيُعاد التسميع.
      final r = matchRecitation('قل هو الله', ayah);
      expect(r.score, 0.75);
      expect(r.isGood, isFalse);
      expect(r.firstMismatchIndex, 3);
    });

    test('first mismatch index points at the wrong word', () {
      final r = matchRecitation(
        'قل هو الملك أحد',
        ayah,
      );
      expect(r.firstMismatchIndex, 2);
      expect(r.wordMatches, [true, true, false, true]);
    });

    test('one-letter slip in a long word is tolerated', () {
      // "الذن" بدل "الذين" و"امنوا" بدل "ءامنوا": فرق حرف واحد
      // في كلمة من 4 أحرف فأكثر — تسامح مع نطق عمر 5 سنوات.
      final r = matchRecitation('ان الذن امنوا', 'إِنَّ ٱلَّذِینَ ءَامَنُوا۟');
      expect(r.score, 1.0);
    });

    test('empty recitation scores 0 with first word flagged', () {
      final r = matchRecitation('', ayah);
      expect(r.score, 0);
      expect(r.isGood, isFalse);
      expect(r.firstMismatchIndex, 0);
    });

    test('unrelated words score 0', () {
      final r = matchRecitation('قطة جميلة تلعب', ayah);
      expect(r.score, 0);
      expect(r.isGood, isFalse);
    });

    test('extra filler words do not break the match', () {
      final r = matchRecitation('يعني قل هو الله أحد يا أمي', ayah);
      expect(r.score, 1.0);
      expect(r.isGood, isTrue);
    });
  });

  group('ayahWords', () {
    test('drops words that vanish after normalization', () {
      final words = ayahWords('۞ أَفَلَا یَعۡلَمُ');
      expect(words.map((w) => w.original).toList(), ['أَفَلَا', 'یَعۡلَمُ']);
      expect(words.map((w) => w.normalized).toList(), ['افلا', 'يعلم']);
    });
  });
}
