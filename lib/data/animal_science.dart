// التصنيف العلمي للحيوانات — المرحلة الثانية 2.4.
// كل حيوان من المئة له فئة علمية صحيحة وحقول مبسطة للطفل
// (الحركة، الحجم، العمر، أليف/بري، نوع الغذاء).
// المصادر: التصنيف العلمي المعتمد للفقاريات واللافقاريات
// (ثدييات، طيور، أسماك، زواحف، برمائيات، حشرات، عنكبيات، لافقاريات).
// ملاحظات علمية مهمة صُححت هنا:
// - الحوت والدولفين والفقمة وأسد البحر ثدييات لا أسماك.
// - البطريق والنعامة طيور رغم أنهما لا يطيران.
// - الضفدع برمائي لا زاحف؛ والسلحفاة البحرية من الزواحف.
// - العنكبوت والعقرب عنكبيات لا حشرات.
// - الأخطبوط والحلزون رخويات، والسلطعون والروبيان قشريات،
//   وقنديل البحر من اللاسعات، ونجمة البحر من شوكيات الجلد،
//   والدودة من الديدان — كلها «لافقاريات» (بلا عمود فقري)،
//   وهي الفئة الثامنة لأن الفئات السبع لا تغطيها.
// الأعمار تقريبية ومبسطة للطفل (متوسط العمر في البرية).
import 'animals.dart';

enum SciClass {
  mammal,
  bird,
  fish,
  reptile,
  amphibian,
  insect,
  arachnid,
  invertebrate,
}

extension SciClassLabel on SciClass {
  String get label {
    switch (this) {
      case SciClass.mammal:
        return 'ثدييات';
      case SciClass.bird:
        return 'طيور';
      case SciClass.fish:
        return 'أسماك';
      case SciClass.reptile:
        return 'زواحف';
      case SciClass.amphibian:
        return 'برمائيات';
      case SciClass.insect:
        return 'حشرات';
      case SciClass.arachnid:
        return 'عنكبيات';
      case SciClass.invertebrate:
        return 'لافقاريات';
    }
  }

  /// وصف مبسط للطفل.
  String get description {
    switch (this) {
      case SciClass.mammal:
        return 'تلد صغارها وتُرضعها، وجسمها مغطى بالشعر أو الفرو';
      case SciClass.bird:
        return 'لها ريش ومنقار، وتضع البيض';
      case SciClass.fish:
        return 'تعيش في الماء وتتنفس بالخياشيم';
      case SciClass.reptile:
        return 'جلدها حراشف، وتضع البيض على اليابسة';
      case SciClass.amphibian:
        return 'تعيش في الماء واليابسة معاً';
      case SciClass.insect:
        return 'لها ست أرجل وجسم من ثلاثة أجزاء';
      case SciClass.arachnid:
        return 'لها ثماني أرجل، مثل العنكبوت والعقرب';
      case SciClass.invertebrate:
        return 'كائنات بلا عمود فقري تعيش غالباً في البحر';
    }
  }
}

class AnimalScience {
  final SciClass sciClass;
  final String movement;
  final String size;
  final String lifespan;
  final bool isPet;
  final String diet;
  const AnimalScience({
    required this.sciClass,
    required this.movement,
    required this.size,
    required this.lifespan,
    required this.isPet,
    required this.diet,
  });
}

/// الحجوم المسموحة (تُستخدم في الاختبارات).
const List<String> animalSizes = [
  'صغير جداً',
  'صغير',
  'متوسط',
  'كبير',
  'ضخم',
];

/// أنواع الغذاء المسموحة (تُستخدم في الاختبارات).
const List<String> animalDiets = [
  'آكل لحوم',
  'آكل أعشاب',
  'آكل كل شيء',
  'آكل حبوب',
  'آكل فواكه',
  'آكل أسماك',
  'آكل حشرات',
  'يشرب الرحيق',
];

