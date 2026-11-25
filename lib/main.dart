import 'dart:async';
import 'dart:math';

import 'package:material_ui/material_ui.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'data/animals.dart';
import 'data/diamond_levels.dart';
import 'data/letters.dart';
import 'data/quran.dart';
import 'data/religion.dart';
import 'data/stories.dart';
import 'services/app_sound.dart';
import 'services/child_profile.dart';
import 'services/progress_store.dart';
import 'utils/matching.dart';

/// اسم التطبيق الثابت في النظام؛ العنوان داخل الشاشات يتغير مع الطفل.
const String appTitle = 'فارس والحيوانات';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ترحيل تقدم النسخ القديمة إلى ملف فارس قبل أي قراءة للتقدم.
  await ChildProfile.migrateLegacyProgress();
  runApp(const FaresAnimalsApp());
}

class FaresAnimalsApp extends StatefulWidget {
  const FaresAnimalsApp({super.key});
  @override
  State<FaresAnimalsApp> createState() => _FaresAnimalsAppState();
}

class _FaresAnimalsAppState extends State<FaresAnimalsApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // إيقاف كل صوت فور انتقال التطبيق للخلفية.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      AppSound.instance.stopAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فارس والحيوانات',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const SplashScreen(),
    );
  }
}

Widget animalImage(Animal a, {double height = 200}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Image.network(
      a.imageUrl,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          height: height,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stack) => Container(
        height: height,
        color: Colors.orange.shade100,
        child: const Center(
          child: Icon(Icons.pets, size: 90, color: Colors.orange),
        ),
      ),
    ),
  );
}

class BigButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const BigButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                softWrap: false,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _childName = ChildProfile.defaultChild;

  @override
  void initState() {
    super.initState();
    ChildProfile.currentChild().then(
      (name) => mounted ? setState(() => _childName = name) : null,
    );
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/logo_center.png',
                        width: 340,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      ChildProfile.appTitleFor(_childName),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'تعلم والعب مع الحيوانات',
                      style: TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                ChildProfile.dedicationFor(_childName),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _stars = 0;
  String _childName = ChildProfile.defaultChild;
  List<String> _children = ChildProfile.defaultChildren;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await ProgressStore.stars();
    final name = await ChildProfile.currentChild();
    final kids = await ChildProfile.children();
    if (mounted) {
      setState(() {
        _stars = s;
        _childName = name;
        _children = kids;
      });
    }
  }

  /// ورقة تبديل الطفل: اختيار طفل أو إضافة طفل جديد أو حذف طفل.
  Future<void> _showChildSwitcher() async {
    final nameController = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (context, setSheetState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'من يلعب الآن؟',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              for (final kid in _children)
                ListTile(
                  leading: Icon(
                    kid == _childName
                        ? Icons.check_circle
                        : Icons.account_circle,
                    size: 40,
                    color: kid == _childName ? Colors.green : Colors.orange,
                  ),
                  title: Text(
                    kid,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: _children.length > 1
                      ? IconButton(
                          icon: const Icon(
                            Icons.delete,
                            size: 30,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text(
                                  'حذف $kid؟',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  'سيُحذف $kid وتقدمه كاملاً (نجومه وما تعلمه). هل أنت متأكد؟',
                                  style: const TextStyle(fontSize: 20),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text(
                                      'إلغاء',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text(
                                      'نعم، احذف',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed != true) return;
                            await ChildProfile.removeChild(kid);
                            final kids = await ChildProfile.children();
                            final current =
                                await ChildProfile.currentChild();
                            setSheetState(() => _children = kids);
                            await _load();
                            if (current != _childName) {
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            }
                          },
                        )
                      : null,
                  onTap: () async {
                    await ChildProfile.setCurrent(kid);
                    if (context.mounted) Navigator.pop(context);
                    await _load();
                  },
                ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nameController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24),
                      decoration: const InputDecoration(
                        hintText: 'اسم طفل جديد',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final added = await ChildProfile.addChild(
                        nameController.text,
                      );
                      if (!added) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'اكتب اسماً جديداً غير مكرر',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          );
                        }
                        return;
                      }
                      await ChildProfile.setCurrent(
                        nameController.text.trim(),
                      );
                      if (context.mounted) Navigator.pop(context);
                      await _load();
                    },
                    icon: const Icon(Icons.add, size: 30),
                    label: const Text(
                      'أضف طفلاً',
                      style: TextStyle(fontSize: 22),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      appBar: AppBar(
        title: Text(
          ChildProfile.appTitleFor(_childName),
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.switch_account, size: 32),
            tooltip: 'تبديل الطفل',
            onPressed: _showChildSwitcher,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/logo_center.png',
                        width: 110,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'أهلاً يا $_childName!',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'هيا نتعلم ونلعب معاً',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const Icon(Icons.star, size: 32, color: Colors.amber),
                        Text(
                          '$_stars',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  BigButton(
                    icon: Icons.pets,
                    label: 'الحيوانات',
                    color: Colors.orange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AnimalsScreen()),
                    ).then((_) => _load()),
                  ),
                  BigButton(
                    icon: Icons.menu_book,
                    label: 'تحفيظ القرآن',
                    color: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MemorizationListScreen(),
                      ),
                    ).then((_) => _load()),
                  ),
                  BigButton(
                    icon: Icons.school,
                    label: 'تعلّم',
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LearnScreen()),
                    ).then((_) => _load()),
                  ),
                  BigButton(
                    icon: Icons.mosque,
                    label: 'تعلم ديني',
                    color: Colors.teal,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReligionScreen()),
                    ).then((_) => _load()),
                  ),
                  BigButton(
                    icon: Icons.bedtime,
                    label: 'قصص قبل النوم',
                    color: Colors.indigo,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BedtimeStoriesScreen(),
                      ),
                    ).then((_) => _load()),
                  ),
                  BigButton(
                    icon: Icons.games,
                    label: 'ألعاب',
                    color: Colors.purple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GamesScreen()),
                    ).then((_) => _load()),
                  ),
                  BigButton(
                    icon: Icons.star,
                    label: 'نجومي',
                    color: Colors.amber.shade700,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StarsScreen()),
                    ).then((_) => _load()),
                  ),
                  BigButton(
                    icon: Icons.family_restroom,
                    label: 'ركن الوالدين',
                    color: Colors.brown,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ParentsGateScreen(),
                      ),
                    ).then((_) => _load()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade200, width: 2),
                ),
                child: Text(
                  ChildProfile.dedicationFor(_childName),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
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

// ---------------- الحيوانات ----------------

class AnimalsScreen extends StatefulWidget {
  const AnimalsScreen({super.key});
  @override
  State<AnimalsScreen> createState() => _AnimalsScreenState();
}

class _AnimalsScreenState extends State<AnimalsScreen> {
  String _category = 'all';
  String _query = '';
  final Set<String> _learned = {};
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
    if (mounted) setState(() => _learned.addAll(learned));
  }

  List<Animal> get _shown {
    final byCat = _category == 'all'
        ? animals
        : animals.where((a) => a.category == _category).toList();
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
      backgroundColor: Colors.amber.shade50,
      appBar: AppBar(
        title: const Text(
          'الحيوانات',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        centerTitle: true,
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
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip('all', 'الكل (${animals.length})'),
                for (final e in categoryLabels.entries) _chip(e.key, e.value),
              ],
            ),
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

  @override
  void initState() {
    super.initState();
    ProgressStore.isLearned(widget.animal.nameAr)
        .then((v) => mounted ? setState(() => _learned = v) : null);
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

  Future<void> _markLearned() async {
    if (_learned) return;
    await ProgressStore.markLearned(widget.animal.nameAr);
    await ProgressStore.addStars(1);
    if (mounted) setState(() => _learned = true);
    await AppSound.instance.praise();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.animal;
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      appBar: AppBar(
        title: Text(
          a.nameAr,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        centerTitle: true,
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
}

// ---------------- التعليم الديني ----------------

class ReligionScreen extends StatelessWidget {
  const ReligionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text(
          'تعلم ديني',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _menuButton(
            context,
            Icons.menu_book,
            'تحفيظ القرآن',
            Colors.green,
            const MemorizationListScreen(),
          ),
          _menuButton(
            context,
            Icons.self_improvement,
            'الأذكار',
            Colors.green,
            const AdhkarScreen(),
          ),
          _menuButton(
            context,
            Icons.mosque,
            'الوضوء والصلاة',
            Colors.blue,
            const WuduPrayerScreen(),
          ),
          _menuButton(
            context,
            Icons.auto_awesome,
            'أسماء الله الحسنى',
            Colors.purple,
            const NamesScreen(),
          ),
          _menuButton(
            context,
            Icons.auto_stories,
            'قصص جميلة',
            Colors.orange,
            const StoriesScreen(),
          ),
          _menuButton(
            context,
            Icons.favorite,
            'آداب جميلة',
            Colors.pink,
            const MannersScreen(),
          ),
        ],
      ),
    );
  }

  Widget _menuButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    Widget page,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Icon(icon, size: 44, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    label,
                    softWrap: false,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdhkarScreen extends StatelessWidget {
  const AdhkarScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الأذكار',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final entry in adhkar.entries)
            Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                title: Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: const Icon(
                  Icons.self_improvement,
                  size: 36,
                  color: Colors.green,
                ),
                children: [
                  for (final d in entry.value)
                    _DhikrCounter(category: entry.key, dhikr: d),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// سبحة رقمية: كل ضغطة على العدّاد تزيده، وعند إتمام العدد المطلوب
/// (من repeat: «3 مرات» أو «مرة واحدة») يمنح نجمة واحدة.
/// ملاحظة: نطق الذكر عبر جهاز TTS مضبوط التشكيل، وليس تسجيلاً بشرياً.
class _DhikrCounter extends StatefulWidget {
  final String category;
  final Dhikr dhikr;
  const _DhikrCounter({required this.category, required this.dhikr});
  @override
  State<_DhikrCounter> createState() => _DhikrCounterState();
}

class _DhikrCounterState extends State<_DhikrCounter> {
  int _count = 0;
  bool _done = false;

  int get _target {
    final m = RegExp(r'\d+').firstMatch(widget.dhikr.repeat);
    return m == null ? 1 : int.parse(m.group(0)!);
  }

  String get _key => 'dhikr_${widget.category}_${widget.dhikr.title}';

  @override
  void initState() {
    super.initState();
    ProgressStore.isReligion(_key)
        .then((v) => mounted ? setState(() => _done = v) : null);
  }

  @override
  void dispose() {
    AppSound.instance.stopAll();
    super.dispose();
  }

  Future<void> _tap() async {
    if (_done) return;
    final next = _count + 1;
    setState(() => _count = next);
    if (next >= _target) {
      await ProgressStore.markReligion(_key);
      await ProgressStore.addStars(1);
      if (mounted) setState(() => _done = true);
      await AppSound.instance.praise();
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.dhikr;
    return ListTile(
      title: Text(
        d.title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        '${d.text}\n(${d.repeat})',
        style: const TextStyle(fontSize: 20),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.volume_up, size: 30, color: Colors.green),
            onPressed: () => AppSound.instance.speak(d.text),
          ),
          InkWell(
            onTap: _tap,
            borderRadius: BorderRadius.circular(32),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _done ? Colors.amber : Colors.green.shade100,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Center(
                child: _done
                    ? const Icon(Icons.star, size: 32, color: Colors.white)
                    : Text(
                        '$_count/$_target',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// رسم توضيحي مبسط لكل خطوة (أيقونة + رقم الخطوة).
const List<IconData> _wuduIcons = [
  Icons.favorite,
  Icons.front_hand,
  Icons.water_drop,
  Icons.air,
  Icons.face,
  Icons.pan_tool,
  Icons.person,
  Icons.directions_walk,
];
const List<IconData> _prayerIcons = [
  Icons.person,
  Icons.record_voice_over,
  Icons.menu_book,
  Icons.trending_down,
  Icons.vertical_align_bottom,
  Icons.check_circle,
];

class WuduPrayerScreen extends StatelessWidget {
  const WuduPrayerScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الوضوء والصلاة',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Row(
            children: [
              Icon(Icons.water_drop, size: 32, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'خطوات الوضوء',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < wuduSteps.length; i++)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ),
                title: Row(
                  children: [
                    Icon(_wuduIcons[i], size: 28, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        wuduSteps[i],
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.blue),
                  onPressed: () => AppSound.instance.speak(wuduSteps[i]),
                ),
              ),
            ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.mosque, size: 32, color: Colors.teal),
              SizedBox(width: 8),
              Text(
                'خطوات الصلاة',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < prayerSteps.length; i++)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ),
                title: Row(
                  children: [
                    Icon(_prayerIcons[i], size: 28, color: Colors.teal),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        prayerSteps[i],
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.teal),
                  onPressed: () => AppSound.instance.speak(prayerSteps[i]),
                ),
              ),
            ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.schedule, size: 32, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'الصلوات الخمس',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final e in prayers.entries)
                Chip(
                  label: Text(
                    '${e.key}: ${e.value} ركعات',
                    style: const TextStyle(fontSize: 22),
                  ),
                  backgroundColor: Colors.blue.shade100,
                  padding: const EdgeInsets.all(10),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class NamesScreen extends StatelessWidget {
  const NamesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'أسماء الله الحسنى',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final e in allahNames.entries)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(
                  Icons.auto_awesome,
                  size: 32,
                  color: Colors.purple,
                ),
                title: Text(
                  e.key,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(e.value, style: const TextStyle(fontSize: 20)),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.volume_up,
                    size: 32,
                    color: Colors.purple,
                  ),
                  onPressed: () {
                    AppSound.instance.speak('${e.key}. ${e.value}');
                    ProgressStore.markReligion('name_${e.key}');
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});
  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  String _childName = ChildProfile.defaultChild;

  @override
  void initState() {
    super.initState();
    ChildProfile.currentChild().then(
      (name) => mounted ? setState(() => _childName = name) : null,
    );
  }

  /// اسم بطل القصة هو الطفل الحالي («فارس الصغير» تصير «فهد الصغير»).
  String _hero(String text) => text.replaceAll('فارس', _childName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'قصص جميلة',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stories.length,
        itemBuilder: (context, i) {
          final st = stories[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const Icon(
                Icons.auto_stories,
                size: 36,
                color: Colors.orange,
              ),
              title: Text(
                _hero(st.title),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(st.moral, style: const TextStyle(fontSize: 18)),
              trailing: IconButton(
                icon: const Icon(
                  Icons.volume_up,
                  size: 32,
                  color: Colors.orange,
                ),
                onPressed: () {
                  AppSound.instance.speak(
                    '${_hero(st.title)}. ${_hero(st.body)} ${st.moral}',
                  );
                  ProgressStore.markReligion('story_${st.title}');
                },
              ),
              onTap: () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(
                    _hero(st.title),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: SingleChildScrollView(
                    child: Text(
                      _hero(st.body),
                      style: const TextStyle(fontSize: 22, height: 1.8),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'حسناً',
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MannersScreen extends StatelessWidget {
  const MannersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'آداب جميلة',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final e in manners.entries)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: const Icon(
                  Icons.favorite,
                  size: 32,
                  color: Colors.pink,
                ),
                title: Text(
                  e.key,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(e.value, style: const TextStyle(fontSize: 20)),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.volume_up,
                    size: 32,
                    color: Colors.pink,
                  ),
                  onPressed: () {
                    AppSound.instance.speak('${e.key}. ${e.value}');
                    ProgressStore.markReligion('manner_${e.key}');
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------- الألعاب ----------------

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text(
          'ألعاب',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
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
                icon: Icons.volume_up,
                label: 'خمّن الصوت',
                color: Colors.green,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GuessSoundGame()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.image,
                label: 'خمّن الصورة',
                color: Colors.blue,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GuessPictureGame()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.psychology,
                label: 'لعبة الذاكرة',
                color: Colors.pink,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MemoryGame()),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.diamond,
                label: 'أكل الماس 💎',
                color: Colors.cyan,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DiamondGameScreen(),
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

class GuessSoundGame extends StatefulWidget {
  const GuessSoundGame({super.key});
  @override
  State<GuessSoundGame> createState() => _GuessSoundGameState();
}

class _GuessSoundGameState extends State<GuessSoundGame> {
  final _rnd = Random();
  late Animal _answer;
  late List<Animal> _options;
  bool _hasQuestions = true;
  int _score = 0;
  int _round = 1;
  String _message = 'اسمع الصوت وخمّن الحيوان!';

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  @override
  void dispose() {
    AppSound.instance.stopAll();
    super.dispose();
  }

  void _newRound() {
    // الأسئلة من الحيوانات القابلة للتخمين فقط، وبصوت حقيقي فقط،
    // والصوت المشغّل هو صوت كائن الإجابة نفسه (نفس Animal).
    final pool = animals.where((a) => a.guessable && a.hasRealSound).toList();
    if (pool.isEmpty) {
      setState(() {
        _hasQuestions = false;
        _message = 'لا توجد أصوات حقيقية بعد';
      });
      return;
    }
    _answer = pool[_rnd.nextInt(pool.length)];
    final others = animals.where((a) => a != _answer).toList()..shuffle(_rnd);
    _options = [_answer, others[0], others[1]]..shuffle(_rnd);
    setState(() => _message = 'اسمع الصوت وخمّن الحيوان!');
    AppSound.instance.playAnimalSound(_answer);
  }

  Future<void> _choose(Animal a) async {
    if (a == _answer) {
      await ProgressStore.addStars(1);
      setState(() {
        _score++;
        _message = 'صح! هذا هو ${_answer.nameAr}';
      });
      await AppSound.instance.praise(_score);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _round++);
      _newRound();
    } else {
      setState(() => _message = 'حاول مرة أخرى يا بطل!');
      await AppSound.instance.speak('حاول مرة أخرى يا بطل!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'خمّن الصوت — الجولة $_round',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: !_hasQuestions
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'نقاطك: $_score',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => AppSound.instance.playAnimalSound(_answer),
                    icon: const Icon(Icons.volume_up, size: 48),
                    label: const Text(
                      'اسمع الصوت',
                      style: TextStyle(fontSize: 30),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: _options.length,
                      itemBuilder: (context, i) {
                        final a = _options[i];
                        return InkWell(
                          onTap: () => _choose(a),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Expanded(child: animalImage(a, height: 120)),
                                Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(
                                    a.nameAr,
                                    style: const TextStyle(
                                      fontSize: 20,
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
                  ),
                ],
              ),
            ),
    );
  }
}

class GuessPictureGame extends StatefulWidget {
  const GuessPictureGame({super.key});
  @override
  State<GuessPictureGame> createState() => _GuessPictureGameState();
}

class _GuessPictureGameState extends State<GuessPictureGame> {
  final _rnd = Random();
  late Animal _answer;
  late List<Animal> _options;
  int _score = 0;
  int _round = 1;
  String _message = 'ما اسم هذا الحيوان؟';

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  @override
  void dispose() {
    AppSound.instance.stopAll();
    super.dispose();
  }

  void _newRound() {
    _answer = animals[_rnd.nextInt(animals.length)];
    final others = animals.where((a) => a != _answer).toList()..shuffle(_rnd);
    _options = [_answer, others[0], others[1]]..shuffle(_rnd);
    setState(() => _message = 'ما اسم هذا الحيوان؟');
  }

  Future<void> _choose(Animal a) async {
    if (a == _answer) {
      await ProgressStore.addStars(1);
      setState(() {
        _score++;
        _message = 'صح! أحسنت';
      });
      await AppSound.instance.praise(_score);
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _round++);
      _newRound();
    } else {
      setState(() => _message = 'حاول مرة أخرى يا بطل!');
      await AppSound.instance.speak('حاول مرة أخرى يا بطل!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'خمّن الصورة — الجولة $_round',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'نقاطك: $_score',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            animalImage(_answer, height: 260),
            const SizedBox(height: 12),
            Text(
              _message,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (final a in _options)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _choose(a),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Text(a.nameAr, style: const TextStyle(fontSize: 28)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});
  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  final _rnd = Random();
  late List<Animal> _cards;
  final Set<int> _flipped = {};
  final Set<int> _matched = {};
  int? _first;
  bool _busy = false;
  int _pairs = 0;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  @override
  void dispose() {
    AppSound.instance.stopAll();
    super.dispose();
  }

  void _setup() {
    final picks = animals.toList()..shuffle(_rnd);
    final chosen = picks.take(4).toList();
    _cards = [...chosen, ...chosen]..shuffle(_rnd);
    _flipped.clear();
    _matched.clear();
    _first = null;
    _pairs = 0;
  }

  Future<void> _tap(int i) async {
    if (_busy || _flipped.contains(i) || _matched.contains(i)) return;
    setState(() => _flipped.add(i));
    if (_first == null) {
      _first = i;
      return;
    }
    _busy = true;
    final j = _first!;
    _first = null;
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    if (_cards[i] == _cards[j]) {
      setState(() {
        _matched.add(i);
        _matched.add(j);
        _pairs++;
      });
      await AppSound.instance.praise(_pairs);
      if (_pairs == 4) {
        await ProgressStore.addStars(2);
        if (!mounted) return;
        await AppSound.instance.speak('رائع! أكملت لعبة الذاكرة!');
        setState(_setup);
      }
    } else {
      setState(() {
        _flipped.remove(i);
        _flipped.remove(j);
      });
    }
    _busy = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'لعبة الذاكرة',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'الأزواج: $_pairs من 4',
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
                childAspectRatio: 0.82,
              ),
              itemCount: _cards.length,
              itemBuilder: (context, i) {
                final open = _flipped.contains(i) || _matched.contains(i);
                final a = _cards[i];
                return InkWell(
                  onTap: () => _tap(i),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: open ? Colors.white : Colors.pink.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: open
                        ? Column(
                            children: [
                              Expanded(child: animalImage(a, height: 120)),
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: Text(
                                  a.nameAr,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Center(
                            child: Icon(
                              Icons.help_outline,
                              size: 64,
                              color: Colors.white,
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

// ---------------- نجومي ----------------

// ---------------- لعبة أكل الماس 💎 ----------------

/// شاشة اختيار المرحلة: 10 مراحل، المقفلة بقفل، والمكتملة بنجمة.
class DiamondGameScreen extends StatefulWidget {
  const DiamondGameScreen({super.key});
  @override
  State<DiamondGameScreen> createState() => _DiamondGameScreenState();
}

class _DiamondGameScreenState extends State<DiamondGameScreen> {
  int _unlocked = 1;
  Map<int, int> _best = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final unlocked = await ProgressStore.diamondUnlocked();
    final best = <int, int>{};
    for (final lv in diamondLevels) {
      best[lv.level] = await ProgressStore.diamondBest(lv.level);
    }
    if (mounted) setState(() => _unlocked = unlocked);
    if (mounted) setState(() => _best = best);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan.shade50,
      appBar: AppBar(
        title: const Text(
          'أكل الماس 💎',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'اضغط على الماسة ليأكلها الحيوان! أكمل الهدف قبل انتهاء الوقت.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.6,
                ),
                itemCount: diamondLevels.length,
                itemBuilder: (context, i) {
                  final lv = diamondLevels[i];
                  final open = lv.level <= _unlocked;
                  final done =
                      (_best[lv.level] ?? 0) >= lv.target;
                  return ElevatedButton(
                    onPressed: open
                        ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DiamondLevelScreen(level: lv.level),
                            ),
                          ).then((_) => _load())
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: open ? Colors.cyan : Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          open
                              ? (done ? Icons.star : Icons.diamond)
                              : Icons.lock,
                          size: 40,
                        ),
                        Text(
                          'المرحلة ${lv.level}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'كل ${lv.target} 💎 في ${lv.seconds} ث',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ماسة واحدة على الساحة.
class _Diamond {
  final int id;
  final double x;
  final double y;
  _Diamond({required this.id, required this.x, required this.y});
}

/// شاشة لعب مرحلة: ماسات تظهر عشوائياً وتختفي، والضغط عليها يأكلها.
class DiamondLevelScreen extends StatefulWidget {
  final int level;
  const DiamondLevelScreen({super.key, required this.level});
  @override
  State<DiamondLevelScreen> createState() => _DiamondLevelScreenState();
}

class _DiamondLevelScreenState extends State<DiamondLevelScreen> {
  late final DiamondLevel _config;
  int _timeLeft = 0;
  int _eaten = 0;
  int _nextId = 0;
  final List<_Diamond> _diamonds = [];
  Timer? _timer;
  bool _over = false;
  double _areaWidth = 300;
  double _areaHeight = 300;
  String _childName = ChildProfile.defaultChild;
  // الحيوان يتغير كل مرحلة، والضغط عليه يبدّله.
  late int _animalIndex;
  // آخر مرة نطق فيها «يم!» — لمنع تداخل الصوت عند الضغط السريع.
  DateTime _lastYum = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _config = diamondLevel(widget.level);
    _timeLeft = _config.seconds;
    _animalIndex = (widget.level - 1) % diamondAnimals.length;
    ChildProfile.currentChild().then(
      (name) => mounted ? setState(() => _childName = name) : null,
    );
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      for (var i = 0; i < _config.maxDiamonds; i++) {
        _spawnDiamond();
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _over) return;
      setState(() => _timeLeft--);
      if (_timeLeft <= 0) _finish(false);
    });
  }

  @override
  void dispose() {
    // إيقاف المؤقت والصوت فوراً عند الرجوع.
    _timer?.cancel();
    unawaited(AppSound.instance.stopAll());
    super.dispose();
  }

  void _spawnDiamond() {
    if (_over || !mounted) return;
    final id = _nextId++;
    final d = _Diamond(
      id: id,
      x: Random().nextDouble() * (_areaWidth - 72),
      y: Random().nextDouble() * (_areaHeight - 72),
    );
    setState(() => _diamonds.add(d));
    // تختفي الماسة بعد مدة إن لم تُؤكل، وتظهر غيرها.
    Future.delayed(
      Duration(milliseconds: (_config.despawnSeconds * 1000).round()),
      () {
        if (!mounted || _over) return;
        final wasThere = _diamonds.any((e) => e.id == id);
        if (!wasThere) return;
        setState(() => _diamonds.removeWhere((e) => e.id == id));
        _spawnDiamond();
      },
    );
  }

  void _eatDiamond(_Diamond d) {
    if (_over) return;
    setState(() {
      _diamonds.removeWhere((e) => e.id == d.id);
      _eaten++;
    });
    // صوت «يم!» واحد فقط كل 400 مللي ثانية حتى مع الضغط السريع.
    final now = DateTime.now();
    if (now.difference(_lastYum).inMilliseconds >= 400) {
      _lastYum = now;
      unawaited(AppSound.instance.speak('يم!'));
    }
    if (_eaten >= _config.target) {
      _finish(true);
    } else {
      _spawnDiamond();
    }
  }

  /// إعادة المرحلة من البداية بعد انتهاء الوقت (بلا خصم نجوم أبداً).
  void _restart() {
    _timer?.cancel();
    setState(() {
      _over = false;
      _eaten = 0;
      _timeLeft = _config.seconds;
      _diamonds.clear();
    });
    _startTimer();
    for (var i = 0; i < _config.maxDiamonds; i++) {
      _spawnDiamond();
    }
  }

  Future<void> _finish(bool won) async {
    if (_over) return;
    _over = true;
    _timer?.cancel();
    await ProgressStore.saveDiamondBest(widget.level, _eaten);
    if (won) {
      await ProgressStore.addStars(1);
      if (widget.level < diamondLevels.length) {
        await ProgressStore.unlockDiamondLevel(widget.level + 1);
      }
      final name = await ChildProfile.currentChild();
      if (mounted) setState(() => _childName = name);
      await AppSound.instance.speak(
        'أحسنت يا $_childName! أكملت المرحلة ${widget.level}!',
      );
    }
    if (!mounted) return;
    final retry = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          won ? 'رائع! 🎉' : 'لا بأس يا بطل! 💪',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        content: Text(
          won
              ? 'أكلت ${_config.target} ماسات في المرحلة ${widget.level}، وكسبت نجمة! ⭐'
              : 'أكلت $_eaten من ${_config.target} ماسات. أنت تستطيع! حاول مجدداً.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22),
        ),
        actions: [
          if (!won)
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'حاول مجدداً',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('حسناً', style: TextStyle(fontSize: 22)),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (retry == true) {
      _restart();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan.shade50,
      appBar: AppBar(
        title: Text(
          'المرحلة ${widget.level} 💎',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.cyan,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat('💎 $_eaten / ${_config.target}', Colors.cyan),
                _stat(
                  '⏱ $_timeLeft ث',
                  _timeLeft <= 10 ? Colors.red : Colors.orange,
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                _areaWidth = constraints.maxWidth;
                _areaHeight = constraints.maxHeight;
                return Stack(
                  children: [
                    // حيوان الساحة: يتغير كل مرحلة، والضغط عليه يبدّله.
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => setState(
                              () => _animalIndex =
                                  (_animalIndex + 1) %
                                  diamondAnimals.length,
                            ),
                            child: Text(
                              diamondAnimals[_animalIndex],
                              style: const TextStyle(fontSize: 110),
                            ),
                          ),
                          const Text(
                            'اضغط على الحيوان لتغييره',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    for (final d in _diamonds)
                      Positioned(
                        left: d.x,
                        top: d.y,
                        child: GestureDetector(
                          onTap: () => _eatDiamond(d),
                          // منطقة لمس كبيرة لعمر 5 سنوات: الماسة نفسها
                          // كبيرة (88) مع حشوة شفافة حولها.
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            color: Colors.transparent,
                            child: const Text(
                              '💎',
                              style: TextStyle(fontSize: 88),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 3),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class StarsScreen extends StatefulWidget {
  const StarsScreen({super.key});
  @override
  State<StarsScreen> createState() => _StarsScreenState();
}

/// مفاتيح التقدم الديني الفعلية (بلا السور القصيرة المنفصلة: هي ضمن
/// سور التحفيظ الـ21). الإجمالي يُحسب من القوائم الفعلية لا رقم ثابت.
List<String> get _religionKeys => [
  ...allahNames.keys.map((k) => 'name_$k'),
  ...stories.map((st) => 'story_${st.title}'),
  ...manners.keys.map((k) => 'manner_$k'),
  for (final ms in memorizeSurahs) 'memorize_${ms.number}',
];

List<String> get _learnKeys => [
  ...arabicLetters.map((e) => 'letter_ar_${e.letter}'),
  ...englishLetters.map((e) => 'letter_en_${e.letter}'),
  ...numbers.map((e) => 'number_${e.value}'),
  ...bedtimeStories.map((st) => 'story_bed_${st.title}'),
];

/// تعريف الأوسمة: (المعرّف، الاسم، الأيقونة).
const List<(String, String, IconData)> _badgeDefs = [
  ('first_animal', 'أول حيوان', Icons.pets),
  ('ten_animals', '10 حيوانات', Icons.emoji_events),
  ('first_surah', 'أول سورة', Icons.menu_book),
  ('story_reader', 'قارئ القصص', Icons.bedtime),
];

class _StarsScreenState extends State<StarsScreen> {
  int _stars = 0;
  int _learned = 0;
  int _religion = 0;
  int _learn = 0;
  Set<String> _badges = {};
  String _childName = ChildProfile.defaultChild;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await ProgressStore.stars();
    final l = await ProgressStore.learnedCount(
      animals.map((a) => a.nameAr).toList(),
    );
    final r = await ProgressStore.religionCount(_religionKeys);
    final ln = await ProgressStore.religionCount(_learnKeys);
    // فتح الأوسمة من التقدم الفعلي عند فتح الشاشة.
    if (l >= 1) await ProgressStore.unlockBadge('first_animal');
    if (l >= 10) await ProgressStore.unlockBadge('ten_animals');
    final memorized = await ProgressStore.religionCount([
      for (final ms in memorizeSurahs) 'memorize_${ms.number}',
    ]);
    if (memorized >= 1) await ProgressStore.unlockBadge('first_surah');
    final bed = await ProgressStore.religionCount(
      bedtimeStories.map((st) => 'story_bed_${st.title}').toList(),
    );
    if (bed >= 1) await ProgressStore.unlockBadge('story_reader');
    final badges = await ProgressStore.badges();
    final childName = await ChildProfile.currentChild();
    if (mounted) {
      setState(() {
        _stars = s;
        _learned = l;
        _religion = r;
        _learn = ln;
        _badges = badges;
        _childName = childName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.amber.shade50,
      appBar: AppBar(
        title: const Text(
          'نجومي',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(
              child: Icon(Icons.star, size: 80, color: Colors.amber),
            ),
            Center(
              child: Text(
                'نجومي: $_stars',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _progress('الحيوانات التي تعلمتها', _learned, animals.length),
            const SizedBox(height: 16),
            _progress(
              'دروس دينية وتحفيظ أنجزتها',
              _religion,
              _religionKeys.length,
            ),
            const SizedBox(height: 16),
            _progress('حروف وأرقام وقصص', _learn, _learnKeys.length),
            const SizedBox(height: 24),
            const Text(
              'أوسمتي',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemCount: _badgeDefs.length,
              itemBuilder: (context, i) {
                final (id, label, icon) = _badgeDefs[i];
                final unlocked = _badges.contains(id);
                return Container(
                  decoration: BoxDecoration(
                    color: unlocked
                        ? Colors.amber.shade100
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: unlocked ? Colors.amber : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        unlocked ? icon : Icons.lock,
                        size: 40,
                        color: unlocked ? Colors.amber.shade800 : Colors.grey,
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          label,
                          softWrap: false,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: unlocked ? Colors.brown : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'استمر يا $_childName! كل نجمة تعني أنك تعلمت شيئاً جديداً.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _progress(String label, int value, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // سطر مستقل بـ FittedBox فلا يلتف «12 من 46» ونحوه.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(
            '$label: $value من $total',
            softWrap: false,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: total == 0 ? 0 : value / total,
          minHeight: 18,
          borderRadius: BorderRadius.circular(10),
          backgroundColor: Colors.grey.shade300,
          color: Colors.orange,
        ),
      ],
    );
  }
}

// ---------------- تعلّم: حروف وأرقام ----------------

Animal? findAnimalByName(String nameAr) {
  for (final a in animals) {
    if (a.nameAr == nameAr) return a;
  }
  return null;
}

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    await ProgressStore.addStars(1);
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
    await ProgressStore.addStars(1);
    if (mounted) setState(() => _learned = true);
    await AppSound.instance.praise();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.letter;
    return Scaffold(
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
    await ProgressStore.addStars(1);
    if (mounted) setState(() => _learned = true);
    await AppSound.instance.praise();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.number;
    final animal = findAnimalByName(n.animalName);
    return Scaffold(
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

class CountingGameScreen extends StatefulWidget {
  const CountingGameScreen({super.key});
  @override
  State<CountingGameScreen> createState() => _CountingGameScreenState();
}

class _CountingGameScreenState extends State<CountingGameScreen> {
  final _rnd = Random();
  late int _target;
  late Animal _animal;
  late List<int> _options;
  int _score = 0;
  String _message = 'كم عدد الحيوانات؟';

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  @override
  void dispose() {
    AppSound.instance.stopAll();
    super.dispose();
  }

  void _newRound() {
    _target = _rnd.nextInt(10) + 1;
    final item = numbers[_target - 1];
    _animal = findAnimalByName(item.animalName) ?? animals[0];
    final opts = {_target};
    while (opts.length < 3) {
      opts.add(_rnd.nextInt(10) + 1);
    }
    _options = opts.toList()..shuffle(_rnd);
    setState(() => _message = 'كم عدد الحيوانات؟');
  }

  Future<void> _choose(int v) async {
    if (v == _target) {
      await ProgressStore.addStars(1);
      setState(() {
        _score++;
        _message = 'صح! العدد هو $_target';
      });
      await AppSound.instance.praise(_score);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) _newRound();
    } else {
      setState(() => _message = 'حاول مرة أخرى يا بطل!');
      await AppSound.instance.speak('حاول مرة أخرى يا بطل!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'لعبة العدّ',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                for (final o in _options)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ElevatedButton(
                        onPressed: () => _choose(o),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                        ),
                        child: Text('$o', style: const TextStyle(fontSize: 32)),
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

// ---------------- تحفيظ القرآن ----------------

class MemorizationListScreen extends StatefulWidget {
  const MemorizationListScreen({super.key});
  @override
  State<MemorizationListScreen> createState() => _MemorizationListScreenState();
}

class _MemorizationListScreenState extends State<MemorizationListScreen> {
  final Set<int> _done = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final done = <int>{};
    for (final s in memorizeSurahs) {
      if (await ProgressStore.isReligion('memorize_${s.number}')) {
        done.add(s.number);
      }
    }
    if (mounted) setState(() => _done.addAll(done));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تحفيظ القرآن',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: memorizeSurahs.length,
        itemBuilder: (context, i) {
          final s = memorizeSurahs[i];
          final done = _done.contains(s.number);
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Icon(
                done ? Icons.star : Icons.menu_book,
                size: 36,
                color: done ? Colors.amber : Colors.green,
              ),
              title: Text(
                'سورة ${s.name}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${s.ayahs.length} آيات — ${s.meaning}',
                style: const TextStyle(fontSize: 18),
              ),
              trailing: const Icon(
                Icons.play_arrow,
                size: 36,
                color: Colors.green,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MemorizationDetailScreen(surah: s),
                ),
              ).then((_) => _load()),
            ),
          );
        },
      ),
    );
  }
}

class MemorizationDetailScreen extends StatefulWidget {
  final MemorizeSurah surah;
  const MemorizationDetailScreen({super.key, required this.surah});
  @override
  State<MemorizationDetailScreen> createState() =>
      _MemorizationDetailScreenState();
}

class _MemorizationDetailScreenState extends State<MemorizationDetailScreen> {
  bool _tasmee = false;
  int _current = 0;
  int _repeat = 1;
  bool _playingAll = false;
  final Set<int> _learned = {};
  final Set<int> _starred = {};

  Future<void> _playAyah(MemorizeAyah a, {int repeat = 1}) async {
    await AppSound.instance.playUrl(a.audioUrl, repeat: repeat);
  }

  Future<void> _playWholeSurah() async {
    setState(() => _playingAll = true);
    await AppSound.instance.playAyahs(
      widget.surah.ayahs.map((a) => a.audioUrl).toList(),
    );
    if (mounted) setState(() => _playingAll = false);
  }

  Future<void> _markAyah(int index) async {
    if (_learned.contains(index)) return;
    setState(() => _learned.add(index));
    if (!_starred.contains(index)) {
      _starred.add(index);
      await ProgressStore.addStars(1);
    }
    if (_learned.length == widget.surah.ayahs.length) {
      await ProgressStore.markReligion('memorize_${widget.surah.number}');
      final childName = await ChildProfile.currentChild();
      await AppSound.instance.speak(
        'أحسنت يا $childName! حفظت سورة ${widget.surah.name}!',
      );
    }
  }

  @override
  void dispose() {
    AppSound.instance.stopAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.surah;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سورة ${s.name}',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => setState(() {
              _tasmee = !_tasmee;
              _current = 0;
            }),
            child: Text(
              _tasmee ? 'كل الآيات' : 'وضع التسميع',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              s.meaning,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // البسملة في ترويسة مستقلة أعلى السورة؛ إلا الفاتحة حيث
            // البسملة آية 1 فلا تُكرر.
            if (!s.basmalaIsAyah)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  child: Text(
                    s.basmala,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 26, height: 1.8),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _playingAll ? null : _playWholeSurah,
              icon: Icon(
                _playingAll ? Icons.hourglass_top : Icons.play_arrow,
                size: 32,
              ),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _playingAll ? 'تُتلى السورة الآن...' : 'استمع للسورة كاملة',
                  softWrap: false,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'تكرار الآية:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                for (final r in [1, 3, 5])
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(
                        '${r}x',
                        style: const TextStyle(fontSize: 18),
                      ),
                      selected: _repeat == r,
                      selectedColor: Colors.blue.shade200,
                      onSelected: (_) => setState(() => _repeat = r),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (!_tasmee)
              Expanded(
                child: ListView.builder(
                  itemCount: s.ayahs.length,
                  itemBuilder: (context, i) {
                    final a = s.ayahs[i];
                    final done = _learned.contains(i);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: done ? Colors.green.shade50 : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.green,
                                  radius: 18,
                                  child: Text(
                                    '${a.numberInSurah}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'الآية ${a.numberInSurah}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                if (done)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 28,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              a.text,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 26, height: 1.9),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _playAyah(a),
                                    icon: const Icon(
                                      Icons.play_arrow,
                                      size: 24,
                                    ),
                                    label: const FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'استمع',
                                        softWrap: false,
                                        style: TextStyle(fontSize: 19),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _playAyah(a, repeat: _repeat),
                                    icon: const Icon(Icons.repeat, size: 24),
                                    label: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'كرر ${_repeat}x',
                                        softWrap: false,
                                        style: const TextStyle(fontSize: 19),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _markAyah(i),
                                    icon: Icon(
                                      done ? Icons.star : Icons.star_border,
                                      size: 24,
                                    ),
                                    label: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        done ? 'حفظتها' : 'حفظتها؟',
                                        softWrap: false,
                                        style: const TextStyle(fontSize: 19),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'الآية ${_current + 1} من ${s.ayahs.length}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          s.ayahs[_current].text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 32, height: 2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'استمع جيداً، ثم كرر الآية بصوتك',
                      style: TextStyle(fontSize: 22),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _playAyah(s.ayahs[_current]),
                      icon: const Icon(Icons.play_arrow, size: 36),
                      label: const Text(
                        'استمع للآية',
                        style: TextStyle(fontSize: 26),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _markAyah(_current);
                        if (!mounted) return;
                        if (_current < s.ayahs.length - 1) {
                          setState(() => _current++);
                        } else {
                          setState(() => _tasmee = false);
                        }
                      },
                      icon: const Icon(Icons.check, size: 36),
                      label: const Text(
                        'كررتها! التالية',
                        style: TextStyle(fontSize: 26),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------- قصص قبل النوم ----------------

// ألوان الوضع الليلي الدافئ لقصص قبل النوم.
const Color _nightBg = Color(0xFF241A12);
const Color _nightBar = Color(0xFF3A2C1E);
const Color _nightCard = Color(0xFF3E3226);

class BedtimeStoriesScreen extends StatefulWidget {
  const BedtimeStoriesScreen({super.key});
  @override
  State<BedtimeStoriesScreen> createState() => _BedtimeStoriesScreenState();
}

class _BedtimeStoriesScreenState extends State<BedtimeStoriesScreen> {
  bool _night = false;
  final Set<String> _done = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final night = await ProgressStore.nightMode();
    final done = <String>{};
    for (final st in bedtimeStories) {
      if (await ProgressStore.isReligion('story_bed_${st.title}')) {
        done.add(st.title);
      }
    }
    if (mounted) {
      setState(() {
        _night = night;
        _done.addAll(done);
      });
    }
  }

  Future<void> _toggleNight() async {
    final next = !_night;
    await ProgressStore.setNightMode(next);
    if (mounted) setState(() => _night = next);
  }

  @override
  Widget build(BuildContext context) {
    final night = _night;
    return Scaffold(
      backgroundColor: night ? _nightBg : Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text(
          'قصص قبل النوم',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: night ? _nightBar : Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(night ? Icons.wb_sunny : Icons.bedtime, size: 30),
            tooltip: 'وضع ليلي',
            onPressed: _toggleNight,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bedtimeStories.length,
        itemBuilder: (context, i) {
          final st = bedtimeStories[i];
          final done = _done.contains(st.title);
          return Card(
            color: night ? _nightCard : Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                Icons.auto_stories,
                size: 40,
                color: night ? Colors.amber.shade200 : Colors.indigo,
              ),
              title: Text(
                st.title,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: night ? Colors.amber.shade100 : Colors.black,
                ),
              ),
              subtitle: Text(
                st.isProphet ? 'قصة نبي — ${st.moral}' : st.moral,
                style: TextStyle(
                  fontSize: 18,
                  color: night ? Colors.amber.shade200 : Colors.grey.shade700,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (done)
                    const Icon(
                      Icons.check_circle,
                      size: 30,
                      color: Colors.green,
                    ),
                  Icon(
                    Icons.play_arrow,
                    size: 36,
                    color: night ? Colors.amber.shade200 : Colors.indigo,
                  ),
                ],
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BedtimeStoryDetailScreen(story: st),
                ),
              ).then((_) => _load()),
            ),
          );
        },
      ),
    );
  }
}

class BedtimeStoryDetailScreen extends StatefulWidget {
  final BedtimeStory story;
  const BedtimeStoryDetailScreen({super.key, required this.story});
  @override
  State<BedtimeStoryDetailScreen> createState() =>
      _BedtimeStoryDetailScreenState();
}

class _BedtimeStoryDetailScreenState extends State<BedtimeStoryDetailScreen> {
  bool _playing = false;
  bool _calm = true;
  bool _listened = false;
  bool _night = false;

  Future<void> _play() async {
    setState(() => _playing = true);
    if (_calm) {
      await AppSound.instance.speakCalm(
        '${widget.story.title}. ${widget.story.body} ${widget.story.moral}',
      );
    } else {
      await AppSound.instance.speak(
        '${widget.story.title}. ${widget.story.body} ${widget.story.moral}',
      );
    }
    if (mounted) setState(() => _playing = false);
  }

  Future<void> _stop() async {
    await AppSound.instance.stopSpeaking();
    if (mounted) setState(() => _playing = false);
  }

  Future<void> _markListened() async {
    if (_listened) return;
    await ProgressStore.markReligion('story_bed_${widget.story.title}');
    await ProgressStore.addStars(1);
    if (mounted) setState(() => _listened = true);
    await AppSound.instance.praise();
  }

  @override
  void initState() {
    super.initState();
    ProgressStore.isReligion('story_bed_${widget.story.title}')
        .then((v) => mounted ? setState(() => _listened = v) : null);
    ProgressStore.nightMode().then(
      (v) => mounted ? setState(() => _night = v) : null,
    );
  }

  @override
  void dispose() {
    AppSound.instance.stopAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = widget.story;
    final night = _night;
    final bodyColor = night ? Colors.amber.shade100 : Colors.black;
    final moralColor = night ? Colors.amber.shade200 : Colors.indigo;
    return Scaffold(
      backgroundColor: night ? _nightBg : Colors.indigo.shade50,
      appBar: AppBar(
        title: Text(
          st.title,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: night ? _nightBar : Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(night ? Icons.wb_sunny : Icons.bedtime, size: 28),
            tooltip: 'وضع ليلي',
            onPressed: () async {
              final next = !night;
              await ProgressStore.setNightMode(next);
              if (mounted) setState(() => _night = next);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.auto_stories,
                size: 80,
                color: night ? Colors.amber.shade200 : Colors.indigo,
              ),
              const SizedBox(height: 8),
              Text(
                st.body,
                style: TextStyle(fontSize: 24, height: 1.9, color: bodyColor),
              ),
              const SizedBox(height: 16),
              Text(
                st.moral,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: moralColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.bedtime,
                    size: 28,
                    color: night ? Colors.amber.shade200 : Colors.indigo,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'صوت هادئ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: bodyColor,
                    ),
                  ),
                  Switch(
                    value: _calm,
                    onChanged: (v) => setState(() => _calm = v),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _playing ? _stop : _play,
                      icon: Icon(
                        _playing ? Icons.stop : Icons.play_arrow,
                        size: 32,
                      ),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _playing ? 'إيقاف' : 'اسمع الحدوتة',
                          softWrap: false,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: night ? _nightBar : Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _markListened,
                      icon: Icon(
                        _listened ? Icons.star : Icons.star_border,
                        size: 32,
                      ),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _listened ? 'سمعتها' : 'سمعتها',
                          softWrap: false,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // القصة تُروى بصوت آلي هادئ (TTS) وليست تسجيلاً بشرياً.
              Text(
                'القصة تُروى بصوت آلي هادئ وليست تسجيلاً بشرياً',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: night ? Colors.amber.shade200 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- ركن الوالدين ----------------

/// بوابة بسيطة بسؤال حسابي، تفتح إعدادات الوالدين.
class ParentsGateScreen extends StatefulWidget {
  const ParentsGateScreen({super.key});
  @override
  State<ParentsGateScreen> createState() => _ParentsGateScreenState();
}

class _ParentsGateScreenState extends State<ParentsGateScreen> {
  final _rnd = Random();
  final _controller = TextEditingController();
  late int _a;
  late int _b;
  String _message = 'أجب عن السؤال لفتح ركن الوالدين';

  @override
  void initState() {
    super.initState();
    _newQuestion();
  }

  void _newQuestion() {
    _a = _rnd.nextInt(8) + 2;
    _b = _rnd.nextInt(8) + 2;
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _check() {
    final answer = int.tryParse(_controller.text.trim());
    if (answer == _a + _b) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ParentsSettingsScreen()),
      );
    } else {
      setState(() {
        _message = 'إجابة خاطئة، حاول مجدداً';
        _newQuestion();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade50,
      appBar: AppBar(
        title: const Text(
          'ركن الوالدين',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'هذا الركن للوالدين فقط',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '$_a + $_b = ؟',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32),
              decoration: InputDecoration(
                hintText: 'اكتب الناتج',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onSubmitted: (_) => _check(),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _check,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('دخول', style: TextStyle(fontSize: 26)),
            ),
            const SizedBox(height: 12),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class ParentsSettingsScreen extends StatefulWidget {
  const ParentsSettingsScreen({super.key});
  @override
  State<ParentsSettingsScreen> createState() => _ParentsSettingsScreenState();
}

class _ParentsSettingsScreenState extends State<ParentsSettingsScreen> {
  double _volume = 1.0;
  int _stars = 0;
  String _childName = ChildProfile.defaultChild;

  @override
  void initState() {
    super.initState();
    ProgressStore.volume().then(
      (v) => mounted ? setState(() => _volume = v) : null,
    );
    ProgressStore.stars().then(
      (v) => mounted ? setState(() => _stars = v) : null,
    );
    ChildProfile.currentChild().then(
      (name) => mounted ? setState(() => _childName = name) : null,
    );
  }

  Future<void> _resetProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'إعادة ضبط التقدم؟',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'سيُمسح تقدم $_childName فقط: نجومه والحيوانات التي تعلمها والدروس والأوسمة. تقدم الأطفال الآخرين يبقى كما هو. هل أنت متأكد؟',
          style: const TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء', style: TextStyle(fontSize: 20)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'نعم، امسح التقدم',
              style: TextStyle(fontSize: 20, color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ProgressStore.resetAll();
    if (!mounted) return;
    setState(() => _stars = 0);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('تمت إعادة ضبط التقدم')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade50,
      appBar: AppBar(
        title: const Text(
          'إعدادات الوالدين',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.volume_up, size: 30, color: Colors.brown),
                        SizedBox(width: 8),
                        Text(
                          'مستوى الصوت',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _volume,
                      min: 0,
                      max: 1,
                      divisions: 10,
                      label: '${(_volume * 100).round()}%',
                      onChanged: (v) {
                        setState(() => _volume = v);
                        unawaited(AppSound.instance.setVolume(v));
                      },
                    ),
                    Text(
                      'مستوى الصوت: ${(_volume * 100).round()}%',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.star, size: 30, color: Colors.amber),
                        SizedBox(width: 8),
                        Text(
                          'التقدم',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'نجوم $_childName: $_stars',
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _resetProgress,
                      icon: const Icon(Icons.delete_forever, size: 28),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'إعادة ضبط التقدم',
                          softWrap: false,
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
