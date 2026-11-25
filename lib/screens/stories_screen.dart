// قصص قبل النوم — قائمة القصص + تفاصيل القصة.
// القصص القصيرة: نص واحد. القصص الطويلة (5 دقائق): مشاهد متتالية
// مع شريط تحكم صوتي وبطاقة «ماذا تعلمنا اليوم؟» في المشهد الأخير.
// الوضع الليلي الدافئ (كحلي) + شريط أزرار مثبت داخل SafeArea.
import 'package:material_ui/material_ui.dart';

import '../data/stories.dart';
import '../services/app_sound.dart';
import '../services/child_profile.dart';
import '../services/progress_store.dart';
import '../widgets/app_footer.dart';

// الوضع الليلي الدافئ (Cozy Night Mode): كحلي هادئ مع نص كهرماني دافئ.
const Color _nightBg = Color(0xFF0E1B2E);
const Color _nightBar = Color(0xFF1B2F4A);
const Color _nightCard = Color(0xFF1E3A5C);

/// أيقونة كل مشهد من مفتاحه النصي في البيانات.
const Map<String, IconData> _sceneIcons = {
  'moon': Icons.nightlight,
  'star': Icons.star,
  'bug': Icons.bug_report,
  'garden': Icons.park,
  'heart': Icons.favorite,
  'sun': Icons.wb_sunny,
  'bed': Icons.bedtime,
  'bee': Icons.emoji_nature,
  'ball': Icons.sports_soccer,
  'bear': Icons.pets,
  'chat': Icons.chat_bubble,
  'hands': Icons.handshake,
  'flower': Icons.local_florist,
  'water': Icons.water_drop,
  'gift': Icons.card_giftcard,
  'bird': Icons.flutter_dash,
  'food': Icons.restaurant,
  'tree': Icons.park,
  'music': Icons.music_note,
  'key': Icons.key,
  'turtle': Icons.pets,
  'think': Icons.psychology,
  'give': Icons.volunteer_activism,
  'chest': Icons.inventory_2,
  'owl': Icons.nights_stay,
  'family': Icons.family_restroom,
};

class BedtimeStoriesScreen extends StatefulWidget {
  const BedtimeStoriesScreen({super.key});
  @override
  State<BedtimeStoriesScreen> createState() => _BedtimeStoriesScreenState();
}

class _BedtimeStoriesScreenState extends State<BedtimeStoriesScreen> {
  bool _night = false;
  String _child = 'فارس';
  final Set<String> _done = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final night = await ProgressStore.nightMode();
    final child = await ChildProfile.currentChild();
    final done = <String>{};
    for (final st in bedtimeStories) {
      if (await ProgressStore.isReligion('story_bed_${st.title}')) {
        done.add(st.title);
      }
    }
    if (mounted) {
      setState(() {
        _night = night;
        _child = child;
        _done.addAll(done);
      });
    }
  }

  Future<void> _toggleNight() async {
    final next = !_night;
    await ProgressStore.setNightMode(next);
    if (mounted) setState(() => _night = next);
  }

  @override
  Widget build(BuildContext context) {
    final night = _night;
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: night ? _nightBg : Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text(
          'قصص قبل النوم',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: night ? _nightBar : Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(night ? Icons.wb_sunny : Icons.bedtime, size: 30),
            tooltip: 'وضع ليلي',
            onPressed: _toggleNight,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bedtimeStories.length,
        itemBuilder: (context, i) {
          final st = bedtimeStories[i];
          final done = _done.contains(st.title);
          final title = st.titleFor(_child);
          return Card(
            color: night ? _nightCard : Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                Icons.auto_stories,
                size: 40,
                color: night ? Colors.amber.shade200 : Colors.indigo,
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: night ? Colors.amber.shade100 : Colors.black,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    st.isProphet ? 'قصة نبي — ${st.moral}' : st.moral,
                    style: TextStyle(
                      fontSize: 18,
                      color:
                          night ? Colors.amber.shade200 : Colors.grey.shade700,
                    ),
                  ),
                  if (st.isFiveMinute)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Wrap(
                        spacing: 6,
                        children: [
                          Chip(
                            label: const Text('قصة 5 دقائق'),
                            labelStyle: TextStyle(
                              fontSize: 16,
                              color: night
                                  ? Colors.amber.shade100
                                  : Colors.indigo.shade900,
                            ),
                            backgroundColor: night
                                ? _nightBar
                                : Colors.indigo.shade100,
                            visualDensity: VisualDensity.compact,
                          ),
                          Chip(
                            label: Text('بطلها $_child'),
                            labelStyle: TextStyle(
                              fontSize: 16,
                              color: night
                                  ? Colors.amber.shade100
                                  : Colors.brown.shade800,
                            ),
                            backgroundColor: night
                                ? _nightBar
                                : Colors.amber.shade100,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (done)
                    const Icon(
                      Icons.check_circle,
                      size: 30,
                      color: Colors.green,
                    ),
                  Icon(
                    Icons.play_arrow,
                    size: 36,
                    color: night ? Colors.amber.shade200 : Colors.indigo,
                  ),
                ],
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BedtimeStoryDetailScreen(story: st),
                ),
              ).then((_) => _load()),
            ),
          );
        },
      ),
    );
  }
}

