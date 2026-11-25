// G11 اكتشف العلاقة: صورة حيوان + سؤال عن بيئته أو غذائه؛
// على الطفل اختيار الإجابة المرتبطة بالحيوان.
import 'package:material_ui/material_ui.dart';

import '../../data/animals.dart';
import '../../services/app_sound.dart';
import '../../services/game_engine.dart';
import '../../utils/matching.dart';
import '../../widgets/animal_image.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/game_guide.dart';

const Map<String, GameDifficulty> relationLevels = {
  'سهل': GameDifficulty.easy,
  'متوسط': GameDifficulty.medium,
  'صعب': GameDifficulty.hard,
  'خبير': GameDifficulty.expert,
};

class RelationGameScreen extends StatefulWidget {
  const RelationGameScreen({super.key});
  @override
  State<RelationGameScreen> createState() => _RelationGameScreenState();
}

class _RelationGameScreenState extends State<RelationGameScreen>
    with GameScreenMixin {
  @override
  String get gameId => 'g11';

  @override
  String get guideText =>
      'أنا فارس! كل حيوان له بيت يعيش فيه وطعام يأكله! اكتشف العلاقة واختر الإجابة الصحيحة!';

  GameDifficulty _difficulty = GameDifficulty.easy;
  late List<GameRound> _rounds;
  int _roundIndex = 0;
  int _score = 0;
  String _message = 'اكتشف العلاقة!';
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _rounds = GameEngine.buildRelationRounds(
      count: 5,
      difficulty: _difficulty,
    );
    initGuide();
  }

  GameRound get _round => _rounds[_roundIndex];

  Animal get _animal => findAnimalByName(_round.payload!)!;

  void _changeDifficulty(GameDifficulty d) {
    setState(() {
      _difficulty = d;
      _rounds = GameEngine.buildRelationRounds(count: 5, difficulty: d);
      _roundIndex = 0;
      _score = 0;
      _locked = false;
      _message = 'اكتشف العلاقة!';
    });
  }

  Future<void> _choose(String value) async {
    if (_locked) return;
    if (_round.options[_round.correctIndex] == value) {
      setState(() {
        _locked = true;
        _score++;
        _message = 'صح! ${_animal.nameAr} $value';
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
          _message = 'اكتشف العلاقة!';
        });
      }
    } else {
      setState(() => _message = 'حاول مرة أخرى يا بطل!');
      await AppSound.instance.speak('حاول مرة أخرى يا بطل!');
    }
  }

  Future<void> _finish() async {
    await GameEngine.completeGame('g11');
    if (!mounted) return;
    final replay = await showGameDoneDialog(
      context,
      gameName: 'اكتشف العلاقة',
    );
    if (!mounted) return;
    if (replay == true) {
      setState(() {
        _rounds = GameEngine.buildRelationRounds(
          count: 5,
          difficulty: _difficulty,
        );
        _roundIndex = 0;
        _score = 0;
        _locked = false;
        _message = 'اكتشف العلاقة!';
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: Text(
          'اكتشف العلاقة — الجولة ${_roundIndex + 1} من ${_rounds.length}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.indigo,
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
                for (final entry in relationLevels.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 18),
                      ),
                      selected: _difficulty == entry.value,
                      selectedColor: Colors.indigo.shade200,
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
            animalImage(_animal, height: 200),
            const SizedBox(height: 8),
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
            for (final value in _round.options)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _choose(value),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Text(
                      value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
