// منطق مطابقة اسم الحيوان المنطوق — يُختبر بوحدة اختبار.
import '../data/animals.dart';

/// يوحّد النص العربي: إزالة التشكيل، وتوحيد الألف والتاء المربوطة والياء،
/// وإزالة "ال" التعريف من البداية.
String normalizeArabic(String input) {
  var s = input.trim();
  s = s.replaceAll(RegExp(r'[\u064B-\u0652\u0670]'), '');
  s = s.replaceAll(RegExp(r'[أإآٱ]'), 'ا');
  s = s.replaceAll('ة', 'ه');
  s = s.replaceAll('ى', 'ي');
  s = s.replaceAll('ؤ', 'و');
  s = s.replaceAll('ئ', 'ي');
  if (s.startsWith('ال') && s.length > 2) s = s.substring(2);
  return s.trim();
}

/// أسماء بديلة شائعة ينطق بها الأطفال.
const Map<String, String> animalAliases = {
  'قطه': 'قط',
  'قطة': 'قط',
  'كلبة': 'كلب',
  'اسد': 'أسد',
  'فيله': 'فيل',
  'زرافه': 'زرافة',
  'بقره': 'بقرة',
  'حصان': 'حصان',
  'خروف': 'خروف',
  'دجاجه': 'دجاجة',
  'بطه': 'بطة',
  'ارنب': 'أرنب',
  'سلحفاه': 'سلحفاة',
  'فراشه': 'فراشة',
  'نحله': 'نحلة',
  'ثعبان': 'ثعبان',
  'حيه': 'ثعبان',
  'عصفور': 'عصفور',
  'طير': 'عصفور',
  'بومه': 'بومة',
  'جمل': 'جمل',
  'ناقه': 'جمل',
};

/// يبحث عن الحيوان المطابق لما نطقه الطفل (عربي أو إنجليزي).
Animal? findAnimal(String spoken, List<Animal> all) {
  final raw = spoken.trim();
  if (raw.isEmpty) return null;
  final norm = normalizeArabic(raw);
  final alias = animalAliases[norm] ?? animalAliases[raw.trim()];
  final target = alias != null ? normalizeArabic(alias) : norm;
  // مطابقة تامة أولاً
  for (final a in all) {
    if (normalizeArabic(a.nameAr) == target) return a;
    if (a.nameEn.toLowerCase() == raw.toLowerCase().trim()) return a;
  }
  // مطابقة جزئية: الاسم داخل الجملة المنطوقة أو العكس
  for (final a in all) {
    final n = normalizeArabic(a.nameAr);
    if (n.length >= 3 && (target.contains(n) || n.contains(target))) {
      return a;
    }
  }
  return null;
}

/// أسماء الأقسام بالعربية.
const Map<String, String> categoryNames = {
  'forest': 'حيوانات الغابة',
  'farm': 'حيوانات المزرعة',
  'birds': 'طيور',
  'sea': 'حيوانات البحر',
  'reptiles': 'زواحف وحشرات',
  'desert': 'حيوانات الصحراء والثلج',
};
