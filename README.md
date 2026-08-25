# Hakim | حكيم

تطبيق Flutter يهدف إلى تسهيل الوصول إلى معلومات الأدوية والصيدليات والعيادات
المجانية في قطاع غزة، مع التخطيط لدعم قاعدة أدوية محلية تعمل دون إنترنت.

## الموجود حاليًا

- شاشة تسجيل الدخول.
- شاشة استعادة كلمة المرور بالبريد الإلكتروني أو رقم الهاتف.
- شاشة رمز تحقق من خمسة أرقام مع عدّاد وإعادة إرسال.
- شاشة إعادة تعيين كلمة المرور ورسالة نجاح سفلية.
- تنقّل مكتمل بين الشاشات الأربع.
- تصميم عربي RTL وخط `ThmanyahSerifDisplay` ولون أساسي `#0C3468`.

## التشغيل

```powershell
flutter clean
flutter pub get
flutter run
```

## هيكل الملفات الحالية

```text
lib/main.dart
lib/screens/login_screen.dart
lib/screens/forget_password/forget_password_screen.dart
lib/screens/forget_password/verification_code_screen.dart
lib/screens/forget_password/reset_password_screen.dart
assets/fonts/
assets/images/
test/widget_test.dart
```

## غير منفذ بعد

- ربط تسجيل الدخول واستعادة كلمة المرور بالـAPI.
- شاشة إنشاء الحساب وتسجيل Google وApple.
- الصفحة الرئيسية والبحث عن الأدوية.
- بيانات الأدوية المحلية والعمل دون إنترنت والمزامنة.
- الصيدليات والمخزون والأسعار والخرائط.
- العيادات المجانية والخدمات الطبية.

هذه النسخة مخصصة لتثبيت واجهات المستخدم أولًا، ولا تحتوي ربط API.
