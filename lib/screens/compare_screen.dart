// مقارنة حيوانين جنباً إلى جنب — المرحلة الثانية 2.5.
import 'package:material_ui/material_ui.dart';

import '../data/animal_science.dart';
import '../data/animals.dart';
import '../widgets/animal_image.dart';
import '../widgets/app_footer.dart';

class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});
  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  Animal? _first;
  Animal? _second;

  Future<void> _pick(bool isFirst) async {
    final picked = await Navigator.push<Animal>(
      context,
      MaterialPageRoute(builder: (_) => const AnimalPickerScreen()),
    );
    if (picked == null) return;
    setState(() {
      if (isFirst) {
        _first = picked;
      } else {
        _second = picked;
      }
    });
  }

  void _swap() {
    setState(() {
      final tmp = _first;
      _first = _second;
      _second = tmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.amber.shade50,
      appBar: AppBar(
        title: const Text(
          'قارن بين حيوانين',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _slot(_first, true)),
                IconButton(
                  icon: const Icon(Icons.swap_horiz, size: 36),
                  tooltip: 'بدّل بينهما',
                  onPressed:
                      (_first != null && _second != null) ? _swap : null,
                ),
                Expanded(child: _slot(_second, false)),
              ],
            ),
            if (_first != null && _second != null) ...[
              const SizedBox(height: 16),
              _comparisonTable(_first!, _second!),
            ] else
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Text(
                  'اختر حيوانين لترى الفرق بينهما!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _slot(Animal? animal, bool isFirst) {
    return InkWell(
      onTap: () => _pick(isFirst),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: animal == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle, size: 48, color: Colors.orange),
                  const SizedBox(height: 8),
                  Text(
                    isFirst ? 'اختر الحيوان الأول' : 'اختر الحيوان الثاني',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              )
            : Column(
                children: [
                  Expanded(child: animalImage(animal, height: 120)),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      animal.nameAr,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _comparisonTable(Animal a, Animal b) {
    final sa = scienceFor(a);
    final sb = scienceFor(b);
    final rows = <(String, String, String)>[
      ('الاسم', a.nameAr, b.nameAr),
      ('التصنيف العلمي', sa?.sciClass.label ?? '؟', sb?.sciClass.label ?? '؟'),
      ('أين يعيش؟', a.home, b.home),
      ('يتحرك', sa?.movement ?? '؟', sb?.movement ?? '؟'),
      ('حجمه', sa?.size ?? '؟', sb?.size ?? '؟'),
      ('يعيش', sa?.lifespan ?? '؟', sb?.lifespan ?? '؟'),
      ('أليف أم بري؟', _petLabel(sa), _petLabel(sb)),
      ('نوع الغذاء', sa?.diet ?? '؟', sb?.diet ?? '؟'),
    ];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            for (final (label, va, vb) in rows) ...[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      va,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 19),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      vb,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 19),
                    ),
                  ),
                ],
              ),
              const Divider(),
            ],
          ],
        ),
      ),
    );
  }

  String _petLabel(AnimalScience? s) =>
      s == null ? '؟' : (s.isPet ? 'أليف' : 'بري');
}

/// منتقي حيوان: شبكة كل الحيوانات، والضغط على حيوان يعيده.
class AnimalPickerScreen extends StatelessWidget {
  const AnimalPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.amber.shade50,
      appBar: AppBar(
        title: const Text(
          'اختر حيواناً',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: animals.length,
        itemBuilder: (context, i) {
          final a = animals[i];
          return InkWell(
            onTap: () => Navigator.pop(context, a),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Expanded(child: animalImage(a, height: 90)),
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
    );
  }
}
