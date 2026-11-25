// تحفيظ القرآن — نُقلت من lib/main.dart دون تغيير (المرحلة الثانية 2.3).
import 'package:material_ui/material_ui.dart';

import '../data/quran.dart';
import '../services/app_sound.dart';
import '../services/child_profile.dart';
import '../services/progress_store.dart';
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

  @override
  void dispose() {
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
            onPressed: () => setState(() {
              _tasmee = !_tasmee;
              _current = 0;
            }),
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
                        child: Text(
                          s.ayahs[_current].text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 32, height: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'استمع جيداً، ثم كرر الآية بصوتك',
                      style: TextStyle(fontSize: 22),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _playAyah(s.ayahs[_current]),
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
                      onPressed: () async {
                        await _markAyah(_current);
                        if (!mounted) return;
                        if (_current < s.ayahs.length - 1) {
                          setState(() => _current++);
                        } else {
                          setState(() => _tasmee = false);
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
          ],
        ),
      ),
    );
  }
}

// ---------------- قصص قبل النوم ----------------

// ألوان الوضع الليلي الدافئ لقصص قبل النوم.

