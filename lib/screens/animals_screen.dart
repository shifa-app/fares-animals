// الحيوانات وتفاصيل الحيوان — نُقلت من lib/main.dart دون تغيير (المرحلة الثانية 2.3).
import 'package:material_ui/material_ui.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../data/animal_science.dart';
import '../data/animals.dart';
import '../services/app_sound.dart';
import '../services/progress_store.dart';
import '../utils/matching.dart';
import '../widgets/animal_image.dart';
import '../widgets/app_footer.dart';
import 'compare_screen.dart';
import 'group_quiz_screen.dart';

// ---------------- الحيوانات ----------------

class AnimalsScreen extends StatefulWidget {
  /// فئة البداية (مثلاً من عالم فارس)؛ الافتراضي 'all' (كل الحيوانات).
  final String initialCategory;
  const AnimalsScreen({super.key, this.initialCategory = 'all'});
  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  late String _category = widget.initialCategory;
  bool _byScience = false;
  String _query = '';
  final Set<String> _learned = {};
  final Set<String> _favorites = {};
  final SpeechToText _speech = SpeechToText();
  bool _listening = false;
  String _heard = '';
  String _message = 'اضغط الميكروفون وقل اسم حيوان!';

  @override
  void initState() {
    super.initState();
    _loadLearned();
  }

  Future<void> _loadLearned() async {
    final learned = <String>{};
    for (final a in animals) {
      if (await ProgressStore.isLearned(a.nameAr)) learned.add(a.nameAr);
    }
    final favorites = (await ProgressStore.favorites()).toSet();
    if (mounted) {
      setState(() {
        _learned.addAll(learned);
        _favorites
          ..clear()
          ..addAll(favorites);
      });
    }
  }

  /// حيوانات المجموعة المختارة دون تصفية البحث.
  List<Animal> get _groupAnimals {
    if (_category == 'all') return animals;
    if (_category == 'favorites') {
      return animals.where((a) => _favorites.contains(a.nameAr)).toList();
    }
    if (_byScience) {
      return animals
          .where((a) => scienceFor(a)?.sciClass.name == _category)
          .toList();
    }
    return animals.where((a) => a.category == _category).toList();
  }

  String get _groupLabel {
    if (_byScience) {
      return SciClass.values
          .firstWhere((c) => c.name == _category)
          .label;
    }
    return categoryLabels[_category] ?? '';
  }

  List<Animal> get _shown {
    final byCat = _groupAnimals;
    final q = _query.trim();
    if (q.isEmpty) return byCat;
    final nq = normalizeArabic(q);
    final lq = q.toLowerCase();
    return byCat
        .where(
          (a) =>
              normalizeArabic(a.nameAr).contains(nq) ||
              a.nameEn.toLowerCase().contains(lq),
        )
        .toList();
  }

  Future<void> _listen() async {
    final available = await _speech.initialize();
    if (!available) {
      setState(() => _message = 'الميكروفون غير متاح، العب باللمس!');
      return;
    }
    setState(() {
      _listening = true;
      _message = 'أنا أسمعك... قل اسم الحيوان!';
    });
    await _speech.listen(
      listenOptions: SpeechListenOptions(
        localeId: 'ar_EG',
        listenFor: Duration(seconds: 10),
      ),
      onResult: (result) {
        if (!result.finalResult) return;
        final found = findAnimal(result.recognizedWords, animals);
        if (!mounted) return;
        setState(() {
          _listening = false;
          _heard = result.recognizedWords;
        });
        if (found != null) {
          setState(() => _message = 'وجدته! هذا هو ${found.nameAr}');
          AppSound.instance.praise();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AnimalDetailScreen(animal: found),
            ),
          );
        } else {
          setState(() => _message = 'لم أسمع جيداً، حاول مرة أخرى يا بطل!');
          AppSound.instance.speak('حاول مرة أخرى يا بطل!');
        }
      },
    );
  }

  @override
  void dispose() {
    _speech.stop();
    AppSound.instance.stopAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.amber.shade50,
      appBar: AppBar(
        title: const Text(
          'الحيوانات',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows, size: 32),
            tooltip: 'قارن بين حيوانين',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CompareScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _query = v),
                        decoration: InputDecoration(
                          hintText: 'ابحث عن حيوان...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: _listening ? null : _listen,
                      borderRadius: BorderRadius.circular(40),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: _listening ? Colors.red : Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _listening ? Icons.mic : Icons.mic_none,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _heard.isEmpty ? _message : 'سمعت: $_heard',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: false,
                  label: Text(
                    'حسب البيئة',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                ButtonSegment(
                  value: true,
                  label: Text(
                    'حسب التصنيف العلمي',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
              selected: {_byScience},
              onSelectionChanged: (s) => setState(() {
                _byScience = s.first;
                _category = 'all';
              }),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip('all', 'الكل (${animals.length})'),
                _chip('favorites', 'المفضلة (${_favorites.length})'),
                if (!_byScience)
                  for (final e in categoryLabels.entries) _chip(e.key, e.value)
                else
                  for (final c in SciClass.values)
                    _chip(c.name, '${c.label} (${_scienceCount(c)})'),
              ],
            ),
          ),
          if (_category != 'all' && _category != 'favorites')
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: _groupAnimals.length >= 3
                  ? ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupQuizScreen(
                            groupKey: _category,
                            groupLabel: _groupLabel,
                            animals: _groupAnimals,
                          ),
                        ),
                      ).then((_) => _loadLearned()),
                      icon: const Icon(Icons.quiz, size: 28),
                      label: Text(
                        'اختبر نفسك في $_groupLabel',
                        style: const TextStyle(fontSize: 22),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _shown.length,
              itemBuilder: (context, i) {
                final a = _shown[i];
                final learned = _learned.contains(a.nameAr);
                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnimalDetailScreen(animal: a),
                    ),
                  ).then((_) => _loadLearned()),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Expanded(child: animalImage(a, height: 140)),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                a.nameAr,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (learned)
                          const Positioned(
                            top: 6,
                            left: 6,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 30,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _scienceCount(SciClass c) =>
      animals.where((a) => scienceFor(a)?.sciClass == c).length;

  Widget _chip(String key, String label) {
    final selected = _category == key;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 20)),
        selected: selected,
        selectedColor: Colors.orange.shade300,
        onSelected: (_) => setState(() => _category = key),
      ),
    );
  }
}

