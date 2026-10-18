import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/quran_reciters_catalog.dart';

class QuranAudioRecitersService {
  static const String _prefActiveReciterKey = 'quran_active_reciter_id';
  static const String _prefCustomRecitersKey = 'quran_custom_reciters';

  static final List<QuranReciter> _customReciters = [];
  static List<QuranReciter> _allReciters = List.from(QuranRecitersCatalog.defaultReciters);
  static String _activeReciterId = "jaza";

  static final ValueNotifier<String> activeReciterNotifier =
      ValueNotifier<String>("jaza");
  static final ValueNotifier<int> recitersVersionNotifier =
      ValueNotifier<int>(0);

  /// Initialize and load saved custom reciters and selected active reciter
  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final rawCustom = prefs.getString(_prefCustomRecitersKey);
      if (rawCustom != null && rawCustom.isNotEmpty) {
        try {
          final List<dynamic> list = jsonDecode(rawCustom) as List<dynamic>;
          _customReciters.clear();
          _customReciters.addAll(
            list.map((item) => QuranReciter.fromJson(item as Map<String, dynamic>)),
          );
        } catch (_) {
          _customReciters.clear();
        }
      }

      _rebuildRecitersList();

      final savedId = prefs.getString(_prefActiveReciterKey);
      if (savedId != null && isReciterAvailable(savedId)) {
        _activeReciterId = savedId;
      } else {
        _activeReciterId = "jaza";
      }
      activeReciterNotifier.value = _activeReciterId;
    } catch (_) {
      _rebuildRecitersList();
    }
  }

  static void _rebuildRecitersList() {
    final Map<String, QuranReciter> map = {};
    for (final r in QuranRecitersCatalog.defaultReciters) {
      map[r.id] = r;
    }
    for (final r in _customReciters) {
      map[r.id] = r;
    }
    _allReciters = map.values.toList();
    recitersVersionNotifier.value++;
  }

  static List<QuranReciter> get allReciters => List.unmodifiable(_allReciters);

  static String get activeReciterId => _activeReciterId;

  static QuranReciter get activeReciter => getReciterById(_activeReciterId);

  static bool isReciterAvailable(String id) =>
      _allReciters.any((r) => r.id == id);

  static QuranReciter getReciterById(String id) {
    return _allReciters.firstWhere(
      (r) => r.id == id,
      orElse: () => QuranRecitersCatalog.defaultReciters[0],
    );
  }

  static Future<void> setActiveReciter(String id) async {
    if (!isReciterAvailable(id)) return;
    _activeReciterId = id;
    activeReciterNotifier.value = id;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefActiveReciterKey, id);
    } catch (_) {}
  }

  /// Add reciter from catalog or custom
  static Future<void> addReciter(QuranReciter reciter, {bool activateNow = true}) async {
    final index = _allReciters.indexWhere((r) => r.id == reciter.id);
    if (index == -1) {
      _customReciters.add(reciter);
      _rebuildRecitersList();
      await _persistCustomReciters();
    }

    if (activateNow) {
      await setActiveReciter(reciter.id);
    }
  }

  /// Remove user-added custom reciter
  static Future<bool> removeCustomReciter(String id) async {
    final exists = _customReciters.any((r) => r.id == id);
    if (!exists) return false;

    _customReciters.removeWhere((r) => r.id == id);
    _rebuildRecitersList();
    await _persistCustomReciters();

    if (_activeReciterId == id) {
      await setActiveReciter("jaza");
    }
    return true;
  }

  static Future<void> _persistCustomReciters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_customReciters.map((r) => r.toJson()).toList());
      await prefs.setString(_prefCustomRecitersKey, encoded);
    } catch (_) {}
  }

  /// Search catalog reciters not yet in available reciters list
  static List<QuranReciter> searchCatalogAvailableToAdd(String query) {
    final q = query.trim().toLowerCase();
    final currentIds = _allReciters.map((r) => r.id.toLowerCase()).toSet();

    return QuranRecitersCatalog.availableCatalog.where((r) {
      if (currentIds.contains(r.id.toLowerCase())) return false;
      if (q.isEmpty) return true;

      return r.name.toLowerCase().contains(q) ||
          r.riwayah.toLowerCase().contains(q) ||
          r.id.toLowerCase().contains(q);
    }).toList();
  }

  /// Search currently available reciters
  static List<QuranReciter> searchCurrentReciters(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _allReciters;

    return _allReciters.where((r) {
      return r.name.toLowerCase().contains(q) ||
          r.riwayah.toLowerCase().contains(q) ||
          r.id.toLowerCase().contains(q);
    }).toList();
  }
}
