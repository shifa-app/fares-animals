// G07 أحجية الحيوانات: صورة حيوان مقسمة (2×2 أو 3×3) وقطعة ناقصة (؟)؛
// على الطفل اختيار القطعة الصحيحة من 3 قطع مقصوصة. 5 جولات،
// 4 مستويات صعوبة، نجمة عند الإكمال، بلا خصم أبداً.
// القطع مقصوصة من الصورة نفسها بـ ClipRect + Align (بلا حزم خارجية).
import 'package:material_ui/material_ui.dart';

import '../../data/animals.dart';
import '../../services/app_sound.dart';
import '../../services/game_engine.dart';
import '../../utils/matching.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/game_guide.dart';

const Map<String, GameDifficulty> puzzleLevels = {
  'سهل': GameDifficulty.easy,
  'متوسط': GameDifficulty.medium,
  'صعب': GameDifficulty.hard,
  'خبير': GameDifficulty.expert,
};

class PuzzleGameScreen extends StatefulWidget {
  const PuzzleGameScreen({super.key});
  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen>
    with GameScreenMixin {
  @override
  String get gameId => 'g07';

  @override
  String get guideText =>
      'أنا فارس! انظر إلى الصورة الناقصة، واختر القطعة التي تكملها!';

  late List<GameRound> _rounds;
  int _roundIndex = 0;
  GameDifficulty _difficulty = GameDifficulty.easy;
  int _score = 0;
  String _message = 'أكمل الصورة! ما القطعة الناقصة؟';
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _rounds = GameEngine.buildPuzzleRounds(
      difficulty: _difficulty,
      count: 5,
    );
    initGuide();
  }

  GameRound get _round => _rounds[_roundIndex];

  /// الحمولة بصيغة «اسم الحيوان:حجم الشبكة:الخلية الناقصة».
  List<String> get _payloadParts => (_round.payload ?? '').split(':');
  Animal get _animal =>
      findAnimalByName(_payloadParts.first) ?? animals[0];
  int get _grid => int.tryParse(
        _payloadParts.length > 1 ? _payloadParts[1] : '2',
      ) ??
      2;
  int get _missing => int.tryParse(
        _payloadParts.length > 2 ? _payloadParts[2] : '0',
      ) ??
      0;

  void _setDifficulty(GameDifficulty difficulty) {
    if (difficulty == _difficulty) return;
    setState(() {
      _difficulty = difficulty;
      _rounds = GameEngine.buildPuzzleRounds(
        difficulty: _difficulty,
        count: 5,
      );
      _roundIndex = 0;
      _score = 0;
      _locked = false;
      _message = 'أكمل الصورة! ما القطعة الناقصة؟';
    });
  }

  Future<void> _choose(String option) async {
    if (_locked) return;
    if (_round.options[_round.correctIndex] == option) {
      final name = option.split(':').first;
      setState(() {
        _locked = true;
        _score++;
        _message = 'صح! هذه قطعة الـ $name';
      });
      await AppSound.instance.praise(_score);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      if (_roundIndex + 1 >= _rounds.length) {
        await _finish();
      } else {
        setState(() {
          _roundIndex++;
          _locked = false;
          _message = 'أكمل الصورة! ما القطعة الناقصة؟';
        });
      }
    } else {
      setState(() => _message = 'حاول مرة أخرى يا بطل!');
      await AppSound.instance.speak('حاول مرة أخرى يا بطل!');
    }
  }

  Future<void> _finish() async {
    await GameEngine.completeGame('g07');
    if (!mounted) return;
    final replay =
        await showGameDoneDialog(context, gameName: 'أحجية الحيوانات');
    if (!mounted) return;
    if (replay == true) {
      setState(() {
        _rounds = GameEngine.buildPuzzleRounds(
          difficulty: _difficulty,
          count: 5,
        );
        _roundIndex = 0;
        _score = 0;
        _locked = false;
        _message = 'أكمل الصورة! ما القطعة الناقصة؟';
      });
    } else {
      Navigator.pop(context);
    }
  }

  /// قطعة مقصوصة من صورة الحيوان: الخلية cell من شبكة grid×grid.
  Widget _piece(Animal animal, int cell, int grid, double cellSize) {
    final row = cell ~/ grid;
    final col = cell % grid;
    final ax = grid == 1 ? 0.0 : col / (grid - 1) * 2 - 1;
    final ay = grid == 1 ? 0.0 : row / (grid - 1) * 2 - 1;
    return ClipRect(
      child: Align(
        alignment: Alignment(ax, ay),
        widthFactor: 1 / grid,
        heightFactor: 1 / grid,
        child: Image.network(
          animal.imageUrl,
          width: cellSize * grid,
          height: cellSize * grid,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(
            width: cellSize * grid,
            height: cellSize * grid,
            color: Colors.orange.shade100,
            child: const Center(
              child: Icon(Icons.pets, size: 60, color: Colors.orange),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const boardSize = 300.0;
    final cellSize = boardSize / _grid;
    final cells = _grid * _grid;
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: Text(
          'أحجية الحيوانات — الجولة ${_roundIndex + 1} من ${_rounds.length}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, size: 28, color: Colors.amber),
                const SizedBox(width: 6),
                Text(
                  'نقاطك: $_score',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // مستويات الصعوبة: تغيير المستوى يعيد اللعبة من الجولة الأولى.
            Row(
              children: [
                for (final entry in puzzleLevels.entries)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: () => _setDifficulty(entry.value),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _difficulty == entry.value
                              ? Colors.deepPurple
                              : Colors.grey.shade300,
                          foregroundColor: _difficulty == entry.value
                              ? Colors.white
                              : Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // لوحة الأحجية: الصورة مقسمة، والخلية الناقصة علامة استفهام.
            Container(
              width: boardSize,
              height: boardSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.deepPurple.shade200,
                  width: 3,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _grid,
                  ),
                  itemCount: cells,
                  itemBuilder: (context, i) {
                    if (i == _missing) {
                      return Container(
                        color: Colors.amber.shade200,
                        child: const Center(
                          child: Text(
                            '؟',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }
                    return _piece(_animal, i, _grid, cellSize);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // القطع الثلاث المرشحة (مقصوصة من صور حيوانات).
            Row(
              children: [
                for (final o in _round.options)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ElevatedButton(
                        onPressed: () => _choose(o),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _piece(
                            findAnimalByName(o.split(':').first) ?? animals[0],
                            int.tryParse(o.split(':').last) ?? 0,
                            _grid,
                            88,
                          ),
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
  }
}
