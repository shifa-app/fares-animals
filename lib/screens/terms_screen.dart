// شروط الاستخدام — شاشة قراءة منسقة، نص محلي (بلا إنترنت)،
// تمرير كامل مع SafeArea واتجاه RTL صريح، بلا قصّ للنص.
// تُفتح من ركن الوالدين فقط (بعد بوابة الوالدين).
import 'package:material_ui/material_ui.dart';

import '../data/terms.dart';
import '../widgets/app_footer.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter.small(),
      backgroundColor: Colors.brown.shade50,
      appBar: AppBar(
        title: const Text(
          'شروط الاستخدام',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _buildTermsWidgets(),
            ),
          ),
        ),
      ),
    );
  }

  /// تنسيق النص المعتمد سطراً سطراً: عنوان، تاريخ، فقرات،
  /// عناوين أقسام مرقمة، ونقاط. النص نفسه حرفي بلا تعديل.
  List<Widget> _buildTermsWidgets() {
    final lines = termsFullText.trim().split('\n');
    final widgets = <Widget>[];
    final headingPattern = RegExp(r'^\d+\. ');
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 12));
        continue;
      }
      if (i == 0) {
        // عنوان الشروط.
        widgets.add(
          Text(
            line,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
        );
        continue;
      }
      if (line.startsWith('تاريخ آخر تحديث:')) {
        widgets.add(
          Text(
            line,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
          ),
        );
        continue;
      }
      if (headingPattern.hasMatch(line)) {
        widgets.add(const SizedBox(height: 8));
        widgets.add(
          Text(
            line,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
        );
        continue;
      }
      if (line.startsWith('- ')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 20)),
                Expanded(
                  child: Text(
                    line.substring(2),
                    style: const TextStyle(fontSize: 20, height: 1.7),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            line,
            style: const TextStyle(fontSize: 20, height: 1.8),
          ),
        ),
      );
    }
    return widgets;
  }
}
