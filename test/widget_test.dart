import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakim/screens/login_screen.dart';

Widget buildLoginApp() {
  return const MaterialApp(
    home: Directionality(
      textDirection: TextDirection.rtl,
      child: LoginScreen(),
    ),
  );
}

void main() {
  testWidgets('يرفض البريد غير الصحيح في شاشة تسجيل الدخول',
      (tester) async {
    await tester.pumpWidget(buildLoginApp());

    await tester.enterText(
      find.byType(TextField).first,
      'user@example.com',
    );
    await tester.enterText(
      find.byType(TextField).last,
      '12345678',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'تسجيل الدخول'));
    await tester.pump();

    expect(
      find.text('أدخل بريد Gmail صحيحًا مثل name@gmail.com'),
      findsOneWidget,
    );
  });

  testWidgets('تظهر شاشة تسجيل الدخول وتفتح استعادة كلمة المرور',
      (tester) async {
    await tester.pumpWidget(buildLoginApp());

    expect(find.text('مرحباً بك في حكيم'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('نسيت كلمة المرور؟'), findsOneWidget);

    await tester.tap(find.text('نسيت كلمة المرور؟'));
    await tester.pumpAndSettle();

    expect(find.text('نسيت كلمة المرور'), findsOneWidget);
    expect(find.text('حساب الإيميل'), findsOneWidget);
    expect(find.text('رقم الهاتف'), findsOneWidget);
  });
}
