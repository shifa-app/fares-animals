// تحفيظ القرآن — نُقلت من lib/main.dart دون تغيير (المرحلة الثانية 2.3).
import 'package:material_ui/material_ui.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../data/quran.dart';
import '../services/app_sound.dart';
import '../services/child_profile.dart';
import '../services/progress_store.dart';
import '../services/tasmee_matcher.dart';
import '../widgets/app_footer.dart';

// ---------------- تحفيظ القرآن ----------------

class MemorizationListScreen extends StatefulWidget {
  const MemorizationListScreen({super.key});
  @override
  State<MemorizationListScreen> createState() => _MemorizationListScreenState();
}

class _MemorizationListScreenState extends State<MemorizationListScreen> {
  final Set<int> _done = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final done = <int>{};
    for (final s in memorizeSurahs) {
      if (await ProgressStore.isReligion('memorize_${s.number}')) {
        done.add(s.number);
      }
    }
    if (mounted) setState(() => _done.addAll(done));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      appBar: AppBar(
        title: const Text(
          'تحفيظ القرآن',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: memorizeSurahs.length,
        itemBuilder: (context, i) {
          final s = memorizeSurahs[i];
          final done = _done.contains(s.number);
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Icon(
                done ? Icons.star : Icons.menu_book,
                size: 36,
                color: done ? Colors.amber : Colors.green,
              ),
              title: Text(
                'سورة ${s.name}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${s.ayahs.length} آيات — ${s.meaning}',
                style: const TextStyle(fontSize: 18),
              ),
              trailing: const Icon(
                Icons.play_arrow,
                size: 36,
                color: Colors.green,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MemorizationDetailScreen(surah: s),
                ),
              ).then((_) => _load()),
            ),
          );
        },
      ),
    );
  }
}

class MemorizationDetailScreen extends StatefulWidget {
  final MemorizeSurah surah;
  const MemorizationDetailScreen({super.key, required this.surah});
  @override
  State<MemorizationDetailScreen> createState() =>
      _MemorizationDetailScreenState();
}

class _MemorizationDetailScreenState extends State<MemorizationDetailScreen> {
  bool _tasmee = false;
  int _current = 0;
  int _repeat = 1;
  bool _playingAll = false;
  final Set<int> _learned = {};
  final Set<int> _starred = {};

  // التسميع بالميكروفون: نفس حزمة شاشة الحيوانات وإذنها، بلا جديد.
  final SpeechToText _speech = SpeechToText();
  bool _listening = false;
  // هل وصلت نتيجة نهائية في جلسة الاستماع الحالية؟
  bool _tasmeeHandled = false;
  String? _tasmeeMessage;
  int _mismatchIndex = -1;

  Future<void> _playAyah(MemorizeAyah a, {int repeat = 1}) async {
    await AppSound.instance.playUrl(a.audioUrl, repeat: repeat);
  }

  Future<void> _playWholeSurah() async {
    setState(() => _playingAll = true);
    await AppSound.instance.playAyahs(
      widget.surah.ayahs.map((a) => a.audioUrl).toList(),
    );
    if (mounted) setState(() => _playingAll = false);
  }

  Future<void> _markAyah(int index) async {
    if (_learned.contains(index)) return;
    setState(() => _learned.add(index));
    if (!_starred.contains(index)) {
      _starred.add(index);
      await ProgressStore.awardStarsOnce(
        'surah_${widget.surah.number}_ayah_$index',
        1,
      );
    }
    if (_learned.length == widget.surah.ayahs.length) {
      await ProgressStore.markReligion('memorize_${widget.surah.number}');
      final childName = await ChildProfile.currentChild();
      await AppSound.instance.speak(
        'أحسنت يا $childName! حفظت سورة ${widget.surah.name}!',
      );
    }
  }

  /// تسميع صحيح: نجمة الآية + تشجيع باسم الطفل + الانتقال للتالية.
  Future<void> _onTasmeeGood() async {
    final last = _current == widget.surah.ayahs.length - 1;
    if (!last) {
      final childName = await ChildProfile.currentChild();
      await AppSound.instance.speak('أحسنت يا $childName!');
    }
    await _markAyah(_current);
    if (!mounted) return;
    setState(() {
      _mismatchIndex = -1;
      _tasmeeMessage = null;
      if (!last) {
        _current++;
      } else {
        _tasmee = false;
      }
    });
  }

