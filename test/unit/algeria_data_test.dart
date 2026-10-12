import 'package:flutter_test/flutter_test.dart';
import 'package:mihrab_app/data/algeria_communes.dart';
import 'package:mihrab_app/data/algeria_wilayas.dart';

void main() {
  group('Algeria Data Repository Tests', () {
    test('AlgeriaWilayas contains 58 wilayas and matches standard codes', () {
      expect(AlgeriaWilayas.wilayas.length, equals(58));

      final adrar = AlgeriaWilayas.getWilayaByCode(1);
      expect(adrar.nameAr, contains('أدرار'));

      final algiers = AlgeriaWilayas.getWilayaByCode(16);
      expect(algiers.nameAr, contains('الجزائر'));

      final naama = AlgeriaWilayas.getWilayaByCode(45);
      expect(naama.nameAr, contains('النعامة'));
    });

    test('AlgeriaWilayas findNearestWilaya returns closest wilaya by coordinates', () {
      // Coordinates near Algiers (36.75, 3.05)
      final nearest = AlgeriaWilayas.findNearestWilaya(36.75, 3.05);
      expect(nearest.code, equals(16));
    });

    test('AlgeriaCommunes covers comprehensive communes across all 58 wilayas', () {
      expect(AlgeriaCommunes.allCommunes.length, greaterThanOrEqualTo(400));

      for (int code = 1; code <= 58; code++) {
        final communes = AlgeriaCommunes.getCommunesByWilaya(code);
        expect(communes, isNotEmpty, reason: 'Wilaya $code should have at least one commune/locality');
      }
    });

    test('AlgeriaCommunes searchCommunes finds expected localities', () {
      final searchResults = AlgeriaCommunes.searchCommunes('مشرية');
      expect(searchResults, isNotEmpty);
      expect(searchResults.any((c) => c.nameAr.contains('مشرية')), isTrue);
    });
  });
}
