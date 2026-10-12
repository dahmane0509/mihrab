import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mihrab_app/data/algeria_communes.dart';
import 'package:mihrab_app/data/algeria_wilayas.dart';
import 'package:mihrab_app/screens/next_prayer_screen.dart';
import 'package:mihrab_app/services/language_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });
  testWidgets('NextPrayerScreen renders prayer card, countdown and triggers callbacks', (WidgetTester tester) async {
    final wilaya = AlgeriaWilayas.getWilayaByCode(16);
    final commune = AlgeriaCommunes.getCommunesByWilaya(16).first;

    bool drawerOpened = false;
    bool searchTriggered = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NextPrayerScreen(
            currentWilaya: wilaya,
            currentCommune: commune,
            onOpenDrawer: () {
              drawerOpened = true;
            },
            onSearchWilaya: () {
              searchTriggered = true;
            },
            onLocationChanged: (_, __) {},
          ),
        ),
      ),
    );

    await tester.pump();

    // Verify location label and next prayer title
    expect(find.textContaining('ولاية ${wilaya.nameAr}'), findsWidgets);
    expect(find.textContaining('الصلاة القادمة'), findsWidgets);
    expect(find.textContaining(commune.nameAr), findsWidgets);

    // Verify audio action buttons exist
    expect(find.text('سماع الصوت'), findsOneWidget);
    expect(find.text('إيقاف الصوت'), findsOneWidget);

    // Test Open Drawer callback
    final menuButton = find.byIcon(Icons.menu);
    expect(menuButton, findsOneWidget);
    await tester.tap(menuButton);
    await tester.pump();
    expect(drawerOpened, isTrue);

    // Test Search Wilaya callback via AppBar title
    final locationHeader = find.textContaining('ولاية ${wilaya.nameAr}').first;
    await tester.tap(locationHeader);
    await tester.pump();
    expect(searchTriggered, isTrue);

    // Unmount widget so periodic timer cancels cleanly
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('NextPrayerScreen renders correctly in English', (WidgetTester tester) async {
    await LanguageService.setLanguage('en');

    final wilaya = AlgeriaWilayas.getWilayaByCode(16);
    final commune = AlgeriaCommunes.getCommunesByWilaya(16).first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NextPrayerScreen(
            currentWilaya: wilaya,
            currentCommune: commune,
            onOpenDrawer: () {},
            onSearchWilaya: () {},
            onLocationChanged: (_, __) {},
          ),
        ),
      ),
    );

    await tester.pump();

    // Verify translated elements
    expect(find.textContaining('Next Prayer'), findsWidgets);
    expect(find.text('Play Sound'), findsOneWidget);
    expect(find.text('Stop Audio'), findsOneWidget);
    expect(find.textContaining(commune.nameFr), findsWidgets);

    // Reset language back to Arabic and unmount
    await LanguageService.setLanguage('ar');
    await tester.pumpWidget(const SizedBox());
  });
}


