// حفظ التقدم محلياً: النجوم والحيوانات المتعلمة وأقسام الدين المنجزة.
import 'package:shared_preferences/shared_preferences.dart';

class ProgressStore {
  static const _starsKey = 'stars_total';
  static const _learnedPrefix = 'learned_';
  static const _religionPrefix = 'religion_';
  static const _badgesKey = 'badges_unlocked';
  static const _nightModeKey = 'night_mode';
  static const _volumeKey = 'sound_volume';

  static Future<int> stars() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_starsKey) ?? 0;
  }

  static Future<int> addStars(int n) async {
    final p = await SharedPreferences.getInstance();
    final v = (p.getInt(_starsKey) ?? 0) + n;
    await p.setInt(_starsKey, v);
    return v;
  }

  static Future<bool> isLearned(String nameAr) async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('$_learnedPrefix$nameAr') ?? false;
  }

  static Future<void> markLearned(String nameAr) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('$_learnedPrefix$nameAr', true);
  }

  static Future<int> learnedCount(List<String> names) async {
    final p = await SharedPreferences.getInstance();
    var c = 0;
    for (final n in names) {
      if (p.getBool('$_learnedPrefix$n') ?? false) c++;
    }
    return c;
  }

  static Future<void> markReligion(String key) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('$_religionPrefix$key', true);
  }

  static Future<bool> isReligion(String key) async {
    final p = await SharedPreferences.getInstance();
    return p.getBool('$_religionPrefix$key') ?? false;
  }

  static Future<int> religionCount(List<String> keys) async {
    final p = await SharedPreferences.getInstance();
    var c = 0;
    for (final k in keys) {
      if (p.getBool('$_religionPrefix$k') ?? false) c++;
    }
    return c;
  }

  // ---------------- الأوسمة ----------------

  /// معرّفات الأوسمة المفتوحة (مثلاً first_animal, ten_animals,
  /// first_surah, story_reader).
  static Future<Set<String>> badges() async {
    final p = await SharedPreferences.getInstance();
    return (p.getStringList(_badgesKey) ?? <String>[]).toSet();
  }

  static Future<void> unlockBadge(String id) async {
    final p = await SharedPreferences.getInstance();
    final current = (p.getStringList(_badgesKey) ?? <String>[]).toSet()
      ..add(id);
    await p.setStringList(_badgesKey, current.toList());
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

  // ---------------- إعادة ضبط التقدم (ركن الوالدين) ----------------

  /// يمسح النجوم والتعلّم والتقدم الديني والأوسمة، ويبقي الوضع
  /// الليلي ومستوى الصوت كما هما.
  static Future<void> resetAll() async {
    final p = await SharedPreferences.getInstance();
    final keys = p.getKeys().toList();
    for (final k in keys) {
      if (k == _starsKey ||
          k == _badgesKey ||
          k.startsWith(_learnedPrefix) ||
          k.startsWith(_religionPrefix)) {
        await p.remove(k);
      }
    }
  }
}