class AnimalDetailScreen extends StatefulWidget {
  final Animal animal;
  const AnimalDetailScreen({super.key, required this.animal});
  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  bool _learned = false;
  bool _favorite = false;

  @override
  void initState() {
    super.initState();
    ProgressStore.isLearned(widget.animal.nameAr)
        .then((v) => mounted ? setState(() => _learned = v) : null);
    ProgressStore.isFavorite(widget.animal.nameAr)
        .then((v) => mounted ? setState(() => _favorite = v) : null);
  }

  @override
  void dispose() {
    AppSound.instance.stopAll();
    super.dispose();
  }

  Future<void> _playSound() async {
    final ok = await AppSound.instance.playAnimalSound(widget.animal);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد صوت مسجّل لهذا الحيوان')),
      );
    }
  }

  Future<void> _toggleFavorite() async {
    final added =
        await ProgressStore.toggleFavorite(widget.animal.nameAr);
    if (mounted) setState(() => _favorite = added);
  }

  Future<void> _markLearned() async {
    if (_learned) return;
    await ProgressStore.markLearned(widget.animal.nameAr);
    await ProgressStore.awardStarsOnce('animal_${widget.animal.nameAr}', 1);
    if (mounted) setState(() => _learned = true);
    await AppSound.instance.praise();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.animal;
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.amber.shade50,
      appBar: AppBar(
        title: Text(
          a.nameAr,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _favorite ? Icons.favorite : Icons.favorite_border,
              size: 32,
              color: _favorite ? Colors.red.shade200 : Colors.white,
            ),
            tooltip: _favorite ? 'أزله من المفضلة' : 'أضفه إلى المفضلة',
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            animalImage(a, height: 280),
            const SizedBox(height: 12),
            Text(
              a.nameAr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
            ),
            Text(
              a.nameEn,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _playSound,
                    icon: const Icon(Icons.volume_up, size: 32),
                    label: const Text(
                      'اسمع صوته',
                      style: TextStyle(fontSize: 24),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => AppSound.instance.speakName(a),
                    icon: const Icon(Icons.record_voice_over, size: 32),
                    label: const Text(
                      'اسمع اسمه',
                      style: TextStyle(fontSize: 24),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            if (!a.hasRealSound)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'هذا الحيوان بلا صوت مسجّل',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
              ),
            const SizedBox(height: 16),
            _infoCard(Icons.home, 'أين يعيش؟', a.home),
            _infoCard(Icons.restaurant, 'ماذا يأكل؟', a.food),
            _infoCard(Icons.lightbulb, 'معلومة جميلة', a.fact),
            _scienceCard(a),
            const SizedBox(height: 16),
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
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String text) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28, color: Colors.orange),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(text, style: const TextStyle(fontSize: 22)),
          ],
        ),
      ),
    );
  }

  /// بطاقة التصنيف العلمي: الفئة العلمية ووصفها، وحقول مبسطة
  /// (الحركة، الحجم، العمر، أليف/بري، نوع الغذاء) — مفصولة بوضوح
  /// عن «أين يعيش؟» البيئية أعلاه.
  Widget _scienceCard(Animal a) {
    final s = scienceFor(a);
    if (s == null) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.teal.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science, size: 28, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تصنيفه العلمي: ${s.sciClass.label}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              s.sciClass.description,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _scienceChip('يتحرك: ${s.movement}'),
                _scienceChip('حجمه: ${s.size}'),
                _scienceChip('يعيش ${s.lifespan}'),
                _scienceChip(s.isPet ? 'أليف' : 'بري'),
                _scienceChip(s.diet),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _scienceChip(String label) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 18)),
      backgroundColor: Colors.white,
    );
  }
}

