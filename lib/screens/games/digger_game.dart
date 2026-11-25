// حفّار الماس ⛏️: الأرنب يحفر التراب ويجمع الماس ثم يخرج من الباب المضيء.
// 8 مراحل بخرائط ثابتة، مؤقت مريح 120 ثانية، بلا خصم أبداً.
// التحكم: 4 أزرار أسهم كبيرة + السحب على الشبكة.
import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../data/digger_levels.dart';
import '../../services/app_sound.dart';
import '../../services/digger_engine.dart';
import '../../services/game_engine.dart';
import '../../services/progress_store.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/game_guide.dart';

/// شاشة اختيار المرحلة: 8 مراحل، المقفلة بقفل، والمكتملة بنجمة.
class DiggerLevelSelectScreen extends StatefulWidget {
  const DiggerLevelSelectScreen({super.key});
  @override
  State<DiggerLevelSelectScreen> createState() =>
      _DiggerLevelSelectScreenState();
}

class _DiggerLevelSelectScreenState extends State<DiggerLevelSelectScreen> {
  int _unlocked = 1;
  final Set<int> _done = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final unlocked = await ProgressStore.diggerUnlocked();
    final done = <int>{};
    for (final lv in diggerLevels) {
      if (await ProgressStore.hasStarFor('digger_level_${lv.number}')) {
        done.add(lv.number);
      }
    }
    if (mounted) {
      setState(() {
        _unlocked = unlocked;
        _done
          ..clear()
          ..addAll(done);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.brown.shade50,
      appBar: AppBar(
        title: const Text(
          'حفّار الماس ⛏️',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'احفر التراب واجمع كل الماس، ثم اخرج من الباب المضيء!',
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
                itemCount: diggerLevels.length,
                itemBuilder: (context, i) {
                  final lv = diggerLevels[i];
                  final open = lv.number <= _unlocked;
                  final done = _done.contains(lv.number);
                  return ElevatedButton(
                    onPressed: open
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DiggerPlayScreen(level: lv),
                              ),
                            ).then((_) => _load())
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: open ? Colors.brown : Colors.grey,
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
                              ? (done ? Icons.star : Icons.terrain)
                              : Icons.lock,
                          size: 40,
                        ),
                        Text(
                          'المرحلة ${lv.number}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(lv.name, style: const TextStyle(fontSize: 18)),
                        Text(
                          '💎 ${lv.diamondCount}',
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

/// شاشة لعب مرحلة: شبكة حفر 7×9 + أسهم كبيرة + سحب + مؤقت.
class DiggerPlayScreen extends StatefulWidget {
  final DiggerLevel level;
  const DiggerPlayScreen({super.key, required this.level});
  @override
  State<DiggerPlayScreen> createState() => _DiggerPlayScreenState();
}

class _DiggerPlayScreenState extends State<DiggerPlayScreen>
    with GameScreenMixin {
  @override
  String get gameId => 'digger';

  @override
  String get guideText =>
      'أنا الأرنب! احفر التراب بالأسهم، واجمع كل الماس، ثم اخرج من الباب المضيء!';

  late DiggerState _state;
  late int _timeLeft;
  Timer? _timer;
  bool _over = false;
  // آخر مرة نطق فيها «يم!» — لمنع تداخل الصوت عند الجمع السريع.
  DateTime _lastYum = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _state = DiggerEngine.parse(widget.level);
    _timeLeft = widget.level.seconds;
    initGuide();
    _startTimer();
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
    // إيقاف المؤقت هنا (المزيج لا يعرف عنه)، مع إيقاف الصوت كما يفعل
    // dispose المزيج نفسه — فتعريف dispose هنا يحجب dispose المزيج.
    _timer?.cancel();
    unawaited(GameEngine.stopAudio());
    super.dispose();
  }

  Future<void> _move(DiggerDirection dir) async {
    if (_over) return;
    final before = _state.collected;
    if (!DiggerEngine.move(_state, dir)) return;
    setState(() {});
    if (_state.collected > before) {
      final now = DateTime.now();
      if (now.difference(_lastYum).inMilliseconds >= 400) {
        _lastYum = now;
        unawaited(AppSound.instance.speak('يم!'));
      }
    }
    if (_state.completed) {
      await _finish(true);
    }
  }

  /// إعادة المرحلة من البداية بعد انتهاء الوقت (بلا خصم نجوم أبداً).
  void _restart() {
    _timer?.cancel();
    setState(() {
      _state = DiggerEngine.parse(widget.level);
      _timeLeft = widget.level.seconds;
      _over = false;
    });
    _startTimer();
  }

  Future<void> _finish(bool won) async {
    if (_over) return;
    _over = true;
    _timer?.cancel();
    if (won) {
      await ProgressStore.awardStarsOnce(
        'digger_level_${widget.level.number}',
        1,
      );
      if (widget.level.number < diggerLevels.length) {
        await ProgressStore.unlockDiggerLevel(widget.level.number + 1);
      }
      await GameEngine.completeGame('digger');
      await AppSound.instance.praise(1);
    }
    if (!mounted) return;
    final hasNext = won && widget.level.number < diggerLevels.length;
    final go = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          won ? 'رائع! 🎉' : 'انتهى الوقت! ⏰',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        content: Text(
          won
              ? 'جمعت كل الماس وخرجت من الباب، وكسبت نجمة! ⭐'
              : 'لا بأس يا بطل! حاول مجدداً.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              hasNext ? 'المرحلة التالية' : 'حاول مجدداً',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
    if (go == true) {
      if (hasNext) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                DiggerPlayScreen(level: diggerLevels[widget.level.number]),
          ),
        );
      } else {
        _restart();
      }
    } else {
      Navigator.pop(context);
    }
  }

  Widget _cell(int r, int c) {
    final isPlayer = _state.playerRow == r && _state.playerCol == c;
    final cell = _state.cellAt(r, c);
    Color bg;
    Widget? child;
    switch (cell) {
      case DiggerCell.dirt:
        bg = (r + c) % 2 == 0 ? Colors.brown.shade400 : Colors.brown.shade500;
      case DiggerCell.empty:
        bg = const Color(0xFF3E2723);
      case DiggerCell.rock:
        bg = const Color(0xFF3E2723);
        child = Container(
          margin: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
        );
      case DiggerCell.diamond:
        bg = const Color(0xFF3E2723);
        child = const Text('💎', style: TextStyle(fontSize: 26));
      case DiggerCell.hedgehog:
        bg = const Color(0xFF3E2723);
        child = const Text('🦔', style: TextStyle(fontSize: 26));
      case DiggerCell.exit:
        bg =
            _state.exitOpen ? Colors.amber.shade300 : Colors.grey.shade600;
        child = const Text('🚪', style: TextStyle(fontSize: 26));
    }
    return Container(
      color: bg,
      child: Center(
        child: isPlayer
            ? const Text('🐰', style: TextStyle(fontSize: 32))
            : child,
      ),
    );
  }

  Widget _arrow(IconData icon, String tooltip, DiggerDirection dir) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 72,
        height: 72,
        child: ElevatedButton(
          onPressed: () => _move(dir),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.brown,
            foregroundColor: Colors.white,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Icon(icon, size: 44),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.brown.shade50,
      appBar: AppBar(
        title: Text(
          'المرحلة ${widget.level.number} ⛏️ — ${widget.level.name}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, size: 30),
            tooltip: 'اسمع التعليمات',
            onPressed: replayGuide,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (guideVisible)
              GameGuideCard(
                text: guideText,
                onDismiss: dismissGuide,
                onReplay: replayGuide,
              ),
            // زر إعادة المرحلة واضح في الأعلى: إن أغلق الطفل الطريق
            // على نفسه بالصخور يعيد المحاولة فوراً بلا انتظار المؤقت.
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _restart,
                icon: const Icon(Icons.refresh, size: 30),
                label: const Text(
                  'إعادة المرحلة',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  '💎 ${_state.collected} / ${_state.total}',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '⏱ $_timeLeft ث',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: _timeLeft <= 10 ? Colors.red : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // الشبكة: السحب عليها يحرك الأرنب أيضاً.
            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                _move(
                  details.primaryVelocity! > 0
                      ? DiggerDirection.right
                      : DiggerDirection.left,
                );
              },
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                _move(
                  details.primaryVelocity! > 0
                      ? DiggerDirection.down
                      : DiggerDirection.up,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.brown.shade700, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                    ),
                    itemCount: _state.rows * _state.cols,
                    itemBuilder: (context, i) =>
                        _cell(i ~/ _state.cols, i % _state.cols),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // أزرار الأسهم الكبيرة.
            Column(
              children: [
                _arrow(
                  Icons.keyboard_arrow_up,
                  'أعلى',
                  DiggerDirection.up,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _arrow(
                      Icons.keyboard_arrow_right,
                      'يمين',
                      DiggerDirection.right,
                    ),
                    const SizedBox(width: 8),
                    _arrow(
                      Icons.keyboard_arrow_down,
                      'أسفل',
                      DiggerDirection.down,
                    ),
                    const SizedBox(width: 8),
                    _arrow(
                      Icons.keyboard_arrow_left,
                      'يسار',
                      DiggerDirection.left,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
