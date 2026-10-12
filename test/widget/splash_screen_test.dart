import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mihrab_app/screens/splash_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SplashScreen renders brand title, subtitle badge, and loading indicator', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    // Initial frame
    await tester.pump();
    // Advance entrance animation
    await tester.pump(const Duration(milliseconds: 1000));

    // Verify Brand Name, Subtitle & Indicator
    expect(find.text('مِـحْـرَابْ'), findsOneWidget);
    expect(find.text('M I H R A B'), findsOneWidget);
    expect(find.text('مواقيت الصلاة والقرآن'), findsOneWidget);

    // Verify Circular Progress Indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Dispose widget cleanly to verify timer cancellation in dispose()
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
