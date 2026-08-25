# تطبيق طلبات فحص الأعمال (WIR Manager)

نسخة Flutter عربية RTL قابلة للبناء كـ Android APK.

## المتطلبات
- Flutter 3.x
- Android Studio + Android SDK

## التشغيل
```bash
flutter pub get
flutter run
```

## إنشاء APK
```bash
flutter build apk --release
```
الملف الناتج عادةً:
`build/app/outputs/flutter-apk/app-release.apk`

## ملاحظات
هذه النسخة MVP تعمل محليًا داخل التطبيق، وتشمل لوحة التحكم، إنشاء الطلبات، قائمة الطلبات، وتحديث حالة الطلب من شاشة المهندس.
رفع الملفات، تسجيل الدخول، قاعدة البيانات، الإشعارات، والتوقيع الإلكتروني تحتاج ربط Backend في المرحلة التالية.
