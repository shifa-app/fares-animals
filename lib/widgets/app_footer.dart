// الفوتر الموحد: الحقوق + الإهداء — نُقل من lib/main.dart دون تغيير
// (المرحلة الثانية 2.2) لتستخدمه الشاشات الجديدة في lib/screens
// دون استيراد دائري.
import 'package:material_ui/material_ui.dart';

import '../app_version.dart';
import '../services/child_profile.dart';

/// سطر الحقوق الثابت في كل الصفحات.
const String appRightsLine = 'جميع الحقوق محفوظة © فارس والحيوانات';

/// سطر رقم الإصدار — أسفل الإهداء، بخط صغير هادئ.
const String appVersionLine = 'الإصدار $appVersion';

/// فوتر موحد لكل الصفحات: سطر الحقوق + الإهداء باسم الطفل الحالي.
/// [AppFooter.big] للرئيسية (الإهداء بخطه الكبير داخل إطاره البرتقالي)،
/// و[AppFooter.small] لباقي الصفحات (خط صغير).
class AppFooter extends StatefulWidget {
  final bool big;
  const AppFooter.big({super.key}) : big = true;
  const AppFooter.small({super.key}) : big = false;
  @override
  State<AppFooter> createState() => _AppFooterState();
}

class _AppFooterState extends State<AppFooter> {
  String _childName = ChildProfile.defaultChild;

  @override
  void initState() {
    super.initState();
    ChildProfile.currentChild().then(
      (name) => mounted ? setState(() => _childName = name) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dedication = ChildProfile.dedicationFor(_childName);
    if (widget.big) {
      return SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange.shade200, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dedication,
                textAlign: TextAlign.center,
                softWrap: true,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                appVersionLine,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              const Text(
                appRightsLine,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dedication,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              appVersionLine,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            const Text(
              appRightsLine,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
