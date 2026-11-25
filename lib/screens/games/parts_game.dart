// G10 أجزاء الحيوان: صورة حيوان + جزء مطلوب (رأس/جسم/أرجل/ذيل)؛
// على الطفل الضغط على اسم الجزء الصحيح، ثم يسمع وظيفته.
import 'package:material_ui/material_ui.dart';

import '../../data/animals.dart';
import '../../services/app_sound.dart';
import '../../services/game_engine.dart';
import '../../utils/matching.dart';
import '../../widgets/animal_image.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/game_guide.dart';

const Map<String, GameDifficulty> partsLevels = {
  'سهل': GameDifficulty.easy,
  'متوسط': GameDifficulty.medium,
  'صعب': GameDifficulty.hard,
  'خبير': GameDifficulty.expert,
};

class PartsGameScreen extends StatefulWidget {
  const PartsGameScreen({super.key});
  @override
  State<PartsGameScreen> createState() => _PartsGameScreenState();
}

class _PartsGameScreenState extends State<PartsGameScreen>
    with GameScreenMixin {
  @override
  String get gameId => 'g10';

  @override
  String get guideText =>
      'أنا فارس! لكل حيوان رأس وجسم وأرجل وذيل! سأسألك عن جزء، اضغط على اسمه الصحيح!';

  GameDifficulty _difficulty = GameDifficulty.easy;
  late List<GameRound> _rounds;
  int _roundIndex = 0;
  int _score = 0;
  String _message = 'اضغط على الجزء المطلوب!';
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _rounds = GameEngine.buildPartsRounds(count: 5, difficulty: _difficulty);
    initGuide();
  }

  GameRound get _round => _rounds[_roundIndex];

  Animal get _animal => findAnimalByName(_round.payload!.split(':').first)!;

  AnimalPart get _targetPart => animalParts.firstWhere(
    (p) => p.key == _round.payload!.split(':').last,
  );

  void _changeDifficulty(GameDifficulty d) {
    setState(() {
      _difficulty = d;
      _rounds = GameEngine.buildPartsRounds(count: 5, difficulty: d);
      _roundIndex = 0;
      _score = 0;
      _locked = false;
      _message = 'اضغط على الجزء المطلوب!';
    });
  }

  Future<void> _choose(String name) async {
    if (_locked) return;
    if (_round.options[_round.correctIndex] == name) {
      setState(() {
        _locked = true;
        _score++;
        _message = _targetPart.function;
      });
      await AppSound.instance.praise(_score);
      await AppSound.instance.speak(_targetPart.function);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      if (_roundIndex + 1 >= _rounds.length) {
        await _finish();
      } else {
        setState(() {
          _roundIndex++;
          _locked = false;
          _message = 'اضغط على الجزء المطلوب!';
        });
      }
    } else {
      setState(() => _message = 'حاول مرة أخرى يا بطل!');
      await AppSound.instance.speak('حاول مرة أخرى يا بطل!');
    }
  }

  Future<void> _finish() async {
    await GameEngine.completeGame('g10');
    if (!mounted) return;
    final replay = await showGameDoneDialog(context, gameName: 'أجزاء الحيوان');
    if (!mounted) return;
    if (replay == true) {
      setState(() {
        _rounds = GameEngine.buildPartsRounds(count: 5, difficulty: _difficulty);
        _roundIndex = 0;
        _score = 0;
        _locked = false;
        _message = 'اضغط على الجزء المطلوب!';
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: Text(
          'أجزاء الحيوان — الجولة ${_roundIndex + 1} من ${_rounds.length}',
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
                for (final entry in partsLevels.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 18),
                      ),
                      selected: _difficulty == entry.value,
                      selectedColor: Colors.teal.shade200,
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
              _animal.nameAr,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
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
                final name = _round.options[i];
                final part = animalParts.firstWhere((p) => p.name == name);
                return ElevatedButton(
                  onPressed: () => _choose(name),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(part.icon, size: 40),
                      Text(name, style: const TextStyle(fontSize: 26)),
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
