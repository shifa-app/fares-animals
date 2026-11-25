// عالم فارس — المرحلة الثانية 2.2.
// خريطة من 7 مناطق تُفتح بالتعلم لا بالشراء: كل منطقة لها حد أدنى
// من الحيوانات المتعلمة. الضغط على منطقة مفتوحة يفتح حيواناتها،
// والمنطقة المغلقة تعرض رسالة تشجيع بما ينقصها (بلا إحباط أبداً).
// المحتوى الأعمق لكل منطقة (مغامرات وقصص) يأتي في المرحلة الثالثة.
import 'package:material_ui/material_ui.dart';

import '../data/animals.dart';
import '../services/progress_store.dart';
import '../widgets/app_footer.dart';
import '../widgets/big_button.dart';
import 'region_detail_screen.dart';

class WorldRegion {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int requiredLearned;
  const WorldRegion({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.requiredLearned,
  });
}

class FaresWorld {
  static const List<WorldRegion> regions = [
    WorldRegion(
      id: 'forest',
      name: 'الغابة',
      icon: Icons.park,
      color: Colors.green,
      requiredLearned: 0,
    ),
    WorldRegion(
      id: 'farm',
      name: 'المزرعة',
      icon: Icons.agriculture,
      color: Colors.orange,
      requiredLearned: 5,
    ),
    WorldRegion(
      id: 'sea',
      name: 'البحر',
      icon: Icons.waves,
      color: Colors.blue,
      requiredLearned: 10,
    ),
    WorldRegion(
      id: 'birds',
      name: 'عالم الطيور',
      icon: Icons.flutter_dash,
      color: Colors.teal,
      requiredLearned: 15,
    ),
    WorldRegion(
      id: 'desert',
      name: 'الصحراء',
      icon: Icons.wb_sunny,
      color: Colors.amber,
      requiredLearned: 20,
    ),
    WorldRegion(
      id: 'reptiles',
      name: 'عالم الزواحف والحشرات',
      icon: Icons.bug_report,
      color: Colors.brown,
      requiredLearned: 25,
    ),
    WorldRegion(
      id: 'polar',
      name: 'القطب والثلج',
      icon: Icons.ac_unit,
      color: Colors.lightBlue,
      requiredLearned: 30,
    ),
  ];

  /// هل المنطقة مفتوحة لهذا العدد من الحيوانات المتعلمة؟
  static bool isUnlocked(int learnedCount, WorldRegion region) =>
      learnedCount >= region.requiredLearned;
}

class FaresWorldScreen extends StatefulWidget {
  /// يُستدعى عند الضغط على منطقة مفتوحة، بمعرّف فئتها.
  final void Function(String category) onOpenCategory;
  const FaresWorldScreen({super.key, required this.onOpenCategory});

  @override
  State<FaresWorldScreen> createState() => _FaresWorldScreenState();
}

class _FaresWorldScreenState extends State<FaresWorldScreen> {
  int _learned = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final n = await ProgressStore.learnedCount(
      animals.map((a) => a.nameAr).toList(),
    );
    if (mounted) setState(() => _learned = n);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.lightGreen.shade50,
      appBar: AppBar(
        title: const Text(
          'عالم فارس',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightGreen.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'تعلّمت $_learned من ${animals.length} حيواناً — كلما تعلمت أكثر فتحت مناطق جديدة!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  for (final region in FaresWorld.regions)
                    _RegionCard(
                      region: region,
                      unlocked: FaresWorld.isUnlocked(_learned, region),
                      remaining: region.requiredLearned - _learned,
                      onTap: () {
                        if (FaresWorld.isUnlocked(_learned, region)) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RegionDetailScreen(
                                region: region,
                                onOpenCategory: widget.onOpenCategory,
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'ستفتح ${region.name} عندما تتعلم ${region.requiredLearned - _learned} حيوانات أخرى — أحسنت، واصل!',
                              ),
                            ),
                          );
                        }
                      },
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

class _RegionCard extends StatelessWidget {
  final WorldRegion region;
  final bool unlocked;
  final int remaining;
  final VoidCallback onTap;
  const _RegionCard({
    required this.region,
    required this.unlocked,
    required this.remaining,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!unlocked) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade400,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 48, color: Colors.white),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  region.name,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                'تبقى $remaining حيوانات',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
    return BigButton(
      icon: region.icon,
      label: region.name,
      color: region.color,
      onTap: onTap,
    );
  }
}
