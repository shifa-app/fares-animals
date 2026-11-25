// الألعاب — نُقلت من lib/main.dart دون تغيير (المرحلة الثانية 2.3).
import 'dart:async';
import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../data/animals.dart';
import '../data/diamond_levels.dart';
import '../services/app_sound.dart';
import '../services/child_profile.dart';
import '../services/progress_store.dart';
import '../widgets/animal_image.dart';
import '../widgets/app_footer.dart';
import '../widgets/big_button.dart';
import 'games/color_game.dart';
import 'games/coloring_game.dart';
import 'games/digger_game.dart';
import 'games/kitchen_game.dart';
import 'games/letter_game.dart';
import 'games/missing_number_game.dart';
import 'games/needs_game.dart';
import 'games/parts_game.dart';
import 'games/puzzle_game.dart';
import 'games/relation_game.dart';
import 'games/shadow_game.dart';
import 'games/shape_game.dart';
import 'games/touch_game.dart';
import 'learn_screen.dart';

// ---------------- الألعاب ----------------

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text(
          'ألعاب',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.volume_up,
                label: 'خمّن الصوت',
                color: Colors.green,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GuessSoundGame()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.image,
                label: 'خمّن الصورة',
                color: Colors.blue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GuessPictureGame()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.psychology,
                label: 'لعبة الذاكرة',
                color: Colors.pink,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MemoryGame()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.diamond,
                label: 'أكل الماس 💎',
                color: Colors.cyan,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DiamondGameScreen()),
                ),
              ),
            ),
            // ---- مكتبة الألعاب التعليمية (P0: سبع ألعاب جديدة) ----
            const SizedBox(height: 24),
            const Text(
              'ألعاب جديدة 🎮',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.visibility,
                label: 'صائد الظلال',
                color: Colors.brown,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShadowGameScreen()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.spellcheck,
                label: 'وصّل الحروف والصور',
                color: Colors.teal,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LetterGameScreen()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.palette,
                label: 'صياد الألوان',
                color: Colors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ColorGameScreen()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.category,
                label: 'عالم الأشكال',
                color: Colors.indigo,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShapeGameScreen()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.calculate,
                label: 'عدّ مع فارس',
                color: Colors.pink,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CountingGameScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.numbers,
                label: 'أكمل الرقم الناقص',
                color: Colors.teal,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MissingNumberGameScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.extension,
                label: 'أحجية الحيوانات',
                color: Colors.deepPurple,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PuzzleGameScreen()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.terrain,
                label: 'حفّار الماس ⛏️',
                color: Colors.brown,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DiggerLevelSelectScreen(),
                  ),
                ),
              ),
            ),
            // ---- مكتبة الألعاب التعليمية (P1: ست ألعاب جديدة) ----
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.brush,
                label: 'رسام الحيوانات',
                color: Colors.pink,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ColoringGameScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.restaurant,
                label: 'مطبخ فارس',
                color: Colors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KitchenGameScreen()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.pets,
                label: 'أجزاء الحيوان',
                color: Colors.teal,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PartsGameScreen()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.link,
                label: 'اكتشف العلاقة',
                color: Colors.indigo,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RelationGameScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.favorite,
                label: 'ماذا يحتاج الحيوان؟',
                color: Colors.green,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NeedsGameScreen()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.touch_app,
                label: 'المس واكتشف',
                color: Colors.cyan,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TouchGameScreen()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GuessSoundGame extends StatefulWidget {
  const GuessSoundGame({super.key});
  @override
  State<GuessSoundGame> createState() => _GuessSoundGameState();
}

class _GuessSoundGameState extends State<GuessSoundGame> {
  final _rnd = Random();
  late Animal _answer;
  late List<Animal> _options;
  bool _hasQuestions = true;
  int _score = 0;
  int _round = 1;
  String _message = 'اسمع الصوت وخمّن الحيوان!';

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  @override
  void dispose() {
    AppSound.instance.stopAll();
    super.dispose();
  }

