// مدير صوت مركزي — صوت واحد فقط في كل مرة.
//
// القاعدة: كل دالة تشغيل توقف السابق (AudioPlayer + TTS) وتفرغ موارده
// قبل البدء. صوت الحيوان الحقيقي فقط: إن كان soundUrl فارغاً أو فشل
// التشغيل ترجع playAnimalSound قيمة false دون أي نطق آلي لكلمة الصوت
// (بديل TTS لكلمة الصوت أُلغي نهائياً).
//
// ملاحظة صريحة عن النطق: الأسماء والحروف والأرقام والأذكار والقصص
// والتشجيع تُنطق عبر جهاز TTS مضبوط التشكيل، وليست تسجيلاً بشرياً.
// التلاوة وحدها تسجيل بشري (مشاري العفاسي) عبر روابط صوتية.
import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../data/animals.dart';
import 'progress_store.dart';

class AppSound {
  static final AppSound instance = AppSound._();
  AppSound._();

  AudioPlayer? _player;
  FlutterTts? _tts;
  bool _ttsReady = false;
  bool _isPlaying = false;
  bool _disposed = false;
  double _volume = 1.0;
  bool _volumeLoaded = false;
  int _generation = 0;

  /// إنشاء كسول: لا تُبنى كائنات المنصة قبل أول استخدام فعلي،
  /// فيبقى الـ Singleton آمناً قبل تهيئة الربط (وفي الاختبارات).
  AudioPlayer get _audio => _player ??= AudioPlayer();
  FlutterTts get _voice => _tts ??= FlutterTts();

  /// هل يوجد تشغيل صوتي جارٍ الآن (مشغّل أو نطق).
  bool get isPlaying => _isPlaying;

  /// مستوى الصوت الحالي (0.0 - 1.0).
  double get volume => _volume;

  Future<void> _ensureTts() async {
    if (_ttsReady) return;
    try {
      await _voice.setLanguage('ar-EG');
      await _voice.setSpeechRate(0.45);
      await _voice.setPitch(1.1);
      await _voice.setVolume(_volume);
    } catch (_) {
      // جهاز بلا TTS: يبقى النطق صامتاً دون تعطيل الواجهة.
    }
    _ttsReady = true;
  }

  Future<void> _loadVolume() async {
    if (_volumeLoaded) return;
    _volumeLoaded = true;
    try {
      _volume = (await ProgressStore.volume()).clamp(0.0, 1.0);
    } catch (_) {
      _volume = 1.0;
    }
  }

  /// يضبط مستوى الصوت للمشغّل وللنطق معاً، ويحفظ التفضيل.
  Future<void> setVolume(double value) async {
    _volume = value.clamp(0.0, 1.0);
    try {
      await _audio.setVolume(_volume);
    } catch (_) {}
    try {
      await _ensureTts();
      await _voice.setVolume(_volume);
    } catch (_) {}
    try {
      await ProgressStore.setVolume(_volume);
    } catch (_) {}
  }

