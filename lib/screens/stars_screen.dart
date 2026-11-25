// نجومي وإنجازاتي — المرحلة الثانية 2.6.
// أوسمة مرئية (17 وساماً تُفتح من التقدم الفعلي)، وتقدم لكل مهارة،
// وسجل آخر ما تعلمه الطفل، ومستواه الحالي.
// القاعدة: لا خصم أبداً — النجوم والأوسمة تُكسب بالتعلم فقط،
// والخطأ لا يسحب شيئاً، والتشجيع والتعلم التدريجي هما الأساس.
import 'package:material_ui/material_ui.dart';

import '../data/animals.dart';
import '../data/letters.dart';
import '../data/quran.dart';
import '../data/religion.dart';
import '../data/stories.dart';
import '../services/badges.dart';
import '../services/child_profile.dart';
import '../services/levels.dart';
import '../services/progress_store.dart';
import '../widgets/app_footer.dart';

class StarsScreen extends StatefulWidget {
  const StarsScreen({super.key});
  @override
  State<StarsScreen> createState() => _StarsScreenState();
}

/// مفاتيح التعلم الديني غير التحفيظ (أسماء الله + قصص الأنبياء + آداب).
List<String> get _dinKeys => [
  ...allahNames.keys.map((k) => 'name_$k'),
  ...stories.map((st) => 'story_${st.title}'),
  ...manners.keys.map((k) => 'manner_$k'),
];

class _StarsScreenState extends State<StarsScreen> {
  int _stars = 0;
  String _childName = ChildProfile.defaultChild;
  AgeLevel _level = AgeLevel.l56;
  double _mastery = 0;
  final Map<String, (int, int)> _skills = {};
  Set<String> _badges = {};
  List<String> _recent = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final child = await ChildProfile.currentChild();
    final level = await LevelService.levelFor(child);
    final mastery = await LevelService.mastery(child);
    final learned = await ProgressStore.learnedCount(
      animals.map((a) => a.nameAr).toList(),
    );
    final memorized = await ProgressStore.religionCount([
      for (final ms in memorizeSurahs) 'memorize_${ms.number}',
    ]);
    final arLetters = await ProgressStore.religionCount(
      arabicLetters.map((e) => 'letter_ar_${e.letter}').toList(),
    );
    final enLetters = await ProgressStore.religionCount(
      englishLetters.map((e) => 'letter_en_${e.letter}').toList(),
    );
    final nums = await ProgressStore.religionCount(
      numbers.map((e) => 'number_${e.value}').toList(),
    );
    final bed = await ProgressStore.religionCount(
      bedtimeStories.map((st) => 'story_bed_${st.title}').toList(),
    );
    final din = await ProgressStore.religionCount(_dinKeys);
    final diamond = await ProgressStore.diamondUnlocked();
    final quizzes = await completedQuizCount();
    final badges = await unlockedBadges();
    final recent = await ProgressStore.recentActivities();
    final stars = await ProgressStore.stars();
    if (mounted) {
      setState(() {
        _stars = stars;
        _childName = child;
        _level = level;
        _mastery = mastery;
        _skills
          ..clear()
          ..addAll({
            'الحيوانات': (learned, animals.length),
            'القرآن': (memorized, memorizeSurahs.length),
            'الحروف العربية': (arLetters, arabicLetters.length),
            'الحروف الإنجليزية': (enLetters, englishLetters.length),
            'الأرقام': (nums, numbers.length),
            'قصص قبل النوم': (bed, bedtimeStories.length),
            'التعلم الديني': (din, _dinKeys.length),
            'مراحل الماس': (diamond, 10),
            'الاختبارات': (quizzes, quizGroupKeys.length),
          });
        _badges = badges;
        _recent = recent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.amber.shade50,
      appBar: AppBar(
        title: const Text(
          'نجومي وإنجازاتي',
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
            Card(
              color: Colors.amber.shade100,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.star, size: 64, color: Colors.amber),
                    Text(
                      'نجومي: $_stars',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'مستواي: ${_level.title} (${_level.label})',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _mastery,
                      minHeight: 16,
                      borderRadius: BorderRadius.circular(10),
                      backgroundColor: Colors.white,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'إتقاني: ${(_mastery * 100).round()}%',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'تقدمي في كل مهارة',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            for (final e in _skills.entries) ...[
              _progress(e.key, e.value.$1, e.value.$2),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 12),
            const Text(
              'أوسمتي',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'فتحت ${_badges.length} من ${badgeDefs.length} أوسمة',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemCount: badgeDefs.length,
              itemBuilder: (context, i) {
                final def = badgeDefs[i];
                final unlocked = _badges.contains(def.id);
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
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          unlocked ? def.icon : Icons.lock,
                          size: 36,
                          color:
                              unlocked ? Colors.amber.shade800 : Colors.grey,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          def.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: unlocked ? Colors.brown : Colors.grey,
                          ),
                        ),
                        if (!unlocked)
                          Text(
                            def.requirement,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.grey,
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
              'آخر ما تعلمته',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_recent.isEmpty)
              const Text(
                'ابدأ التعلم لتظهر أنشطتك هنا!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              )
            else
              for (final a in _recent)
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    title: Text(a, style: const TextStyle(fontSize: 20)),
                  ),
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
