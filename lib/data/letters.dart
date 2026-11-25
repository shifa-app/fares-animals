// الحروف العربية والإنجليزية والأرقام — لطفل عمره 5 سنوات.
class ArabicLetter {
  final String letter, letterName, word;
  final String? animalName; // اسم الحيوان في قاعدة البيانات (لصورته)
  final String? imageUrl; // صورة مباشرة لغير الحيوانات
  const ArabicLetter({
    required this.letter,
    required this.letterName,
    required this.word,
    this.animalName,
    this.imageUrl,
  });
}

const List<ArabicLetter> arabicLetters = [
  ArabicLetter(letter: 'أ', letterName: 'ألف', word: 'أسد', animalName: 'أسد'),
  ArabicLetter(letter: 'ب', letterName: 'باء', word: 'بطة', animalName: 'بطة'),
  ArabicLetter(letter: 'ت', letterName: 'تاء', word: 'تمساح', animalName: 'تمساح'),
  ArabicLetter(letter: 'ث', letterName: 'ثاء', word: 'ثعبان', animalName: 'ثعبان'),
  ArabicLetter(letter: 'ج', letterName: 'جيم', word: 'جمل', animalName: 'جمل'),
  ArabicLetter(letter: 'ح', letterName: 'حاء', word: 'حصان', animalName: 'حصان'),
  ArabicLetter(letter: 'خ', letterName: 'خاء', word: 'خروف', animalName: 'خروف'),
  ArabicLetter(letter: 'د', letterName: 'دال', word: 'دجاجة', animalName: 'دجاجة'),
  ArabicLetter(letter: 'ذ', letterName: 'ذال', word: 'ذئب', animalName: 'ذئب'),
  ArabicLetter(
    letter: 'ر',
    letterName: 'راء',
    word: 'رمان',
    imageUrl:
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9b/Pomegranate02_edit.jpg/960px-Pomegranate02_edit.jpg',
  ),
  ArabicLetter(letter: 'ز', letterName: 'زاي', word: 'زرافة', animalName: 'زرافة'),
  ArabicLetter(letter: 'س', letterName: 'سين', word: 'سمكة', animalName: 'سمكة'),
  ArabicLetter(
    letter: 'ش',
    letterName: 'شين',
    word: 'شمس',
    imageUrl:
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/6/65/Mrg_sun_sky_blue.jpg/960px-Mrg_sun_sky_blue.jpg',
  ),
  ArabicLetter(letter: 'ص', letterName: 'صاد', word: 'صقر', animalName: 'صقر'),
  ArabicLetter(letter: 'ض', letterName: 'ضاد', word: 'ضفدع', animalName: 'ضفدع'),
  ArabicLetter(letter: 'ط', letterName: 'طاء', word: 'طاووس', animalName: 'طاووس'),
  ArabicLetter(letter: 'ظ', letterName: 'ظاء', word: 'ظبية', animalName: 'غزال'),
  ArabicLetter(letter: 'ع', letterName: 'عين', word: 'عصفور', animalName: 'عصفور'),
  ArabicLetter(letter: 'غ', letterName: 'غين', word: 'غزال', animalName: 'غزال'),
  ArabicLetter(letter: 'ف', letterName: 'فاء', word: 'فراشة', animalName: 'فراشة'),
  ArabicLetter(letter: 'ق', letterName: 'قاف', word: 'قرد', animalName: 'قرد'),
  ArabicLetter(letter: 'ك', letterName: 'كاف', word: 'كلب', animalName: 'كلب'),
  ArabicLetter(
    letter: 'ل',
    letterName: 'لام',
    word: 'ليمون',
    imageUrl:
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/e/e4/Lemon.jpg/960px-Lemon.jpg',
  ),
  ArabicLetter(
    letter: 'م',
    letterName: 'ميم',
    word: 'موز',
    imageUrl:
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/3/31/Cavendish_banana_from_Maracaibo.jpg/960px-Cavendish_banana_from_Maracaibo.jpg',
  ),
  ArabicLetter(letter: 'ن', letterName: 'نون', word: 'نحلة', animalName: 'نحلة'),
  ArabicLetter(
    letter: 'هـ',
    letterName: 'هاء',
    word: 'هلال',
    imageUrl:
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/7/75/2023_Ramadan_crescent_moon1.jpg/960px-2023_Ramadan_crescent_moon1.jpg',
  ),
  ArabicLetter(
    letter: 'و',
    letterName: 'واو',
    word: 'وردة',
    imageUrl:
        'https://thumb.wikimedia.org/wikipedia/commons/thumb/8/8b/Red-Rose-Sitia-Crete-2.jpg/960px-Red-Rose-Sitia-Crete-2.jpg',
  ),
  ArabicLetter(letter: 'ي', letterName: 'ياء', word: 'يمامة', animalName: 'حمامة'),
];

class EnglishLetter {
  final String letter, word, emoji;
  const EnglishLetter({required this.letter, required this.word, required this.emoji});
  String get lower => letter.toLowerCase();
}