class BedtimeStoryDetailScreen extends StatefulWidget {
  final BedtimeStory story;
  const BedtimeStoryDetailScreen({super.key, required this.story});
  @override
  State<BedtimeStoryDetailScreen> createState() =>
      _BedtimeStoryDetailScreenState();
}

class _BedtimeStoryDetailScreenState extends State<BedtimeStoryDetailScreen> {
  bool _playing = false;
  bool _calm = true;
  bool _listened = false;
  bool _night = false;
  String _child = 'فارس';
  int _sceneIndex = 0;

  String get _displayTitle => widget.story.titleFor(_child);

  /// كلمات المشاهد المتبقية من المشهد الحالي (لتقدير الوقت المتبقي).
  int get _remainingWords {
    final st = widget.story;
    if (!st.isFiveMinute) return 0;
    var n = 0;
    for (var i = _sceneIndex; i < st.scenes.length; i++) {
      n += st
          .sceneTextFor(i, _child)
          .split(RegExp(r'\s+'))
          .where((w) => w.trim().isNotEmpty)
          .length;
    }
    return n;
  }

  /// الوقت المتبقي تقديراً (~110 كلمة/دقيقة بالإيقاع الهادئ).
  String get _remainingLabel {
    final minutes = (_remainingWords / 110).ceil();
    if (minutes <= 0) return 'المتبقي تقديراً: أقل من دقيقة';
    if (minutes == 1) return 'المتبقي تقديراً: دقيقة واحدة';
    if (minutes == 2) return 'المتبقي تقديراً: دقيقتان';
    return 'المتبقي تقديراً: $minutes دقائق';
  }

  Future<void> _playStory() async {
    if (_playing) {
      await _stop();
      return;
    }
    setState(() => _playing = true);
    final st = widget.story;
    if (st.isFiveMinute) {
      // مشهداً مشهداً بالإيقاع الهادئ، مع انتقال تلقائي للمشهد التالي.
      for (var i = _sceneIndex; i < st.scenes.length; i++) {
        if (!mounted || !_playing) break;
        if (mounted) setState(() => _sceneIndex = i);
        await AppSound.instance.speakCalm(st.sceneTextFor(i, _child));
      }
    } else {
      final text = '$_displayTitle. ${st.body} ${st.moral}';
      if (_calm) {
        await AppSound.instance.speakCalm(text);
      } else {
        await AppSound.instance.speak(text);
      }
    }
    if (mounted) setState(() => _playing = false);
  }

  Future<void> _stop() async {
    await AppSound.instance.stopSpeaking();
    if (mounted) setState(() => _playing = false);
  }

  /// الانتقال لمشهد آخر يوقف النطق الحالي أولاً.
  Future<void> _goToScene(int index) async {
    if (_playing) await AppSound.instance.stopSpeaking();
    if (mounted) {
      setState(() {
        _sceneIndex = index;
        _playing = false;
      });
    }
  }

  Future<void> _markListened() async {
    if (_listened) return;
    await ProgressStore.markReligion('story_bed_${widget.story.title}');
    await ProgressStore.awardStarsOnce('story_bed_${widget.story.title}', 1);
    if (mounted) setState(() => _listened = true);
    await AppSound.instance.praise();
  }

  @override
  void initState() {
    super.initState();
    ChildProfile.currentChild()
        .then((v) => mounted ? setState(() => _child = v) : null);
    ProgressStore.isReligion('story_bed_${widget.story.title}')
        .then((v) => mounted ? setState(() => _listened = v) : null);
    ProgressStore.nightMode().then(
      (v) => mounted ? setState(() => _night = v) : null,
    );
  }

