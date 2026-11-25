// ركن الوالدين — نُقلت من lib/main.dart دون تغيير (المرحلة الثانية 2.3).
import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../services/app_sound.dart';
import '../services/backup_service.dart';
import '../services/child_profile.dart';
import '../services/levels.dart';
import '../services/parent_dashboard.dart';
import '../services/progress_store.dart';
import '../services/screen_time.dart';
import '../widgets/app_footer.dart';
import 'terms_screen.dart';

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
      bottomNavigationBar: const AppFooter.small(),
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
  List<String> _children = [];
  Map<String, int?> _ages = {};
  Map<String, AgeLevel> _levels = {};
  Map<String, int> _childStars = {};
  String _dashboardChild = ChildProfile.defaultChild;
  Map<String, (int, int)> _skills = {};
  int _timeLimit = 0;
  int _timeUsed = 0;
  bool _nightMode = false;
  final TextEditingController _importController = TextEditingController();
  final TextEditingController _newChildController = TextEditingController();
  String _backupMessage = '';
  String _childMessage = '';
  List<BackupFile> _backups = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final volume = await ProgressStore.volume();
    final stars = await ProgressStore.stars();
    final name = await ChildProfile.currentChild();
    final kids = await ChildProfile.children();
    final night = await ProgressStore.nightMode();
    final ages = <String, int?>{};
    final levels = <String, AgeLevel>{};
    final childStars = <String, int>{};
    for (final k in kids) {
      ages[k] = await ChildProfile.childAge(k);
      levels[k] = await LevelService.levelFor(k);
      childStars[k] = await ProgressStore.starsFor(k);
    }
    if (mounted) {
      setState(() {
        _volume = volume;
        _stars = stars;
        _childName = name;
        _children = kids;
        _ages = ages;
        _levels = levels;
        _childStars = childStars;
        _dashboardChild = name;
        _nightMode = night;
      });
    }
    await _loadDashboard();
    // قائمة النسخ تُحمّل في الخلفية: بطء التخزين أو تعذّره
    // لا يجمّد ركن الوالدين ولا يمنع إدارة الأطفال.
    unawaited(_loadBackups());
  }

  Future<void> _loadBackups() async {
    try {
      final list = await BackupService.listBackups();
      if (mounted) setState(() => _backups = list);
    } catch (_) {
      // تعذّر قراءة مجلد النسخ لا يمنع فتح ركن الوالدين.
      if (mounted) setState(() => _backups = []);
    }
  }

  Future<void> _saveBackupFile() async {
    final file = await BackupService.saveToFile();
    await _loadBackups();
    if (!mounted) return;
    setState(
      () => _backupMessage =
          'حُفظت النسخة في ملف: ${file.label} (${file.sizeLabel}).',
    );
  }

  Future<void> _restoreBackupFile(BackupFile file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'استعادة نسخة احتياطية؟',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'سيُتحقق من سلامة الملف (${file.label}) قبل أي استبدال، والقيم التراكمية لا تتراجع أبداً. هل أنت متأكد؟',
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
              'نعم، استعد',
              style: TextStyle(fontSize: 20, color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await BackupService.restoreFromFile(file.path);
    if (!mounted) return;
    if (result.ok) {
      final stars = await ProgressStore.stars();
      if (!mounted) return;
      setState(() {
        _stars = stars;
        _backupMessage = 'تمت الاستعادة من الملف: ${result.restored} قيمة.';
      });
    } else {
      setState(() => _backupMessage = result.error ?? 'تعذرت الاستعادة.');
    }
  }

  Future<void> _deleteBackupFile(BackupFile file) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'حذف النسخة؟',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'سيُحذف ملف النسخة (${file.label}) نهائياً. هل أنت متأكد؟',
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
              'نعم، احذف',
              style: TextStyle(fontSize: 20, color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await BackupService.deleteBackup(file.path);
    await _loadBackups();
    if (mounted) {
      setState(() => _backupMessage = 'حُذف ملف النسخة.');
    }
  }

  Future<void> _loadDashboard() async {
    final skills = await skillProgress(_dashboardChild);
    final limit = await ScreenTime.limitMinutes(_dashboardChild);
    final used = await ScreenTime.minutesToday(_dashboardChild);
    if (mounted) {
      setState(() {
        _skills = skills;
        _timeLimit = limit;
        _timeUsed = used;
      });
    }
  }

  Future<void> _setAge(String child, int? age) async {
    if (age == null) {
      await ChildProfile.clearChildAge(child);
    } else {
      await ChildProfile.setChildAge(child, age);
    }
    final newAge = await ChildProfile.childAge(child);
    final newLevel = await LevelService.levelFor(child);
    if (mounted) {
      setState(() {
        _ages[child] = newAge;
        _levels[child] = newLevel;
      });
    }
  }

  Future<void> _setLevel(String child, AgeLevel level) async {
    await LevelService.setLevel(child, level);
    if (mounted) setState(() => _levels[child] = level);
  }

  Future<void> _setCurrentChild(String child) async {
    await ChildProfile.setCurrent(child);
    final stars = await ProgressStore.stars();
    if (mounted) {
      setState(() {
        _childName = child;
        _stars = stars;
        _dashboardChild = child;
      });
    }
    await _loadDashboard();
  }

  Future<void> _addChild() async {
    final name = _newChildController.text.trim();
    final ok = await ChildProfile.addChild(name);
    if (!mounted) return;
    if (!ok) {
      setState(
        () => _childMessage = 'تعذر إضافة الطفل — تحقق من الاسم (غير مكرر، حتى 20 حرفاً).',
      );
      return;
    }
    _newChildController.clear();
    await _load();
    if (mounted) {
      setState(() => _childMessage = 'أُضيف الطفل $name بنجاح.');
    }
  }

  Future<void> _deleteChild(String child) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'حذف الطفل؟',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'سيُحذف $child وتقدمه كاملاً نهائياً. هل أنت متأكد؟',
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
              'نعم، احذف',
              style: TextStyle(fontSize: 20, color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ChildProfile.removeChild(child);
    await _load();
  }

  @override
  void dispose() {
    _importController.dispose();
    _newChildController.dispose();
    super.dispose();
  }

  Widget _childRow(String child) {
    final isCurrent = child == _childName;
    final age = _ages[child];
    final level = _levels[child] ?? AgeLevel.l56;
    return Card(
      color: isCurrent ? Colors.amber.shade50 : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    child,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (isCurrent)
                  const Chip(
                    label: Text('الحالي'),
                    backgroundColor: Colors.amber,
                  ),
                const SizedBox(width: 8),
                Text(
                  '⭐ ${_childStars[child] ?? 0}',
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('العمر: ', style: TextStyle(fontSize: 20)),
                DropdownButton<int?>(
                  value: age,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('غير محدد'),
                    ),
                    for (var a = 3; a <= 10; a++)
                      DropdownMenuItem<int?>(
                        value: a,
                        child: Text('$a سنوات'),
                      ),
                  ],
                  onChanged: (v) => _setAge(child, v),
                ),
                const SizedBox(width: 12),
                const Text('المستوى: ', style: TextStyle(fontSize: 20)),
                Expanded(
                  child: DropdownButton<AgeLevel>(
                    value: level,
                    isExpanded: true,
                    items: [
                      for (final l in AgeLevel.values)
                        DropdownMenuItem(
                          value: l,
                          child: Text(l.title, softWrap: false),
                        ),
                    ],
                    onChanged: (v) {
                      if (v != null) _setLevel(child, v);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (!isCurrent)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _setCurrentChild(child),
                      child: const Text(
                        'اجعله الحالي',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                if (!isCurrent) const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _children.length <= 1
                        ? null
                        : () => _deleteChild(child),
                    child: const Text(
                      'حذف الطفل',
                      style: TextStyle(fontSize: 20, color: Colors.red),
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

  Future<void> _exportBackup() async {
    final json = await BackupService.exportJson();
    await Clipboard.setData(ClipboardData(text: json));
    if (!mounted) return;
    setState(() {
      _backupMessage =
          'تم نسخ النسخة الاحتياطية (${json.length} حرفاً). الصقها في ملاحظة آمنة واحتفظ بها — بها تقدم كل الأطفال.';
    });
  }

  Future<void> _restoreBackup() async {
    if (_importController.text.trim().isEmpty) {
      setState(
        () => _backupMessage = 'الصق نص النسخة الاحتياطية في المربع أولاً.',
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'استعادة نسخة احتياطية؟',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'ستُكتب قيم النسخة فوق التقدم الحالي. القيم غير الموجودة في النسخة تبقى كما هي. هل أنت متأكد؟',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء', style: TextStyle(fontSize: 20)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'نعم، استعد',
              style: TextStyle(fontSize: 20, color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final result = await BackupService.importJson(_importController.text);
    if (!mounted) return;
    if (result.ok) {
      _importController.clear();
      final stars = await ProgressStore.stars();
      final name = await ChildProfile.currentChild();
      if (!mounted) return;
      setState(() {
        _stars = stars;
        _childName = name;
        _backupMessage = 'تمت الاستعادة: ${result.restored} قيمة.';
      });
    } else {
      setState(() => _backupMessage = result.error ?? 'تعذرت الاستعادة.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
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
      body: SingleChildScrollView(
        child: Padding(
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
                          Icon(
                            Icons.family_restroom,
                            size: 30,
                            color: Colors.brown,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'إدارة الأطفال',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      for (final child in _children) _childRow(child),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _newChildController,
                              decoration: const InputDecoration(
                                hintText: 'اسم طفل جديد',
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _addChild,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.brown,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14,
                                horizontal: 16,
                              ),
                            ),
                            child: const Text(
                              'إضافة',
                              style: TextStyle(fontSize: 22),
                            ),
                          ),
                        ],
                      ),
                      if (_childMessage.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _childMessage,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
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
                          Icon(
                            Icons.school,
                            size: 30,
                            color: Colors.brown,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'متابعة المهارات',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _children.contains(_dashboardChild)
                            ? _dashboardChild
                            : null,
                        hint: const Text('اختر طفلاً'),
                        isExpanded: true,
                        items: [
                          for (final c in _children)
                            DropdownMenuItem(value: c, child: Text(c)),
                        ],
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _dashboardChild = v);
                          unawaited(_loadDashboard());
                        },
                      ),
                      const SizedBox(height: 12),
                      for (final e in _skills.entries) ...[
                        Text(
                          '${e.key}: ${e.value.$1} من ${e.value.$2}',
                          style: const TextStyle(fontSize: 20),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: e.value.$2 == 0
                              ? 0
                              : e.value.$1 / e.value.$2,
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(8),
                          backgroundColor: Colors.grey.shade300,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        'مهارات متقنة: ${masteredSkills(_skills).isEmpty ? 'لا شيء بعد — واصل التعلم!' : masteredSkills(_skills).join('، ')}',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'تحتاج مراجعة: ${reviewSkills(_skills).isEmpty ? 'كل المهارات بخير!' : reviewSkills(_skills).join('، ')}',
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
                          Icon(
                            Icons.timer,
                            size: 30,
                            color: Colors.brown,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'وقت الاستخدام',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'الطفل: $_dashboardChild',
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<int>(
                        value: _timeLimit,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('بلا حد')),
                          DropdownMenuItem(
                            value: 15,
                            child: Text('15 دقيقة يومياً'),
                          ),
                          DropdownMenuItem(
                            value: 30,
                            child: Text('30 دقيقة يومياً'),
                          ),
                          DropdownMenuItem(
                            value: 60,
                            child: Text('60 دقيقة يومياً'),
                          ),
                        ],
                        onChanged: (v) async {
                          if (v == null) return;
                          await ScreenTime.setLimitMinutes(_dashboardChild, v);
                          if (mounted) setState(() => _timeLimit = v);
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'استخدم اليوم: $_timeUsed دقيقة',
                        style: const TextStyle(fontSize: 20),
                      ),
                      Text(
                        _timeLimit == 0
                            ? 'بلا حد يومي'
                            : 'المتبقي اليوم: ${(_timeLimit - _timeUsed).clamp(0, _timeLimit)} دقيقة',
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'عند بلوغ الحد يظهر للطفل تذكير ودود بالراحة (لا قفل للتطبيق).',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  title: const Text(
                    'الوضع الليلي لقصص قبل النوم',
                    style: TextStyle(fontSize: 22),
                  ),
                  value: _nightMode,
                  onChanged: (v) async {
                    await ProgressStore.setNightMode(v);
                    if (mounted) setState(() => _nightMode = v);
                  },
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
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.backup, size: 30, color: Colors.brown),
                          SizedBox(width: 8),
                          Text(
                            'نسخة احتياطية',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'احفظ تقدم كل الأطفال في نص واحد، والصقه هنا لاستعادته بعد حذف التطبيق أو على جهاز آخر. النسخة تبقى عندك ولا تُرسل لأي مكان.',
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _exportBackup,
                        icon: const Icon(Icons.copy, size: 28),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'نسخ نسخة احتياطية',
                            softWrap: false,
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _importController,
                        maxLines: 4,
                        textDirection: TextDirection.ltr,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'الصق نص النسخة الاحتياطية هنا',
                          hintStyle: TextStyle(fontSize: 20),
                        ),
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _restoreBackup,
                        icon: const Icon(Icons.restore, size: 28),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'استعادة من النسخة',
                            softWrap: false,
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'نسخ محفوظة في ملفات',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _saveBackupFile,
                        icon: const Icon(Icons.save, size: 28),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'حفظ نسخة في ملف',
                            softWrap: false,
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_backups.isEmpty)
                        const Text(
                          'لا توجد نسخ محفوظة بعد.',
                          style: TextStyle(fontSize: 20),
                        )
                      else
                        for (final b in _backups)
                          Card(
                            color: Colors.brown.shade50,
                            child: ListTile(
                              title: Text(
                                b.label,
                                style: const TextStyle(fontSize: 20),
                              ),
                              subtitle: Text(
                                b.sizeLabel,
                                style: const TextStyle(fontSize: 18),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.restore,
                                      color: Colors.green,
                                    ),
                                    tooltip: 'استعادة',
                                    onPressed: () => _restoreBackupFile(b),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    tooltip: 'حذف',
                                    onPressed: () => _deleteBackupFile(b),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      if (_backupMessage.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _backupMessage,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
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
                          Icon(
                            Icons.description,
                            size: 30,
                            color: Colors.brown,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'شروط الاستخدام',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'اقرأ شروط استخدام التطبيق كاملة (محفوظة داخل التطبيق وتفتح دون إنترنت).',
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const TermsScreen(),
                            ),
                          ),
                          icon: const Icon(Icons.description, size: 28),
                          label: const Text(
                            'شروط الاستخدام',
                            style: TextStyle(fontSize: 24),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
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