const List<EnglishLetter> englishLetters = [
  EnglishLetter(letter: 'A', word: 'Apple', emoji: '🍎'),
  EnglishLetter(letter: 'B', word: 'Ball', emoji: '⚽'),
  EnglishLetter(letter: 'C', word: 'Cat', emoji: '🐱'),
  EnglishLetter(letter: 'D', word: 'Dog', emoji: '🐶'),
  EnglishLetter(letter: 'E', word: 'Elephant', emoji: '🐘'),
  EnglishLetter(letter: 'F', word: 'Fish', emoji: '🐟'),
  EnglishLetter(letter: 'G', word: 'Giraffe', emoji: '🦒'),
  EnglishLetter(letter: 'H', word: 'Horse', emoji: '🐴'),
  EnglishLetter(letter: 'I', word: 'Ice cream', emoji: '🍦'),
  EnglishLetter(letter: 'J', word: 'Juice', emoji: '🧃'),
  EnglishLetter(letter: 'K', word: 'Kite', emoji: '🪁'),
  EnglishLetter(letter: 'L', word: 'Lion', emoji: '🦁'),
  EnglishLetter(letter: 'M', word: 'Monkey', emoji: '🐵'),
  EnglishLetter(letter: 'N', word: 'Nut', emoji: '🌰'),
  EnglishLetter(letter: 'O', word: 'Orange', emoji: '🍊'),
  EnglishLetter(letter: 'P', word: 'Penguin', emoji: '🐧'),
  EnglishLetter(letter: 'Q', word: 'Queen', emoji: '👸'),
  EnglishLetter(letter: 'R', word: 'Rabbit', emoji: '🐰'),
  EnglishLetter(letter: 'S', word: 'Sun', emoji: '☀️'),
  EnglishLetter(letter: 'T', word: 'Tiger', emoji: '🐯'),
  EnglishLetter(letter: 'U', word: 'Umbrella', emoji: '☂️'),
  EnglishLetter(letter: 'V', word: 'Violin', emoji: '🎻'),
  EnglishLetter(letter: 'W', word: 'Whale', emoji: '🐳'),
  EnglishLetter(letter: 'X', word: 'Box', emoji: '📦'),
  EnglishLetter(letter: 'Y', word: 'Yo-yo', emoji: '🪀'),
  EnglishLetter(letter: 'Z', word: 'Zebra', emoji: '🦓'),
];

class NumberItem {
  final int value;
  final String arWord, enWord, animalName;
  const NumberItem({
    required this.value,
    required this.arWord,
    required this.enWord,
    required this.animalName,
  });
}

const List<NumberItem> numbers = [
  NumberItem(value: 1, arWord: 'واحد', enWord: 'One', animalName: 'قط'),
  NumberItem(value: 2, arWord: 'اثنان', enWord: 'Two', animalName: 'كلب'),
  NumberItem(value: 3, arWord: 'ثلاثة', enWord: 'Three', animalName: 'بطة'),
  NumberItem(value: 4, arWord: 'أربعة', enWord: 'Four', animalName: 'أرنب'),
  NumberItem(value: 5, arWord: 'خمسة', enWord: 'Five', animalName: 'سمكة'),
  NumberItem(value: 6, arWord: 'ستة', enWord: 'Six', animalName: 'عصفور'),
  NumberItem(value: 7, arWord: 'سبعة', enWord: 'Seven', animalName: 'نحلة'),
  NumberItem(value: 8, arWord: 'ثمانية', enWord: 'Eight', animalName: 'فراشة'),
  NumberItem(value: 9, arWord: 'تسعة', enWord: 'Nine', animalName: 'ضفدع'),
  NumberItem(value: 10, arWord: 'عشرة', enWord: 'Ten', animalName: 'خروف'),
  NumberItem(value: 11, arWord: 'أحد عشر', enWord: 'Eleven', animalName: 'ماعز'),
  NumberItem(value: 12, arWord: 'اثنا عشر', enWord: 'Twelve', animalName: 'دجاجة'),
  NumberItem(value: 13, arWord: 'ثلاثة عشر', enWord: 'Thirteen', animalName: 'حصان'),
  NumberItem(value: 14, arWord: 'أربعة عشر', enWord: 'Fourteen', animalName: 'بقرة'),
  NumberItem(value: 15, arWord: 'خمسة عشر', enWord: 'Fifteen', animalName: 'جمل'),
  NumberItem(value: 16, arWord: 'ستة عشر', enWord: 'Sixteen', animalName: 'فيل'),
  NumberItem(value: 17, arWord: 'سبعة عشر', enWord: 'Seventeen', animalName: 'زرافة'),
  NumberItem(value: 18, arWord: 'ثمانية عشر', enWord: 'Eighteen', animalName: 'أسد'),
  NumberItem(value: 19, arWord: 'تسعة عشر', enWord: 'Nineteen', animalName: 'قرد'),
  NumberItem(value: 20, arWord: 'عشرون', enWord: 'Twenty', animalName: 'بطريق'),
];
