// G13 المس واكتشف: تعليمة صوتية «المس الحيوان!» + شبكة صور؛
// على الطفل لمس صورة الحيوان المطلوب (بلا أسماء مكتوبة —
// التعرف بصري وسمعي لتدريب الانتباه).
import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../services/app_sound.dart';
import '../../services/game_engine.dart';
import '../../utils/matching.dart';
import '../../widgets/animal_image.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/game_guide.dart';

const Map<String, GameDifficulty> touchLevels = {
  'سهل': GameDifficulty.easy,
  'متوسط': GameDifficulty.medium,
  'صعب': GameDifficulty.hard,
  'خبير': GameDifficulty.expert,
};

class TouchGameScreen extends StatefulWidget {
  const TouchGameScreen({super.key});
  @override
  State<TouchGameScreen> createState() => _TouchGameScreenState();
}

class _TouchGameScreenState extends State<TouchGameScreen>
    with GameScreenMixin {
  @override
  String get gameId => 'g13';

  @override
  String get guideText =>
      'أنا فارس! سأقول لك اسم حيوان، المس صورته بسرعة! انتبه جيداً واسمع!';

  GameDifficulty _difficulty = GameDifficulty.easy;
  late List<GameRound> _rounds;
  int _roundIndex = 0;
  int _score = 0;
  String _message = 'اسمع وانتبه!';
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _rounds = GameEngine.buildTouchRounds(count: 5, difficulty: _difficulty);
    initGuide().then((_) {
      if (mounted) unawaited(_speakInstruction());
    });
  }

  GameRound get _round => _rounds[_roundIndex];

  Future<void> _speakInstruction() =>
      AppSound.instance.speak(_round.question);

  void _changeDifficulty(GameDifficulty d) {
    setState(() {
      _difficulty = d;
      _rounds = GameEngine.buildTouchRounds(count: 5, difficulty: d);
      _roundIndex = 0;
      _score = 0;
      _locked = false;
      _message = 'اسمع وانتبه!';
    });
    unawaited(_speakInstruction());
  }

  Future<void> _choose(String name) async {
    if (_locked) return;
    if (_round.options[_round.correctIndex] == name) {
      setState(() {
        _locked = true;
        _score++;
        _message = 'صح! هذا هو $name';
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
          _message = 'اسمع وانتبه!';
        });
        await _speakInstruction();
      }
    } else {
      setState(() => _message = 'حاول مرة أخرى يا بطل!');
      await AppSound.instance.speak('حاول مرة أخرى يا بطل!');
    }
  }

  Future<void> _finish() async {
    await GameEngine.completeGame('g13');
    if (!mounted) return;
    final replay = await showGameDoneDialog(context, gameName: 'المس واكتشف');
    if (!mounted) return;
    if (replay == true) {
      setState(() {
        _rounds = GameEngine.buildTouchRounds(count: 5, difficulty: _difficulty);
        _roundIndex = 0;
        _score = 0;
        _locked = false;
        _message = 'اسمع وانتبه!';
      });
      await _speakInstruction();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final columns = _round.options.length >= 9 ? 3 : 2;
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.cyan.shade50,
      appBar: AppBar(
        title: Text(
          'المس واكتشف — الجولة ${_roundIndex + 1} من ${_rounds.length}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.cyan,
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
                for (final entry in touchLevels.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 18),
                      ),
                      selected: _difficulty == entry.value,
                      selectedColor: Colors.cyan.shade200,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    _round.question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 40),
                  tooltip: 'اسمع التعليمة',
                  onPressed: () => unawaited(_speakInstruction()),
                ),
              ],
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
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _round.options.length,
              itemBuilder: (context, i) {
                final animal = findAnimalByName(_round.options[i])!;
                return InkWell(
                  onTap: () => _choose(animal.nameAr),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.cyan.shade200,
                        width: 3,
                      ),
                    ),
                    child: animalImage(animal, height: 120),
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
