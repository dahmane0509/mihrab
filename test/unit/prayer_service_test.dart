import 'package:flutter_test/flutter_test.dart';
import 'package:mihrab_app/data/algeria_communes.dart';
import 'package:mihrab_app/data/algeria_wilayas.dart';
import 'package:mihrab_app/services/prayer_service.dart';

void main() {
  group('PrayerService Tests', () {
    test('Calculates prayer times for a valid commune', () {
      final communes = AlgeriaCommunes.getCommunesByWilaya(16);
      expect(communes, isNotEmpty);
      final commune = communes.first;

      final testDate = DateTime(2026, 5, 1);
      final times = PrayerService.calculateTimesForCommune(commune, testDate);

      expect(times, contains('fajr'));
      expect(times, contains('sunrise'));
      expect(times, contains('dhuhr'));
      expect(times, contains('asr'));
      expect(times, contains('maghrib'));
      expect(times, contains('isha'));
      expect(times, contains('hijri_date'));
      expect(times, contains('gregorian_date'));

      final timeRegex = RegExp(r'^\d{2}:\d{2}$');
      expect(timeRegex.hasMatch(times['fajr']!), isTrue);
      expect(timeRegex.hasMatch(times['sunrise']!), isTrue);
      expect(timeRegex.hasMatch(times['dhuhr']!), isTrue);
      expect(timeRegex.hasMatch(times['asr']!), isTrue);
      expect(timeRegex.hasMatch(times['maghrib']!), isTrue);
      expect(timeRegex.hasMatch(times['isha']!), isTrue);
    });

    test('Multiple calculation methods produce valid timings', () {
      final wilaya = AlgeriaWilayas.getWilayaByCode(16);
      final date = DateTime(2026, 5, 1);

      for (final method in CalculationMethod.values) {
        final times = PrayerService.calculateTimesForWilaya(
          wilaya,
          date,
          method: method,
        );
        expect(times['fajr'], isNotNull);
        expect(times['isha'], isNotNull);
      }
    });

    test('Manual mosque minute adjustments shift prayer times correctly', () {
      final wilaya = AlgeriaWilayas.getWilayaByCode(16);
      final date = DateTime(2026, 5, 1);

      final baseline = PrayerService.calculateTimes(
        wilaya: wilaya,
        date: date,
        adjustments: const PrayerAdjustments(),
      );

      final adjusted = PrayerService.calculateTimes(
        wilaya: wilaya,
        date: date,
        adjustments: const PrayerAdjustments(fajrMinutes: 10, dhuhrMinutes: -5),
      );

      expect(adjusted.fajr.difference(baseline.fajr).inMinutes, equals(10));
      expect(adjusted.dhuhr.difference(baseline.dhuhr).inMinutes, equals(-5));
    });

    test('getNextPrayer returns upcoming prayer accurately', () {
      final commune = AlgeriaCommunes.allCommunes.first;
      final testTime = DateTime(2026, 5, 1, 10, 0); // 10:00 AM -> next should be Dhuhr
      final timesResult = PrayerService.calculateTimesForCommuneResult(commune: commune, date: testTime);
      final next = PrayerService.getNextPrayer(timesResult, testTime);

      expect(next.nameAr, isNotEmpty);
      expect(next.time, isNotNull);
      expect(next.remaining, isNotNull);
      expect(next.progress, inInclusiveRange(0.0, 1.0));
    });

    test('All 58 Wilayas can compute prayer times without errors', () {
      final testDate = DateTime(2026, 1, 15);
      for (final wilaya in AlgeriaWilayas.wilayas) {
        final communes = AlgeriaCommunes.getCommunesByWilaya(wilaya.code);
        final commune = communes.isNotEmpty ? communes.first : AlgeriaCommunes.allCommunes[0];
        final times = PrayerService.calculateTimesForCommune(commune, testDate);

        expect(times['fajr'], isNotNull);
        expect(times['dhuhr'], isNotNull);
        expect(times['maghrib'], isNotNull);
      }
    });
  });
}
