import 'package:animals/data/animals.dart';
import 'package:animals/data/letters.dart';
import 'package:animals/data/quran.dart';
import 'package:animals/data/religion.dart';
import 'package:animals/data/stories.dart';
import 'package:animals/main.dart';
import 'package:animals/services/child_profile.dart';
import 'package:animals/utils/matching.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('normalizeArabic', () {
    test('removes diacritics and unifies alef', () {
      expect(normalizeArabic('الأسَدُ'), 'اسد');
    });
    test('teh marbuta becomes heh', () {
      expect(normalizeArabic('قطة'), 'قطه');
    });
    test('empty stays empty', () {
      expect(normalizeArabic('  '), '');
    });
  });

  group('findAnimal', () {
    test('finds lion by Arabic name', () {
      expect(findAnimal('أسد', animals)?.nameEn, 'Lion');
    });
    test('finds lion with definite article', () {
      expect(findAnimal('الأسد', animals)?.nameEn, 'Lion');
    });
    test('finds cat by alias قطة', () {
      expect(findAnimal('قطة', animals)?.nameEn, 'Cat');
    });
    test('finds animal by English name', () {
      expect(findAnimal('elephant', animals)?.nameAr, 'فيل');
    });
    test('finds animal inside a sentence', () {
      expect(findAnimal('أنا أحب الأسد', animals)?.nameEn, 'Lion');
    });
    test('returns null for unknown words', () {
      expect(findAnimal('سيارة', animals), isNull);
      expect(findAnimal('', animals), isNull);
    });
  });

  group('animals data', () {
    test('has exactly 100 animals with unique Arabic names', () {
      expect(animals.length, 100);
      expect(animals.map((a) => a.nameAr).toSet().length, 100);
    });
    test('every animal has text fields and a valid image url', () {
      const validCats = {'forest', 'farm', 'birds', 'sea', 'reptiles', 'desert', 'polar'};
      for (final a in animals) {
        expect(a.nameAr.isNotEmpty, true, reason: 'empty nameAr');
        expect(a.nameEn.isNotEmpty, true);
        expect(validCats.contains(a.category), true, reason: a.nameAr);
        expect(a.imageUrl.startsWith('http'), true, reason: a.nameAr);
        expect(a.home.isNotEmpty, true);
        expect(a.food.isNotEmpty, true);
        expect(a.fact.isNotEmpty, true);
        expect(a.soundWord.isNotEmpty, true);
        if (a.soundUrl.isNotEmpty) {
          expect(a.soundUrl.startsWith('http'), true, reason: a.nameAr);
        }
      }
    });
    test('each category has the expected count after the desert/polar split', () {
      const expected = {
        'forest': 19,
        'farm': 16,
        'birds': 18,
        'sea': 16,
        'reptiles': 16,
        'desert': 6,
        'polar': 9,
      };
      expect(animals.length, 100);
      for (final entry in expected.entries) {
        expect(
          animals.where((a) => a.category == entry.key).length,
          entry.value,
          reason: entry.key,
        );
      }
      // Desert holds only desert animals; polar holds only snow animals.
      for (final name in ['جمل', 'نعامة', 'ضب', 'ورل', 'قنفذ الصحراء', 'ثعلب الفنك']) {
        expect(animals.firstWhere((a) => a.nameAr == name).category, 'desert');
      }
      for (final name in ['دب قطبي', 'ثعلب القطب', 'رنة', 'بومة ثلجية', 'لاما', 'ألبكة', 'ماعز جبلي', 'نمر الثلج', 'هاسكي']) {
        expect(animals.firstWhere((a) => a.nameAr == name).category, 'polar');
      }
      expect(animals.firstWhere((a) => a.nameAr == 'سنجاب طائر').category, 'forest');
    });
    test('categoryLabels covers all seven categories', () {
      expect(categoryLabels.length, 7);
      for (final c in ['forest', 'farm', 'birds', 'sea', 'reptiles', 'desert', 'polar']) {
        expect(categoryLabels[c]?.isNotEmpty, true, reason: c);
      }
    });
    test('every animal has a verified real sound or an explicitly empty soundUrl', () {
      // 74 animals have a real, HTTP-verified sound (see tool/verify_animal_media.py);
      // the other 26 are explicitly silent — no unverified or generic link remains.
      final withSound = animals.where((a) => a.soundUrl.isNotEmpty).toList();
      final silent = animals.where((a) => a.soundUrl.isEmpty).toList();
      expect(withSound.length, 74);
      expect(silent.length, 26);
      for (final a in animals) {
        expect(a.hasRealSound, a.soundUrl.isNotEmpty, reason: a.nameAr);
        if (a.soundUrl.isNotEmpty) {
          expect(a.soundUrl.startsWith('http'), true, reason: a.nameAr);
          expect(a.soundUrl, isNot(contains('animal_bark_and_growl')), reason: a.nameAr);
        } else {
          // A silent animal must never be offered as a guess-by-sound.
          expect(a.guessable, false, reason: a.nameAr);
        }
      }
      // Insect buzzes, the giraffe hum and the cheetah chirp are real sounds
      // but too hard for a child to tell apart, so they are not guessable either.
      for (final name in ['نحلة', 'جندب', 'صرصور', 'ذبابة', 'زرافة', 'فهد']) {
        expect(animals.firstWhere((a) => a.nameAr == name).guessable, false, reason: name);
      }
      // The dog bark is knowingly shared by Dog and Husky only (both dogs).
      final barkUsers = animals.where((a) => a.soundUrl.endsWith('dog_barking.ogg')).map((a) => a.nameAr).toSet();
      expect(barkUsers, {'كلب', 'هاسكي'});
    });
  });

  group('religion data', () {
    test('five short surahs with audio urls', () {
      expect(surahs.length, 5);
      for (final s in surahs) {
        expect(s.audioUrl, contains('cdn.islamic.network'));
        expect(s.text.isNotEmpty, true);
      }
    });
    test('adhkar, names, stories and manners are present', () {
      expect(adhkar.length, 4);
      expect(allahNames.length, 10);
      expect(stories.length, 4);
      expect(manners.length, 6);
      expect(wuduSteps.length, 8);
      expect(prayerSteps.length, 6);
      expect(prayers.length, 5);
    });
  });

  group('quran memorization data', () {
    test('38 surahs (Al-Fatiha + full Juz Amma) with 571 ayahs and verse audio urls', () {
      expect(memorizeSurahs.length, 38);
      var total = 0;
      for (final s in memorizeSurahs) {
        expect(s.ayahs.isNotEmpty, true, reason: s.name);
        expect(s.meaning.isNotEmpty, true);
        for (final a in s.ayahs) {
          expect(a.text.isNotEmpty, true);
          expect(
            a.audioUrl,
            'https://cdn.islamic.network/quran/audio/128/ar.alafasy/${a.globalNumber}.mp3',
          );
          total++;
        }
      }
      expect(total, 571);
      expect(memorizeSurahs.first.number, 1);
      expect(memorizeSurahs.last.number, 114);
    });
    test('basmala is separate: only Al-Fatiha keeps it as its first ayah', () {
      const basmala = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
      for (final s in memorizeSurahs) {
        expect(s.basmala, basmala, reason: s.name);
        expect(s.basmalaIsAyah, s.number == 1, reason: s.name);
        final first = s.ayahs.first.text;
        if (s.number == 1) {
          expect(first, contains('بِسۡمِ'), reason: s.name);
        } else {
          expect(first.startsWith('بِسۡمِ'), false, reason: s.name);
          expect(first.startsWith('بِّسۡمِ'), false, reason: s.name);
        }
      }
    });
  });

  group('letters and numbers data', () {
    test('28 Arabic letters, 26 English letters, numbers 1-20', () {
      expect(arabicLetters.length, 28);
      expect(arabicLetters.map((e) => e.letter).toSet().length, 28);
      expect(englishLetters.length, 26);
      expect(englishLetters.map((e) => e.letter).toSet().length, 26);
      expect(numbers.length, 20);
      expect(numbers.map((e) => e.value).toList(), List.generate(20, (i) => i + 1));
      for (final l in arabicLetters) {
        expect(l.word.isNotEmpty, true);
        expect(l.animalName != null || l.imageUrl != null, true, reason: l.letter);
      }
      for (final n in numbers) {
        expect(n.arWord.isNotEmpty, true);
        expect(n.enWord.isNotEmpty, true);
      }
      for (final l in englishLetters) {
        expect(l.lower, l.letter.toLowerCase());
      }
      expect(englishLetters.first.lower, 'a');
      expect(englishLetters.last.lower, 'z');
    });
  });

  group('bedtime stories data', () {
    test('13 stories: 8 short with morals + 5 five-minute', () {
      expect(bedtimeStories.length, 13);
      expect(bedtimeStories.where((s) => s.isProphet).length, 2);
      expect(bedtimeStories.where((s) => s.isFiveMinute).length, 5);
      for (final st in bedtimeStories) {
        expect(st.body.length, greaterThan(50), reason: st.title);
        expect(st.moral.isNotEmpty, true);
      }
    });
    test('Ahmed story title matches its body (the vase, not a ball)', () {
      final titles = bedtimeStories.map((s) => s.title).toList();
      expect(titles, contains('أحمد والمزهرية المكسورة'));
      expect(titles, isNot(contains('أحمد والكرة المكسورة')));
      final ahmed = bedtimeStories.firstWhere((s) => s.title.contains('أحمد'));
      // The ball is only the passing setup ("كان يلعب بالكرة"); the broken
      // object and the whole point of the story is the vase.
      expect(ahmed.body, contains('مزهرية'));
      expect(ahmed.body, contains('كسرت المزهرية'));
    });
  });

  group('app identity', () {
    test('correct app title and dedication text', () {
      expect(appTitle, 'فارس والحيوانات');
      expect(
        ChildProfile.dedicationFor('فارس'),
        'إهداء إلى ابني حبيبي فارس اسامة ابراهيم عبدالحكيم',
      );
      expect(ChildProfile.appTitleFor('فهد'), 'فهد والحيوانات');
    });
  });
}