  void _newRound() {
    // الأسئلة من الحيوانات القابلة للتخمين فقط، وبصوت حقيقي فقط،
    // والصوت المشغّل هو صوت كائن الإجابة نفسه (نفس Animal).
    final pool = animals.where((a) => a.guessable && a.hasRealSound).toList();
    if (pool.isEmpty) {
      setState(() {
        _hasQuestions = false;
        _message = 'لا توجد أصوات حقيقية بعد';
      });
      return;
    }
    _answer = pool[_rnd.nextInt(pool.length)];
    final others = animals.where((a) => a != _answer).toList()..shuffle(_rnd);
    _options = [_answer, others[0], others[1]]..shuffle(_rnd);
    setState(() => _message = 'اسمع الصوت وخمّن الحيوان!');
    AppSound.instance.playAnimalSound(_answer);
  }

  Future<void> _choose(Animal a) async {
    if (a == _answer) {
      await ProgressStore.awardStarsOnce('game_guess_sound_win', 1);
      setState(() {
        _score++;
        _message = 'صح! هذا هو ${_answer.nameAr}';
      });
      await AppSound.instance.praise(_score);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _round++);
      _newRound();
    } else {
      setState(() => _message = 'حاول مرة أخرى يا بطل!');
      await AppSound.instance.speak('حاول مرة أخرى يا بطل!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      appBar: AppBar(
        title: Text(
          'خمّن الصوت — الجولة $_round',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: !_hasQuestions
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'نقاطك: $_score',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => AppSound.instance.playAnimalSound(_answer),
                    icon: const Icon(Icons.volume_up, size: 48),
                    label: const Text(
                      'اسمع الصوت',
                      style: TextStyle(fontSize: 30),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: _options.length,
                      itemBuilder: (context, i) {
                        final a = _options[i];
                        return InkWell(
                          onTap: () => _choose(a),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Expanded(child: animalImage(a, height: 120)),
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(
                                    a.nameAr,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class GuessPictureGame extends StatefulWidget {
  const GuessPictureGame({super.key});
  @override
  State<GuessPictureGame> createState() => _GuessPictureGameState();
}

class _GuessPictureGameState extends State<GuessPictureGame> {
  final _rnd = Random();
  late Animal _answer;
  late List<Animal> _options;
  int _score = 0;
  int _round = 1;
  String _message = 'ما اسم هذا الحيوان؟';

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  @override
  void dispose() {
    AppSound.instance.stopAll();
    super.dispose();
  }

  void _newRound() {
    _answer = animals[_rnd.nextInt(animals.length)];
    final others = animals.where((a) => a != _answer).toList()..shuffle(_rnd);
    _options = [_answer, others[0], others[1]]..shuffle(_rnd);
    setState(() => _message = 'ما اسم هذا الحيوان؟');
  }

  Future<void> _choose(Animal a) async {
    if (a == _answer) {
      await ProgressStore.awardStarsOnce('game_guess_picture_win', 1);
      setState(() {
        _score++;
        _message = 'صح! أحسنت';
      });
      await AppSound.instance.praise(_score);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _round++);
      _newRound();
    } else {
      setState(() => _message = 'حاول مرة أخرى يا بطل!');
      await AppSound.instance.speak('حاول مرة أخرى يا بطل!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      appBar: AppBar(
        title: Text(
          'خمّن الصورة — الجولة $_round',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'نقاطك: $_score',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            animalImage(_answer, height: 260),
            const SizedBox(height: 12),
            Text(
              _message,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (final a in _options)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _choose(a),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Text(a.nameAr, style: const TextStyle(fontSize: 28)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});
  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  final _rnd = Random();
  late List<Animal> _cards;
  final Set<int> _flipped = {};
  final Set<int> _matched = {};
  int? _first;
  bool _busy = false;
  int _pairs = 0;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  @override
  void dispose() {
    AppSound.instance.stopAll();
    super.dispose();
  }

  void _setup() {
    final picks = animals.toList()..shuffle(_rnd);
    final chosen = picks.take(4).toList();
    _cards = [...chosen, ...chosen]..shuffle(_rnd);
    _flipped.clear();
    _matched.clear();
    _first = null;
    _pairs = 0;
  }

  Future<void> _tap(int i) async {
    if (_busy || _flipped.contains(i) || _matched.contains(i)) return;
    setState(() => _flipped.add(i));
    if (_first == null) {
      _first = i;
      return;
    }
    _busy = true;
    final j = _first!;
    _first = null;
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    if (_cards[i] == _cards[j]) {
      setState(() {
        _matched.add(i);
        _matched.add(j);
        _pairs++;
      });
      await AppSound.instance.praise(_pairs);
      if (_pairs == 4) {
        await ProgressStore.awardStarsOnce('game_memory_win', 2);
        if (!mounted) return;
        await AppSound.instance.speak('رائع! أكملت لعبة الذاكرة!');
        setState(_setup);
      }
    } else {
      setState(() {
        _flipped.remove(i);
        _flipped.remove(j);
      });
    }
    _busy = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      appBar: AppBar(
        title: const Text(
          'لعبة الذاكرة',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'الأزواج: $_pairs من 4',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemCount: _cards.length,
              itemBuilder: (context, i) {
                final open = _flipped.contains(i) || _matched.contains(i);
                final a = _cards[i];
                return InkWell(
                  onTap: () => _tap(i),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: open ? Colors.white : Colors.pink.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: open
                        ? Column(
                            children: [
                              Expanded(child: animalImage(a, height: 120)),
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  a.nameAr,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Center(
                            child: Icon(
                              Icons.help_outline,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- نجومي ----------------

// ---------------- لعبة أكل الماس 💎 ----------------

/// شاشة اختيار المرحلة: 10 مراحل، المقفلة بقفل، والمكتملة بنجمة.
class DiamondGameScreen extends StatefulWidget {
  const DiamondGameScreen({super.key});
  @override
  State<DiamondGameScreen> createState() => _DiamondGameScreenState();
}

class _DiamondGameScreenState extends State<DiamondGameScreen> {
  int _unlocked = 1;
  Map<int, int> _best = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final unlocked = await ProgressStore.diamondUnlocked();
    final best = <int, int>{};
    for (final lv in diamondLevels) {
      best[lv.level] = await ProgressStore.diamondBest(lv.level);
    }
    if (mounted) setState(() => _unlocked = unlocked);
    if (mounted) setState(() => _best = best);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.cyan.shade50,
      appBar: AppBar(
        title: const Text(
          'أكل الماس 💎',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'اضغط على الماسة ليأكلها الحيوان! أكمل الهدف قبل انتهاء الوقت.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.6,
                ),
                itemCount: diamondLevels.length,
                itemBuilder: (context, i) {
                  final lv = diamondLevels[i];
                  final open = lv.level <= _unlocked;
                  final done = (_best[lv.level] ?? 0) >= lv.target;
                  return ElevatedButton(
                    onPressed: open
                        ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DiamondLevelScreen(level: lv.level),
                            ),
                          ).then((_) => _load())
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: open ? Colors.cyan : Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          open
                              ? (done ? Icons.star : Icons.diamond)
                              : Icons.lock,
                          size: 40,
                        ),
                        Text(
                          'المرحلة ${lv.level}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'كل ${lv.target} 💎 في ${lv.seconds} ث',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ماسة واحدة على الساحة.
class _Diamond {
  final int id;
  final double x;
  final double y;
  _Diamond({required this.id, required this.x, required this.y});
}

/// شاشة لعب مرحلة: ماسات تظهر عشوائياً وتختفي، والضغط عليها يأكلها.
class DiamondLevelScreen extends StatefulWidget {
  final int level;
  const DiamondLevelScreen({super.key, required this.level});
  @override
  State<DiamondLevelScreen> createState() => _DiamondLevelScreenState();
}

class _DiamondLevelScreenState extends State<DiamondLevelScreen> {
  late final DiamondLevel _config;
  int _timeLeft = 0;
  int _eaten = 0;
  int _nextId = 0;
  final List<_Diamond> _diamonds = [];
  Timer? _timer;
  bool _over = false;
  double _areaWidth = 300;
  double _areaHeight = 300;
  String _childName = ChildProfile.defaultChild;
  // الحيوان يتغير كل مرحلة، والضغط عليه يبدّله.
  late int _animalIndex;
  // آخر مرة نطق فيها «يم!» — لمنع تداخل الصوت عند الضغط السريع.
  DateTime _lastYum = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _config = diamondLevel(widget.level);
    _timeLeft = _config.seconds;
    _animalIndex = (widget.level - 1) % diamondAnimals.length;
    ChildProfile.currentChild().then(
      (name) => mounted ? setState(() => _childName = name) : null,
    );
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (var i = 0; i < _config.maxDiamonds; i++) {
        _spawnDiamond();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _over) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) _finish(false);
    });
  }

  @override
  void dispose() {
    // إيقاف المؤقت والصوت فوراً عند الرجوع.
    _timer?.cancel();
    unawaited(AppSound.instance.stopAll());
    super.dispose();
  }

  void _spawnDiamond() {
    if (_over || !mounted) return;
    final id = _nextId++;
    final d = _Diamond(
      id: id,
      x: Random().nextDouble() * (_areaWidth - 72),
      y: Random().nextDouble() * (_areaHeight - 72),
    );
    setState(() => _diamonds.add(d));
    // تختفي الماسة بعد مدة إن لم تُؤكل، وتظهر غيرها.
    Future.delayed(
      Duration(milliseconds: (_config.despawnSeconds * 1000).round()),
      () {
        if (!mounted || _over) return;
        final wasThere = _diamonds.any((e) => e.id == id);
        if (!wasThere) return;
        setState(() => _diamonds.removeWhere((e) => e.id == id));
        _spawnDiamond();
      },
    );
  }

  void _eatDiamond(_Diamond d) {
    if (_over) return;
    setState(() {
      _diamonds.removeWhere((e) => e.id == d.id);
      _eaten++;
    });
    // صوت «يم!» واحد فقط كل 400 مللي ثانية حتى مع الضغط السريع.
    final now = DateTime.now();
    if (now.difference(_lastYum).inMilliseconds >= 400) {
      _lastYum = now;
      unawaited(AppSound.instance.speak('يم!'));
    }
    if (_eaten >= _config.target) {
      _finish(true);
    } else {
      _spawnDiamond();
    }
  }

  /// إعادة المرحلة من البداية بعد انتهاء الوقت (بلا خصم نجوم أبداً).
  void _restart() {
    _timer?.cancel();
    setState(() {
      _over = false;
      _eaten = 0;
      _timeLeft = _config.seconds;
      _diamonds.clear();
    });
    _startTimer();
    for (var i = 0; i < _config.maxDiamonds; i++) {
      _spawnDiamond();
    }
  }

  Future<void> _finish(bool won) async {
    if (_over) return;
    _over = true;
    _timer?.cancel();
    await ProgressStore.saveDiamondBest(widget.level, _eaten);
    if (won) {
      await ProgressStore.awardStarsOnce('diamond_level_${widget.level}', 1);
      if (widget.level < diamondLevels.length) {
        await ProgressStore.unlockDiamondLevel(widget.level + 1);
      }
      final name = await ChildProfile.currentChild();
      if (mounted) setState(() => _childName = name);
      await AppSound.instance.speak(
        'أحسنت يا $_childName! أكملت المرحلة ${widget.level}!',
      );
    }
    if (!mounted) return;
    final retry = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          won ? 'رائع! 🎉' : 'لا بأس يا بطل! 💪',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        content: Text(
          won
              ? 'أكلت ${_config.target} ماسات في المرحلة ${widget.level}، وكسبت نجمة! ⭐'
              : 'أكلت $_eaten من ${_config.target} ماسات. أنت تستطيع! حاول مجدداً.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22),
        ),
        actions: [
          if (!won)
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'حاول مجدداً',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('حسناً', style: TextStyle(fontSize: 22)),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (retry == true) {
      _restart();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.cyan.shade50,
      appBar: AppBar(
        title: Text(
          'المرحلة ${widget.level} 💎',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat('💎 $_eaten / ${_config.target}', Colors.cyan),
                _stat(
                  '⏱ $_timeLeft ث',
                  _timeLeft <= 10 ? Colors.red : Colors.orange,
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                _areaWidth = constraints.maxWidth;
                _areaHeight = constraints.maxHeight;
                return Stack(
                  children: [
                    // حيوان الساحة: يتغير كل مرحلة، والضغط عليه يبدّله.
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => setState(
                              () => _animalIndex =
                                  (_animalIndex + 1) % diamondAnimals.length,
                            ),
                            child: Text(
                              diamondAnimals[_animalIndex],
                              style: const TextStyle(fontSize: 110),
                            ),
                          ),
                          const Text(
                            'اضغط على الحيوان لتغييره',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    for (final d in _diamonds)
                      Positioned(
                        left: d.x,
                        top: d.y,
                        child: GestureDetector(
                          onTap: () => _eatDiamond(d),
                          // منطقة لمس كبيرة لعمر 5 سنوات: الماسة نفسها
                          // كبيرة (88) مع حشوة شفافة حولها.
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            color: Colors.transparent,
                            child: const Text(
                              '💎',
                              style: TextStyle(fontSize: 88),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 3),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

