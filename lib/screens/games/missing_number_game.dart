// G06 أكمل الرقم الناقص: تسلسل من 5 أعداد فيه موضع ناقص واحد (؟)؛
// على الطفل اختيار الرقم الصحيح من 3 خيارات. 5 جولات،
// 4 مستويات صعوبة، نجمة عند الإكمال، بلا خصم أبداً.
import 'package:material_ui/material_ui.dart';

import '../../services/app_sound.dart';
import '../../services/game_engine.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/game_guide.dart';

const Map<String, GameDifficulty> missingNumberLevels = {
  'سهل': GameDifficulty.easy,
  'متوسط': GameDifficulty.medium,
  'صعب': GameDifficulty.hard,
  'خبير': GameDifficulty.expert,
};

class MissingNumberGameScreen extends StatefulWidget {
  const MissingNumberGameScreen({super.key});
  @override
  State<MissingNumberGameScreen> createState() =>
      _MissingNumberGameScreenState();
}

class _MissingNumberGameScreenState extends State<MissingNumberGameScreen>
    with GameScreenMixin {
  @override
  String get gameId => 'g06';

  @override
  String get guideText =>
      'أنا فارس! انظر إلى الأعداد، وخمّن: ما الرقم الناقص؟ اضغط عليه!';

  late List<GameRound> _rounds;
  int _roundIndex = 0;
  GameDifficulty _difficulty = GameDifficulty.easy;
  int _score = 0;
  String _message = 'ما الرقم الناقص؟';
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _rounds = GameEngine.buildMissingNumberRounds(
      difficulty: _difficulty,
      count: 5,
    );
    initGuide();
  }

  GameRound get _round => _rounds[_roundIndex];

  void _setDifficulty(GameDifficulty difficulty) {
    if (difficulty == _difficulty) return;
    setState(() {
      _difficulty = difficulty;
      _rounds = GameEngine.buildMissingNumberRounds(
        difficulty: _difficulty,
        count: 5,
      );
      _roundIndex = 0;
      _score = 0;
      _locked = false;
      _message = 'ما الرقم الناقص؟';
    });
  }

  Future<void> _choose(String value) async {
    if (_locked) return;
    if (_round.options[_round.correctIndex] == value) {
      setState(() {
        _locked = true;
        _score++;
        _message = 'صح! الرقم الناقص هو $value';
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
          _message = 'ما الرقم الناقص؟';
        });
      }
    } else {
      setState(() => _message = 'حاول مرة أخرى يا بطل!');
      await AppSound.instance.speak('حاول مرة أخرى يا بطل!');
    }
  }

  Future<void> _finish() async {
    await GameEngine.completeGame('g06');
    if (!mounted) return;
    final replay =
        await showGameDoneDialog(context, gameName: 'أكمل الرقم الناقص');
    if (!mounted) return;
    if (replay == true) {
      setState(() {
        _rounds = GameEngine.buildMissingNumberRounds(
          difficulty: _difficulty,
          count: 5,
        );
        _roundIndex = 0;
        _score = 0;
        _locked = false;
        _message = 'ما الرقم الناقص؟';
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sequence = _round.sequence ?? [];
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: Text(
          'أكمل الرقم الناقص — الجولة ${_roundIndex + 1} من ${_rounds.length}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
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
                for (final entry in missingNumberLevels.entries)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: () => _setDifficulty(entry.value),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _difficulty == entry.value
                              ? Colors.teal
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
            const SizedBox(height: 20),
            // التسلسل: 5 خانات، والناقصة علامة استفهام.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < sequence.length; i++)
                  Container(
                    width: 56,
                    height: 72,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: sequence[i] == null
                          ? Colors.amber.shade200
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sequence[i] == null
                            ? Colors.amber
                            : Colors.teal.shade200,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        sequence[i] == null ? '؟' : '${sequence[i]}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                for (final o in _round.options)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ElevatedButton(
                        onPressed: () => _choose(o),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: Text(o, style: const TextStyle(fontSize: 32)),
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
