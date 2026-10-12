import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mihrab_app/data/algeria_communes.dart';
import 'package:mihrab_app/data/algeria_wilayas.dart';
import 'package:mihrab_app/screens/prayer_times_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('PrayerTimesScreen displays all prayer items, date navigation, and handles notifications', (WidgetTester tester) async {
    final wilaya = AlgeriaWilayas.getWilayaByCode(16);
    final commune = AlgeriaCommunes.getCommunesByWilaya(16).first;

    bool drawerCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: PrayerTimesScreen(
          currentWilaya: wilaya,
          currentCommune: commune,
          onOpenDrawer: () {
            drawerCalled = true;
          },
        ),
      ),
    );

    await tester.pump();

    // Verify Title in AppBar
    expect(find.textContaining('أوقات الصلاة'), findsOneWidget);
    expect(find.textContaining(commune.nameAr), findsOneWidget);

    // Verify All 6 Prayer Names are displayed
    expect(find.text('الصبح'), findsOneWidget);
    expect(find.text('الشروق'), findsOneWidget);
    expect(find.text('الظهر'), findsOneWidget);
    expect(find.text('العصر'), findsOneWidget);
    expect(find.text('المغرب'), findsOneWidget);
    expect(find.text('العشاء'), findsOneWidget);

    // Test Drawer button
    final drawerBtn = find.byIcon(Icons.menu);
    expect(drawerBtn, findsOneWidget);
    await tester.tap(drawerBtn);
    await tester.pump();
    expect(drawerCalled, isTrue);

    // Test Date Navigation (Next Day and Previous Day)
    final nextDayBtn = find.byIcon(Icons.chevron_left);
    expect(nextDayBtn, findsOneWidget);
    await tester.tap(nextDayBtn);
    await tester.pump();

    final prevDayBtn = find.byIcon(Icons.chevron_right);
    expect(prevDayBtn, findsOneWidget);
    await tester.tap(prevDayBtn);
    await tester.pump();

    // Verify notification buttons for 5 daily prayers (all except sunrise)
    final notifIcons = find.byIcon(Icons.notifications_active);
    expect(notifIcons, findsNWidgets(5));

    // Tap first notification icon to mute it
    await tester.tap(notifIcons.first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify one prayer is now muted
    expect(find.byIcon(Icons.notifications_off_outlined), findsOneWidget);
    expect(find.byIcon(Icons.notifications_active), findsNWidgets(4));
  });
}
