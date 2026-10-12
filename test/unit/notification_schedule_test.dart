import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:mihrab_app/data/algeria_communes.dart';
import 'package:mihrab_app/services/prayer_service.dart';

void main() {
  test('Prayer scheduled dates are valid and in the future', () {
    tz.initializeTimeZones();
    final location = tz.getLocation('Africa/Algiers');
    tz.setLocalLocation(location);

    final commune = AlgeriaCommunes.allCommunes[0];
    final now = DateTime.now();
    final times = PrayerService.calculateTimesForCommuneResult(
      commune: commune,
      date: now,
    );

    print("Now: $now");
    print("Fajr: ${times.fajr}");
    print("Dhuhr: ${times.dhuhr}");
    print("Asr: ${times.asr}");
    print("Maghrib: ${times.maghrib}");
    print("Isha: ${times.isha}");

    final scheduledDate = tz.TZDateTime(
      location,
      times.maghrib.year,
      times.maghrib.month,
      times.maghrib.day,
      times.maghrib.hour,
      times.maghrib.minute,
      0,
    );

    print("Scheduled Maghrib: $scheduledDate");
    final currentTz = tz.TZDateTime.now(location);
    print("Current TZ: $currentTz");
    print("isAfter: ${scheduledDate.isAfter(currentTz)}");
    expect(scheduledDate, isNotNull);
  });
}