  /// يوقف كل صوت فوراً (مشغّل + نطق) ويلغي أي تشغيل متسلسل جارٍ.
  Future<void> stopAll() async {
    _generation++;
    _isPlaying = false;
    try {
      await _player?.stop();
    } catch (_) {}
    try {
      await _tts?.stop();
    } catch (_) {}
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts?.stop();
    } catch (_) {}
    // لا نمسّ _isPlaying هنا إن كان المشغّل يعمل؛ stopAll يوقف الكل.
  }

  Future<void> speak(String text) async {
    if (_disposed || text.trim().isEmpty) return;
    await stopAll();
    await _ensureTts();
    _isPlaying = true;
    try {
      await _voice.speak(text);
    } catch (_) {
      _isPlaying = false;
    }
  }

  /// نطق إنجليزي بطيء واضح، ثم العودة للعربية.
  Future<void> speakEnglish(String text) async {
    if (_disposed || text.trim().isEmpty) return;
    await stopAll();
    await _ensureTts();
    _isPlaying = true;
    try {
      await _voice.setLanguage('en-US');
      await _voice.setSpeechRate(0.4);
      await _voice.speak(text);
    } catch (_) {
      _isPlaying = false;
    } finally {
      try {
        await _voice.setLanguage('ar-EG');
        await _voice.setSpeechRate(0.45);
      } catch (_) {}
    }
  }

  /// نطق هادئ لقصص قبل النوم: أبطأ وأخفض.
  Future<void> speakCalm(String text) async {
    if (_disposed || text.trim().isEmpty) return;
    await stopAll();
    await _ensureTts();
    _isPlaying = true;
    try {
      await _voice.setSpeechRate(0.35);
      await _voice.setPitch(0.9);
      await _voice.speak(text);
    } catch (_) {
      _isPlaying = false;
    } finally {
      try {
        await _voice.setSpeechRate(0.45);
        await _voice.setPitch(1.1);
      } catch (_) {}
    }
  }

  Future<void> speakName(Animal a) async {
    await speak('هذا ${a.nameAr}. ${a.fact}');
  }

  /// يشغّل صوت الحيوان الحقيقي فقط إن وجد.
  /// يرجع false دون أي نطق آلي إن كان soundUrl فارغاً أو فشل التشغيل.
  Future<bool> playAnimalSound(Animal a) async {
    if (_disposed) return false;
    if (!a.hasRealSound) return false;
    await stopAll();
    await _loadVolume();
    final ok = await _playOnce(a.soundUrl);
    return ok;
  }

  /// يتحقق من الرابط أولاً (HEAD بمهلة قصيرة). false عند أي فشل.
  Future<bool> _urlOk(String url) async {
    if (url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.scheme != 'https') return false;
    HttpClient? client;
    try {
      client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
      final request = await client
          .headUrl(uri)
          .timeout(const Duration(seconds: 4));
      final response = await request.close().timeout(
        const Duration(seconds: 4),
      );
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (_) {
      return false;
    } finally {
      client?.close(force: true);
    }
  }

  /// يشغّل رابطاً واحداً حتى نهايته (أو حتى إيقافه)، ويرجع نجاح التشغيل.
  Future<bool> _playOnce(String url) async {
    if (_disposed) return false;
    final gen = _generation;
    _isPlaying = true;
    try {
      await _audio.setVolume(_volume);
      await _audio.play(UrlSource(url));
      try {
        await _audio.onPlayerComplete.first.timeout(
          const Duration(seconds: 90),
        );
      } on TimeoutException {
        // مقطع طويل أو بلا إشارة نهاية: نكمل دون تعليق الواجهة.
      }
      return gen == _generation;
    } catch (_) {
      return false;
    } finally {
      if (gen == _generation) _isPlaying = false;
    }
  }

  /// تشغيل متسلسل لرابط واحد مع التكرار، مع التحقق من الرابط أولاً.
  Future<void> playUrl(String url, {int repeat = 1}) async {
    if (_disposed || url.isEmpty) return;
    await stopAll();
    await _loadVolume();
    final count = repeat < 1 ? 1 : repeat;
    if (!await _urlOk(url)) return;
    final gen = _generation;
    for (var i = 0; i < count; i++) {
      if (gen != _generation || _disposed) break;
      await _playOnce(url);
    }
    _isPlaying = false;
  }

  /// تشغيل متواصل لقائمة روابط (تلاوة سورة كاملة مثلاً).
  Future<void> playAyahs(List<String> urls, {int repeat = 1}) async {
    if (_disposed || urls.isEmpty) return;
    await stopAll();
    await _loadVolume();
    final count = repeat < 1 ? 1 : repeat;
    final gen = _generation;
    for (var r = 0; r < count; r++) {
      for (final url in urls) {
        if (gen != _generation || _disposed) {
          _isPlaying = false;
          return;
        }
        if (url.isEmpty) continue;
        if (!await _urlOk(url)) continue;
        await _playOnce(url);
      }
    }
    _isPlaying = false;
  }

  static const List<String> praises = [
    'أحسنت يا بطل!',
    'رائع يا فارس!',
    'ممتاز! أنت ذكي!',
    'برافو عليك!',
    'أنت شاطر جداً!',
  ];

  Future<void> praise([int index = 0]) async {
    await speak(praises[index % praises.length]);
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await stopAll();
    try {
      await _player?.dispose();
    } catch (_) {}
    _player = null;
    _tts = null;
  }
}
