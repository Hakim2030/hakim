import 'package:flutter_test/flutter_test.dart';
import 'package:hakim/main.dart';

void main() {
  testWidgets('تظهر شاشة تسجيل الدخول', (tester) async {
    await tester.pumpWidget(const Hakim());

    expect(find.text('مرحباً بك في حكيم'), findsOneWidget);
    expect(find.text('تسجيل الدخول'), findsOneWidget);
    expect(find.text('نسيت كلمة المرور؟'), findsOneWidget);
  });
}
