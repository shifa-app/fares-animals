// حفظ التقدم محلياً: النجوم والحيوانات المتعلمة وأقسام الدين المنجزة.
// التقدم مستقل لكل طفل: كل مفتاح مسبوق ببادئة الطفل الحالي.
import 'package:shared_preferences/shared_preferences.dart';

import '../data/quran.dart';
import 'child_profile.dart';

class ProgressStore {
  static const _starsKey = 'stars_total';
  static const _learnedPrefix = 'learned_';
  static const _religionPrefix = 'religion_';
  static const _badgesKey = 'badges_unlocked';
  static const _nightModeKey = 'night_mode';
  static const _volumeKey = 'sound_volume';

  /// بادئة مفاتيح الطفل الحالي، مثلاً `c_فهد_`.
  static Future<String> _prefix() async {
    final child = await ChildProfile.currentChild();
    return ChildProfile.keyPrefix(child);
  }

  static Future<int> stars() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('${await _prefix()}$_starsKey') ?? 0;
  }

  /// نجوم طفل محدد (بلا تبديل الطفل الحالي).
  static Future<int> starsFor(String child) async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('${ChildProfile.keyPrefix(child)}$_starsKey') ?? 0;
  }

  static Future<int> addStars(int n) async {
    final p = await SharedPreferences.getInstance();
    final key = '${await _prefix()}$_starsKey';
    final v = (p.getInt(key) ?? 0) + n;
    await p.setInt(key, v);
    return v;
  }

  // ---------------- نجمة واحدة لكل إنجاز ----------------

  static const _starredPrefix = 'starred_';

  /// يمنح [n] نجوماً لأول مرة فقط لهذا الإنجاز ([activityId]).
  /// يعيد true إن مُنحت النجوم الآن، وfalse إن كانت مُنحت من قبل
  /// (إعادة النشاط نفسه لا تمنح نجوماً جديدة).
  /// مفتاح الإنجاز يُمسح مع إعادة ضبط التقدم، فيستطيع الطفل
  /// كسب النجوم من جديد بعد إعادة الضبط.
  static Future<bool> awardStarsOnce(String activityId, int n) async {
    final p = await SharedPreferences.getInstance();
    final key = '${await _prefix()}$_starredPrefix$activityId';
    if (p.getBool(key) ?? false) return false;
    await p.setBool(key, true);
    await addStars(n);
    return true;
  }

  /// هل سبق منح نجمة لهذا الإنجاز؟
  static Future<bool> hasStarFor(String activityId) async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('${await _prefix()}$_starredPrefix$activityId') ?? false;
  }

  /// هل سبق منح نجمة لهذا الإنجاز لطفل محدد (بلا تبديل الطفل الحالي)؟
  static Future<bool> hasStarForChild(String child, String activityId) async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(
          '${ChildProfile.keyPrefix(child)}$_starredPrefix$activityId',
        ) ??
        false;
  }

  static Future<bool> isLearned(String nameAr) async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('${await _prefix()}$_learnedPrefix$nameAr') ?? false;
  }

  static Future<void> markLearned(String nameAr) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('${await _prefix()}$_learnedPrefix$nameAr', true);
    await logActivity('تعلّمت $nameAr');
  }

  // ---------------- المفضلة ----------------

  static const _favoritesKey = 'favorites';

  /// أسماء الحيوانات المفضلة لدى الطفل الحالي.
  static Future<List<String>> favorites() async {
    final p = await SharedPreferences.getInstance();
    return p.getStringList('${await _prefix()}$_favoritesKey') ?? [];
  }

  static Future<bool> isFavorite(String nameAr) async =>
      (await favorites()).contains(nameAr);

  /// يبدّل المفضلة لحيوان، ويعيد الحالة الجديدة
  /// (true = أُضيف إلى المفضلة، false = أُزيل منها).
  static Future<bool> toggleFavorite(String nameAr) async {
    final p = await SharedPreferences.getInstance();
    final key = '${await _prefix()}$_favoritesKey';
    final list = List<String>.from(p.getStringList(key) ?? []);
    final added = !list.contains(nameAr);
    if (added) {
      list.add(nameAr);
    } else {
      list.remove(nameAr);
    }
    await p.setStringList(key, list);
    return added;
  }

  static Future<int> learnedCount(List<String> names) async {
    final p = await SharedPreferences.getInstance();
    final prefix = await _prefix();
    var c = 0;
    for (final n in names) {
      if (p.getBool('$prefix$_learnedPrefix$n') ?? false) c++;
    }
    return c;
  }

  static Future<void> markReligion(String key) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('${await _prefix()}$_religionPrefix$key', true);
    final label = _religionLabel(key);
    if (label != null) await logActivity(label);
  }

  /// وصف عربي قصير لمفتاح ديني، ليظهر في آخر الأنشطة.
  static String? _religionLabel(String key) {
    if (key.startsWith('number_')) {
      return 'تعلّم الرقم ${key.substring('number_'.length)}';
    }
    if (key.startsWith('letter_ar_')) {
      return 'تعلّم الحرف ${key.substring('letter_ar_'.length)}';
    }
    if (key.startsWith('letter_en_')) {
      return 'تعلّم الحرف ${key.substring('letter_en_'.length)}';
    }
    if (key.startsWith('memorize_')) {
      final n = int.tryParse(key.substring('memorize_'.length));
      final name = n == null
          ? null
          : memorizeSurahs
              .where((s) => s.number == n)
              .map((s) => s.name)
              .firstOrNull;
      return name == null ? 'حفظ سورة' : 'حفظ سورة $name';
    }
    if (key.startsWith('story_bed_')) return 'استمع إلى قصة';
    if (key.startsWith('dhikr_')) return 'تعلّم ذكراً';
    return null;
  }

  static Future<bool> isReligion(String key) async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('${await _prefix()}$_religionPrefix$key') ?? false;
  }

  static Future<int> religionCount(List<String> keys) async {
    final p = await SharedPreferences.getInstance();
    final prefix = await _prefix();
    var c = 0;
    for (final k in keys) {
      if (p.getBool('$prefix$_religionPrefix$k') ?? false) c++;
    }
    return c;
  }

  // ---------------- قراءة تقدم طفل محدد (بلا تبديل الطفل الحالي) ----------------

  /// عدد الحيوانات المتعلمة لطفل محدد.
  static Future<int> learnedCountFor(String child, List<String> names) async {
    final p = await SharedPreferences.getInstance();
    final prefix = ChildProfile.keyPrefix(child);
    var c = 0;
    for (final n in names) {
      if (p.getBool('$prefix$_learnedPrefix$n') ?? false) c++;
    }
    return c;
  }

  /// عدد مفاتيح الدين المتعلمة لطفل محدد.
  static Future<int> religionCountFor(String child, List<String> keys) async {
    final p = await SharedPreferences.getInstance();
    final prefix = ChildProfile.keyPrefix(child);
    var c = 0;
    for (final k in keys) {
      if (p.getBool('$prefix$_religionPrefix$k') ?? false) c++;
    }
    return c;
  }

  // ---------------- آخر الأنشطة (تظهر في الرئيسية) ----------------

  static const _recentKey = 'recent';

  /// أقصى عدد أنشطة يُعرض في الرئيسية.
  static const int recentMax = 4;

  /// آخر أنشطة الطفل الحالي (الأحدث أولاً، حتى [recentMax]).
  static Future<List<String>> recentActivities() async {
    final p = await SharedPreferences.getInstance();
    return p.getStringList('${await _prefix()}$_recentKey') ?? <String>[];
  }

  /// يسجل نشاطاً في آخر الأنشطة (الأحدث أولاً، بلا تكرار متتالٍ).
  static Future<void> logActivity(String label) async {
    if (label.trim().isEmpty) return;
    final p = await SharedPreferences.getInstance();
    final key = '${await _prefix()}$_recentKey';
    final list = (p.getStringList(key) ?? <String>[]).toList();
    if (list.isNotEmpty && list.first == label) return;
    list.insert(0, label);
    await p.setStringList(key, list.take(recentMax).toList());
  }

  // ---------------- الأوسمة ----------------

  /// معرّفات الأوسمة المفتوحة (مثلاً first_animal, ten_animals,
  /// first_surah, story_reader).
  static Future<Set<String>> badges() async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList('${await _prefix()}$_badgesKey') ?? <String>[])
        .toSet();
  }

  static Future<void> unlockBadge(String id) async {
    final p = await SharedPreferences.getInstance();
    final key = '${await _prefix()}$_badgesKey';
    final current = (p.getStringList(key) ?? <String>[]).toSet()..add(id);
    await p.setStringList(key, current.toList());
  }

  // ---------------- الوضع الليلي الدافئ (قصص قبل النوم) ----------------

  static Future<bool> nightMode() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_nightModeKey) ?? false;
  }

  static Future<void> setNightMode(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_nightModeKey, value);
  }

  // ---------------- مستوى الصوت (ركن الوالدين) ----------------

  static Future<double> volume() async {
    final p = await SharedPreferences.getInstance();
    return (p.getDouble(_volumeKey) ?? 1.0).clamp(0.0, 1.0);
  }

  static Future<void> setVolume(double value) async {
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_volumeKey, value.clamp(0.0, 1.0));
  }

  // ---------------- لعبة أكل الماس 💎 (مستقلة لكل طفل) ----------------

  static const _diamondUnlockedKey = 'diamond_unlocked';
  static const _diamondBestPrefix = 'diamond_best_';

  /// أعلى مرحلة مفتوحة في لعبة أكل الماس (تبدأ بـ 1).
  static Future<int> diamondUnlocked() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('${await _prefix()}$_diamondUnlockedKey') ?? 1;
  }

  /// أعلى مرحلة ماس مفتوحة لطفل محدد.
  static Future<int> diamondUnlockedFor(String child) async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('${ChildProfile.keyPrefix(child)}$_diamondUnlockedKey') ??
        1;
  }

  /// يفتح المرحلة التالية بعد إكمال مرحلة (لا ينقص أبداً).
  static Future<void> unlockDiamondLevel(int level) async {
    final p = await SharedPreferences.getInstance();
    final key = '${await _prefix()}$_diamondUnlockedKey';
    final current = p.getInt(key) ?? 1;
    if (level > current) {
      await p.setInt(key, level);
      await logActivity('فتح مرحلة الماس $level');
    }
  }

  /// أفضل عدد ماسات أكلها الطفل في مرحلة ما.
  static Future<int> diamondBest(int level) async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('${await _prefix()}$_diamondBestPrefix$level') ?? 0;
  }

  /// يحفظ أفضل نتيجة في مرحلة ما (الأعلى فقط).
  static Future<void> saveDiamondBest(int level, int eaten) async {
    final p = await SharedPreferences.getInstance();
    final key = '${await _prefix()}$_diamondBestPrefix$level';
    final current = p.getInt(key) ?? 0;
    if (eaten > current) await p.setInt(key, eaten);
  }

  // ---------------- حفّار الماس ⛏️ (مستقل لكل طفل) ----------------

  static const _diggerUnlockedKey = 'digger_unlocked';

  /// أعلى مرحلة مفتوحة في حفّار الماس (تبدأ بـ 1).
  static Future<int> diggerUnlocked() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt('${await _prefix()}$_diggerUnlockedKey') ?? 1;
  }

  /// يفتح المرحلة التالية بعد إكمال مرحلة (لا ينقص أبداً).
  static Future<void> unlockDiggerLevel(int level) async {
    final p = await SharedPreferences.getInstance();
    final key = '${await _prefix()}$_diggerUnlockedKey';
    final current = p.getInt(key) ?? 1;
    if (level > current) {
      await p.setInt(key, level);
      await logActivity('فتح مرحلة حفّار الماس $level');
    }
  }

  // ---------------- إعادة ضبط التقدم (ركن الوالدين) ----------------

  /// يمسح تقدم الطفل الحالي فقط: النجوم والتعلّم والتقدم الديني والأوسمة،
  /// ويبقي الوضع الليلي ومستوى الصوت كما هما، وتقدم الأطفال الآخرين كما هو.
  static Future<void> resetAll() async {
    final p = await SharedPreferences.getInstance();
    final prefix = await _prefix();
    final keys = p.getKeys().toList();
    for (final k in keys) {
      if (k.startsWith(prefix)) await p.remove(k);
    }
  }
}
