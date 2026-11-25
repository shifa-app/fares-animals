// بطاقة تعليمات فارس المرشد + مزيج شاشات الألعاب:
// - التعليمات تظهر تلقائياً في المرة الأولى فقط لكل لعبة ولكل طفل،
//   وتُنطق عبر AppSound المركزي، وقابلة للتخطي بنقرة على «فهمت، لنبدأ»
//   (توقف النطق فوراً)، وقابلة لإعادة الاستماع من زر السماعة.
// - الخروج من أي لعبة يوقف كل الأصوات فوراً (dispose).
import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../services/game_engine.dart';

/// مزيج مشترك لشاشات الألعاب السبع.
mixin GameScreenMixin<T extends StatefulWidget> on State<T> {
  String get gameId;
  String get guideText;

  bool _guideVisible = false;
  bool get guideVisible => _guideVisible;

  /// تُستدعى في initState: تعرض التعليمات وتنطقها في المرة الأولى فقط.
  Future<void> initGuide() async {
    if (await GameEngine.shouldShowGuide(gameId)) {
      if (!mounted) return;
      setState(() => _guideVisible = true);
      await GameEngine.markGuideShown(gameId);
      await GameEngine.speakGuide(guideText);
    }
  }

  /// تخطي التعليمات بنقرة (يوقف النطق فوراً).
  void dismissGuide() {
    unawaited(GameEngine.stopAudio());
    if (mounted) setState(() => _guideVisible = false);
  }

  /// إعادة الاستماع للتعليمات في أي وقت.
  void replayGuide() => unawaited(GameEngine.speakGuide(guideText));

  @override
  void dispose() {
    unawaited(GameEngine.stopAudio());
    super.dispose();
  }
}

/// بطاقة التعليمات: نص قصير + زر تخطٍّ + زر إعادة استماع.
class GameGuideCard extends StatelessWidget {
  final String text;
  final VoidCallback onDismiss;
  final VoidCallback onReplay;
  const GameGuideCard({
    super.key,
    required this.text,
    required this.onDismiss,
    required this.onReplay,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade100,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up, size: 36),
                  tooltip: 'اسمع التعليمات',
                  onPressed: onReplay,
                ),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'فهمت، لنبدأ!',
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// حوار إكمال اللعبة: نجمة + تشجيع + إعادة اللعب أو الخروج.
Future<bool?> showGameDoneDialog(
  BuildContext context, {
  required String gameName,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text(
        'رائع! 🎉',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
      content: Text(
        'أكملت لعبة $gameName، وكسبت نجمة! ⭐',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'العب مجدداً',
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
}
