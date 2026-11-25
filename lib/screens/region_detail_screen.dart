// شاشة منطقة في «عالم فارس» — المرحلة الثالثة (2.0-beta):
// وصف المنطقة + حقيقة ممتعة + حيواناتها وتقدم الطفل فيها +
// مغامرة قصيرة لفارس (3 مشاهد مع نطق) + زر لعرض كل حيواناتها.
import 'package:material_ui/material_ui.dart';

import '../data/animals.dart';
import '../data/world_regions.dart';
import '../services/app_sound.dart';
import '../services/progress_store.dart';
import '../widgets/animal_image.dart';
import '../widgets/app_footer.dart';
import 'animals_screen.dart';
import 'fares_world_screen.dart';

class RegionDetailScreen extends StatefulWidget {
  final WorldRegion region;
  final void Function(String category) onOpenCategory;
  const RegionDetailScreen({
    super.key,
    required this.region,
    required this.onOpenCategory,
  });

  @override
  State<RegionDetailScreen> createState() => _RegionDetailScreenState();
}

class _RegionDetailScreenState extends State<RegionDetailScreen> {
  int _learned = 0;
  int _sceneIndex = 0;

  List<Animal> get _regionAnimals =>
      animals.where((a) => a.category == widget.region.id).toList();

  WorldRegionContent get _content =>
      contentForRegion(widget.region.id) ??
      const WorldRegionContent(
        regionId: '',
        description: '',
        funFact: '',
        adventure: [],
      );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final n = await ProgressStore.learnedCount(
      _regionAnimals.map((a) => a.nameAr).toList(),
    );
    if (mounted) setState(() => _learned = n);
  }

  @override
  void dispose() {
    AppSound.instance.stopAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _regionAnimals.length;
    final scenes = _content.adventure;
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.lightGreen.shade50,
      appBar: AppBar(
        title: Text(
          widget.region.name,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: widget.region.color,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _content.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.amber.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '💡 حقيقة ممتعة: ${_content.funFact}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'تعلمت $_learned من $total حيواناً في هذه المنطقة',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: total == 0 ? 0 : _learned / total,
              backgroundColor: Colors.grey.shade300,
              color: widget.region.color,
              minHeight: 12,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => widget.onOpenCategory(widget.region.id),
                icon: const Icon(Icons.pets, size: 30),
                label: Text(
                  'شاهد كل حيوانات ${widget.region.name}',
                  style: const TextStyle(fontSize: 24),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.region.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'حيوانات المنطقة:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _regionAnimals.length,
              itemBuilder: (context, i) {
                final a = _regionAnimals[i];
                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnimalDetailScreen(animal: a),
                    ),
                  ),
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
                              fontSize: 18,
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
            const SizedBox(height: 24),
            const Text(
              'مغامرة فارس 🚀',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      scenes.isEmpty ? '' : scenes[_sceneIndex],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'المشهد ${_sceneIndex + 1} من ${scenes.length}',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _sceneIndex > 0
                              ? () => setState(() => _sceneIndex--)
                              : null,
                          child: const Text(
                            'السابق',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: scenes.isEmpty
                              ? null
                              : () => AppSound.instance.speak(
                                  scenes[_sceneIndex],
                                ),
                          icon: const Icon(Icons.volume_up, size: 28),
                          label: const Text(
                            'اسمع المشهد',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _sceneIndex + 1 < scenes.length
                              ? () => setState(() => _sceneIndex++)
                              : null,
                          child: const Text(
                            'التالي',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
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