  /// تسميع ناقص: إبراز أول كلمة لم تُطابق بلون لطيف، ثم تشجيع
  /// باسم الطفل وإعادة تلاوة الآية تلقائياً، والبقاء على نفس الآية.
  Future<void> _onTasmeeRetry(TasmeeResult result) async {
    final childName = await ChildProfile.currentChild();
    if (!mounted) return;
    setState(() {
      _mismatchIndex = result.firstMismatchIndex;
      _tasmeeMessage = 'قربت يا $childName! لنسمعها معاً ثم جرّب ثانية';
    });
    await AppSound.instance.speak(
      'قربت يا $childName! لنسمعها معاً ثم جرّب ثانية',
    );
    if (!mounted) return;
    await _playAyah(widget.surah.ayahs[_current]);
  }

  /// زر الميكروفون: يوقف أي تلاوة أولاً، ثم يسمع الطفل ويطابق
  /// نطقه بالآية الحالية مطابقة مرنة تتجاهل التشكيل.
  /// لا يعلق أبداً: أي خطأ تعرّف أو توقف بلا نتيجة نهائية
  /// يعيد الزر لحالته مع رسالة لطيفة توضح السبب.
  Future<void> _listenTasmee() async {
    await AppSound.instance.stopAll();
    final available = await _speech.initialize(
      onError: _onSpeechError,
      onStatus: _onSpeechStatus,
    );
    if (!available) {
      if (!mounted) return;
      setState(
        () => _tasmeeMessage =
            'الميكروفون غير متاح — فعّل إذن الميكروفون من إعدادات التطبيق، أو استخدم زر «كررتها!» الذي يعمل دون إنترنت.',
      );
      return;
    }
    if (!mounted) return;
    setState(() {
      _listening = true;
      _tasmeeHandled = false;
      _mismatchIndex = -1;
      _tasmeeMessage = 'أنا أسمعك... اقرأ الآية بصوتك!';
    });
    await _speech.listen(
      listenOptions: SpeechListenOptions(
        localeId: 'ar_EG',
        listenFor: Duration(seconds: 20),
      ),
      onResult: (result) async {
        if (!result.finalResult || !mounted) return;
        _tasmeeHandled = true;
        setState(() => _listening = false);
        final match = matchRecitation(
          result.recognizedWords,
          widget.surah.ayahs[_current].text,
        );
        if (match.isGood) {
          await _onTasmeeGood();
        } else {
          await _onTasmeeRetry(match);
        }
      },
    );
    // انتهى الاستماع بلا نتيجة نهائية ولا خطأ: أعد الزر لحالته
    // حتى لا يبقى معطلاً على «أنا أسمعك...».
    if (mounted && _listening && !_tasmeeHandled) {
      setState(() {
        _listening = false;
        _tasmeeMessage = 'لم أسمع شيئاً — اضغط الزر وجرّب ثانية';
      });
    }
  }

  /// خطأ تعرّف أثناء التسميع: أوقف حالة الاستماع وأخبر
  /// الطفل بلطف حسب السبب، ولا تترك الزر معلقاً.
  void _onSpeechError(SpeechRecognitionError error) {
    if (!mounted || !_listening) return;
    setState(() {
      _listening = false;
      _tasmeeMessage = tasmeeErrorMessage(error.errorMsg);
    });
  }

  /// حالة الاستماع: إن توقف دون نتيجة نهائية، أعد الزر لحالته.
  void _onSpeechStatus(String status) {
    if (!mounted || !_listening || _tasmeeHandled) return;
    if (status == 'notListening') {
      setState(() {
        _listening = false;
        _tasmeeMessage = 'لم أسمع شيئاً — اضغط الزر وجرّب ثانية';
      });
    }
  }

