// حفظ التقدم محلياً: النجوم والحيوانات المتعلمة وأقسام الدين المنجزة.
// التقدم مستقل لكل طفل: كل مفتاح مسبوق ببادئة الطفل الحالي.
import 'package:shared_preferences/shared_preferences.dart';

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

  static Future<bool> isLearned(String nameAr) async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('${await _prefix()}$_learnedPrefix$nameAr') ?? false;
  }

  static Future<void> markLearned(String nameAr) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('${await _prefix()}$_learnedPrefix$nameAr', true);
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

  /// يفتح المرحلة التالية بعد إكمال مرحلة (لا ينقص أبداً).
  static Future<void> unlockDiamondLevel(int level) async {
    final p = await SharedPreferences.getInstance();
    final key = '${await _prefix()}$_diamondUnlockedKey';
    final current = p.getInt(key) ?? 1;
    if (level > current) await p.setInt(key, level);
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
