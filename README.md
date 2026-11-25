# فارس والحيوانات

تطبيق أندرويد تعليمي متكامل للأطفال — «فارس والحيوانات».

برنامج تعليمي مسلٍّ لطفل عمره 5 سنوات: 100 حيوان بصور وأصوات حقيقية،
وتحفيظ القرآن (21 سورة قصيرة مع التلاوة)، والتعليم الديني (أذكار، وضوء،
صلاة، أسماء الله الحسنى، آداب)، والحروف العربية والإنجليزية، والأرقام
من 1 إلى 20، وألعاب تعليمية، وقصص وحدوتة قبل النوم بصوت، ونجوم وتقدم.

## البناء محلياً

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release --split-per-abi
```

ملفات APK الناتجة في `build/app/outputs/flutter-apk/` — الملف الموصى به
للهواتف الحديثة هو `app-arm64-v8a-release.apk`.

## التوقيع (مهم)

النسخة موقعة بمخزن debug مثبَّت في `android/debug.keystore` (بصمة
SHA-256 ‏`3F:85:02:BB:57:22:77:52:C1:83:84:B7:A7:71:3D:B1:48:7D:25:2D:8D:A8:E8:08:32:7F:AC:C9:60:13:1B:85`).
هذا المخزن **لا يُرفع إلى Git أبداً** (مستثنى في `.gitignore`) — المستودع عام.
مخزن التوقيع الذي وقّع نسخة v1.0.0 الأولى (بصمة `2D:7D:…:4F:92`) مفقود
ولا يمكن استرجاعه؛ المخزن المعتمد من v1.0.1 فصاعداً هو المخزن أعلاه.

## البناء على Codemagic والإصدارات

- ملف `codemagic.yaml` يبني تلقائياً عند دفع أي وسم `v*`
  (مثل `v1.0.2`): `linux_x2`، ‏Flutter stable، ‏Java 17.
- قبل أول بناء: ارفع نسخة من `android/debug.keystore` إلى Codemagic
  (Team settings > codemagic.yaml settings > Code signing identities >
  Android keystores) باسم مرجعي `fares-animals-debug-keystore`.
- لإصدار نسخة جديدة: حدّث `version:` في `pubspec.yaml`، ثم
  `git tag vX.Y.Z && git push origin vX.Y.Z`، فيبني Codemagic،
  ثم أرفق ملف `app-arm64-v8a-release.apk` من مخرجات البناء إلى
  إصدار GitHub بنفس الوسم — الرابط الدائم للتحميل:
  `https://github.com/shifa-app/fares-animals/releases/download/vX.Y.Z/app-arm64-v8a-release.apk`

## الإهداء

إهداء إلى ابني حبيبي فارس اسامة ابراهيم عبدالحكيم.
