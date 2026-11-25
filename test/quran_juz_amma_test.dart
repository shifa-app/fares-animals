import 'package:animals/data/quran.dart';
import 'package:flutter_test/flutter_test.dart';

/// جزء عمّ كاملاً + الفاتحة: 38 سورة، 571 آية.
/// النصوص من مصحف المدينة (رواية حفص)، طبعة quran-uthmani-quran-academy
/// عبر api.alquran.cloud — نفس المصدر والترميز العثماني للسور القديمة،
/// وتُحقق آيةً آيةً وعدد آيات كل سورة والترقيم العالمي قبل البناء.
void main() {
  const expectedCounts = <int, int>{
    1: 7,
    78: 40,
    79: 46,
    80: 42,
    81: 29,
    82: 19,
    83: 36,
    84: 25,
    85: 22,
    86: 17,
    87: 19,
    88: 26,
    89: 30,
    90: 20,
    91: 15,
    92: 21,
    93: 11,
    94: 8,
    95: 8,
    96: 19,
    97: 5,
    98: 8,
    99: 8,
    100: 11,
    101: 11,
    102: 8,
    103: 3,
    104: 9,
    105: 5,
    106: 4,
    107: 7,
    108: 3,
    109: 6,
    110: 3,
    111: 5,
    112: 4,
    113: 5,
    114: 6,
  };

  test('Juz Amma is complete: Al-Fatiha + surahs 78-114 in order', () {
    expect(memorizeSurahs.length, 38);
    expect(
      memorizeSurahs.map((s) => s.number).toList(),
      [1, ...List.generate(37, (i) => 78 + i)],
    );
    expect(memorizeSurahs.first.name, 'الفاتحة');
    expect(memorizeSurahs.last.name, 'الناس');
  });

  test('every surah has its known ayah count; total is 571', () {
    var total = 0;
    for (final s in memorizeSurahs) {
      expect(s.ayahs.length, expectedCounts[s.number], reason: s.name);
      expect(s.meaning.isNotEmpty, true, reason: s.name);
      total += s.ayahs.length;
    }
    expect(total, 571);
  });

  test('global numbers are sequential across the stored surahs', () {
    // الفاتحة 1..7، ثم جزء عمّ 5673..6236 (السور 2-77 ليست في التطبيق).
    var prev = 0;
    var prevNumber = 0;
    for (final s in memorizeSurahs) {
      for (var i = 0; i < s.ayahs.length; i++) {
        final a = s.ayahs[i];
        expect(a.numberInSurah, i + 1, reason: s.name);
        if (prevNumber == 1 && s.number == 78 && i == 0) {
          expect(a.globalNumber, 5673, reason: s.name);
        } else {
          expect(a.globalNumber, prev + 1, reason: '${s.name}:${a.numberInSurah}');
        }
        expect(
          a.audioUrl,
          'https://cdn.islamic.network/quran/audio/128/ar.alafasy/${a.globalNumber}.mp3',
        );
        prev = a.globalNumber;
      }
      prevNumber = s.number;
    }
    expect(prev, 6236);
  });

  test('the 17 new surahs carry no basmala inside their first ayah', () {
    const newNumbers = {
      78, 79, 80, 81, 82, 83, 84, 85, 86, 88, 89, 90, 92, 96, 97, 98, 101,
    };
    for (final s in memorizeSurahs.where((s) => newNumbers.contains(s.number))) {
      final first = s.ayahs.first.text;
      expect(first.startsWith('بِسۡمِ'), isFalse, reason: s.name);
      expect(first.startsWith('بِّسۡمِ'), isFalse, reason: s.name);
      expect(s.basmalaIsAyah, isFalse, reason: s.name);
    }
  });
}
