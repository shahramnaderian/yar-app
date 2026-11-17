import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yar/screens/auth_screen.dart';

void main() {
  testWidgets('Yar sign-in screen renders in Persian', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AuthScreen()));
    expect(find.text('یار'), findsOneWidget);
    expect(find.text('ورود'), findsOneWidget);
    expect(find.text('حساب نداری؟ ثبت‌نام کن'), findsOneWidget);
  });
}
