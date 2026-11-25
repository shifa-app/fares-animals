// G12 ماذا يحتاج الحيوان؟: موقف تعليمي + احتياج مناسب؛
// على الطفل اختيار الاحتياج الصحيح ثم يسمع تفسيره.
import 'package:material_ui/material_ui.dart';

import '../../services/app_sound.dart';
import '../../services/game_engine.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/game_guide.dart';

const Map<String, GameDifficulty> needsLevels = {
  'سهل': GameDifficulty.easy,
  'متوسط': GameDifficulty.medium,
  'صعب': GameDifficulty.hard,
  'خبير': GameDifficulty.expert,
};

class NeedsGameScreen extends StatefulWidget {
  const NeedsGameScreen({super.key});
  @override
  State<NeedsGameScreen> createState() => _NeedsGameScreenState();
}

class _NeedsGameScreenState extends State<NeedsGameScreen>
    with GameScreenMixin {
  @override
  String get gameId => 'g12';

  @override
  String get guideText =>
      'أنا فارس! كل حيوان يحتاج شيئاً! اسمع الموقف، واختر ما يحتاجه الحيوان!';

  GameDifficulty _difficulty = GameDifficulty.easy;
  late List<GameRound> _rounds;
  int _roundIndex = 0;
  int _score = 0;
  String _message = 'ماذا يحتاج الحيوان؟';
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _rounds = GameEngine.buildNeedsRounds(count: 5, difficulty: _difficulty);
    initGuide();
  }

  GameRound get _round => _rounds[_roundIndex];

  AnimalNeed get _scenario => animalNeeds.firstWhere(
    (n) => n.animal == _round.payload,
  );

  void _changeDifficulty(GameDifficulty d) {
    setState(() {
      _difficulty = d;
      _rounds = GameEngine.buildNeedsRounds(count: 5, difficulty: d);
      _roundIndex = 0;
      _score = 0;
      _locked = false;
      _message = 'ماذا يحتاج الحيوان؟';
    });
  }

  Future<void> _choose(String need) async {
    if (_locked) return;
    if (_round.options[_round.correctIndex] == need) {
      setState(() {
        _locked = true;
        _score++;
        _message = _scenario.why;
      });
      await AppSound.instance.praise(_score);
      await AppSound.instance.speak(_scenario.why);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      if (_roundIndex + 1 >= _rounds.length) {
        await _finish();
      } else {
        setState(() {
          _roundIndex++;
          _locked = false;
          _message = 'ماذا يحتاج الحيوان؟';
        });
      }
    } else {
      setState(() => _message = 'حاول مرة أخرى يا بطل!');
      await AppSound.instance.speak('حاول مرة أخرى يا بطل!');
    }
  }

  Future<void> _finish() async {
    await GameEngine.completeGame('g12');
    if (!mounted) return;
    final replay = await showGameDoneDialog(
      context,
      gameName: 'ماذا يحتاج الحيوان؟',
    );
    if (!mounted) return;
    if (replay == true) {
      setState(() {
        _rounds = GameEngine.buildNeedsRounds(count: 5, difficulty: _difficulty);
        _roundIndex = 0;
        _score = 0;
        _locked = false;
        _message = 'ماذا يحتاج الحيوان؟';
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: Text(
          'ماذا يحتاج الحيوان؟ — الجولة ${_roundIndex + 1} من ${_rounds.length}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
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
                for (final entry in needsLevels.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 18),
                      ),
                      selected: _difficulty == entry.value,
                      selectedColor: Colors.green.shade200,
                      onSelected: (_) => _changeDifficulty(entry.value),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
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
            Text(
              _scenario.emoji,
              style: const TextStyle(fontSize: 110),
            ),
            Text(
              _round.question,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              itemCount: _round.options.length,
              itemBuilder: (context, i) {
                final need = _round.options[i];
                return ElevatedButton(
                  onPressed: () => _choose(need),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        animalNeedEmojis[need] ?? '❓',
                        style: const TextStyle(fontSize: 40),
                      ),
                      Text(need, style: const TextStyle(fontSize: 26)),
                    ],
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
