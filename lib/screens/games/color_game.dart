// G03 صياد الألوان: 9 نقاط ملونة فيها 3 من اللون المطلوب؛
// على الطفل اصطياد النقاط الثلاث. 5 جولات، نجمة عند الإكمال، بلا خصم أبداً.
import 'package:material_ui/material_ui.dart';

import '../../services/app_sound.dart';
import '../../services/game_engine.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/game_guide.dart';

class ColorGameScreen extends StatefulWidget {
  const ColorGameScreen({super.key});
  @override
  State<ColorGameScreen> createState() => _ColorGameScreenState();
}

class _ColorGameScreenState extends State<ColorGameScreen>
    with GameScreenMixin {
  @override
  String get gameId => 'g03';

  @override
  String get guideText =>
      'أنا فارس! انظر إلى اللون المطلوب، واضغط على كل النقاط بهذا اللون حتى تصطادها كلها!';

  late List<GameRound> _rounds;
  int _roundIndex = 0;
  int _score = 0;
  final Set<int> _caught = {};
  String _message = 'اصطد اللون المطلوب!';
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _rounds = GameEngine.buildColorRounds(count: 5);
    _message = _rounds.first.question;
    initGuide();
  }

  GameRound get _round => _rounds[_roundIndex];

  Color _colorOf(String key) =>
      gameColors.firstWhere((c) => c.key == key).color;

  Future<void> _tapDot(int i) async {
    if (_locked || _caught.contains(i)) return;
    if (_round.correct.contains(i)) {
      setState(() => _caught.add(i));
      if (_caught.length >= _round.correct.length) {
        setState(() {
          _locked = true;
          _score++;
          _message = 'صح! اصطدت اللون كله!';
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
            _message = _rounds[_roundIndex].question;
          });
        }
      }
    } else {
      setState(() => _message = 'حاول مرة أخرى يا بطل!');
      await AppSound.instance.speak('حاول مرة أخرى يا بطل!');
    }
  }

  Future<void> _finish() async {
    await GameEngine.completeGame('g03');
    if (!mounted) return;
    final replay = await showGameDoneDialog(context, gameName: 'صياد الألوان');
    if (!mounted) return;
    if (replay == true) {
      setState(() {
        _rounds = GameEngine.buildColorRounds(count: 5);
        _roundIndex = 0;
        _score = 0;
        _caught.clear();
        _locked = false;
        _message = _rounds.first.question;
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
          'صياد الألوان — الجولة ${_roundIndex + 1} من ${_rounds.length}',
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
              _round.question,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: _round.options.length,
              itemBuilder: (context, i) {
                final caught = _caught.contains(i);
                return GestureDetector(
                  onTap: () => _tapDot(i),
                  child: Center(
                    child: caught
                        ? const Icon(
                            Icons.star,
                            size: 72,
                            color: Colors.amber,
                          )
                        : Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              color: _colorOf(_round.options[i]),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
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
