// G02 وصّل الحروف والصور: حرف كبير + 4 صور حيوانات؛
// على الطفل اختيار الحيوان الذي يبدأ اسمه بالحرف.
// 5 جولات، نجمة عند الإكمال، بلا خصم أبداً.
import 'package:material_ui/material_ui.dart';

import '../../services/app_sound.dart';
import '../../services/game_engine.dart';
import '../../utils/matching.dart';
import '../../widgets/animal_image.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/game_guide.dart';

class LetterGameScreen extends StatefulWidget {
  const LetterGameScreen({super.key});
  @override
  State<LetterGameScreen> createState() => _LetterGameScreenState();
}

class _LetterGameScreenState extends State<LetterGameScreen>
    with GameScreenMixin {
  @override
  String get gameId => 'g02';

  @override
  String get guideText =>
      'أنا فارس! انظر إلى الحرف الكبير، واضغط على صورة الحيوان الذي يبدأ اسمه بهذا الحرف!';

  late List<GameRound> _rounds;
  int _roundIndex = 0;
  int _score = 0;
  String _message = 'أي حيوان يبدأ بهذا الحرف؟';
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _rounds = GameEngine.buildLetterRounds(count: 5);
    initGuide();
  }

  GameRound get _round => _rounds[_roundIndex];

  Future<void> _choose(String name) async {
    if (_locked) return;
    if (_round.options[_round.correctIndex] == name) {
      setState(() {
        _locked = true;
        _score++;
        _message = 'صح! $name يبدأ بحرف ${_round.payload}';
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
          _message = 'أي حيوان يبدأ بهذا الحرف؟';
        });
      }
    } else {
      setState(() => _message = 'حاول مرة أخرى يا بطل!');
      await AppSound.instance.speak('حاول مرة أخرى يا بطل!');
    }
  }

  Future<void> _finish() async {
    await GameEngine.completeGame('g02');
    if (!mounted) return;
    final replay = await showGameDoneDialog(
      context,
      gameName: 'وصّل الحروف والصور',
    );
    if (!mounted) return;
    if (replay == true) {
      setState(() {
        _rounds = GameEngine.buildLetterRounds(count: 5);
        _roundIndex = 0;
        _score = 0;
        _locked = false;
        _message = 'أي حيوان يبدأ بهذا الحرف؟';
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
          'وصّل الحروف والصور — الجولة ${_roundIndex + 1} من ${_rounds.length}',
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
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.indigo.shade200, width: 3),
              ),
              child: Center(
                child: Text(
                  _round.payload ?? '?',
                  style: TextStyle(
                    fontSize: 100,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _message,
              textAlign: TextAlign.center,
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
                childAspectRatio: 0.85,
              ),
              itemCount: _round.options.length,
              itemBuilder: (context, i) {
                final name = _round.options[i];
                final animal = findAnimalByName(name);
                return InkWell(
                  onTap: () => _choose(name),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: animal == null
                              ? const Icon(Icons.pets, size: 80)
                              : animalImage(animal, height: 120),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 22,
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
          ],
        ),
      ),
    );
  }
}
