// الشاشة الافتتاحية — نُقلت من lib/main.dart دون تغيير (المرحلة الثانية 2.3).
import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  bool _gone = false;

  @override
  void initState() {
    super.initState();
    // الشاشة الافتتاحية: صورة المستخدم بملء الشاشة 5 ثوانٍ ثم الرئيسية،
    // أو فوراً عند الضغط على «تخطٍّ».
    _timer = Timer(const Duration(seconds: 5), _goHome);
  }

  void _goHome() {
    if (_gone || !mounted) return;
    _gone = true;
    _timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/splash.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: _goHome,
                icon: const Icon(Icons.skip_next, size: 32),
                label: const Text(
                  'تخطٍّ',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  foregroundColor: Colors.brown,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