  @override
  void dispose() {
    AppSound.instance.stopAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = widget.story;
    final night = _night;
    final isLong = st.isFiveMinute;
    final bodyColor = night ? Colors.amber.shade100 : Colors.black;
    final moralColor = night ? Colors.amber.shade200 : Colors.indigo;
    return Scaffold(
      backgroundColor: night ? _nightBg : Colors.indigo.shade50,
      appBar: AppBar(
        title: Text(
          _displayTitle,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: night ? _nightBar : Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(night ? Icons.wb_sunny : Icons.bedtime, size: 28),
            tooltip: 'وضع ليلي',
            onPressed: () async {
              final next = !night;
              await ProgressStore.setNightMode(next);
              if (mounted) setState(() => _night = next);
            },
          ),
        ],
      ),
      // شريط الأزرار مثبت أسفل الشاشة داخل SafeArea (لا يُقصّ أبداً).
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: night ? _nightBar : Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _playStory,
                      icon: Icon(
                        _playing ? Icons.pause : Icons.play_arrow,
                        size: 32,
                      ),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _playing ? 'إيقاف مؤقت' : 'اسمع الحدوتة',
                          softWrap: false,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: night ? _nightBar : Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _markListened,
                      icon: Icon(
                        _listened ? Icons.star : Icons.star_border,
                        size: 32,
                      ),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'سمعتها',
                          softWrap: false,
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const AppFooter.small(),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // زخرفة ليلية: هلال ونجوم خفيفة في الوضع الليلي.
              if (night)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, size: 18, color: Colors.amber.shade200),
                    const SizedBox(width: 14),
                    Icon(
                      Icons.nightlight,
                      size: 44,
                      color: Colors.amber.shade200,
                    ),
                    const SizedBox(width: 14),
                    Icon(Icons.star, size: 18, color: Colors.amber.shade200),
                  ],
                ),
              if (night) const SizedBox(height: 8),
              if (isLong) _buildScenePlayer(st, night, bodyColor) else ...[
                Icon(
                  Icons.auto_stories,
                  size: 80,
                  color: night ? Colors.amber.shade200 : Colors.indigo,
                ),
                const SizedBox(height: 8),
                Text(
                  st.body,
                  style:
                      TextStyle(fontSize: 24, height: 1.9, color: bodyColor),
                ),
                const SizedBox(height: 16),
                Text(
                  st.moral,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: moralColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.bedtime,
                      size: 28,
                      color: night ? Colors.amber.shade200 : Colors.indigo,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'صوت هادئ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: bodyColor,
                      ),
                    ),
                    Switch(
                      value: _calm,
                      onChanged: (v) => setState(() => _calm = v),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              // القصة تُروى بصوت آلي هادئ (TTS) وليست تسجيلاً بشرياً.
              Text(
                'القصة تُروى بصوت آلي هادئ وليست تسجيلاً بشرياً',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: night ? Colors.amber.shade200 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// مشغل المشاهد للقصص الطويلة: أيقونة المشهد + نصه + تنقل + شريط صوتي.
  Widget _buildScenePlayer(BedtimeStory st, bool night, Color bodyColor) {
    final scene = st.scenes[_sceneIndex];
    final isLast = _sceneIndex == st.scenes.length - 1;
    final progress = st.scenes.isEmpty
        ? 0.0
        : _sceneIndex / st.scenes.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // أيقونة المشهد المعبرة عنه.
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: night ? _nightCard : Colors.indigo.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _sceneIcons[scene.icon] ?? Icons.auto_stories,
              size: 52,
              color: night ? Colors.amber.shade200 : Colors.indigo,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'المشهد ${_sceneIndex + 1} من ${st.scenes.length}',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: night ? Colors.amber.shade200 : Colors.grey.shade600,
          ),
        ),
        // نقاط المشاهد (قابلة للضغط للانتقال).
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < st.scenes.length; i++)
              GestureDetector(
                onTap: () => _goToScene(i),
                child: Container(
                  width: i == _sceneIndex ? 16 : 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: i == _sceneIndex
                        ? Colors.amber
                        : (night ? Colors.amber.shade200 : Colors.grey),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          st.sceneTextFor(_sceneIndex, _child),
          style: TextStyle(fontSize: 24, height: 1.9, color: bodyColor),
        ),
        const SizedBox(height: 16),
        // التنقل بين المشاهد.
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    _sceneIndex > 0 ? () => _goToScene(_sceneIndex - 1) : null,
                icon: const Icon(Icons.arrow_back, size: 28),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('المشهد السابق', style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isLast
                    ? null
                    : () => _goToScene(_sceneIndex + 1),
                icon: const Icon(Icons.arrow_forward, size: 28),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('المشهد التالي', style: TextStyle(fontSize: 20)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // شريط التحكم الصوتي: تشغيل/إيقاف + تقدم + وقت متبقٍ.
        Card(
          color: night ? _nightCard : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _playing ? Icons.pause : Icons.play_arrow,
                        size: 36,
                        color:
                            night ? Colors.amber.shade200 : Colors.indigo,
                      ),
                      tooltip: _playing ? 'إيقاف مؤقت' : 'اسمع المشهد',
                      onPressed: _playStory,
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor:
                            night ? _nightBar : Colors.indigo.shade100,
                        color: Colors.amber,
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _remainingLabel,
                      style: TextStyle(
                        fontSize: 16,
                        color: night
                            ? Colors.amber.shade200
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // بطاقة العبرة في المشهد الأخير قبل زر «سمعتها».
        if (isLast) ...[
          const SizedBox(height: 16),
          Card(
            color: Colors.amber.shade100,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'ماذا تعلمنا اليوم؟',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    st.moral,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      height: 1.7,
                      color: Colors.brown.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------- ركن الوالدين ----------------
