// تعلّم الحروف والأرقام — نُقلت من lib/main.dart دون تغيير (المرحلة الثانية 2.3).
import 'package:material_ui/material_ui.dart';

import '../data/animals.dart';
import '../data/letters.dart';
import '../services/app_sound.dart';
import '../services/game_engine.dart';
import '../services/progress_store.dart';
import '../utils/matching.dart';
import '../widgets/animal_image.dart';
import '../widgets/app_footer.dart';
import '../widgets/big_button.dart';
import '../widgets/game_guide.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.blue.shade50,
      appBar: AppBar(
        title: const Text(
          'تعلّم',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.school,
                label: 'الحروف العربية',
                color: Colors.orange,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ArabicLettersScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.translate,
                label: 'الحروف الإنجليزية',
                color: Colors.purple,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EnglishLettersScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.calculate,
                label: 'الأرقام 1 - 20',
                color: Colors.green,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NumbersScreen()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.format_list_numbered,
                label: 'لعبة العدّ',
                color: Colors.pink,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CountingGameScreen()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ArabicLettersScreen extends StatefulWidget {
  const ArabicLettersScreen({super.key});
  @override
  State<ArabicLettersScreen> createState() => _ArabicLettersScreenState();
}

class _ArabicLettersScreenState extends State<ArabicLettersScreen> {
  final Set<String> _done = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final done = <String>{};
    for (final l in arabicLetters) {
      if (await ProgressStore.isReligion('letter_ar_${l.letter}')) {
        done.add(l.letter);
      }
    }
    if (mounted) setState(() => _done.addAll(done));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      appBar: AppBar(
        title: const Text(
          'الحروف العربية',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: arabicLetters.length,
        itemBuilder: (context, i) {
          final l = arabicLetters[i];
          final done = _done.contains(l.letter);
          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArabicLetterDetailScreen(letter: l),
              ),
            ).then((_) => _load()),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      l.letter,
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  if (done)
                    const Positioned(
                      top: 4,
                      left: 4,
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 26,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ArabicLetterDetailScreen extends StatefulWidget {
  final ArabicLetter letter;
  const ArabicLetterDetailScreen({super.key, required this.letter});
  @override
  State<ArabicLetterDetailScreen> createState() =>
      _ArabicLetterDetailScreenState();
}

class _ArabicLetterDetailScreenState extends State<ArabicLetterDetailScreen> {
  bool _learned = false;

  @override
  void initState() {
    super.initState();
    ProgressStore.isReligion('letter_ar_${widget.letter.letter}')
        .then((v) => mounted ? setState(() => _learned = v) : null);
  }

  @override
  void dispose() {
    AppSound.instance.stopAll();
    super.dispose();
  }

  Future<void> _markLearned() async {
    if (_learned) return;
    await ProgressStore.markReligion('letter_ar_${widget.letter.letter}');
    await ProgressStore.awardStarsOnce('letter_ar_${widget.letter.letter}', 1);
    if (mounted) setState(() => _learned = true);
    await AppSound.instance.praise();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.letter;
    final animal = l.animalName != null
        ? findAnimalByName(l.animalName!)
        : null;
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      appBar: AppBar(
        title: Text(
          'حرف ${l.letter}',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.letter,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 120,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            Text(
              '${l.letterName} — ${l.word}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (animal != null)
              animalImage(animal, height: 220)
            else if (l.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  l.imageUrl!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => const SizedBox(
                    height: 220,
                    child: Center(child: Icon(Icons.image, size: 80)),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  AppSound.instance.speak('${l.letterName}، ${l.word}'),
              icon: const Icon(Icons.volume_up, size: 32),
              label: const Text('اسمع الحرف', style: TextStyle(fontSize: 26)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _markLearned,
              icon: Icon(_learned ? Icons.star : Icons.star_border, size: 32),
              label: Text(
                _learned ? 'تعلمته! أحسنت' : 'تعلمته',
                style: const TextStyle(fontSize: 26),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EnglishLettersScreen extends StatefulWidget {
  const EnglishLettersScreen({super.key});
  @override
  State<EnglishLettersScreen> createState() => _EnglishLettersScreenState();
}

class _EnglishLettersScreenState extends State<EnglishLettersScreen> {
  final Set<String> _done = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final done = <String>{};
    for (final l in englishLetters) {
      if (await ProgressStore.isReligion('letter_en_${l.letter}')) {
        done.add(l.letter);
      }
    }
    if (mounted) setState(() => _done.addAll(done));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      appBar: AppBar(
        title: const Text(
          'الحروف الإنجليزية',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: englishLetters.length,
          itemBuilder: (context, i) {
            final l = englishLetters[i];
            final done = _done.contains(l.letter);
            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EnglishLetterDetailScreen(letter: l),
                ),
              ).then((_) => _load()),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${l.letter} ${l.letter.toLowerCase()}',
                          softWrap: false,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                    ),
                    if (done)
                      const Positioned(
                        top: 4,
                        left: 4,
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 26,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class EnglishLetterDetailScreen extends StatefulWidget {
  final EnglishLetter letter;
  const EnglishLetterDetailScreen({super.key, required this.letter});
  @override
  State<EnglishLetterDetailScreen> createState() =>
      _EnglishLetterDetailScreenState();
}

/// أيقونة Material موحدة لرسم الكلمة الإنجليزية (بدل الإيموجي).
IconData _englishLetterIcon(String letter) {
  switch (letter) {
    case 'B':
      return Icons.sports_soccer;
    case 'C':
    case 'D':
    case 'E':
    case 'G':
    case 'H':
    case 'L':
    case 'M':
    case 'P':
    case 'R':
    case 'T':
    case 'Z':
      return Icons.pets;
    case 'F':
    case 'W':
      return Icons.waves;
    case 'I':
      return Icons.icecream;
    case 'J':
      return Icons.local_drink;
    case 'K':
      return Icons.navigation;
    case 'N':
      return Icons.eco;
    case 'O':
      return Icons.circle;
    case 'Q':
      return Icons.person;
    case 'S':
      return Icons.wb_sunny;
    case 'U':
      return Icons.umbrella;
    case 'V':
      return Icons.music_note;
    case 'X':
      return Icons.inventory_2;
    case 'Y':
      return Icons.sports_baseball;
    default:
      return Icons.abc;
  }
}

class _EnglishLetterDetailScreenState extends State<EnglishLetterDetailScreen> {
  bool _learned = false;

  @override
  void initState() {
    super.initState();
    ProgressStore.isReligion('letter_en_${widget.letter.letter}')
        .then((v) => mounted ? setState(() => _learned = v) : null);
  }

  @override
  void dispose() {
    AppSound.instance.stopAll();
    super.dispose();
  }

  Future<void> _markLearned() async {
    if (_learned) return;
    await ProgressStore.markReligion('letter_en_${widget.letter.letter}');
    await ProgressStore.awardStarsOnce('letter_en_${widget.letter.letter}', 1);
    if (mounted) setState(() => _learned = true);
    await AppSound.instance.praise();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.letter;
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      appBar: AppBar(
        title: Text(
          'Letter ${l.letter}',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(_englishLetterIcon(l.letter), size: 100, color: Colors.purple),
            Text(
              '${l.letter} ${l.letter.toLowerCase()}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 110,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            Text(
              l.word,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  AppSound.instance.speakEnglish('${l.letter}. ${l.word}'),
              icon: const Icon(Icons.volume_up, size: 32),
              label: const Text('اسمع الحرف', style: TextStyle(fontSize: 26)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _markLearned,
              icon: Icon(_learned ? Icons.star : Icons.star_border, size: 32),
              label: Text(
                _learned ? 'تعلمته! أحسنت' : 'تعلمته',
                style: const TextStyle(fontSize: 26),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NumbersScreen extends StatefulWidget {
  const NumbersScreen({super.key});
  @override
  State<NumbersScreen> createState() => _NumbersScreenState();
}

class _NumbersScreenState extends State<NumbersScreen> {
  final Set<int> _done = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final done = <int>{};
    for (final n in numbers) {
      if (await ProgressStore.isReligion('number_${n.value}')) {
        done.add(n.value);
      }
    }
    if (mounted) setState(() => _done.addAll(done));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      appBar: AppBar(
        title: const Text(
          'الأرقام 1 - 20',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: numbers.length,
          itemBuilder: (context, i) {
            final n = numbers[i];
            final done = _done.contains(n.value);
            return InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NumberDetailScreen(number: n),
                ),
              ).then((_) => _load()),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        '${n.value}',
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    if (done)
                      const Positioned(
                        top: 4,
                        left: 4,
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 26,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class NumberDetailScreen extends StatefulWidget {
  final NumberItem number;
  const NumberDetailScreen({super.key, required this.number});
  @override
  State<NumberDetailScreen> createState() => _NumberDetailScreenState();
}

class _NumberDetailScreenState extends State<NumberDetailScreen> {
  bool _learned = false;

  @override
  void initState() {
    super.initState();
    ProgressStore.isReligion('number_${widget.number.value}')
        .then((v) => mounted ? setState(() => _learned = v) : null);
  }

  @override
  void dispose() {
    AppSound.instance.stopAll();
    super.dispose();
  }

  Future<void> _markLearned() async {
    if (_learned) return;
    await ProgressStore.markReligion('number_${widget.number.value}');
    await ProgressStore.awardStarsOnce('number_${widget.number.value}', 1);
    if (mounted) setState(() => _learned = true);
    await AppSound.instance.praise();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.number;
    final animal = findAnimalByName(n.animalName);
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      appBar: AppBar(
        title: Text(
          'العدد ${n.value}',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${n.value}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 110,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              '${n.arWord} — ${n.enWord}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'هيا نعدّ ${n.value} ${n.animalName}!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 12),
            if (animal != null)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: n.value,
                itemBuilder: (context, i) => animalImage(animal, height: 80),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        AppSound.instance.speak('${n.arWord}، ${n.value}'),
                    icon: const Icon(Icons.volume_up, size: 28),
                    label: const Text(
                      'بالعربية',
                      style: TextStyle(fontSize: 22),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => AppSound.instance.speakEnglish(n.enWord),
                    icon: const Icon(Icons.volume_up, size: 28),
                    label: const Text(
                      'English',
                      style: TextStyle(fontSize: 22),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _markLearned,
              icon: Icon(_learned ? Icons.star : Icons.star_border, size: 32),
              label: Text(
                _learned ? 'تعلمته! أحسنت' : 'تعلمته',
                style: const TextStyle(fontSize: 26),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// G05 عدّ مع فارس — توسيع لعبة العدّ: 3 مستويات (حتى 5 / 10 / 20)،
// 5 جولات من محرك الألعاب، نجمة عند الإكمال، بلا خصم أبداً.
// (كانت جولات لا نهائية بلا مستويات وبلا نهاية؛ مفتاح النجمة القديم
// 'game_counting_win' استُبدل بنجمة الإكمال الموحدة 'game_g05'.)
class CountingGameScreen extends StatefulWidget {
  const CountingGameScreen({super.key});
  @override
  State<CountingGameScreen> createState() => _CountingGameScreenState();
}

/// مستويات العدّ: الحد الأقصى للعدد في الجولة.
const Map<String, int> countingLevels = {
  'سهل': 5,
  'متوسط': 10,
  'صعب': 20,
};

class _CountingGameScreenState extends State<CountingGameScreen>
    with GameScreenMixin {
  @override
  String get gameId => 'g05';

  @override
  String get guideText =>
      'أنا فارس! عدّ الحيوانات في الصورة، واضغط على العدد الصحيح!';

  late List<GameRound> _rounds;
  int _roundIndex = 0;
  int _max = 10;
  int _score = 0;
  String _message = 'كم عدد الحيوانات؟';
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _rounds = GameEngine.buildCountingRounds(max: _max, count: 5);
    initGuide();
  }

  GameRound get _round => _rounds[_roundIndex];
  int get _target => int.parse(_round.options[_round.correctIndex]);
  Animal get _animal =>
      findAnimalByName(_round.payload ?? '') ?? animals[0];

  void _setLevel(int max) {
    if (max == _max) return;
    setState(() {
      _max = max;
      _rounds = GameEngine.buildCountingRounds(max: _max, count: 5);
      _roundIndex = 0;
      _score = 0;
      _locked = false;
      _message = 'كم عدد الحيوانات؟';
    });
  }

  Future<void> _choose(int v) async {
    if (_locked) return;
    if (v == _target) {
      setState(() {
        _locked = true;
        _score++;
        _message = 'صح! العدد هو $_target';
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
          _message = 'كم عدد الحيوانات؟';
        });
      }
    } else {
      setState(() => _message = 'حاول مرة أخرى يا بطل!');
      await AppSound.instance.speak('حاول مرة أخرى يا بطل!');
    }
  }

  Future<void> _finish() async {
    await GameEngine.completeGame('g05');
    if (!mounted) return;
    final replay = await showGameDoneDialog(context, gameName: 'عدّ مع فارس');
    if (!mounted) return;
    if (replay == true) {
      setState(() {
        _rounds = GameEngine.buildCountingRounds(max: _max, count: 5);
        _roundIndex = 0;
        _score = 0;
        _locked = false;
        _message = 'كم عدد الحيوانات؟';
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      appBar: AppBar(
        title: Text(
          'عدّ مع فارس — الجولة ${_roundIndex + 1} من ${_rounds.length}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink,
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
            // مستويات العدّ: تغيير المستوى يعيد اللعبة من الجولة الأولى.
            Row(
              children: [
                for (final entry in countingLevels.entries)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        onPressed: () => _setLevel(entry.value),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _max == entry.value
                              ? Colors.pink
                              : Colors.grey.shade300,
                          foregroundColor: _max == entry.value
                              ? Colors.white
                              : Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          '${entry.key} (حتى ${entry.value})',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // الشبكة بمقاس محسوب من عدد العناصر، بلا فراغ كبير.
            SizedBox(
              height:
                  ((_target + 4) ~/ 5) * 72.0 +
                  (((_target + 4) ~/ 5) - 1) * 8.0,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _target,
                itemBuilder: (context, i) => animalImage(_animal, height: 64),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _message,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final o in _round.options)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ElevatedButton(
                        onPressed: () => _choose(int.parse(o)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
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

