// بطاقة التنزيل المسبق في ركن الوالدين — المرحلة الثالثة (2.0-beta):
// تعرض حالة تنزيل صور الحيوانات وأصواتها، وزرّي التحميل والحذف.
import 'package:material_ui/material_ui.dart';

import '../services/download_manager.dart';

class OfflineDownloadsCard extends StatefulWidget {
  final DownloadManager? manager;
  const OfflineDownloadsCard({super.key, this.manager});

  @override
  State<OfflineDownloadsCard> createState() => _OfflineDownloadsCardState();
}

class _OfflineDownloadsCardState extends State<OfflineDownloadsCard> {
  DownloadManager get _manager => widget.manager ?? DownloadManager.instance;

  OfflineStatus? _status;
  bool _downloading = false;
  int _done = 0;
  int _total = 0;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final status = await _manager.status();
    if (mounted) setState(() => _status = status);
  }

  Future<void> _download() async {
    setState(() {
      _downloading = true;
      _done = 0;
      // العدد الكلي معروف مسبقاً: شريط التقدم محدد من أول إطار
      // (قيمة null تجعله متحركاً بلا نهاية فيمنع pumpAndSettle).
      _total = DownloadManager.totalItems;
      _message = '';
    });
    final report = await _manager.downloadAll(
      onProgress: (done, total) {
        if (mounted) {
          setState(() {
            _done = done;
            _total = total;
          });
        }
      },
    );
    if (!mounted) return;
    setState(() {
      _downloading = false;
      _message = report.failed == 0
          ? 'اكتمل التنزيل! الصور والأصوات تعمل الآن دون إنترنت.'
          : 'تم تنزيل ${report.done} من ${report.total} (تعذر تنزيل ${report.failed} — جرّب مجدداً لاحقاً).';
    });
    await _refresh();
  }

  Future<void> _delete() async {
    final sure = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف التنزيلات؟'),
        content: const Text(
          'ستُحذف الصور والأصوات المنزّلة، وتعود للبث من الإنترنت.',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لا', style: TextStyle(fontSize: 20)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('نعم، احذفها', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
    if (sure != true || !mounted) return;
    await _manager.deleteAll();
    if (!mounted) return;
    setState(() => _message = 'حُذفت التنزيلات.');
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final status = _status;
    final complete = status?.isComplete ?? false;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.download, size: 30, color: Colors.teal),
                SizedBox(width: 8),
                Text(
                  'التنزيل المسبق',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'حمّل صور الحيوانات وأصواتها مرة واحدة، لتعمل دون إنترنت. صوت القرآن يبقى بثاً.',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 12),
            if (status == null)
              const Text('جارٍ فحص التنزيلات...', style: TextStyle(fontSize: 20))
            else
              Text(
                status.downloaded == 0
                    ? 'لم يُنزَّل شيء بعد.'
                    : 'تم تنزيل ${status.downloaded} من ${status.total} (${status.sizeLabel})',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            if (_downloading) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _total == 0 ? 0 : _done / _total,
                minHeight: 12,
              ),
              const SizedBox(height: 8),
              Text(
                'جارٍ التنزيل... $_done / $_total',
                style: const TextStyle(fontSize: 20),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _downloading || complete ? null : _download,
                    icon: const Icon(Icons.download, size: 28),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'حمّل الصور والأصوات',
                        softWrap: false,
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _downloading || (status?.downloaded ?? 0) == 0
                            ? null
                            : _delete,
                    icon: const Icon(Icons.delete, size: 28),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'احذف التنزيلات',
                        softWrap: false,
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            if (_message.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(_message, style: const TextStyle(fontSize: 20)),
            ],
          ],
        ),
      ),
    );
  }
}
