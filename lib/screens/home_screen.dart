// الرئيسية — نُقلت من lib/main.dart دون تغيير (المرحلة الثانية 2.3).
import 'package:material_ui/material_ui.dart';

import 'animals_screen.dart';
import 'drawing_screen.dart';
import 'fares_world_screen.dart';
import 'games_screen.dart';
import 'learn_screen.dart';
import 'math_screen.dart';
import 'parents_screen.dart';
import 'quran_screen.dart';
import 'religion_screen.dart';
import 'stars_screen.dart';
import 'stories_screen.dart';

import '../services/app_sound.dart';
import '../services/child_profile.dart';
import '../services/levels.dart';
import '../services/progress_store.dart';
import '../services/screen_time.dart';

import '../widgets/app_footer.dart';
import '../widgets/big_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _stars = 0;
  String _childName = ChildProfile.defaultChild;
  List<String> _children = ChildProfile.defaultChildren;
  AgeLevel _level = AgeLevel.l56;
  double _mastery = 0.0;
  List<String> _recent = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await ProgressStore.stars();
    final name = await ChildProfile.currentChild();
    final kids = await ChildProfile.children();
    final level = await LevelService.levelFor(name);
    final mastery = await LevelService.mastery(name);
    final recent = await ProgressStore.recentActivities();
    if (mounted) {
      setState(() {
        _stars = s;
        _childName = name;
        _children = kids;
        _level = level;
        _mastery = mastery;
        _recent = recent;
      });
    }
    // تذكير الراحة عند بلوغ حد وقت الاستخدام (مرة واحدة في اليوم).
    if (mounted &&
        await ScreenTime.limitReached(name) &&
        !await ScreenTime.restRemindedToday(name)) {
      await ScreenTime.markRestReminded(name);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'حان وقت الراحة يا $name!',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'لعبت كثيراً اليوم، خذ استراحة قصيرة وعد لاحقاً يا بطل!',
            style: TextStyle(fontSize: 22),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً', style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      );
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
                            final current = await ChildProfile.currentChild();
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
                      await ChildProfile.setCurrent(nameController.text.trim());
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
      bottomNavigationBar: const AppFooter.big(),
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
            icon: const Icon(Icons.volume_up, size: 32),
            tooltip: 'اسمع التعليمات',
            onPressed: () => AppSound.instance.speak(
              'أهلاً يا $_childName! اختر قسماً من الأقسام لتبدأ التعلم واللعب.',
            ),
          ),
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
                          const SizedBox(height: 6),
                          Text(
                            'المستوى: ${_level.title} • ${_level.label}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: _mastery,
                                    minHeight: 10,
                                    backgroundColor: Colors.grey.shade300,
                                    color: Colors.teal,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'الإتقان ${(_mastery * 100).round()}%',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
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
            if (_recent.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'آخر أنشطتك',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final a in _recent)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Chip(
                          label: Text(a, style: const TextStyle(fontSize: 16)),
                          backgroundColor: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ],
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
                    label: 'القرآن',
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
                    label: 'الحروف والكلمات',
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LearnScreen()),
                    ).then((_) => _load()),
                  ),
                  BigButton(
                    icon: Icons.calculate,
                    label: 'الرياضيات',
                    color: Colors.cyan.shade700,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MathScreen(
                          onNumbers: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NumbersScreen(),
                            ),
                          ),
                          onCounting: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CountingGameScreen(),
                            ),
                          ),
                        ),
                      ),
                    ).then((_) => _load()),
                  ),
                  BigButton(
                    icon: Icons.mosque,
                    label: 'التعلم الديني',
                    color: Colors.teal,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReligionScreen()),
                    ).then((_) => _load()),
                  ),
                  BigButton(
                    icon: Icons.bedtime,
                    label: 'القصص',
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
                    label: 'الألعاب',
                    color: Colors.purple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GamesScreen()),
                    ).then((_) => _load()),
                  ),
                  BigButton(
                    icon: Icons.public,
                    label: 'عالم فارس',
                    color: Colors.lightGreen.shade700,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FaresWorldScreen(
                          onOpenCategory: (category) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AnimalsScreen(
                                initialCategory: category,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ).then((_) => _load()),
                  ),
                  BigButton(
                    icon: Icons.star,
                    label: 'نجومي وإنجازاتي',
                    color: Colors.amber.shade700,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StarsScreen()),
                    ).then((_) => _load()),
                  ),
                  BigButton(
                    icon: Icons.brush,
                    label: 'الرسم والتلوين',
                    color: Colors.pink,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DrawingScreen(),
                      ),
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
          ],
        ),
      ),
    );
  }
}

