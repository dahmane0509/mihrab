import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mihrab_app/data/algeria_communes.dart';
import 'package:mihrab_app/data/algeria_wilayas.dart';
import 'package:mihrab_app/screens/prayer_screen.dart';

void main() {
  testWidgets('PrayerScreen displays location, prayer countdown, all prayers with mute toggles, and quick shortcuts', (WidgetTester tester) async {
    final wilaya = AlgeriaWilayas.getWilayaByCode(16); // Alger
    final commune = AlgeriaCommunes.getCommunesByWilaya(16).first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrayerScreen(
            currentWilaya: wilaya,
            currentCommune: commune,
            onLocationChanged: (_, __) {},
          ),
        ),
      ),
    );

    await tester.pump();

    // Verify Wilaya and Commune info in Header
    expect(find.textContaining(wilaya.nameAr), findsWidgets);
    expect(find.textContaining(commune.nameAr), findsWidgets);

    // Verify Location button and search action icons
    expect(find.byIcon(Icons.my_location), findsOneWidget);
    expect(find.byIcon(Icons.swap_vert), findsOneWidget);
    expect(find.textContaining("تغيير البلدية"), findsOneWidget);

    // Verify Prayers list items
    expect(find.text("الفجر"), findsWidgets);
    expect(find.text("الشروق"), findsWidgets);
    expect(find.text("الظهر"), findsWidgets);
    expect(find.text("العصر"), findsWidgets);
    expect(find.text("المغرب"), findsWidgets);
    expect(find.text("العشاء"), findsWidgets);

    // Verify Quick Action shortcuts
    expect(find.text("القرآن الكريم"), findsOneWidget);
    expect(find.text("البث المباشر"), findsOneWidget);
    expect(find.text("حصن المسلم"), findsOneWidget);
    expect(find.text("بوصلة القبلة"), findsOneWidget);

    // Scroll to reveal prayer tiles
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
    await tester.pump();

    // Verify Mute/Unmute notification toggles exist
    expect(find.byIcon(Icons.notifications_active), findsWidgets);

    // Toggle a prayer notification icon
    final firstNotifBtn = find.byIcon(Icons.notifications_active).first;
    await tester.tap(firstNotifBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify feedback SnackBar appears
    expect(find.textContaining("صلاة"), findsWidgets);
  });
}
