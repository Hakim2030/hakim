# مراجعة مشروع حكيم — نسخة الواجهات

هذه النسخة تنظّم وتثبت شاشات الدخول واستعادة كلمة المرور فقط، ولا تحتوي على
ربط API أو Backend.

## أين يوضع كل ملف؟

| الملف | مكانه داخل المشروع |
|---|---|
| `main.dart` | `lib/main.dart` |
| `login_screen.dart` | `lib/screens/login_screen.dart` |
| `forget_password_screen.dart` | `lib/screens/forget_password/forget_password_screen.dart` |
| `verification_code_screen.dart` | `lib/screens/forget_password/verification_code_screen.dart` |
| `reset_password_screen.dart` | `lib/screens/forget_password/reset_password_screen.dart` |
| `pubspec.yaml` | جذر المشروع |
| `README.md` | جذر المشروع |
| `widget_test.dart` | `test/widget_test.dart` |
| `AndroidManifest.xml` | `android/app/src/main/AndroidManifest.xml` |
| `Info.plist` | `ios/Runner/Info.plist` |
| `manifest.json` | `web/manifest.json` |
| `index.html` | `web/index.html` |

## الخطوط

انسخي ملفات الخط التالية إلى `assets/fonts/`:

- `thmanyahserifdisplay-Light.otf`
- `thmanyahserifdisplay-Regular.otf`
- `thmanyahserifdisplay-Medium.otf`
- `thmanyahserifdisplay-Bold.otf`
- `thmanyahserifdisplay-Black.otf`

العائلة مسجلة في `pubspec.yaml` باسم `ThmanyahSerifDisplay`، وتم ضبطها خطًا
افتراضيًا للتطبيق في `main.dart`.

## الصور

انسخي الملفات التالية إلى `assets/images/`:

- `login_pattern.png`
- `forget_password_pattern.png`
- `google_icon.png`
- `apple_icon.png`
- `success_check.png`

## أهم التعديلات

- توحيد الخط العربي واللون الأساسي `#0C3468` واتجاه RTL.
- حذف أي Home Indicator أسود مرسوم داخل الواجهات.
- توحيد لون شريط النظام السفلي بالأبيض وأيقوناته بالأسود.
- إضافة تحقق محلي لحقول تسجيل الدخول واستعادة كلمة المرور.
- إصلاح الانتقال بين الشاشات الأربع.
- إصلاح مؤقت رمز التحقق، إدخال الأرقام فقط، وإعادة الإرسال.
- إصلاح أيقونة إظهار كلمة المرور ونافذة نجاح إعادة التعيين.
- استخدام صورة `success_check.png` وإضافة زر إغلاق لنافذة النجاح.
- إصلاح أخطاء تكرار في كود الزر كانت تمنع البناء في شاشتي التحقق وإعادة التعيين.
- تحديث اسم التطبيق على Android وiOS والويب إلى «حكيم».
- استبدال اختبار Flutter الافتراضي باختبار شاشة الدخول والانتقال لشاشة الاستعادة.
- استبدال README الافتراضي بوصف فعلي للمشروع وحالته الحالية.

## ما لم يُنفّذ عمدًا

- لا يوجد API أو Backend في هذه النسخة.
- أزرار Google وApple وإنشاء الحساب تعرض رسالة مؤقتة فقط.
- لا توجد بعد شاشات الصفحة الرئيسية أو الأدوية أو الصيدليات أو العيادات.
- معرّف الحزمة ما زال `com.example.hakim`؛ يجب تغييره لاحقًا عند اعتماد معرّف
  رسمي، ولا يُفضّل اختراع معرّف دون قرار من الفريق.

## التشغيل بعد النسخ

```powershell
flutter clean
flutter pub get
flutter analyze
flutter test
flutter run
```

إذا بقي شكل قديم على المحاكي، أوقفي التطبيق تمامًا ثم شغّليه من جديد بعد
`flutter clean`؛ لا تكتفي بـ Hot Reload عند تغيير الخطوط أو `pubspec.yaml`.
