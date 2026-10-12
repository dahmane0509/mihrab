import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../data/algeria_wilayas.dart';
import '../data/algeria_communes.dart';
import '../data/world_cities.dart';

class DetectedLocationResult {
  final Wilaya wilaya;
  final Commune commune;
  final double latitude;
  final double longitude;
  final String source;

  DetectedLocationResult({
    required this.wilaya,
    required this.commune,
    required this.latitude,
    required this.longitude,
    required this.source,
  });
}

class LocationService {
  static bool _isInsideAlgeria(double lat, double lng) {
    return lat >= 18.5 && lat <= 37.5 && lng >= -9.0 && lng <= 12.2;
  }

  static DetectedLocationResult _createResultFromCoordinates({
    required double lat,
    required double lng,
    required String source,
  }) {
    if (_isInsideAlgeria(lat, lng)) {
      final nearestCommune = AlgeriaCommunes.findNearestCommune(lat, lng);
      final parentWilaya = AlgeriaWilayas.getWilayaByCode(nearestCommune.wilayaCode);
      return DetectedLocationResult(
        wilaya: parentWilaya,
        commune: nearestCommune,
        latitude: lat,
        longitude: lng,
        source: source,
      );
    } else {
      // User is located outside Algeria (Global Location)
      final nearestWorldCity = WorldCitiesData.findNearestCity(lat, lng);
      final cityWilaya = nearestWorldCity.toWilaya();
      final cityCommune = Commune(
        id: nearestWorldCity.code,
        wilayaCode: nearestWorldCity.code,
        nameAr: nearestWorldCity.nameAr,
        nameFr: nearestWorldCity.nameFr,
        latitude: lat,
        longitude: lng,
        type: nearestWorldCity.countryAr,
      );
      return DetectedLocationResult(
        wilaya: cityWilaya,
        commune: cityCommune,
        latitude: lat,
        longitude: lng,
        source: "$source (${nearestWorldCity.nameAr})",
      );
    }
  }

  static Future<DetectedLocationResult?> detectLocation() async {
    // 1. Hardware GPS
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          final position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 7),
          );

          return _createResultFromCoordinates(
            lat: position.latitude,
            lng: position.longitude,
            source: "GPS (الأقمار الصناعية)",
          );
        }
      }
    } catch (e) {
      debugPrint("GPS location notice: $e");
    }

    // 2. Network Geolocation Fallback
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      final request = await client.getUrl(Uri.parse('https://ipapi.co/json/'));
      final response = await request.close();

      if (response.statusCode == 200) {
        final jsonString = await response.transform(utf8.decoder).join();
        final dynamic data = json.decode(jsonString);

        if (data is Map<String, dynamic> && data['latitude'] != null && data['longitude'] != null) {
          final lat = (data['latitude'] as num).toDouble();
          final lng = (data['longitude'] as num).toDouble();

          return _createResultFromCoordinates(
            lat: lat,
            lng: lng,
            source: "شبكة الإنترنت (Wi-Fi/4G)",
          );
        }
      }
    } catch (e) {
      debugPrint("Network location notice: $e");
    }

    // 3. Default to Naama (Wilaya 45)
    final defaultCommune = AlgeriaCommunes.allCommunes.firstWhere(
      (c) => c.wilayaCode == 45 && c.nameAr == "النعامة",
      orElse: () => AlgeriaCommunes.allCommunes[0],
    );
    final defaultWilaya = AlgeriaWilayas.getWilayaByCode(45);

    return DetectedLocationResult(
      wilaya: defaultWilaya,
      commune: defaultCommune,
      latitude: defaultCommune.latitude,
      longitude: defaultCommune.longitude,
      source: "الموقع الافتراضي (النعامة)",
    );
  }

  static Future<Wilaya?> detectCurrentWilaya() async {
    final res = await detectLocation();
    return res?.wilaya;
  }
}
