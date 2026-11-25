// G08 رسام الحيوانات: صفحات تلوين أصلية (رسوم بخطوط فارغة) +
// ألوان وفرش وممحاة + حفظ الرسمة في معرض الطفل (ملف لكل طفل).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

import '../../services/child_profile.dart';
import '../../services/game_engine.dart';
import '../../widgets/app_footer.dart';
import '../../widgets/game_guide.dart';
import '../../widgets/game_painters.dart';

class _ColorPoint {
  final Offset offset;
  final Color color;
  final double width;
  const _ColorPoint(this.offset, this.color, this.width);
}

class ColoringGameScreen extends StatefulWidget {
  const ColoringGameScreen({super.key});
  @override
  State<ColoringGameScreen> createState() => _ColoringGameScreenState();
}

class _ColoringGameScreenState extends State<ColoringGameScreen>
    with GameScreenMixin {
  @override
  String get gameId => 'g08';

  @override
  String get guideText =>
      'أنا فارس! اختر حيواناً ولوّنه بألوانك الجميلة، ثم احفظه في معرضك!';

  String? _selectedId;
  List<File> _gallery = [];
  String _childName = '';

  @override
  void initState() {
    super.initState();
    initGuide();
    _loadGallery();
  }

  Future<void> _loadGallery() async {
    try {
      final child = await ChildProfile.currentChild();
      final dir = await getApplicationDocumentsDirectory();
      final drawings = Directory('${dir.path}/drawings');
      if (!await drawings.exists()) return;
      final files = await drawings
          .list()
          .where(
            (e) =>
                e is File &&
                e.path.split('/').last.startsWith('coloring_${child}_'),
          )
          .toList();
      files.sort((a, b) => b.path.compareTo(a.path));
      if (mounted) {
        setState(() {
          _childName = child;
          _gallery = files.cast<File>();
        });
      }
    } catch (_) {
      // تعذر قراءة المعرض لا يوقف اللعبة — يظهر فارغاً.
    }
  }

  Future<void> _viewColoring(File file) async {
    final stateContext = context;
    final deleted = await showDialog<bool>(
      context: stateContext,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.file(file),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('إغلاق', style: TextStyle(fontSize: 22)),
                ),
                TextButton(
                  onPressed: () async {
                    final sure = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('حذف الرسمة؟'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('لا'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('نعم، احذفها'),
                          ),
                        ],
                      ),
                    );
                    if (!mounted) return;
                    if (sure == true) {
                      try {
                        await file.delete();
                      } catch (_) {}
                      if (!stateContext.mounted) return;
                      Navigator.pop(stateContext, true);
                    }
                  },
                  child: const Text(
                    'حذف',
                    style: TextStyle(fontSize: 22, color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    if (deleted == true) _loadGallery();
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedId != null) {
      return ColoringCanvasScreen(
        animalId: _selectedId!,
        onBack: () {
          setState(() => _selectedId = null);
          _loadGallery();
        },
      );
    }
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: const Text(
          'رسام الحيوانات',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        centerTitle: true,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (guideVisible)
              GameGuideCard(
                text: guideText,
                onDismiss: dismissGuide,
                onReplay: replayGuide,
              ),
            const Text(
              'اختر حيواناً لتلوينه:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: shadowAnimals.length,
              itemBuilder: (context, i) {
                final animal = shadowAnimals[i];
                return InkWell(
                  onTap: () => setState(() => _selectedId = animal.id),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.pink.shade200,
                        width: 3,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CustomPaint(
                            painter: ColoringPainter(animal.id),
                            size: const Size(120, 120),
                          ),
                        ),
                        Text(
                          animal.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              _gallery.isEmpty
                  ? 'معرض ${_childName.isEmpty ? 'الطفل' : _childName} فارغ — لوّن أول صفحة!'
                  : 'معرضي 🎨 (${_gallery.length})',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_gallery.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: _gallery.length,
                itemBuilder: (context, i) {
                  return InkWell(
                    onTap: () => _viewColoring(_gallery[i]),
                    borderRadius: BorderRadius.circular(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(_gallery[i], fit: BoxFit.cover),
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

/// لوحة تلوين صفحة واحدة: الخطوط + فرشاة الطفل + حفظ PNG.
class ColoringCanvasScreen extends StatefulWidget {
  final String animalId;
  final VoidCallback onBack;
  const ColoringCanvasScreen({
    super.key,
    required this.animalId,
    required this.onBack,
  });
  @override
  State<ColoringCanvasScreen> createState() => _ColoringCanvasScreenState();
}

class _ColoringCanvasScreenState extends State<ColoringCanvasScreen>
    with GameScreenMixin {
  @override
  String get gameId => 'g08';

  @override
  String get guideText =>
      'أنا فارس! اختر حيواناً ولوّنه بألوانك الجميلة، ثم احفظه في معرضك!';

  final GlobalKey _canvasKey = GlobalKey();
  final List<List<_ColorPoint>> _strokes = [];
  List<_ColorPoint> _current = [];
  Color _color = Colors.blue;
  double _width = 8;
  bool _erasing = false;

  static const List<Color> palette = [
    Colors.black,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
  ];

  void _startStroke(Offset p) {
    setState(() {
      _current = [
        _ColorPoint(p, _erasing ? Colors.white : _color, _erasing ? 24 : _width),
      ];
    });
  }

  void _addPoint(Offset p) {
    setState(() {
      _current.add(
        _ColorPoint(p, _erasing ? Colors.white : _color, _erasing ? 24 : _width),
      );
    });
  }

  void _endStroke() {
    if (_current.isEmpty) return;
    setState(() {
      _strokes.add(_current);
      _current = [];
    });
  }

  Future<void> _save() async {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لوّن شيئاً أولاً!')),
      );
      return;
    }
    try {
      final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      final size = box.size;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white,
      );
      ColoringPainter(widget.animalId).paint(canvas, size);
      _drawStrokes(canvas, _strokes);
      final image = await recorder.endRecording().toImage(
        size.width.toInt(),
        size.height.toInt(),
      );
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;
      final child = await ChildProfile.currentChild();
      final dir = await getApplicationDocumentsDirectory();
      final drawings = Directory('${dir.path}/drawings');
      await drawings.create(recursive: true);
      final file = File(
        '${drawings.path}/coloring_${child}_${widget.animalId}_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes.buffer.asUint8List());
      await GameEngine.completeGame('g08');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حُفظت في معرضك! أحسنت يا فنان!')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حفظ الرسمة، حاول مرة أخرى')),
      );
    }
  }

  static void _drawStrokes(Canvas canvas, List<List<_ColorPoint>> strokes) {
    for (final stroke in strokes) {
      for (var i = 0; i < stroke.length - 1; i++) {
        final a = stroke[i];
        final b = stroke[i + 1];
        canvas.drawLine(
          a.offset,
          b.offset,
          Paint()
            ..color = a.color
            ..strokeWidth = a.width
            ..strokeCap = StrokeCap.round,
        );
      }
      if (stroke.length == 1) {
        final p = stroke.first;
        canvas.drawCircle(p.offset, p.width / 2, Paint()..color = p.color);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final animal = shadowAnimals.firstWhere(
      (s) => s.id == widget.animalId,
      orElse: () => shadowAnimals.first,
    );
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: Text(
          'لوّن الـ ${animal.name}',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30),
          tooltip: 'رجوع',
          onPressed: widget.onBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 30),
            tooltip: 'مسح اللوحة',
            onPressed: () => setState(() {
              _strokes.clear();
              _current = [];
            }),
          ),
          IconButton(
            icon: const Icon(Icons.save, size: 30),
            tooltip: 'حفظ في معرضي',
            onPressed: _save,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Container(
                key: _canvasKey,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: GestureDetector(
                    onPanStart: (d) => _startStroke(d.localPosition),
                    onPanUpdate: (d) => _addPoint(d.localPosition),
                    onPanEnd: (_) => _endStroke(),
                    child: Stack(
                      children: [
                        CustomPaint(
                          painter: ColoringPainter(widget.animalId),
                          size: Size.infinite,
                        ),
                        CustomPaint(
                          painter: _StrokePainter([..._strokes, _current]),
                          size: Size.infinite,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final c in palette)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _color = c;
                        _erasing = false;
                      }),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _color == c && !_erasing
                                ? Colors.black
                                : Colors.white,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ToolChip(
                  label: 'رفيع',
                  selected: !_erasing && _width == 4,
                  onTap: () => setState(() {
                    _width = 4;
                    _erasing = false;
                  }),
                ),
                _ToolChip(
                  label: 'وسط',
                  selected: !_erasing && _width == 8,
                  onTap: () => setState(() {
                    _width = 8;
                    _erasing = false;
                  }),
                ),
                _ToolChip(
                  label: 'سميك',
                  selected: !_erasing && _width == 14,
                  onTap: () => setState(() {
                    _width = 14;
                    _erasing = false;
                  }),
                ),
                _ToolChip(
                  label: 'ممحاة',
                  selected: _erasing,
                  onTap: () => setState(() => _erasing = true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToolChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 18)),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _StrokePainter extends CustomPainter {
  final List<List<_ColorPoint>> strokes;
  const _StrokePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    _ColoringCanvasScreenState._drawStrokes(canvas, strokes);
  }

  @override
  bool shouldRepaint(_StrokePainter old) => true;
}
