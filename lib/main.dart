import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'screens/splash_screen.dart';
import 'services/app_sound.dart';
import 'services/child_profile.dart';
import 'services/download_manager.dart';
import 'services/screen_time.dart';

/// اسم التطبيق الثابت في النظام؛ العنوان داخل الشاشات يتغير مع الطفل.
const String appTitle = 'فارس والحيوانات';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ترحيل تقدم النسخ القديمة إلى ملف فارس قبل أي قراءة للتقدم.
  await ChildProfile.migrateLegacyProgress();
  // تجهيز فهرس التنزيلات المسبقة (بلا انتظار — غيابه يعني البث).
  unawaited(DownloadManager.instance.init());
  runApp(const FaresAnimalsApp());
}

class FaresAnimalsApp extends StatefulWidget {
  const FaresAnimalsApp({super.key});
  @override
  State<FaresAnimalsApp> createState() => _FaresAnimalsAppState();
}

class _FaresAnimalsAppState extends State<FaresAnimalsApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // إيقاف كل صوت فور انتقال التطبيق للخلفية.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      AppSound.instance.stopAll();
      unawaited(ScreenTime.noteBackground());
    } else if (state == AppLifecycleState.resumed) {
      unawaited(ScreenTime.noteForeground());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'فارس والحيوانات',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const SplashScreen(),
    );
  }
}

