import 'package:flutter_test/flutter_test.dart';
import 'package:mihrab_app/data/world_cities.dart';
import 'package:mihrab_app/services/prayer_service.dart';

void main() {
  group('WorldCitiesData & Global Calculations Tests', () {
    test('Contains diverse worldwide cities across all continents', () {
      expect(WorldCitiesData.cities.length, greaterThanOrEqualTo(25));

      final makkah = WorldCitiesData.getCityByCode(1001);
      expect(makkah, isNotNull);
      expect(makkah!.nameAr, contains('مكة'));

      final paris = WorldCitiesData.getCityByCode(1020);
      expect(paris, isNotNull);
      expect(paris!.nameEn, equals('Paris'));
    });

    test('Searches world cities in Arabic, English, and French', () {
      final searchEn = WorldCitiesData.searchCities('london');
      expect(searchEn.any((c) => c.code == 1023), isTrue);

      final searchAr = WorldCitiesData.searchCities('القدس');
      expect(searchAr.any((c) => c.code == 1003), isTrue);

      final searchFr = WorldCitiesData.searchCities('Caire');
      expect(searchFr.any((c) => c.code == 1005), isTrue);
    });

    test('Finds nearest world city given latitude and longitude', () {
      // Near Eiffel Tower in Paris
      final nearestParis = WorldCitiesData.findNearestCity(48.8584, 2.2945);
      expect(nearestParis.nameEn, equals('Paris'));

      // Near Grand Mosque in Makkah
      final nearestMakkah = WorldCitiesData.findNearestCity(21.4225, 39.8262);
      expect(nearestMakkah.nameEn, contains('Makkah'));
    });

    test('Calculates valid prayer times for international cities', () {
      final makkah = WorldCitiesData.getCityByCode(1001)!;
      final makkahWilaya = makkah.toWilaya();

      final timesMakkah = PrayerService.calculateTimesForWilaya(
        makkahWilaya,
        DateTime(2026, 4, 15),
      );

      expect(timesMakkah.containsKey('fajr'), isTrue);
      expect(timesMakkah.containsKey('dhuhr'), isTrue);
      expect(timesMakkah.containsKey('asr'), isTrue);
      expect(timesMakkah.containsKey('maghrib'), isTrue);
      expect(timesMakkah.containsKey('isha'), isTrue);

      final timePattern = RegExp(r'^\d{2}:\d{2}$');
      expect(timePattern.hasMatch(timesMakkah['fajr']!), isTrue);
      expect(timePattern.hasMatch(timesMakkah['dhuhr']!), isTrue);
      expect(timePattern.hasMatch(timesMakkah['maghrib']!), isTrue);
    });
  });
}
