import 'dart:math';

class QiblaService {
  // Coordinates of the Holy Kaaba in Makkah
  static const double kaabaLat = 21.4225;
  static const double kaabaLng = 39.8262;

  /// Calculates the Qibla angle in degrees (0 - 360) clockwise from North
  static double calculateQiblaDirection(double userLat, double userLng) =>
      calculateQiblaBearing(userLat, userLng);

  /// Alias for backward and forward compatibility
  static double calculateQiblaBearing(double userLat, double userLng) {
    final double phi1 = _toRadians(userLat);
    final double phi2 = _toRadians(kaabaLat);
    final double deltaLambda = _toRadians(kaabaLng - userLng);

    final double y = sin(deltaLambda) * cos(phi2);
    final double x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(deltaLambda);

    double bearing = _toDegrees(atan2(y, x));
    return (bearing + 360.0) % 360.0;
  }

  /// Calculates distance to Makkah in kilometers using the Haversine formula
  static double calculateDistanceToKaabaKm(double userLat, double userLng) =>
      calculateDistanceToKaaba(userLat, userLng);

  /// Alias for backward and forward compatibility
  static double calculateDistanceToKaaba(double userLat, double userLng) {
    const double earthRadiusKm = 6371.0;

    final double dLat = _toRadians(kaabaLat - userLat);
    final double dLng = _toRadians(kaabaLng - userLng);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(userLat)) * cos(_toRadians(kaabaLat)) * sin(dLng / 2) * sin(dLng / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  static double _toRadians(double degrees) => degrees * (pi / 180.0);
  static double _toDegrees(double radians) => radians * (180.0 / pi);
}
