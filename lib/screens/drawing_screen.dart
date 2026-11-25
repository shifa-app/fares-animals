// الرسم والتلوين — المرحلة الثانية 2.2.
// لوحة رسم حقيقية تعمل دون إنترنت: ألوان، وأحجام فرشاة، وممحاة،
// ومسح، وحفظ الرسمة كملف PNG في مجلد التطبيق. معرض الرسم لكل طفل
// يأتي في المرحلة الثالثة.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';

import '../widgets/app_footer.dart';

class _DrawPoint {
  final Offset offset;
  final Color color;
  final double width;
  const _DrawPoint(this.offset, this.color, this.width);
}

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  final GlobalKey _canvasKey = GlobalKey();
  final List<List<_DrawPoint>> _strokes = [];
  List<_DrawPoint> _current = [];
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
        _DrawPoint(p, _erasing ? Colors.white : _color, _erasing ? 24 : _width),
      ];
    });
  }

  void _addPoint(Offset p) {
    setState(() {
      _current.add(
        _DrawPoint(p, _erasing ? Colors.white : _color, _erasing ? 24 : _width),
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
        const SnackBar(content: Text('ارسم شيئاً أولاً!')),
      );
      return;
    }
    try {
      final box =
          _canvasKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      final size = box.size;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white,
      );
      _drawStrokes(canvas, _strokes);
      final image = await recorder.endRecording().toImage(
        size.width.toInt(),
        size.height.toInt(),
      );
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final drawings = Directory('${dir.path}/drawings');
      await drawings.create(recursive: true);
      final file = File(
        '${drawings.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes.buffer.asUint8List());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حُفظت رسمتك! أحسنت يا فنان!')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حفظ الرسمة، حاول مرة أخرى')),
      );
    }
  }

  static void _drawStrokes(Canvas canvas, List<List<_DrawPoint>> strokes) {
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
        canvas.drawCircle(
          p.offset,
          p.width / 2,
          Paint()..color = p.color,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: const Text(
          'الرسم والتلوين',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        centerTitle: true,
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
            tooltip: 'حفظ الرسمة',
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
                    child: CustomPaint(
                      painter: _DrawingPainter([..._strokes, _current]),
                      size: Size.infinite,
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

class _DrawingPainter extends CustomPainter {
  final List<List<_DrawPoint>> strokes;
  const _DrawingPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    _DrawingScreenState._drawStrokes(canvas, strokes);
  }

  @override
  bool shouldRepaint(_DrawingPainter old) => true;
}