const Map<String, AnimalScience> animalScience = {
  'أسد': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يجري',
    size: 'ضخم',
    lifespan: 'نحو 15 سنة',
    isPet: false,
    diet: 'آكل لحوم',
  ),
  'نمر': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يجري',
    size: 'ضخم',
    lifespan: 'نحو 15 سنة',
    isPet: false,
    diet: 'آكل لحوم',
  ),
  'فيل': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يمشي',
    size: 'ضخم',
    lifespan: 'نحو 60 سنة',
    isPet: false,
    diet: 'آكل أعشاب',
  ),
  'زرافة': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يمشي',
    size: 'ضخم',
    lifespan: 'نحو 25 سنة',
    isPet: false,
    diet: 'آكل أعشاب',
  ),
  'قرد': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يتسلق ويقفز',
    size: 'متوسط',
    lifespan: 'نحو 25 سنة',
    isPet: false,
    diet: 'آكل كل شيء',
  ),
  'دب': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يمشي',
    size: 'ضخم',
    lifespan: 'نحو 25 سنة',
    isPet: false,
    diet: 'آكل كل شيء',
  ),
  'ذئب': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يجري',
    size: 'كبير',
    lifespan: 'نحو 13 سنة',
    isPet: false,
    diet: 'آكل لحوم',
  ),
  'ثعلب': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يجري',
    size: 'متوسط',
    lifespan: 'نحو 10 سنوات',
    isPet: false,
    diet: 'آكل كل شيء',
  ),
  'غزال': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يجري',
    size: 'متوسط',
    lifespan: 'نحو 15 سنة',
    isPet: false,
    diet: 'آكل أعشاب',
  ),
  'حمار وحشي': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يجري',
    size: 'كبير',
    lifespan: 'نحو 25 سنة',
    isPet: false,
    diet: 'آكل أعشاب',
  ),
  'فرس النهر': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يمشي ويسبح',
    size: 'ضخم',
    lifespan: 'نحو 45 سنة',
    isPet: false,
    diet: 'آكل أعشاب',
  ),
  'وحيد القرن': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يمشي',
    size: 'ضخم',
    lifespan: 'نحو 45 سنة',
    isPet: false,
    diet: 'آكل أعشاب',
  ),
  'فهد': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يجري',
    size: 'كبير',
    lifespan: 'نحو 12 سنة',
    isPet: false,
    diet: 'آكل لحوم',
  ),
  'باندا': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يمشي ويتسلق',
    size: 'كبير',
    lifespan: 'نحو 20 سنة',
    isPet: false,
    diet: 'آكل أعشاب',
  ),
  'كوالا': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يتسلق',
    size: 'متوسط',
    lifespan: 'نحو 15 سنة',
    isPet: false,
    diet: 'آكل أعشاب',
  ),
  'كنغر': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يقفز',
    size: 'كبير',
    lifespan: 'نحو 20 سنة',
    isPet: false,
    diet: 'آكل أعشاب',
  ),
  'غوريلا': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يمشي',
    size: 'ضخم',
    lifespan: 'نحو 40 سنة',
    isPet: false,
    diet: 'آكل كل شيء',
  ),
  'سنجاب': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يتسلق ويقفز',
    size: 'صغير',
    lifespan: 'نحو 10 سنوات',
    isPet: false,
    diet: 'آكل كل شيء',
  ),
  'قط': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يمشي ويقفز',
    size: 'صغير',
    lifespan: 'نحو 15 سنة',
    isPet: true,
    diet: 'آكل لحوم',
  ),
  'كلب': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يجري',
    size: 'متوسط',
    lifespan: 'نحو 13 سنة',
    isPet: true,
    diet: 'آكل كل شيء',
  ),
  'بقرة': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يمشي',
    size: 'كبير',
    lifespan: 'نحو 20 سنة',
    isPet: true,
    diet: 'آكل أعشاب',
  ),
  'حصان': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يجري',
    size: 'كبير',
    lifespan: 'نحو 30 سنة',
    isPet: true,
    diet: 'آكل أعشاب',
  ),
  'خروف': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يمشي',
    size: 'متوسط',
    lifespan: 'نحو 12 سنة',
    isPet: true,
    diet: 'آكل أعشاب',
  ),
  'ماعز': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يمشي ويقفز',
    size: 'متوسط',
    lifespan: 'نحو 15 سنة',
    isPet: true,
    diet: 'آكل أعشاب',
  ),
  'حمار': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يمشي',
    size: 'متوسط',
    lifespan: 'نحو 25 سنة',
    isPet: true,
    diet: 'آكل أعشاب',
  ),
  'ديك': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يمشي',
    size: 'صغير',
    lifespan: 'نحو 8 سنوات',
    isPet: true,
    diet: 'آكل حبوب',
  ),
  'دجاجة': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يمشي',
    size: 'صغير',
    lifespan: 'نحو 8 سنوات',
    isPet: true,
    diet: 'آكل حبوب',
  ),
  'بطة': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يمشي ويسبح',
    size: 'صغير',
    lifespan: 'نحو 10 سنوات',
    isPet: true,
    diet: 'آكل كل شيء',
  ),
  'أوزة': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يمشي ويسبح',
    size: 'متوسط',
    lifespan: 'نحو 20 سنة',
    isPet: true,
    diet: 'آكل أعشاب',
  ),
  'أرنب': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يقفز',
    size: 'صغير',
    lifespan: 'نحو 10 سنوات',
    isPet: true,
    diet: 'آكل أعشاب',
  ),
  'جاموس': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يمشي',
    size: 'ضخم',
    lifespan: 'نحو 25 سنة',
    isPet: true,
    diet: 'آكل أعشاب',
  ),
  'ثور': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يمشي',
    size: 'ضخم',
    lifespan: 'نحو 20 سنة',
    isPet: true,
    diet: 'آكل أعشاب',
  ),
  'ديك رومي': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يمشي',
    size: 'متوسط',
    lifespan: 'نحو 10 سنوات',
    isPet: true,
    diet: 'آكل حبوب',
  ),
  'كتكوت': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يمشي',
    size: 'صغير جداً',
    lifespan: 'نحو 8 سنوات',
    isPet: true,
    diet: 'آكل حبوب',
  ),
  'عصفور': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يطير',
    size: 'صغير',
    lifespan: 'نحو 5 سنوات',
    isPet: false,
    diet: 'آكل حبوب',
  ),
  'بومة': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يطير',
    size: 'متوسط',
    lifespan: 'نحو 15 سنة',
    isPet: false,
    diet: 'آكل لحوم',
  ),
  'ببغاء': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يطير',
    size: 'متوسط',
    lifespan: 'نحو 50 سنة',
    isPet: false,
    diet: 'آكل فواكه',
  ),
  'نسر': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يطير',
    size: 'كبير',
    lifespan: 'نحو 30 سنة',
    isPet: false,
    diet: 'آكل لحوم',
  ),
  'صقر': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يطير',
    size: 'متوسط',
    lifespan: 'نحو 20 سنة',
    isPet: false,
    diet: 'آكل لحوم',
  ),
  'غراب': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يطير',
    size: 'متوسط',
    lifespan: 'نحو 20 سنة',
    isPet: false,
    diet: 'آكل كل شيء',
  ),
  'حمامة': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يطير',
    size: 'صغير',
    lifespan: 'نحو 10 سنوات',
    isPet: true,
    diet: 'آكل حبوب',
  ),
  'طاووس': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يمشي',
    size: 'متوسط',
    lifespan: 'نحو 20 سنة',
    isPet: false,
    diet: 'آكل كل شيء',
  ),
  'فلامنجو': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يمشي ويسبح',
    size: 'متوسط',
    lifespan: 'نحو 30 سنة',
    isPet: false,
    diet: 'آكل كل شيء',
  ),
  'بجعة': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يسبح ويطير',
    size: 'كبير',
    lifespan: 'نحو 25 سنة',
    isPet: false,
    diet: 'آكل أعشاب',
  ),
  'بطريق': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يمشي ويسبح',
    size: 'متوسط',
    lifespan: 'نحو 20 سنة',
    isPet: false,
    diet: 'آكل أسماك',
  ),
  'كناري': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يطير',
    size: 'صغير',
    lifespan: 'نحو 10 سنوات',
    isPet: true,
    diet: 'آكل حبوب',
  ),
  'بلبل': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يطير',
    size: 'صغير',
    lifespan: 'نحو 10 سنوات',
    isPet: false,
    diet: 'آكل حشرات',
  ),
  'نقار الخشب': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يطير',
    size: 'صغير',
    lifespan: 'نحو 10 سنوات',
    isPet: false,
    diet: 'آكل حشرات',
  ),
  'طائر الطنان': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يطير',
    size: 'صغير جداً',
    lifespan: 'نحو 5 سنوات',
    isPet: false,
    diet: 'يشرب الرحيق',
  ),
  'لقلق': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يطير',
    size: 'كبير',
    lifespan: 'نحو 25 سنة',
    isPet: false,
    diet: 'آكل أسماك',
  ),
  'نورس': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يطير',
    size: 'متوسط',
    lifespan: 'نحو 20 سنة',
    isPet: false,
    diet: 'آكل أسماك',
  ),
  'كروان': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يطير',
    size: 'متوسط',
    lifespan: 'نحو 15 سنة',
    isPet: false,
    diet: 'آكل حشرات',
  ),
  'دولفين': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يسبح',
    size: 'كبير',
    lifespan: 'نحو 40 سنة',
    isPet: false,
    diet: 'آكل أسماك',
  ),
  'حوت': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يسبح',
    size: 'ضخم',
    lifespan: 'نحو 70 سنة',
    isPet: false,
    diet: 'آكل أسماك',
  ),
  'سمكة': AnimalScience(
    sciClass: SciClass.fish,
    movement: 'يسبح',
    size: 'صغير',
    lifespan: 'نحو 5 سنوات',
    isPet: false,
    diet: 'آكل كل شيء',
  ),
  'قرش': AnimalScience(
    sciClass: SciClass.fish,
    movement: 'يسبح',
    size: 'ضخم',
    lifespan: 'نحو 30 سنة',
    isPet: false,
    diet: 'آكل لحوم',
  ),
  'أخطبوط': AnimalScience(
    sciClass: SciClass.invertebrate,
    movement: 'يسبح',
    size: 'متوسط',
    lifespan: 'نحو 3 سنوات',
    isPet: false,
    diet: 'آكل لحوم',
  ),
  'سلحفاة بحرية': AnimalScience(
    sciClass: SciClass.reptile,
    movement: 'يسبح',
    size: 'كبير',
    lifespan: 'نحو 80 سنة',
    isPet: false,
    diet: 'آكل أعشاب',
  ),
  'سلطعون': AnimalScience(
    sciClass: SciClass.invertebrate,
    movement: 'يمشي ويسبح',
    size: 'صغير',
    lifespan: 'نحو 5 سنوات',
    isPet: false,
    diet: 'آكل كل شيء',
  ),
  'قنديل البحر': AnimalScience(
    sciClass: SciClass.invertebrate,
    movement: 'يسبح',
    size: 'صغير',
    lifespan: 'نحو سنة واحدة',
    isPet: false,
    diet: 'آكل كل شيء',
  ),
  'حصان البحر': AnimalScience(
    sciClass: SciClass.fish,
    movement: 'يسبح',
    size: 'صغير جداً',
    lifespan: 'نحو 3 سنوات',
    isPet: false,
    diet: 'آكل كل شيء',
  ),
  'نجمة البحر': AnimalScience(
    sciClass: SciClass.invertebrate,
    movement: 'يمشي ببطء',
    size: 'صغير',
    lifespan: 'نحو 10 سنوات',
    isPet: false,
    diet: 'آكل كل شيء',
  ),
  'فقمة': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يسبح',
    size: 'كبير',
    lifespan: 'نحو 30 سنة',
    isPet: false,
    diet: 'آكل أسماك',
  ),
  'أسد البحر': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يسبح',
    size: 'كبير',
    lifespan: 'نحو 25 سنة',
    isPet: false,
    diet: 'آكل أسماك',
  ),
  'سمكة المهرج': AnimalScience(
    sciClass: SciClass.fish,
    movement: 'يسبح',
    size: 'صغير',
    lifespan: 'نحو 10 سنوات',
    isPet: false,
    diet: 'آكل كل شيء',
  ),
  'روبيان': AnimalScience(
    sciClass: SciClass.invertebrate,
    movement: 'يسبح',
    size: 'صغير',
    lifespan: 'نحو 3 سنوات',
    isPet: false,
    diet: 'آكل كل شيء',
  ),
  'ثعبان البحر': AnimalScience(
    sciClass: SciClass.fish,
    movement: 'يسبح',
    size: 'متوسط',
    lifespan: 'نحو 15 سنة',
    isPet: false,
    diet: 'آكل أسماك',
  ),
  'حوت العنبر': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يسبح',
    size: 'ضخم',
    lifespan: 'نحو 70 سنة',
    isPet: false,
    diet: 'آكل أسماك',
  ),
  'ثعبان': AnimalScience(
    sciClass: SciClass.reptile,
    movement: 'يزحف',
    size: 'متوسط',
    lifespan: 'نحو 20 سنة',
    isPet: false,
    diet: 'آكل لحوم',
  ),
  'تمساح': AnimalScience(
    sciClass: SciClass.reptile,
    movement: 'يمشي ويسبح',
    size: 'ضخم',
    lifespan: 'نحو 70 سنة',
    isPet: false,
    diet: 'آكل لحوم',
  ),
  'سحلية': AnimalScience(
    sciClass: SciClass.reptile,
    movement: 'يزحف',
    size: 'صغير',
    lifespan: 'نحو 10 سنوات',
    isPet: false,
    diet: 'آكل حشرات',
  ),
  'ضفدع': AnimalScience(
    sciClass: SciClass.amphibian,
    movement: 'يقفز ويسبح',
    size: 'صغير',
    lifespan: 'نحو 10 سنوات',
    isPet: false,
    diet: 'آكل حشرات',
  ),
  'نحلة': AnimalScience(
    sciClass: SciClass.insect,
    movement: 'يطير',
    size: 'صغير جداً',
    lifespan: 'نحو شهرين',
    isPet: false,
    diet: 'يشرب الرحيق',
  ),
  'فراشة': AnimalScience(
    sciClass: SciClass.insect,
    movement: 'يطير',
    size: 'صغير',
    lifespan: 'نحو شهر واحد',
    isPet: false,
    diet: 'يشرب الرحيق',
  ),
  'نملة': AnimalScience(
    sciClass: SciClass.insect,
    movement: 'يمشي',
    size: 'صغير جداً',
    lifespan: 'نحو سنة واحدة',
    isPet: false,
    diet: 'آكل كل شيء',
  ),
  'خنفساء': AnimalScience(
    sciClass: SciClass.insect,
    movement: 'يمشي ويطير',
    size: 'صغير',
    lifespan: 'نحو سنة واحدة',
    isPet: false,
    diet: 'آكل أعشاب',
  ),
  'جندب': AnimalScience(
    sciClass: SciClass.insect,
    movement: 'يقفز ويطير',
    size: 'صغير',
    lifespan: 'نحو سنة واحدة',
    isPet: false,
    diet: 'آكل أعشاب',
  ),
  'صرصور': AnimalScience(
    sciClass: SciClass.insect,
    movement: 'يقفز',
    size: 'صغير',
    lifespan: 'نحو سنة واحدة',
    isPet: false,
    diet: 'آكل أعشاب',
  ),
  'ذبابة': AnimalScience(
    sciClass: SciClass.insect,
    movement: 'يطير',
    size: 'صغير جداً',
    lifespan: 'نحو شهر واحد',
    isPet: false,
    diet: 'آكل كل شيء',
  ),
  'حلزون': AnimalScience(
    sciClass: SciClass.invertebrate,
    movement: 'يزحف',
    size: 'صغير',
    lifespan: 'نحو 5 سنوات',
    isPet: false,
    diet: 'آكل أعشاب',
  ),
  'عنكبوت': AnimalScience(
    sciClass: SciClass.arachnid,
    movement: 'يمشي',
    size: 'صغير',
    lifespan: 'نحو سنتين',
    isPet: false,
    diet: 'آكل حشرات',
  ),
  'عقرب': AnimalScience(
    sciClass: SciClass.arachnid,
    movement: 'يمشي',
    size: 'صغير',
    lifespan: 'نحو 5 سنوات',
    isPet: false,
    diet: 'آكل حشرات',
  ),
  'دودة': AnimalScience(
    sciClass: SciClass.invertebrate,
    movement: 'يزحف',
    size: 'صغير',
    lifespan: 'نحو 5 سنوات',
    isPet: false,
    diet: 'آكل أعشاب',
  ),
  'يعسوب': AnimalScience(
    sciClass: SciClass.insect,
    movement: 'يطير',
    size: 'صغير',
    lifespan: 'نحو سنة واحدة',
    isPet: false,
    diet: 'آكل حشرات',
  ),
  'جمل': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يمشي',
    size: 'ضخم',
    lifespan: 'نحو 40 سنة',
    isPet: true,
    diet: 'آكل أعشاب',
  ),
  'دب قطبي': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يمشي ويسبح',
    size: 'ضخم',
    lifespan: 'نحو 25 سنة',
    isPet: false,
    diet: 'آكل لحوم',
  ),
  'ثعلب القطب': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يجري',
    size: 'متوسط',
    lifespan: 'نحو 10 سنوات',
    isPet: false,
    diet: 'آكل كل شيء',
  ),
  'رنة': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يمشي',
    size: 'كبير',
    lifespan: 'نحو 15 سنة',
    isPet: false,
    diet: 'آكل أعشاب',
  ),
  'بومة ثلجية': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يطير',
    size: 'متوسط',
    lifespan: 'نحو 15 سنة',
    isPet: false,
    diet: 'آكل لحوم',
  ),
  'لاما': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يمشي',
    size: 'كبير',
    lifespan: 'نحو 20 سنة',
    isPet: true,
    diet: 'آكل أعشاب',
  ),
  'ألبكة': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يمشي',
    size: 'متوسط',
    lifespan: 'نحو 20 سنة',
    isPet: true,
    diet: 'آكل أعشاب',
  ),
  'نعامة': AnimalScience(
    sciClass: SciClass.bird,
    movement: 'يجري',
    size: 'ضخم',
    lifespan: 'نحو 40 سنة',
    isPet: false,
    diet: 'آكل كل شيء',
  ),
  'ضب': AnimalScience(
    sciClass: SciClass.reptile,
    movement: 'يزحف',
    size: 'صغير',
    lifespan: 'نحو 15 سنة',
    isPet: false,
    diet: 'آكل أعشاب',
  ),
  'ورل': AnimalScience(
    sciClass: SciClass.reptile,
    movement: 'يمشي ويزحف',
    size: 'كبير',
    lifespan: 'نحو 15 سنة',
    isPet: false,
    diet: 'آكل لحوم',
  ),
  'قنفذ الصحراء': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يمشي',
    size: 'صغير',
    lifespan: 'نحو 5 سنوات',
    isPet: false,
    diet: 'آكل حشرات',
  ),
  'سنجاب طائر': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يتسلق ويقفز',
    size: 'صغير',
    lifespan: 'نحو 10 سنوات',
    isPet: false,
    diet: 'آكل كل شيء',
  ),
  'ماعز جبلي': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يمشي ويقفز',
    size: 'متوسط',
    lifespan: 'نحو 15 سنة',
    isPet: false,
    diet: 'آكل أعشاب',
  ),
  'نمر الثلج': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يجري',
    size: 'كبير',
    lifespan: 'نحو 15 سنة',
    isPet: false,
    diet: 'آكل لحوم',
  ),
  'هاسكي': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يجري',
    size: 'متوسط',
    lifespan: 'نحو 13 سنة',
    isPet: true,
    diet: 'آكل كل شيء',
  ),
  'ثعلب الفنك': AnimalScience(
    sciClass: SciClass.mammal,
    movement: 'يجري',
    size: 'صغير',
    lifespan: 'نحو 10 سنوات',
    isPet: false,
    diet: 'آكل كل شيء',
  ),
};

/// البيانات العلمية لحيوان ما (أو null إن لم توجد).
AnimalScience? scienceFor(Animal a) => animalScience[a.nameAr];

