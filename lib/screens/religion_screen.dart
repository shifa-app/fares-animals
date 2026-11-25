// التعلم الديني وأقسامه — نُقلت من lib/main.dart دون تغيير (المرحلة الثانية 2.3).
import 'package:material_ui/material_ui.dart';

import '../data/religion.dart';
import '../services/app_sound.dart';
import '../services/child_profile.dart';
import '../services/progress_store.dart';
import '../widgets/app_footer.dart';
import 'quran_screen.dart';

// ---------------- التعليم الديني ----------------

class ReligionScreen extends StatelessWidget {
  const ReligionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text(
          'تعلم ديني',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _menuButton(
            context,
            Icons.menu_book,
            'تحفيظ القرآن',
            Colors.green,
            const MemorizationListScreen(),
          ),
          _menuButton(
            context,
            Icons.self_improvement,
            'الأذكار',
            Colors.green,
            const AdhkarScreen(),
          ),
          _menuButton(
            context,
            Icons.mosque,
            'الوضوء والصلاة',
            Colors.blue,
            const WuduPrayerScreen(),
          ),
          _menuButton(
            context,
            Icons.auto_awesome,
            'أسماء الله الحسنى',
            Colors.purple,
            const NamesScreen(),
          ),
          _menuButton(
            context,
            Icons.auto_stories,
            'قصص جميلة',
            Colors.orange,
            const StoriesScreen(),
          ),
          _menuButton(
            context,
            Icons.favorite,
            'آداب جميلة',
            Colors.pink,
            const MannersScreen(),
          ),
        ],
      ),
    );
  }

  Widget _menuButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    Widget page,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Icon(icon, size: 44, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    label,
                    softWrap: false,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdhkarScreen extends StatelessWidget {
  const AdhkarScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      appBar: AppBar(
        title: const Text(
          'الأذكار',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final entry in adhkar.entries)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                title: Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: const Icon(
                  Icons.self_improvement,
                  size: 36,
                  color: Colors.green,
                ),
                children: [
                  for (final d in entry.value)
                    _DhikrCounter(category: entry.key, dhikr: d),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// سبحة رقمية: كل ضغطة على العدّاد تزيده، وعند إتمام العدد المطلوب
/// (من repeat: «3 مرات» أو «مرة واحدة») يمنح نجمة واحدة.
/// ملاحظة: نطق الذكر عبر جهاز TTS مضبوط التشكيل، وليس تسجيلاً بشرياً.
class _DhikrCounter extends StatefulWidget {
  final String category;
  final Dhikr dhikr;
  const _DhikrCounter({required this.category, required this.dhikr});
  @override
  State<_DhikrCounter> createState() => _DhikrCounterState();
}

class _DhikrCounterState extends State<_DhikrCounter> {
  int _count = 0;
  bool _done = false;

  int get _target {
    final m = RegExp(r'\d+').firstMatch(widget.dhikr.repeat);
    return m == null ? 1 : int.parse(m.group(0)!);
  }

  String get _key => 'dhikr_${widget.category}_${widget.dhikr.title}';

  @override
  void initState() {
    super.initState();
    ProgressStore.isReligion(_key)
        .then((v) => mounted ? setState(() => _done = v) : null);
  }

  @override
  void dispose() {
    AppSound.instance.stopAll();
    super.dispose();
  }

  Future<void> _tap() async {
    if (_done) return;
    final next = _count + 1;
    setState(() => _count = next);
    if (next >= _target) {
      await ProgressStore.markReligion(_key);
      await ProgressStore.awardStarsOnce(_key, 1);
      if (mounted) setState(() => _done = true);
      await AppSound.instance.praise();
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dhikr;
    return ListTile(
      title: Text(
        d.title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${d.text}\n(${d.repeat})',
        style: const TextStyle(fontSize: 20),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.volume_up, size: 30, color: Colors.green),
            onPressed: () => AppSound.instance.speak(d.text),
          ),
          InkWell(
            onTap: _tap,
            borderRadius: BorderRadius.circular(32),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _done ? Colors.amber : Colors.green.shade100,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Center(
                child: _done
                    ? const Icon(Icons.star, size: 32, color: Colors.white)
                    : Text(
                        '$_count/$_target',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// رسم توضيحي مبسط لكل خطوة (أيقونة + رقم الخطوة).
const List<IconData> _wuduIcons = [
  Icons.favorite,
  Icons.front_hand,
  Icons.water_drop,
  Icons.air,
  Icons.face,
  Icons.pan_tool,
  Icons.person,
  Icons.directions_walk,
];
const List<IconData> _prayerIcons = [
  Icons.person,
  Icons.record_voice_over,
  Icons.menu_book,
  Icons.trending_down,
  Icons.vertical_align_bottom,
  Icons.check_circle,
];

class WuduPrayerScreen extends StatelessWidget {
  const WuduPrayerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      appBar: AppBar(
        title: const Text(
          'الوضوء والصلاة',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Row(
            children: [
              Icon(Icons.water_drop, size: 32, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'خطوات الوضوء',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < wuduSteps.length; i++)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ),
                title: Row(
                  children: [
                    Icon(_wuduIcons[i], size: 28, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        wuduSteps[i],
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.blue),
                  onPressed: () => AppSound.instance.speak(wuduSteps[i]),
                ),
              ),
            ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.mosque, size: 32, color: Colors.teal),
              SizedBox(width: 8),
              Text(
                'خطوات الصلاة',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < prayerSteps.length; i++)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ),
                title: Row(
                  children: [
                    Icon(_prayerIcons[i], size: 28, color: Colors.teal),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        prayerSteps[i],
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.teal),
                  onPressed: () => AppSound.instance.speak(prayerSteps[i]),
                ),
              ),
            ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.schedule, size: 32, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'الصلوات الخمس',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final e in prayers.entries)
                Chip(
                  label: Text(
                    '${e.key}: ${e.value} ركعات',
                    style: const TextStyle(fontSize: 22),
                  ),
                  backgroundColor: Colors.blue.shade100,
                  padding: const EdgeInsets.all(10),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class NamesScreen extends StatelessWidget {
  const NamesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      appBar: AppBar(
        title: const Text(
          'أسماء الله الحسنى',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final e in allahNames.entries)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(
                  Icons.auto_awesome,
                  size: 32,
                  color: Colors.purple,
                ),
                title: Text(
                  e.key,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(e.value, style: const TextStyle(fontSize: 20)),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.volume_up,
                    size: 32,
                    color: Colors.purple,
                  ),
                  onPressed: () {
                    AppSound.instance.speak('${e.key}. ${e.value}');
                    ProgressStore.markReligion('name_${e.key}');
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});
  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  String _childName = ChildProfile.defaultChild;

  @override
  void initState() {
    super.initState();
    ChildProfile.currentChild().then(
      (name) => mounted ? setState(() => _childName = name) : null,
    );
  }

  /// اسم بطل القصة هو الطفل الحالي («فارس الصغير» تصير «فهد الصغير»).
  String _hero(String text) => text.replaceAll('فارس', _childName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      appBar: AppBar(
        title: const Text(
          'قصص جميلة',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stories.length,
        itemBuilder: (context, i) {
          final st = stories[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(
                Icons.auto_stories,
                size: 36,
                color: Colors.orange,
              ),
              title: Text(
                _hero(st.title),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(st.moral, style: const TextStyle(fontSize: 18)),
              trailing: IconButton(
                icon: const Icon(
                  Icons.volume_up,
                  size: 32,
                  color: Colors.orange,
                ),
                onPressed: () {
                  AppSound.instance.speak(
                    '${_hero(st.title)}. ${_hero(st.body)} ${st.moral}',
                  );
                  ProgressStore.markReligion('story_${st.title}');
                },
              ),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(
                    _hero(st.title),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Text(
                      _hero(st.body),
                      style: const TextStyle(fontSize: 22, height: 1.8),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'حسناً',
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MannersScreen extends StatelessWidget {
  const MannersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      appBar: AppBar(
        title: const Text(
          'آداب جميلة',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final e in manners.entries)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(
                  Icons.favorite,
                  size: 32,
                  color: Colors.pink,
                ),
                title: Text(
                  e.key,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(e.value, style: const TextStyle(fontSize: 20)),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.volume_up,
                    size: 32,
                    color: Colors.pink,
                  ),
                  onPressed: () {
                    AppSound.instance.speak('${e.key}. ${e.value}');
                    ProgressStore.markReligion('manner_${e.key}');
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

