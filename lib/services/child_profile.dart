// ملفات الأطفال: اختيار الطفل الحالي من داخل التطبيق، وتفعيل الاسم
// في الترحيب والتشجيع والإهداء وعنوان التطبيق، مع نجوم وتقدم مستقل
// لكل طفل. يبدأ التطبيق بفارس وفهد، ويمكن للوالدين إضافة أطفال آخرين.
import 'package:shared_preferences/shared_preferences.dart';

class ChildProfile {
  static const String defaultChild = 'فارس';
  static const List<String> defaultChildren = ['فارس', 'فهد'];

  static const _currentKey = 'child_current';
  static const _listKey = 'child_list';
  static const _migratedKey = 'child_migrated_v1';

  /// بادئة مفاتيح تقدم الطفل (النجوم والتعلّم والدروس والأوسمة).
  static String keyPrefix(String childName) => 'c_${childName}_';

  static Future<String> currentChild() async {
    final p = await SharedPreferences.getInstance();
    final name = p.getString(_currentKey);
    if (name == null || name.trim().isEmpty) return defaultChild;
    return name;
  }

  static Future<List<String>> children() async {
    final p = await SharedPreferences.getInstance();
    final list = p.getStringList(_listKey);
    if (list == null || list.isEmpty) return List.of(defaultChildren);
    return list;
  }

  static Future<void> setCurrent(String name) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_currentKey, name.trim());
  }

  // ---------------- عمر الطفل (أساس المستويات العمرية) ----------------

  static String _ageKey(String name) => 'child_age_$name';

  /// عمر الطفل بالسنوات (3–10)، أو null إن لم يُحدد بعد.
  /// فارس عمره 5 سنوات (حقيقة ذكرها المستخدم) فيُستخدم كافتراضي له
  /// ما لم يحدد الوالد عمراً مختلفاً؛ وأي طفل آخر بلا عمر محدد يبقى null.
  static Future<int?> childAge(String name) async {
    final p = await SharedPreferences.getInstance();
    final stored = p.getInt(_ageKey(name));
    if (stored != null) return stored;
    if (name == defaultChild) return 5;
    return null;
  }

  /// يحفظ عمر الطفل (يُقيد إلى 3–10 سنوات).
  static Future<void> setChildAge(String name, int age) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_ageKey(name), age.clamp(3, 10));
  }

  /// يمسح العمر المحفوظ فيعود للافتراضي (فارس 5، وغيره بلا عمر محدد).
  static Future<void> clearChildAge(String name) async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_ageKey(name));
  }

  /// يضيف طفلاً جديداً. يرجع false إن كان الاسم فارغاً أو مكرراً أو طويلاً.
  static Future<bool> addChild(String name) async {
    final clean = name.trim();
    if (clean.isEmpty || clean.length > 20) return false;
    final list = await children();
    if (list.contains(clean)) return false;
    list.add(clean);
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_listKey, list);
    return true;
  }

  /// يحذف الطفل وتقدمه كاملاً. لا يحذف إن كان الطفل الوحيد.
  static Future<void> removeChild(String name) async {
    final list = await children();
    if (list.length <= 1 || !list.contains(name)) return;
    list.remove(name);
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_listKey, list);
    final prefix = keyPrefix(name);
    for (final k in p.getKeys().toList()) {
      if (k.startsWith(prefix)) await p.remove(k);
    }
    if ((await currentChild()) == name) {
      await p.setString(_currentKey, list.first);
    }
  }

  /// عنوان التطبيق حسب الطفل، مثلاً «فهد والحيوانات».
  static String appTitleFor(String name) => '$name والحيوانات';

  /// الإهداء: نص فارس الأصلي حرفياً، ولأي طفل آخر إهداء عام باسمه.
  static String dedicationFor(String name) {
    if (name == defaultChild) {
      return 'إهداء إلى ابني حبيبي فارس اسامة ابراهيم عبدالحكيم';
    }
    return 'إهداء إلى ابني حبيبي $name';
  }

  /// ترحيل تقدم النسخ القديمة (المحفوظ بلا بادئة) إلى ملف فارس، مرة واحدة.
  /// المفاتيح القديمة تبقى كما هي؛ النسخة الجديدة تقرأ المفاتيح المسبوقة فقط.
  static Future<void> migrateLegacyProgress() async {
    final p = await SharedPreferences.getInstance();
    if (p.getBool(_migratedKey) ?? false) return;
    const legacyKeys = ['stars_total', 'badges_unlocked'];
    const legacyPrefixes = ['learned_', 'religion_'];
    final prefix = keyPrefix(defaultChild);
    for (final k in p.getKeys().toList()) {
      final isLegacy = legacyKeys.contains(k) ||
          legacyPrefixes.any((pre) => k.startsWith(pre));
      if (isLegacy && !p.containsKey('$prefix$k')) {
        final v = p.get(k);
        if (v is int) {
          await p.setInt('$prefix$k', v);
        } else if (v is bool) {
          await p.setBool('$prefix$k', v);
        } else if (v is String) {
          await p.setString('$prefix$k', v);
        } else if (v is List<String>) {
          await p.setStringList('$prefix$k', v);
        }
      }
    }
    await p.setBool(_migratedKey, true);
  }
}
