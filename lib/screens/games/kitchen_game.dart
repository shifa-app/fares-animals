// G09 مطبخ فارس: وجبة + مكوناتها بين خيارات؛ على الطفل
// اصطياد كل مكونات الوجبة (بلا خصم عند الخطأ).
import 'package:material_ui/material_ui.dart';

import '../../services/app_sound.dart';
import '../../services/game_engine.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/game_guide.dart';

const Map<String, GameDifficulty> kitchenLevels = {
  'سهل': GameDifficulty.easy,
  'متوسط': GameDifficulty.medium,
  'صعب': GameDifficulty.hard,
  'خبير': GameDifficulty.expert,
};

class KitchenGameScreen extends StatefulWidget {
  const KitchenGameScreen({super.key});
  @override
  State<KitchenGameScreen> createState() => _KitchenGameScreenState();
}

class _KitchenGameScreenState extends State<KitchenGameScreen>
    with GameScreenMixin {
  @override
  String get gameId => 'g09';

  @override
  String get guideText =>
      'أنا فارس! هذه وجبة لذيذة، ساعدني أجمع مكوناتها! اضغط على كل مكون صحيح من مكونات الوجبة!';

  GameDifficulty _difficulty = GameDifficulty.easy;
  late List<GameRound> _rounds;
  int _roundIndex = 0;
  int _score = 0;
  String _message = 'ما مكونات الوجبة؟';
  final Set<int> _caught = {};
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _rounds = GameEngine.buildKitchenRounds(
      count: 5,
      difficulty: _difficulty,
    );
    initGuide();
  }

  GameRound get _round => _rounds[_roundIndex];

  KitchenMeal get _meal => kitchenMeals.firstWhere(
    (m) => m.name == _round.payload,
    orElse: () => kitchenMeals.first,
  );

  void _changeDifficulty(GameDifficulty d) {
    setState(() {
      _difficulty = d;
      _rounds = GameEngine.buildKitchenRounds(count: 5, difficulty: d);
      _roundIndex = 0;
      _score = 0;
      _caught.clear();
      _locked = false;
      _message = 'ما مكونات الوجبة؟';
    });
  }

  String _emojiOf(String foodName) => kitchenFoods
      .firstWhere((f) => f.name == foodName, orElse: () => kitchenFoods.first)
      .emoji;

  Future<void> _tapFood(int i) async {
    if (_locked || _caught.contains(i)) return;
    if (_round.correct.contains(i)) {
      setState(() {
        _caught.add(i);
        _message = 'صح! ${_round.options[i]} من مكونات الوجبة!';
      });
      await AppSound.instance.speak('صح!');
      if (!mounted) return;
      if (_caught.length >= _round.correct.length) {
        setState(() {
          _locked = true;
          _score++;
        });
        await AppSound.instance.praise(_score);
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        if (_roundIndex + 1 >= _rounds.length) {
          await _finish();
        } else {
          setState(() {
            _roundIndex++;
            _caught.clear();
            _locked = false;
            _message = 'ما مكونات الوجبة؟';
          });
        }
      }
    } else {
      setState(() => _message = 'هذا ليس من مكونات الوجبة، حاول مرة أخرى!');
      await AppSound.instance.speak('حاول مرة أخرى يا بطل!');
    }
  }

  Future<void> _finish() async {
    await GameEngine.completeGame('g09');
    if (!mounted) return;
    final replay = await showGameDoneDialog(context, gameName: 'مطبخ فارس');
    if (!mounted) return;
    if (replay == true) {
      setState(() {
        _rounds = GameEngine.buildKitchenRounds(
          count: 5,
          difficulty: _difficulty,
        );
        _roundIndex = 0;
        _score = 0;
        _caught.clear();
        _locked = false;
        _message = 'ما مكونات الوجبة؟';
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: Text(
          'مطبخ فارس — الجولة ${_roundIndex + 1} من ${_rounds.length}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
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
                for (final entry in kitchenLevels.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 18),
                      ),
                      selected: _difficulty == entry.value,
                      selectedColor: Colors.orange.shade200,
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
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      _meal.emoji,
                      style: const TextStyle(fontSize: 72),
                    ),
                    Text(
                      _round.question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'وجدت ${_caught.length} من ${_round.correct.length} مكونات',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemCount: _round.options.length,
              itemBuilder: (context, i) {
                final name = _round.options[i];
                final caught = _caught.contains(i);
                return ElevatedButton(
                  onPressed: () => _tapFood(i),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: caught ? Colors.green : Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        caught ? '✅' : _emojiOf(name),
                        style: const TextStyle(fontSize: 44),
                      ),
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20),
                      ),
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
