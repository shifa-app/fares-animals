// وقت الاستخدام الاختياري — المرحلة الثانية 2.7.
// تتبع اختياري يضبطه الوالدان: حد يومي بالدقائق (أو بلا حد)،
// وتسجيل الدقائق المستخدمة فعلاً لكل طفل في كل يوم.
// عند بلوغ الحد يظهر للطفل تذكير ودود بالراحة مرة واحدة في اليوم
// (تذكير لا قفل: التطبيق لا يُغلق في وجه الطفل).
// يُستدعى noteForeground/noteBackground من مراقب دورة حياة التطبيق.
import 'package:shared_preferences/shared_preferences.dart';

import 'child_profile.dart';

class ScreenTime {
  static const List<int> allowedLimits = [0, 15, 30, 60];

  static String _limitKey(String child) =>
      '${ChildProfile.keyPrefix(child)}screen_limit';

  static String _usageKey(String child, DateTime date) =>
      '${ChildProfile.keyPrefix(child)}usage_${_dateKey(date)}';

  static String _restKey(String child, DateTime date) =>
      '${ChildProfile.keyPrefix(child)}rest_${_dateKey(date)}';

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// الحد اليومي بالدقائق (0 = بلا حد).
  static Future<int> limitMinutes(String child) async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_limitKey(child)) ?? 0;
  }

  static Future<void> setLimitMinutes(String child, int minutes) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(
      _limitKey(child),
      allowedLimits.contains(minutes) ? minutes : 0,
    );
  }

  /// دقائق اليوم المستخدمة فعلاً.
  static Future<int> minutesToday(String child, {DateTime? date}) async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_usageKey(child, date ?? DateTime.now())) ?? 0;
  }

  /// الدقائق المتبقية اليوم (null = بلا حد).
  static Future<int?> remainingMinutes(String child) async {
    final limit = await limitMinutes(child);
    if (limit <= 0) return null;
    final used = await minutesToday(child);
    final left = limit - used;
    return left < 0 ? 0 : left;
  }

  static Future<bool> limitReached(String child) async {
    final left = await remainingMinutes(child);
    return left != null && left <= 0;
  }

  /// يسجل [minutes] دقيقة استخدام في يوم [date] (للتتبع والاختبار).
  static Future<void> recordMinutes(
    String child,
    int minutes, {
    DateTime? date,
  }) async {
    if (minutes <= 0) return;
    final p = await SharedPreferences.getInstance();
    final key = _usageKey(child, date ?? DateTime.now());
    await p.setInt(key, (p.getInt(key) ?? 0) + minutes);
  }

  /// هل ظهر تذكير الراحة اليوم لهذا الطفل؟
  static Future<bool> restRemindedToday(String child) async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_restKey(child, DateTime.now())) ?? false;
  }

  static Future<void> markRestReminded(String child) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_restKey(child, DateTime.now()), true);
  }

  // ---------------- تتبع الجلسات ----------------

  static DateTime? _sessionStart;
  static String? _sessionChild;

  /// تُستدعى عند عودة التطبيق للمقدمة.
  static Future<void> noteForeground() async {
    _sessionStart = DateTime.now();
    _sessionChild = await ChildProfile.currentChild();
  }

  /// تُستدعى عند انتقال التطبيق للخلفية: تُضاف دقائق الجلسة
  /// إلى استخدام الطفل الذي بدأت الجلسة باسمه.
  static Future<void> noteBackground() async {
    final start = _sessionStart;
    final child = _sessionChild;
    _sessionStart = null;
    _sessionChild = null;
    if (start == null || child == null) return;
    final minutes = DateTime.now().difference(start).inMinutes;
    if (minutes > 0) await recordMinutes(child, minutes);
  }
}
