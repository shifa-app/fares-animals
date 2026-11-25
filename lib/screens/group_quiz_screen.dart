// اختبار قصير بعد كل مجموعة حيوانات — المرحلة الثانية 2.5.
// بلا مؤقت وبلا خصم نجوم: تشجيع فقط، ونجمة واحدة لإكمال اختبار
// كل مجموعة (مرة واحدة مهما أعيد الاختبار).
import 'dart:math';

import 'package:material_ui/material_ui.dart';

import '../data/animal_science.dart';
import '../data/animals.dart';
import '../services/app_sound.dart';
import '../services/progress_store.dart';
import '../widgets/animal_image.dart';
import '../widgets/app_footer.dart';

class QuizQuestion {
  /// 'name' (ما اسم هذا الحيوان؟) أو 'sound' (ما هذا الصوت؟)
  /// أو 'class' (ما تصنيفه العلمي؟).
  final String kind;
  final Animal animal;
  final List<String> options;
  final String correct;
  const QuizQuestion({
    required this.kind,
    required this.animal,
    required this.options,
    required this.correct,
  });
}

/// يبني أسئلة الاختبار من حيوانات المجموعة.
/// 5 أسئلة كحد أقصى، و3 خيارات لكل سؤال، والصحيح من ضمنها.
/// أسئلة الصوت مقصورة على أصحاب الصوت الحقيقي.
/// إن كانت المجموعة أقل من 3 حيوانات فلا اختبار (لا خيارات كافية).
List<QuizQuestion> buildQuizQuestions(List<Animal> group, {int? seed}) {
  if (group.length < 3) return [];
  final rng = Random(seed);
  final pool = List<Animal>.from(group)..shuffle(rng);
  final soundPool = pool.where((a) => a.hasRealSound).toList();
  final count = pool.length < 5 ? pool.length : 5;
  final questions = <QuizQuestion>[];
  for (var i = 0; i < count; i++) {
    final a = pool[i];
    var kind = ['name', 'sound', 'class'][i % 3];
    if (kind == 'sound' && (!a.hasRealSound || soundPool.length < 3)) {
      kind = 'name';
    }
    if (kind == 'sound') {
      final others =
          soundPool.where((o) => o.nameAr != a.nameAr).toList()
            ..shuffle(rng);
      final opts = [a.nameAr, others[0].nameAr, others[1].nameAr]
        ..shuffle(rng);
      questions.add(
        QuizQuestion(kind: kind, animal: a, options: opts, correct: a.nameAr),
      );
    } else if (kind == 'class') {
      final label = scienceFor(a)?.sciClass.label ?? '؟';
      final others =
          SciClass.values.map((c) => c.label).where((l) => l != label).toList()
            ..shuffle(rng);
      final opts = [label, others[0], others[1]]..shuffle(rng);
      questions.add(
        QuizQuestion(kind: kind, animal: a, options: opts, correct: label),
      );
    } else {
      final others =
          pool.where((o) => o.nameAr != a.nameAr).toList()..shuffle(rng);
      final opts = [a.nameAr, others[0].nameAr, others[1].nameAr]
        ..shuffle(rng);
      questions.add(
        QuizQuestion(kind: kind, animal: a, options: opts, correct: a.nameAr),
      );
    }
  }
  return questions;
}

class GroupQuizScreen extends StatefulWidget {
  final String groupKey;
  final String groupLabel;
  final List<Animal> animals;
  final int? seed;
  const GroupQuizScreen({
    super.key,
    required this.groupKey,
    required this.groupLabel,
    required this.animals,
    this.seed,
  });
  @override
  State<GroupQuizScreen> createState() => _GroupQuizScreenState();
}

class _GroupQuizScreenState extends State<GroupQuizScreen> {
  late List<QuizQuestion> _questions;
  int _index = 0;
  int _score = 0;
  String? _selected;
  bool _done = false;
  bool _starAwarded = false;

  @override
  void initState() {
    super.initState();
    _questions = buildQuizQuestions(widget.animals, seed: widget.seed);
  }

  void _answer(String option) {
    if (_selected != null) return;
    final q = _questions[_index];
    final correct = option == q.correct;
    setState(() {
      _selected = option;
      if (correct) _score++;
    });
    if (correct) AppSound.instance.praise();
  }

  Future<void> _next() async {
    if (_index + 1 >= _questions.length) {
      final awarded = await ProgressStore.awardStarsOnce(
        'quiz_${widget.groupKey}',
        1,
      );
      if (mounted) {
        setState(() {
          _done = true;
          _starAwarded = awarded;
        });
      }
    } else {
      setState(() {
        _index++;
        _selected = null;
      });
    }
  }

  void _replay() {
    setState(() {
      _questions = buildQuizQuestions(widget.animals);
      _index = 0;
      _score = 0;
      _selected = null;
      _done = false;
      _starAwarded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.amber.shade50,
      appBar: AppBar(
        title: Text(
          'اختبر نفسك: ${widget.groupLabel}',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _questions.isEmpty
          ? const Center(
              child: Text(
                'هذه المجموعة صغيرة جداً للاختبار',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            )
          : _done
              ? _resultView()
              : _questionView(),
    );
  }

  Widget _questionView() {
    final q = _questions[_index];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'سؤال ${_index + 1} من ${_questions.length}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (q.kind == 'name') ...[
            const Text(
              'ما اسم هذا الحيوان؟',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            animalImage(q.animal, height: 220),
          ] else if (q.kind == 'sound') ...[
            const Text(
              'ما هذا الصوت؟',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () =>
                  AppSound.instance.playAnimalSound(q.animal),
              icon: const Icon(Icons.volume_up, size: 36),
              label: const Text('اسمع الصوت', style: TextStyle(fontSize: 26)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ] else ...[
            Text(
              'ما التصنيف العلمي لـ ${q.animal.nameAr}؟',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            animalImage(q.animal, height: 180),
          ],
          const SizedBox(height: 16),
          for (final option in q.options) _optionButton(q, option),
          if (_selected != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: Text(
                _index + 1 >= _questions.length ? 'النتيجة' : 'السؤال التالي',
                style: const TextStyle(fontSize: 26),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _optionButton(QuizQuestion q, String option) {
    final isCorrect = option == q.correct;
    final isSelected = option == _selected;
    Color? color;
    if (_selected != null) {
      if (isCorrect) {
        color = Colors.green.shade300;
      } else if (isSelected) {
        color = Colors.red.shade300;
      } else {
        color = Colors.grey.shade200;
      }
    }
    final optionAnimal = q.kind == 'class'
        ? null
        : animals.where((a) => a.nameAr == option).firstOrNull;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () => _answer(option),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: optionAnimal == null
            ? Text(option, style: const TextStyle(fontSize: 26))
            : Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 90,
                      height: 70,
                      child: animalImage(optionAnimal, height: 70),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _resultView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events, size: 90, color: Colors.amber),
            const SizedBox(height: 16),
            const Text(
              'أحسنت يا بطل!',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'أجبت عن $_score من ${_questions.length} أسئلة',
              style: const TextStyle(fontSize: 26),
            ),
            const SizedBox(height: 8),
            Text(
              _starAwarded
                  ? 'حصلت على نجمة جديدة!'
                  : 'أكملت الاختبار، واصل التعلم!',
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _replay,
              icon: const Icon(Icons.replay, size: 32),
              label: const Text('العب مجدداً', style: TextStyle(fontSize: 26)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('رجوع', style: TextStyle(fontSize: 24)),
            ),
          ],
        ),
      ),
    );
  }
}
