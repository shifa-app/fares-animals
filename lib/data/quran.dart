// تحفيظ القرآن — نصوص الآيات من مصحف المدينة (رواية حفص) عبر
// api.alquran.cloud، والتلاوة آيةً آيةً بصوت مشاري العفاسي من
// cdn.islamic.network/quran/audio/128/ar.alafasy/{globalAyah}.mp3
class MemorizeAyah {
  final int numberInSurah, globalNumber;
  final String text;
  const MemorizeAyah({required this.numberInSurah, required this.globalNumber, required this.text});
  String get audioUrl =>
      'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$globalNumber.mp3';
}

class MemorizeSurah {
  final String name, meaning;
  final int number;
  final List<MemorizeAyah> ayahs;
  const MemorizeSurah({required this.name, required this.number, required this.meaning, required this.ayahs});
  String get basmala => 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
  bool get basmalaIsAyah => number == 1;
}

const List<MemorizeSurah> memorizeSurahs = [
  MemorizeSurah(name: 'الفاتحة', number: 1, meaning: 'نحمد الله، ونطلب منه أن يهدينا الطريق الصحيح.', ayahs: [
    MemorizeAyah(numberInSurah: 1, globalNumber: 1, text: 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِیمِ'),
    MemorizeAyah(numberInSurah: 2, globalNumber: 2, text: 'ٱلۡحَمۡدُ لِلَّهِ رَبِّ ٱلۡعَـٰلَمِینَ'),
    MemorizeAyah(numberInSurah: 3, globalNumber: 3, text: 'ٱلرَّحۡمَـٰنِ ٱلرَّحِیمِ'),
    MemorizeAyah(numberInSurah: 4, globalNumber: 4, text: 'مَـٰلِكِ یَوۡمِ ٱلدِّینِ'),
    MemorizeAyah(numberInSurah: 5, globalNumber: 5, text: 'إِیَّاكَ نَعۡبُدُ وَإِیَّاكَ نَسۡتَعِینُ'),
    MemorizeAyah(numberInSurah: 6, globalNumber: 6, text: 'ٱهۡدِنَا ٱلصِّرَ ٰ⁠طَ ٱلۡمُسۡتَقِیمَ'),
    MemorizeAyah(numberInSurah: 7, globalNumber: 7, text: 'صِرَ ٰ⁠طَ ٱلَّذِینَ أَنۡعَمۡتَ عَلَیۡهِمۡ غَیۡرِ ٱلۡمَغۡضُوبِ عَلَیۡهِمۡ وَلَا ٱلضَّاۤلِّینَ'),
  ]),
  MemorizeSurah(name: 'الأعلى', number: 87, meaning: 'الله هو الأعلى، خلق كل شيء وأحسنه.', ayahs: [
    MemorizeAyah(numberInSurah: 1, globalNumber: 5949, text: 'سَبِّحِ ٱسۡمَ رَبِّكَ ٱلۡأَعۡلَى'),
    MemorizeAyah(numberInSurah: 2, globalNumber: 5950, text: 'ٱلَّذِی خَلَقَ فَسَوَّىٰ'),
    MemorizeAyah(numberInSurah: 3, globalNumber: 5951, text: 'وَٱلَّذِی قَدَّرَ فَهَدَىٰ'),
    MemorizeAyah(numberInSurah: 4, globalNumber: 5952, text: 'وَٱلَّذِیۤ أَخۡرَجَ ٱلۡمَرۡعَىٰ'),
    MemorizeAyah(numberInSurah: 5, globalNumber: 5953, text: 'فَجَعَلَهُۥ غُثَاۤءً أَحۡوَىٰ'),
    MemorizeAyah(numberInSurah: 6, globalNumber: 5954, text: 'سَنُقۡرِئُكَ فَلَا تَنسَىٰۤ'),
    MemorizeAyah(numberInSurah: 7, globalNumber: 5955, text: 'إِلَّا مَا شَاۤءَ ٱللَّهُۚ إِنَّهُۥ یَعۡلَمُ ٱلۡجَهۡرَ وَمَا یَخۡفَىٰ'),
    MemorizeAyah(numberInSurah: 8, globalNumber: 5956, text: 'وَنُیَسِّرُكَ لِلۡیُسۡرَىٰ'),
    MemorizeAyah(numberInSurah: 9, globalNumber: 5957, text: 'فَذَكِّرۡ إِن نَّفَعَتِ ٱلذِّكۡرَىٰ'),
    MemorizeAyah(numberInSurah: 10, globalNumber: 5958, text: 'سَیَذَّكَّرُ مَن یَخۡشَىٰ'),
    MemorizeAyah(numberInSurah: 11, globalNumber: 5959, text: 'وَیَتَجَنَّبُهَا ٱلۡأَشۡقَى'),
    MemorizeAyah(numberInSurah: 12, globalNumber: 5960, text: 'ٱلَّذِی یَصۡلَى ٱلنَّارَ ٱلۡكُبۡرَىٰ'),
    MemorizeAyah(numberInSurah: 13, globalNumber: 5961, text: 'ثُمَّ لَا یَمُوتُ فِیهَا وَلَا یَحۡیَىٰ'),
    MemorizeAyah(numberInSurah: 14, globalNumber: 5962, text: 'قَدۡ أَفۡلَحَ مَن تَزَكَّىٰ'),
    MemorizeAyah(numberInSurah: 15, globalNumber: 5963, text: 'وَذَكَرَ ٱسۡمَ رَبِّهِۦ فَصَلَّىٰ'),
    MemorizeAyah(numberInSurah: 16, globalNumber: 5964, text: 'بَلۡ تُؤۡثِرُونَ ٱلۡحَیَوٰةَ ٱلدُّنۡیَا'),
    MemorizeAyah(numberInSurah: 17, globalNumber: 5965, text: 'وَٱلۡـَٔاخِرَةُ خَیۡرࣱ وَأَبۡقَىٰۤ'),
    MemorizeAyah(numberInSurah: 18, globalNumber: 5966, text: 'إِنَّ هَـٰذَا لَفِی ٱلصُّحُفِ ٱلۡأُولَىٰ'),
    MemorizeAyah(numberInSurah: 19, globalNumber: 5967, text: 'صُحُفِ إِبۡرَ ٰ⁠هِیمَ وَمُوسَىٰ'),
  ]),
  MemorizeSurah(name: 'الشمس', number: 91, meaning: 'الله خلق الشمس والقمر، وعلمنا الخير والشر.', ayahs: [
    MemorizeAyah(numberInSurah: 1, globalNumber: 6044, text: 'وَٱلشَّمۡسِ وَضُحَىٰهَا'),
    MemorizeAyah(numberInSurah: 2, globalNumber: 6045, text: 'وَٱلۡقَمَرِ إِذَا تَلَىٰهَا'),
    MemorizeAyah(numberInSurah: 3, globalNumber: 6046, text: 'وَٱلنَّهَارِ إِذَا جَلَّىٰهَا'),
    MemorizeAyah(numberInSurah: 4, globalNumber: 6047, text: 'وَٱلَّیۡلِ إِذَا یَغۡشَىٰهَا'),
    MemorizeAyah(numberInSurah: 5, globalNumber: 6048, text: 'وَٱلسَّمَاۤءِ وَمَا بَنَىٰهَا'),
    MemorizeAyah(numberInSurah: 6, globalNumber: 6049, text: 'وَٱلۡأَرۡضِ وَمَا طَحَىٰهَا'),
    MemorizeAyah(numberInSurah: 7, globalNumber: 6050, text: 'وَنَفۡسࣲ وَمَا سَوَّىٰهَا'),
    MemorizeAyah(numberInSurah: 8, globalNumber: 6051, text: 'فَأَلۡهَمَهَا فُجُورَهَا وَتَقۡوَىٰهَا'),
    MemorizeAyah(numberInSurah: 9, globalNumber: 6052, text: 'قَدۡ أَفۡلَحَ مَن زَكَّىٰهَا'),
    MemorizeAyah(numberInSurah: 10, globalNumber: 6053, text: 'وَقَدۡ خَابَ مَن دَسَّىٰهَا'),
    MemorizeAyah(numberInSurah: 11, globalNumber: 6054, text: 'كَذَّبَتۡ ثَمُودُ بِطَغۡوَىٰهَاۤ'),
    MemorizeAyah(numberInSurah: 12, globalNumber: 6055, text: 'إِذِ ٱنۢبَعَثَ أَشۡقَىٰهَا'),
    MemorizeAyah(numberInSurah: 13, globalNumber: 6056, text: 'فَقَالَ لَهُمۡ رَسُولُ ٱللَّهِ نَاقَةَ ٱللَّهِ وَسُقۡیَـٰهَا'),
    MemorizeAyah(numberInSurah: 14, globalNumber: 6057, text: 'فَكَذَّبُوهُ فَعَقَرُوهَا فَدَمۡدَمَ عَلَیۡهِمۡ رَبُّهُم بِذَنۢبِهِمۡ فَسَوَّىٰهَا'),
    MemorizeAyah(numberInSurah: 15, globalNumber: 6058, text: 'وَلَا یَخَافُ عُقۡبَـٰهَا'),
  ]),
  MemorizeSurah(name: 'الضحى', number: 93, meaning: 'الله لا يتركنا أبداً، وهو معنا دائماً.', ayahs: [
    MemorizeAyah(numberInSurah: 1, globalNumber: 6080, text: 'وَٱلضُّحَىٰ'),
    MemorizeAyah(numberInSurah: 2, globalNumber: 6081, text: 'وَٱلَّیۡلِ إِذَا سَجَىٰ'),
    MemorizeAyah(numberInSurah: 3, globalNumber: 6082, text: 'مَا وَدَّعَكَ رَبُّكَ وَمَا قَلَىٰ'),
    MemorizeAyah(numberInSurah: 4, globalNumber: 6083, text: 'وَلَلۡـَٔاخِرَةُ خَیۡرࣱ لَّكَ مِنَ ٱلۡأُولَىٰ'),
    MemorizeAyah(numberInSurah: 5, globalNumber: 6084, text: 'وَلَسَوۡفَ یُعۡطِیكَ رَبُّكَ فَتَرۡضَىٰۤ'),
    MemorizeAyah(numberInSurah: 6, globalNumber: 6085, text: 'أَلَمۡ یَجِدۡكَ یَتِیمࣰا فَـَٔاوَىٰ'),
    MemorizeAyah(numberInSurah: 7, globalNumber: 6086, text: 'وَوَجَدَكَ ضَاۤلࣰّا فَهَدَىٰ'),
    MemorizeAyah(numberInSurah: 8, globalNumber: 6087, text: 'وَوَجَدَكَ عَاۤىِٕلࣰا فَأَغۡنَىٰ'),
    MemorizeAyah(numberInSurah: 9, globalNumber: 6088, text: 'فَأَمَّا ٱلۡیَتِیمَ فَلَا تَقۡهَرۡ'),
    MemorizeAyah(numberInSurah: 10, globalNumber: 6089, text: 'وَأَمَّا ٱلسَّاۤىِٕلَ فَلَا تَنۡهَرۡ'),
    MemorizeAyah(numberInSurah: 11, globalNumber: 6090, text: 'وَأَمَّا بِنِعۡمَةِ رَبِّكَ فَحَدِّثۡ'),
  ]),
  MemorizeSurah(name: 'الشرح', number: 94, meaning: 'بعد كل صعب يأتي الفرج من الله.', ayahs: [
    MemorizeAyah(numberInSurah: 1, globalNumber: 6091, text: 'أَلَمۡ نَشۡرَحۡ لَكَ صَدۡرَكَ'),
    MemorizeAyah(numberInSurah: 2, globalNumber: 6092, text: 'وَوَضَعۡنَا عَنكَ وِزۡرَكَ'),
    MemorizeAyah(numberInSurah: 3, globalNumber: 6093, text: 'ٱلَّذِیۤ أَنقَضَ ظَهۡرَكَ'),
    MemorizeAyah(numberInSurah: 4, globalNumber: 6094, text: 'وَرَفَعۡنَا لَكَ ذِكۡرَكَ'),
    MemorizeAyah(numberInSurah: 5, globalNumber: 6095, text: 'فَإِنَّ مَعَ ٱلۡعُسۡرِ یُسۡرًا'),
    MemorizeAyah(numberInSurah: 6, globalNumber: 6096, text: 'إِنَّ مَعَ ٱلۡعُسۡرِ یُسۡرࣰا'),
    MemorizeAyah(numberInSurah: 7, globalNumber: 6097, text: 'فَإِذَا فَرَغۡتَ فَٱنصَبۡ'),
    MemorizeAyah(numberInSurah: 8, globalNumber: 6098, text: 'وَإِلَىٰ رَبِّكَ فَٱرۡغَب'),
  ]),
  MemorizeSurah(name: 'التين', number: 95, meaning: 'الله خلق الإنسان في أحسن صورة.', ayahs: [
    MemorizeAyah(numberInSurah: 1, globalNumber: 6099, text: 'وَٱلتِّینِ وَٱلزَّیۡتُونِ'),
    MemorizeAyah(numberInSurah: 2, globalNumber: 6100, text: 'وَطُورِ سِینِینَ'),
    MemorizeAyah(numberInSurah: 3, globalNumber: 6101, text: 'وَهَـٰذَا ٱلۡبَلَدِ ٱلۡأَمِینِ'),
    MemorizeAyah(numberInSurah: 4, globalNumber: 6102, text: 'لَقَدۡ خَلَقۡنَا ٱلۡإِنسَـٰنَ فِیۤ أَحۡسَنِ تَقۡوِیمࣲ'),
    MemorizeAyah(numberInSurah: 5, globalNumber: 6103, text: 'ثُمَّ رَدَدۡنَـٰهُ أَسۡفَلَ سَـٰفِلِینَ'),
    MemorizeAyah(numberInSurah: 6, globalNumber: 6104, text: 'إِلَّا ٱلَّذِینَ ءَامَنُوا۟ وَعَمِلُوا۟ ٱلصَّـٰلِحَـٰتِ فَلَهُمۡ أَجۡرٌ غَیۡرُ مَمۡنُونࣲ'),
    MemorizeAyah(numberInSurah: 7, globalNumber: 6105, text: 'فَمَا یُكَذِّبُكَ بَعۡدُ بِٱلدِّینِ'),
    MemorizeAyah(numberInSurah: 8, globalNumber: 6106, text: 'أَلَیۡسَ ٱللَّهُ بِأَحۡكَمِ ٱلۡحَـٰكِمِینَ'),
  ]),
  MemorizeSurah(name: 'الزلزلة', number: 99, meaning: 'في يوم القيامة نرى كل أعمالنا.', ayahs: [
    MemorizeAyah(numberInSurah: 1, globalNumber: 6139, text: 'إِذَا زُلۡزِلَتِ ٱلۡأَرۡضُ زِلۡزَالَهَا'),
    MemorizeAyah(numberInSurah: 2, globalNumber: 6140, text: 'وَأَخۡرَجَتِ ٱلۡأَرۡضُ أَثۡقَالَهَا'),
    MemorizeAyah(numberInSurah: 3, globalNumber: 6141, text: 'وَقَالَ ٱلۡإِنسَـٰنُ مَا لَهَا'),
    MemorizeAyah(numberInSurah: 4, globalNumber: 6142, text: 'یَوۡمَىِٕذࣲ تُحَدِّثُ أَخۡبَارَهَا'),
    MemorizeAyah(numberInSurah: 5, globalNumber: 6143, text: 'بِأَنَّ رَبَّكَ أَوۡحَىٰ لَهَا'),
    MemorizeAyah(numberInSurah: 6, globalNumber: 6144, text: 'یَوۡمَىِٕذࣲ یَصۡدُرُ ٱلنَّاسُ أَشۡتَاتࣰا لِّیُرَوۡا۟ أَعۡمَـٰلَهُمۡ'),
    MemorizeAyah(numberInSurah: 7, globalNumber: 6145, text: 'فَمَن یَعۡمَلۡ مِثۡقَالَ ذَرَّةٍ خَیۡرࣰا یَرَهُۥ'),
    MemorizeAyah(numberInSurah: 8, globalNumber: 6146, text: 'وَمَن یَعۡمَلۡ مِثۡقَالَ ذَرَّةࣲ شَرࣰّا یَرَهُۥ'),
  ]),
  MemorizeSurah(name: 'العاديات', number: 100, meaning: 'الخيل السريعة تذكرنا بنعم الله.', ayahs: [
    MemorizeAyah(numberInSurah: 1, globalNumber: 6147, text: 'وَٱلۡعَـٰدِیَـٰتِ ضَبۡحࣰا'),
    MemorizeAyah(numberInSurah: 2, globalNumber: 6148, text: 'فَٱلۡمُورِیَـٰتِ قَدۡحࣰا'),
    MemorizeAyah(numberInSurah: 3, globalNumber: 6149, text: 'فَٱلۡمُغِیرَ ٰ⁠تِ صُبۡحࣰا'),
    MemorizeAyah(numberInSurah: 4, globalNumber: 6150, text: 'فَأَثَرۡنَ بِهِۦ نَقۡعࣰا'),
    MemorizeAyah(numberInSurah: 5, globalNumber: 6151, text: 'فَوَسَطۡنَ بِهِۦ جَمۡعًا'),
    MemorizeAyah(numberInSurah: 6, globalNumber: 6152, text: 'إِنَّ ٱلۡإِنسَـٰنَ لِرَبِّهِۦ لَكَنُودࣱ'),
    MemorizeAyah(numberInSurah: 7, globalNumber: 6153, text: 'وَإِنَّهُۥ عَلَىٰ ذَ ٰ⁠لِكَ لَشَهِیدࣱ'),
    MemorizeAyah(numberInSurah: 8, globalNumber: 6154, text: 'وَإِنَّهُۥ لِحُبِّ ٱلۡخَیۡرِ لَشَدِیدٌ'),
    MemorizeAyah(numberInSurah: 9, globalNumber: 6155, text: '۞ أَفَلَا یَعۡلَمُ إِذَا بُعۡثِرَ مَا فِی ٱلۡقُبُورِ'),
    MemorizeAyah(numberInSurah: 10, globalNumber: 6156, text: 'وَحُصِّلَ مَا فِی ٱلصُّدُورِ'),
    MemorizeAyah(numberInSurah: 11, globalNumber: 6157, text: 'إِنَّ رَبَّهُم بِهِمۡ یَوۡمَىِٕذࣲ لَّخَبِیرُۢ'),
  ]),
  MemorizeSurah(name: 'التكاثر', number: 102, meaning: 'لا ننشغل بالدنيا عن الآخرة.', ayahs: [
    MemorizeAyah(numberInSurah: 1, globalNumber: 6169, text: 'أَلۡهَىٰكُمُ ٱلتَّكَاثُرُ'),
    MemorizeAyah(numberInSurah: 2, globalNumber: 6170, text: 'حَتَّىٰ زُرۡتُمُ ٱلۡمَقَابِرَ'),
    MemorizeAyah(numberInSurah: 3, globalNumber: 6171, text: 'كَلَّا سَوۡفَ تَعۡلَمُونَ'),
    MemorizeAyah(numberInSurah: 4, globalNumber: 6172, text: 'ثُمَّ كَلَّا سَوۡفَ تَعۡلَمُونَ'),
    MemorizeAyah(numberInSurah: 5, globalNumber: 6173, text: 'كَلَّا لَوۡ تَعۡلَمُونَ عِلۡمَ ٱلۡیَقِینِ'),
    MemorizeAyah(numberInSurah: 6, globalNumber: 6174, text: 'لَتَرَوُنَّ ٱلۡجَحِیمَ'),
    MemorizeAyah(numberInSurah: 7, globalNumber: 6175, text: 'ثُمَّ لَتَرَوُنَّهَا عَیۡنَ ٱلۡیَقِینِ'),
    MemorizeAyah(numberInSurah: 8, globalNumber: 6176, text: 'ثُمَّ لَتُسۡـَٔلُنَّ یَوۡمَىِٕذٍ عَنِ ٱلنَّعِیمِ'),
  ]),
  MemorizeSurah(name: 'العصر', number: 103, meaning: 'الوقت غالٍ، نملؤه بالخير والصبر.', ayahs: [
    MemorizeAyah(numberInSurah: 1, globalNumber: 6177, text: 'وَٱلۡعَصۡرِ'),
    MemorizeAyah(numberInSurah: 2, globalNumber: 6178, text: 'إِنَّ ٱلۡإِنسَـٰنَ لَفِی خُسۡرٍ'),
    MemorizeAyah(numberInSurah: 3, globalNumber: 6179, text: 'إِلَّا ٱلَّذِینَ ءَامَنُوا۟ وَعَمِلُوا۟ ٱلصَّـٰلِحَـٰتِ وَتَوَاصَوۡا۟ بِٱلۡحَقِّ وَتَوَاصَوۡا۟ بِٱلصَّبۡرِ'),
  ]),
  MemorizeSurah(name: 'الهمزة', number: 104, meaning: 'لا نسخر من أحد، ولا نؤذي الناس بكلامنا.', ayahs: [
    MemorizeAyah(numberInSurah: 1, globalNumber: 6180, text: 'وَیۡلࣱ لِّكُلِّ هُمَزَةࣲ لُّمَزَةٍ'),
    MemorizeAyah(numberInSurah: 2, globalNumber: 6181, text: 'ٱلَّذِی جَمَعَ مَالࣰا وَعَدَّدَهُۥ'),
    MemorizeAyah(numberInSurah: 3, globalNumber: 6182, text: 'یَحۡسَبُ أَنَّ مَالَهُۥۤ أَخۡلَدَهُۥ'),
    MemorizeAyah(numberInSurah: 4, globalNumber: 6183, text: 'كَلَّاۖ لَیُنۢبَذَنَّ فِی ٱلۡحُطَمَةِ'),
    MemorizeAyah(numberInSurah: 5, globalNumber: 6184, text: 'وَمَاۤ أَدۡرَىٰكَ مَا ٱلۡحُطَمَةُ'),
    MemorizeAyah(numberInSurah: 6, globalNumber: 6185, text: 'نَارُ ٱللَّهِ ٱلۡمُوقَدَةُ'),
    MemorizeAyah(numberInSurah: 7, globalNumber: 6186, text: 'ٱلَّتِی تَطَّلِعُ عَلَى ٱلۡأَفۡـِٔدَةِ'),
    MemorizeAyah(numberInSurah: 8, globalNumber: 6187, text: 'إِنَّهَا عَلَیۡهِم مُّؤۡصَدَةࣱ'),
    MemorizeAyah(numberInSurah: 9, globalNumber: 6188, text: 'فِی عَمَدࣲ مُّمَدَّدَةِۭ'),
  ]),
  MemorizeSurah(name: 'الفيل', number: 105, meaning: 'الله حمى بيته من أصحاب الفيل.', ayahs: [
    MemorizeAyah(numberInSurah: 1, globalNumber: 6189, text: 'أَلَمۡ تَرَ كَیۡفَ فَعَلَ رَبُّكَ بِأَصۡحَـٰبِ ٱلۡفِیلِ'),
    MemorizeAyah(numberInSurah: 2, globalNumber: 6190, text: 'أَلَمۡ یَجۡعَلۡ كَیۡدَهُمۡ فِی تَضۡلِیلࣲ'),
    MemorizeAyah(numberInSurah: 3, globalNumber: 6191, text: 'وَأَرۡسَلَ عَلَیۡهِمۡ طَیۡرًا أَبَابِیلَ'),
    MemorizeAyah(numberInSurah: 4, globalNumber: 6192, text: 'تَرۡمِیهِم بِحِجَارَةࣲ مِّن سِجِّیلࣲ'),
    MemorizeAyah(numberInSurah: 5, globalNumber: 6193, text: 'فَجَعَلَهُمۡ كَعَصۡفࣲ مَّأۡكُولِۭ'),
  ]),
  MemorizeSurah(name: 'قريش', number: 106, meaning: 'الله أطعم قريشاً وآمنها، فنعبده ونشكره.', ayahs: [
    MemorizeAyah(numberInSurah: 1, globalNumber: 6194, text: 'لِإِیلَـٰفِ قُرَیۡشٍ'),
    MemorizeAyah(numberInSurah: 2, globalNumber: 6195, text: 'إِۦلَـٰفِهِمۡ رِحۡلَةَ ٱلشِّتَاۤءِ وَٱلصَّیۡفِ'),
    MemorizeAyah(numberInSurah: 3, globalNumber: 6196, text: 'فَلۡیَعۡبُدُوا۟ رَبَّ هَـٰذَا ٱلۡبَیۡتِ'),
    MemorizeAyah(numberInSurah: 4, globalNumber: 6197, text: 'ٱلَّذِیۤ أَطۡعَمَهُم مِّن جُوعࣲ وَءَامَنَهُم مِّنۡ خَوۡفِۭ'),
  ]),
  MemorizeSurah(name: 'الماعون', number: 107, meaning: 'نساعد المحتاج، ونصلي لله بإخلاص.', ayahs: [
    MemorizeAyah(numberInSurah: 1, globalNumber: 6198, text: 'أَرَءَیۡتَ ٱلَّذِی یُكَذِّبُ بِٱلدِّینِ'),
    MemorizeAyah(numberInSurah: 2, globalNumber: 6199, text: 'فَذَ ٰ⁠لِكَ ٱلَّذِی یَدُعُّ ٱلۡیَتِیمَ'),
    MemorizeAyah(numberInSurah: 3, globalNumber: 6200, text: 'وَلَا یَحُضُّ عَلَىٰ طَعَامِ ٱلۡمِسۡكِینِ'),
    MemorizeAyah(numberInSurah: 4, globalNumber: 6201, text: 'فَوَیۡلࣱ لِّلۡمُصَلِّینَ'),
    MemorizeAyah(numberInSurah: 5, globalNumber: 6202, text: 'ٱلَّذِینَ هُمۡ عَن صَلَاتِهِمۡ سَاهُونَ'),
    MemorizeAyah(numberInSurah: 6, globalNumber: 6203, text: 'ٱلَّذِینَ هُمۡ یُرَاۤءُونَ'),
    MemorizeAyah(numberInSurah: 7, globalNumber: 6204, text: 'وَیَمۡنَعُونَ ٱلۡمَاعُونَ'),
  ]),
  MemorizeSurah(name: 'الكوثر', number: 108, meaning: 'الله أعطى نبينا خيراً كثيراً.', ayahs: [
    MemorizeAyah(numberInSurah: 1, globalNumber: 6205, text: 'إِنَّاۤ أَعۡطَیۡنَـٰكَ ٱلۡكَوۡثَرَ'),
    MemorizeAyah(numberInSurah: 2, globalNumber: 6206, text: 'فَصَلِّ لِرَبِّكَ وَٱنۡحَرۡ'),
    MemorizeAyah(numberInSurah: 3, globalNumber: 6207, text: 'إِنَّ شَانِئَكَ هُوَ ٱلۡأَبۡتَرُ'),
  ]),
  MemorizeSurah(name: 'الكافرون', number: 109, meaning: 'لكل إنسان دينه، ونحن نعبد الله وحده.', ayahs: [
    MemorizeAyah(numberInSurah: 1, globalNumber: 6208, text: 'قُلۡ یَـٰۤأَیُّهَا ٱلۡكَـٰفِرُونَ'),
    MemorizeAyah(numberInSurah: 2, globalNumber: 6209, text: 'لَاۤ أَعۡبُدُ مَا تَعۡبُدُونَ'),
    MemorizeAyah(numberInSurah: 3, globalNumber: 6210, text: 'وَلَاۤ أَنتُمۡ عَـٰبِدُونَ مَاۤ أَعۡبُدُ'),
    MemorizeAyah(numberInSurah: 4, globalNumber: 6211, text: 'وَلَاۤ أَنَا۠ عَابِدࣱ مَّا عَبَدتُّمۡ'),
    MemorizeAyah(numberInSurah: 5, globalNumber: 6212, text: 'وَلَاۤ أَنتُمۡ عَـٰبِدُونَ مَاۤ أَعۡبُدُ'),
    MemorizeAyah(numberInSurah: 6, globalNumber: 6213, text: 'لَكُمۡ دِینُكُمۡ وَلِیَ دِینِ'),
  ]),
  MemorizeSurah(name: 'النصر', number: 110, meaning: 'عندما يأتي نصر الله، نسبحه ونستغفره.', ayahs: [
    MemorizeAyah(numberInSurah: 1, globalNumber: 6214, text: 'إِذَا جَاۤءَ نَصۡرُ ٱللَّهِ وَٱلۡفَتۡحُ'),
    MemorizeAyah(numberInSurah: 2, globalNumber: 6215, text: 'وَرَأَیۡتَ ٱلنَّاسَ یَدۡخُلُونَ فِی دِینِ ٱللَّهِ أَفۡوَاجࣰا'),
    MemorizeAyah(numberInSurah: 3, globalNumber: 6216, text: 'فَسَبِّحۡ بِحَمۡدِ رَبِّكَ وَٱسۡتَغۡفِرۡهُۚ إِنَّهُۥ كَانَ تَوَّابَۢا'),
  ]),
  MemorizeSurah(name: 'المسد', number: 111, meaning: 'من يؤذي نبينا ويعادي الله فمصيره النار.', ayahs: [
    MemorizeAyah(numberInSurah: 1, globalNumber: 6217, text: 'تَبَّتۡ یَدَاۤ أَبِی لَهَبࣲ وَتَبَّ'),
    MemorizeAyah(numberInSurah: 2, globalNumber: 6218, text: 'مَاۤ أَغۡنَىٰ عَنۡهُ مَالُهُۥ وَمَا كَسَبَ'),
    MemorizeAyah(numberInSurah: 3, globalNumber: 6219, text: 'سَیَصۡلَىٰ نَارࣰا ذَاتَ لَهَبࣲ'),
    MemorizeAyah(numberInSurah: 4, globalNumber: 6220, text: 'وَٱمۡرَأَتُهُۥ حَمَّالَةَ ٱلۡحَطَبِ'),
    MemorizeAyah(numberInSurah: 5, globalNumber: 6221, text: 'فِی جِیدِهَا حَبۡلࣱ مِّن مَّسَدِۭ'),
  ]),
  MemorizeSurah(name: 'الإخلاص', number: 112, meaning: 'الله واحد، لا شريك له.', ayahs: [
    MemorizeAyah(numberInSurah: 1, globalNumber: 6222, text: 'قُلۡ هُوَ ٱللَّهُ أَحَدٌ'),
    MemorizeAyah(numberInSurah: 2, globalNumber: 6223, text: 'ٱللَّهُ ٱلصَّمَدُ'),
    MemorizeAyah(numberInSurah: 3, globalNumber: 6224, text: 'لَمۡ یَلِدۡ وَلَمۡ یُولَدۡ'),
    MemorizeAyah(numberInSurah: 4, globalNumber: 6225, text: 'وَلَمۡ یَكُن لَّهُۥ كُفُوًا أَحَدُۢ'),
  ]),
  MemorizeSurah(name: 'الفلق', number: 113, meaning: 'نطلب من الله أن يحمينا من كل شر.', ayahs: [
    MemorizeAyah(numberInSurah: 1, globalNumber: 6226, text: 'قُلۡ أَعُوذُ بِرَبِّ ٱلۡفَلَقِ'),
    MemorizeAyah(numberInSurah: 2, globalNumber: 6227, text: 'مِن شَرِّ مَا خَلَقَ'),
    MemorizeAyah(numberInSurah: 3, globalNumber: 6228, text: 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ'),
    MemorizeAyah(numberInSurah: 4, globalNumber: 6229, text: 'وَمِن شَرِّ ٱلنَّفَّـٰثَـٰتِ فِی ٱلۡعُقَدِ'),
    MemorizeAyah(numberInSurah: 5, globalNumber: 6230, text: 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ'),
  ]),
  MemorizeSurah(name: 'الناس', number: 114, meaning: 'الله ملك الناس، نحتمي به من الوسواس.', ayahs: [
    MemorizeAyah(numberInSurah: 1, globalNumber: 6231, text: 'قُلۡ أَعُوذُ بِرَبِّ ٱلنَّاسِ'),
    MemorizeAyah(numberInSurah: 2, globalNumber: 6232, text: 'مَلِكِ ٱلنَّاسِ'),
    MemorizeAyah(numberInSurah: 3, globalNumber: 6233, text: 'إِلَـٰهِ ٱلنَّاسِ'),
    MemorizeAyah(numberInSurah: 4, globalNumber: 6234, text: 'مِن شَرِّ ٱلۡوَسۡوَاسِ ٱلۡخَنَّاسِ'),
    MemorizeAyah(numberInSurah: 5, globalNumber: 6235, text: 'ٱلَّذِی یُوَسۡوِسُ فِی صُدُورِ ٱلنَّاسِ'),
    MemorizeAyah(numberInSurah: 6, globalNumber: 6236, text: 'مِنَ ٱلۡجِنَّةِ وَٱلنَّاسِ'),
  ]),
];
