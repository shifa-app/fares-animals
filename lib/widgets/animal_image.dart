// صورة الحيوان مع تحميل تدريجي وصورة بديلة — نُقلت من lib/main.dart دون تغيير (المرحلة الثانية 2.3).
// التنزيل المسبق (2.0-beta): إن كانت الصورة منزّلة محلياً تُعرض
// من الملف، وإلا تُبث من الشبكة كما قبل.
import 'dart:io';

import 'package:material_ui/material_ui.dart';

import '../data/animals.dart';
import '../services/download_manager.dart';

Widget animalImage(Animal a, {double height = 200}) {
  final localPath = DownloadManager.instance.localImagePath(a.imageUrl);
  final Widget image;
  if (localPath != null) {
    image = Image.file(
      File(localPath),
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => _fallback(height),
    );
  } else {
    image = Image.network(
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
      errorBuilder: (context, error, stack) => _fallback(height),
    );
  }
  return ClipRRect(borderRadius: BorderRadius.circular(20), child: image);
}

Widget _fallback(double height) => Container(
  height: height,
  color: Colors.orange.shade100,
  child: const Center(
    child: Icon(Icons.pets, size: 90, color: Colors.orange),
  ),
);
