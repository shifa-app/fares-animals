// G01 صائد الظلال: ظل حيوان مرسوم أصلاً (CustomPainter) + 4 أسماء؛
// على الطفل معرفة صاحب الظل. 5 جولات، نجمة عند الإكمال، بلا خصم أبداً.
import 'package:material_ui/material_ui.dart';

import '../../services/app_sound.dart';
import '../../services/game_engine.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/game_guide.dart';
import '../../widgets/game_painters.dart';

class ShadowGameScreen extends StatefulWidget {
  const ShadowGameScreen({super.key});
  @override
  State<ShadowGameScreen> createState() => _ShadowGameScreenState();
}

class _ShadowGameScreenState extends State<ShadowGameScreen>
    with GameScreenMixin {
  @override
  String get gameId => 'g01';

  @override
  String get guideText =>
      'أنا فارس! انظر إلى الظل الأسود، وخمّن: ما الحيوان صاحب هذا الظل؟ اضغط على اسمه!';

  late List<GameRound> _rounds;
  int _roundIndex = 0;
  int _score = 0;
  String _message = 'ما صاحب هذا الظل؟';
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _rounds = GameEngine.buildShadowRounds(count: 5);
    initGuide();
  }

  GameRound get _round => _rounds[_roundIndex];

  Future<void> _choose(String name) async {
    if (_locked) return;
    if (_round.options[_round.correctIndex] == name) {
      setState(() {
        _locked = true;
        _score++;
        _message = 'صح! هذا ظل الـ $name';
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
          _message = 'ما صاحب هذا الظل؟';
        });
      }
    } else {
      setState(() => _message = 'حاول مرة أخرى يا بطل!');
      await AppSound.instance.speak('حاول مرة أخرى يا بطل!');
    }
  }

  Future<void> _finish() async {
    await GameEngine.completeGame('g01');
    if (!mounted) return;
    final replay = await showGameDoneDialog(context, gameName: 'صائد الظلال');
    if (!mounted) return;
    if (replay == true) {
      setState(() {
        _rounds = GameEngine.buildShadowRounds(count: 5);
        _roundIndex = 0;
        _score = 0;
        _locked = false;
        _message = 'ما صاحب هذا الظل؟';
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shadow = shadowAnimals.firstWhere(
      (s) => s.id == _round.payload,
      orElse: () => shadowAnimals.first,
    );
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.brown.shade50,
      appBar: AppBar(
        title: Text(
          'صائد الظلال — الجولة ${_roundIndex + 1} من ${_rounds.length}',
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
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.brown.shade200, width: 3),
              ),
              child: CustomPaint(
                painter: ShadowPainter(shadow.id),
                size: const Size(240, 240),
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
                childAspectRatio: 1.8,
              ),
              itemCount: _round.options.length,
              itemBuilder: (context, i) {
                final name = _round.options[i];
                final emoji = shadowAnimals
                    .firstWhere((s) => s.name == name,
                        orElse: () => shadowAnimals.first)
                    .emoji;
                return ElevatedButton(
                  onPressed: () => _choose(name),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    '$emoji $name',
                    style: const TextStyle(fontSize: 28),
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
