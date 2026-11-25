// شاشة الرياضيات — المرحلة الثانية 2.2.
// قسم مستقل في الرئيسية (كان جزءاً من شاشة «تعلّم»): الأرقام ولعبة العدّ.
// الشاشتان المستهدفتان تعيشان في lib/main.dart حتى البند 2.3، لذلك
// تصل إليهما هذه الشاشة عبر ردّي نداء يمررهما لها الرئيسية.
import 'package:material_ui/material_ui.dart';

import '../widgets/app_footer.dart';
import '../widgets/big_button.dart';

class MathScreen extends StatelessWidget {
  final VoidCallback onNumbers;
  final VoidCallback onCounting;
  const MathScreen({
    super.key,
    required this.onNumbers,
    required this.onCounting,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.cyan.shade50,
      appBar: AppBar(
        title: const Text(
          'الرياضيات',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.cyan.shade700,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.calculate,
                label: 'الأرقام 1 - 20',
                color: Colors.green,
                onTap: onNumbers,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 128,
              child: BigButton(
                icon: Icons.format_list_numbered,
                label: 'لعبة العدّ',
                color: Colors.pink,
                onTap: onCounting,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
