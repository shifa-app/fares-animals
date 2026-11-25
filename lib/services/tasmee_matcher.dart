// التسميع بالميكروفون — مطابقة مرنة لنطق الطفل مع نص الآية.
// يُختبر بوحدة اختبار دون ميكروفون حقيقي.

/// يوحّد نص آية (بالرسم العثماني) مع ما نطقه الطفل للمقارنة:
/// إزالة التشكيل والعلامات الصغيرة والتنوين والتطويل والزخارف
/// والمسافات صفرية العرض، وتوحيد الألف والياء والتاء المربوطة.
/// يختلف عن normalizeArabic (لأسماء الحيوانات) في أنه لا يحذف "ال"
/// من بداية الكلمات — فهي جزء من كلمات الآية ومحاذاتها.
/// العلامات الصغيرة التي تنطق حرفاً تُحوَّل إليه: الألف الفوقية (ٰ)
/// ألفٌ إلا بعد ألف مقصورة أو ألف عادية (حيث تكون زائدة)،
/// والواو الصغيرة (ۥ) واوٌ، والياء الصغيرة (ۦ) ياءٌ،
/// والميم الصغيرة (ۢ) ميمٌ.
String normalizeAyahText(String input) {
  final buf = StringBuffer();
  // آخر حرف أُلحق (للتمييز بين ألف فوقية حرف وألف فوقية زائدة).
  String prev = '';
  for (final ch in input.trim().split('')) {
    if (ch == '\u0670') {
      // الألف الفوقية: زائدة بعد ى أو ا، وإلا فهي الألف نفسها.
      if (prev == 'ى' || prev == 'ا' || prev == 'أ' || prev == 'إ' || prev == 'آ' || prev == 'ٱ') {
        continue;
      }
      buf.write('ا');
      prev = 'ا';
      continue;
    }
    if (ch == '\u06E5') {
      buf.write('و');
      prev = 'و';
      continue;
    }
    if (ch == '\u06E6') {
      buf.write('ي');
      prev = 'ي';
      continue;
    }
    if (ch == '\u06E2') {
      buf.write('م');
      prev = 'م';
      continue;
    }
    if (RegExp(r'[\u064B-\u0652\u06D6-\u06ED\u08F0-\u08F2\u0640\u200A\u2060]').hasMatch(ch)) {
      continue;
    }
    buf.write(ch);
    prev = ch;
  }
  var s = buf.toString();
  s = s.replaceAll(RegExp(r'[أإآٱ]'), 'ا');
  s = s.replaceAll('ة', 'ه');
  s = s.replaceAll(RegExp(r'[ىی]'), 'ي');
  s = s.replaceAll('ؤ', 'و');
  s = s.replaceAll('ئ', 'ي');
  // أي رمز متبقٍ غير عربي يصير فاصلاً (علامات ترقيم وأرقام الآيات).
  s = s.replaceAll(RegExp(r'[^\u0621-\u064A ]'), ' ');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return s;
}

/// كلمات الآية كما تُعرض: الكلمة الأصلية مع نسختها الموحّدة.
/// تُستبعد الكلمات التي تختفي بعد التطبيع (مثل ۞) حتى تتطابق
/// الفهارس بين العرض والمطابقة.
List<({String original, String normalized})> ayahWords(String ayahText) {
  final out = <({String original, String normalized})>[];
  for (final w in ayahText.split(' ')) {
    final n = normalizeAyahText(w);
    if (n.isNotEmpty) out.add((original: w, normalized: n));
  }
  return out;
}

/// مسافة ليвенشتاين بين كلمتين (للتسامح مع نطق عمر 5 سنوات).
int _levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  var prev = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final cur = <int>[i];
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      var best = prev[j] + 1;
      if (cur[j - 1] + 1 < best) best = cur[j - 1] + 1;
      if (prev[j - 1] + cost < best) best = prev[j - 1] + cost;
      cur.add(best);
    }
    prev = cur;
  }
  return prev[b.length];
}

/// كلمتان متطابقتان: تساوٍ بعد التطبيع، أو فرق حرف واحد
/// في كلمة من 4 أحرف فأكثر (تسامح مع نطق الطفل).
bool _wordsMatch(String expected, String spoken) {
  if (expected == spoken) return true;
  if (expected.length >= 4 &&
      spoken.length >= 4 &&
      _levenshtein(expected, spoken) <= 1) {
    return true;
  }
  return false;
}

/// نتيجة مطابقة تسميع آية كاملة.
class TasmeeResult {
  /// نسبة الكلمات المطابقة (0..1).
  final double score;

  /// فهرس أول كلمة لم تُطابق (-1 إن طابقت كل الكلمات).
  final int firstMismatchIndex;

  /// ناجح: 80% فأكثر من الكلمات.
  final bool isGood;

  /// مطابقة كل كلمة بالترتيب.
  final List<bool> wordMatches;

  const TasmeeResult({
    required this.score,
    required this.firstMismatchIndex,
    required this.isGood,
    required this.wordMatches,
  });
}

/// يقارن ما نطقه الطفل بنص الآية بالترتيب، متسامحاً مع كلمة
/// زائدة أو منسية (بحث أمامي حتى كلمتين).
TasmeeResult matchRecitation(String recognized, String ayahText) {
  final expected = ayahWords(ayahText).map((w) => w.normalized).toList();
  final spoken = normalizeAyahText(recognized)
      .split(' ')
      .where((w) => w.isNotEmpty)
      .toList();
  if (expected.isEmpty) {
    return const TasmeeResult(
      score: 0,
      firstMismatchIndex: -1,
      isGood: false,
      wordMatches: [],
    );
  }
  if (spoken.isEmpty) {
    return TasmeeResult(
      score: 0,
      firstMismatchIndex: 0,
      isGood: false,
      wordMatches: List<bool>.filled(expected.length, false),
    );
  }
  final matches = List<bool>.filled(expected.length, false);
  var j = 0;
  for (var i = 0; i < expected.length; i++) {
    for (var k = j; k < spoken.length && k < j + 3; k++) {
      if (_wordsMatch(expected[i], spoken[k])) {
        matches[i] = true;
        j = k + 1;
        break;
      }
    }
  }
  final hit = matches.where((m) => m).length;
  final firstBad = matches.indexWhere((m) => !m);
  final score = hit / expected.length;
  return TasmeeResult(
    score: score,
    firstMismatchIndex: firstBad,
    isGood: score >= 0.8,
    wordMatches: matches,
  );
}

/// رسالة لطيفة لطفل حسب سبب خطأ التعرف على الصوت.
/// رموز الأخطاء كما يرسلها أندرويد عبر حزمة speech_to_text:
/// ‏error_permission (الإذن مرفوض)، error_network / error_network_timeout
/// (التعرف يحتاج إنترنت)، وأي رمز آخر (لم يُسمع كلام واضح).
String tasmeeErrorMessage(String errorMsg) {
  if (errorMsg == 'error_permission') {
    return 'إذن الميكروفون مرفوض — فعّله من إعدادات التطبيق، أو استخدم زر «كررتها!»';
  }
  if (errorMsg == 'error_network' || errorMsg == 'error_network_timeout') {
    return 'التعرف على الصوت يحتاج إنترنت — زر «كررتها!» يعمل دون إنترنت.';
  }
  return 'لم أسمعك بوضوح — جرّب ثانية يا بطل!';
}
