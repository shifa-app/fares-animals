// G04 عالم الأشكال: شكل ملوّن مرسوم أصلاً (CustomPainter) + 4 أسماء؛
// على الطفل معرفة اسم الشكل. 5 جولات، نجمة عند الإكمال، بلا خصم أبداً.
import 'package:material_ui/material_ui.dart';

import '../../services/app_sound.dart';
import '../../services/game_engine.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/game_guide.dart';
import '../../widgets/game_painters.dart';

/// لون ثابت لكل شكل حتى يتعلمه الطفل مرتبطاً بلونه.
const Map<String, Color> shapeColors = {
  'circle': Colors.red,
  'square': Colors.blue,
  'triangle': Colors.green,
  'star': Colors.amber,
  'rectangle': Colors.teal,
  'heart': Colors.pink,
  'diamond': Colors.deepPurple,
  'oval': Colors.orange,
};

class ShapeGameScreen extends StatefulWidget {
  const ShapeGameScreen({super.key});
  @override
  State<ShapeGameScreen> createState() => _ShapeGameScreenState();
}

class _ShapeGameScreenState extends State<ShapeGameScreen>
    with GameScreenMixin {
  @override
  String get gameId => 'g04';

  @override
  String get guideText =>
      'أنا فارس! انظر إلى الشكل الملوّن، وخمّن: ما اسم هذا الشكل؟ اضغط على اسمه!';

  late List<GameRound> _rounds;
  int _roundIndex = 0;
  int _score = 0;
  String _message = 'ما هذا الشكل؟';
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _rounds = GameEngine.buildShapeRounds(count: 5);
    initGuide();
  }

  GameRound get _round => _rounds[_roundIndex];

  Future<void> _choose(String name) async {
    if (_locked) return;
    if (_round.options[_round.correctIndex] == name) {
      setState(() {
        _locked = true;
        _score++;
        _message = 'صح! هذا هو الـ $name';
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
          _message = 'ما هذا الشكل؟';
        });
      }
    } else {
      setState(() => _message = 'حاول مرة أخرى يا بطل!');
      await AppSound.instance.speak('حاول مرة أخرى يا بطل!');
    }
  }

  Future<void> _finish() async {
    await GameEngine.completeGame('g04');
    if (!mounted) return;
    final replay = await showGameDoneDialog(context, gameName: 'عالم الأشكال');
    if (!mounted) return;
    if (replay == true) {
      setState(() {
        _rounds = GameEngine.buildShapeRounds(count: 5);
        _roundIndex = 0;
        _score = 0;
        _locked = false;
        _message = 'ما هذا الشكل؟';
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
          'عالم الأشكال — الجولة ${_roundIndex + 1} من ${_rounds.length}',
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
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.indigo.shade200, width: 3),
              ),
              child: CustomPaint(
                painter: ShapePainter(
                  shape: _round.payload ?? 'circle',
                  color: shapeColors[_round.payload] ?? Colors.indigo,
                ),
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
                return ElevatedButton(
                  onPressed: () => _choose(name),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    name,
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
