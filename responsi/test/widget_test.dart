import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsi/screen/login_screen.dart';

void main() {
  testWidgets('Test Form Login Tampil dengan Baik', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    expect(find.text('ShoppingHub'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