  /// نص الآية في وضع التسميع مع إبراز الكلمة المخطئة بلون لطيف.
  Widget _tasmeeAyahText() {
    final words = ayahWords(widget.surah.ayahs[_current].text);
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(fontSize: 32, height: 2.0, color: Colors.black),
        children: [
          for (var i = 0; i < words.length; i++)
            TextSpan(
              text: '${words[i].original} ',
              style: _mismatchIndex == i
                  ? TextStyle(backgroundColor: Colors.amber.shade200)
                  : null,
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    AppSound.instance.stopAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.surah;
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      appBar: AppBar(
        title: Text(
          'سورة ${s.name}',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              _speech.stop();
              setState(() {
                _tasmee = !_tasmee;
                _current = 0;
                _listening = false;
                _mismatchIndex = -1;
                _tasmeeMessage = null;
              });
            },
            child: Text(
              _tasmee ? 'كل الآيات' : 'وضع التسميع',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              s.meaning,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // البسملة في ترويسة مستقلة أعلى السورة؛ إلا الفاتحة حيث
            // البسملة آية 1 فلا تُكرر.
            if (!s.basmalaIsAyah)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  child: Text(
                    s.basmala,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 26, height: 1.8),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _playingAll ? null : _playWholeSurah,
              icon: Icon(
                _playingAll ? Icons.hourglass_top : Icons.play_arrow,
                size: 32,
              ),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _playingAll ? 'تُتلى السورة الآن...' : 'استمع للسورة كاملة',
                  softWrap: false,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'تكرار الآية:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                for (final r in [1, 3, 5])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        '${r}x',
                        style: const TextStyle(fontSize: 18),
                      ),
                      selected: _repeat == r,
                      selectedColor: Colors.blue.shade200,
                      onSelected: (_) => setState(() => _repeat = r),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (!_tasmee)
              Expanded(
                child: ListView.builder(
                  itemCount: s.ayahs.length,
                  itemBuilder: (context, i) {
                    final a = s.ayahs[i];
                    final done = _learned.contains(i);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: done ? Colors.green.shade50 : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.green,
                                  radius: 18,
                                  child: Text(
                                    '${a.numberInSurah}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'الآية ${a.numberInSurah}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                if (done)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 28,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              a.text,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 26, height: 1.9),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _playAyah(a),
                                    icon: const Icon(
                                      Icons.play_arrow,
                                      size: 24,
                                    ),
                                    label: const FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'استمع',
                                        softWrap: false,
                                        style: TextStyle(fontSize: 19),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _playAyah(a, repeat: _repeat),
                                    icon: const Icon(Icons.repeat, size: 24),
                                    label: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'كرر ${_repeat}x',
                                        softWrap: false,
                                        style: const TextStyle(fontSize: 19),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _markAyah(i),
                                    icon: Icon(
                                      done ? Icons.star : Icons.star_border,
                                      size: 24,
                                    ),
                                    label: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        done ? 'حفظتها' : 'حفظتها؟',
                                        softWrap: false,
                                        style: const TextStyle(fontSize: 19),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    Text(
                      'الآية ${_current + 1} من ${s.ayahs.length}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: _tasmeeAyahText(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'استمع جيداً، ثم كرر الآية بصوتك',
                      style: TextStyle(fontSize: 22),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _listening
                          ? null
                          : () => _playAyah(s.ayahs[_current]),
                      icon: const Icon(Icons.play_arrow, size: 36),
                      label: const Text(
                        'استمع للآية',
                        style: TextStyle(fontSize: 26),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _listening ? null : _listenTasmee,
                      icon: Icon(
                        _listening ? Icons.mic : Icons.mic_none,
                        size: 36,
                      ),
                      label: Text(
                        _listening ? 'أنا أسمعك...' : 'سمّع بصوتك 🎤',
                        style: const TextStyle(fontSize: 26),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _listening ? Colors.red : Colors.deepOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 28,
                        ),
                      ),
                    ),
                    if (_tasmeeMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _tasmeeMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        _speech.stop();
                        await _markAyah(_current);
                        if (!mounted) return;
                        if (_current < s.ayahs.length - 1) {
                          setState(() {
                            _current++;
                            _mismatchIndex = -1;
                            _tasmeeMessage = null;
                          });
                        } else {
                          setState(() {
                            _tasmee = false;
                            _mismatchIndex = -1;
                            _tasmeeMessage = null;
                          });
                        }
                      },
                      icon: const Icon(Icons.check, size: 36),
                      label: const Text(
                        'كررتها! التالية',
                        style: TextStyle(fontSize: 26),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------- قصص قبل النوم ----------------

// ألوان الوضع الليلي الدافئ لقصص قبل النوم.

