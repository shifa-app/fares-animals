// صورة الحيوان مع تحميل تدريجي وصورة بديلة — نُقلت من lib/main.dart دون تغيير (المرحلة الثانية 2.3).
import 'package:material_ui/material_ui.dart';

import '../data/animals.dart';

Widget animalImage(Animal a, {double height = 200}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(20),
    child: Image.network(
      a.imageUrl,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return SizedBox(
          height: height,
          child: const Center(child: CircularProgressIndicator()),
        );
      },
      errorBuilder: (context, error, stack) => Container(
        height: height,
        color: Colors.orange.shade100,
        child: const Center(
          child: Icon(Icons.pets, size: 90, color: Colors.orange),
        ),
      ),
    ),
  );
}

