import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/algeria_wilayas.dart';
import 'data/algeria_communes.dart';
import 'data/world_cities.dart';
import 'screens/splash_screen.dart';
import 'screens/next_prayer_screen.dart';
import 'screens/prayer_times_screen.dart';
import 'screens/services_screen.dart';
import 'screens/qibla_screen.dart';
import 'widgets/app_drawer.dart';
import 'services/theme_service.dart';
import 'services/adhan_audio_service.dart';
import 'services/prayer_service.dart';
import 'services/auto_adhkar_service.dart';
import 'services/prayer_notification_service.dart';
import 'services/app_feedback.dart';
import 'services/location_service.dart';
import 'services/language_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Fast preloading of essential UI state in parallel (< 20ms)
  await Future.wait([
    LanguageService.init(),
    ThemeService.init(),
    PrayerService.loadSettings(),
  ]);

  // Launch Flutter UI immediately to dismiss OS native splash screen instantly
  runApp(const AlgeriaPrayerApp());

  // Concurrently initialize heavier platform services in background during splash animation
  _initBackgroundServices();
}

void _initBackgroundServices() {
  Future.microtask(() async {
    try {
      await AdhanAudioService.init();
      await AutoAdhkarService.initialize();
      await PrayerNotificationService.initialize();
    } catch (e) {
      debugPrint("Background services init note: $e");
    }
  });
}

class AlgeriaPrayerApp extends StatelessWidget {
  const AlgeriaPrayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService.currentLocale,
      builder: (context, activeLocale, _) {
        return ValueListenableBuilder<AppThemeColor>(
          valueListenable: ThemeService.currentTheme,
          builder: (context, activeTheme, _) {
            return MaterialApp(
              title: 'محراب',
              debugShowCheckedModeBanner: false,
              locale: activeLocale,
              supportedLocales: LanguageService.supportedLocales,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.dark,
                scaffoldBackgroundColor: activeTheme.background,
                primaryColor: activeTheme.primary,
                fontFamily: 'Roboto',
                colorScheme: ColorScheme.dark(
                  primary: activeTheme.primary,
                  secondary: activeTheme.accent,
                  surface: activeTheme.cardBackground,
                ),
              ),
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  Wilaya _selectedWilaya = AlgeriaWilayas.getWilayaByCode(16); // Default to Wilaya 16 (Alger)
  Commune? _selectedCommune;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedLocation();
    _initPermissionsAndCheck();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      PrayerNotificationService.checkNotificationsEnabled();
      PrayerNotificationService.scheduleAllPrayerNotifications();
    }
  }

  Future<void> _initPermissionsAndCheck() async {
    await PrayerNotificationService.requestPermissions();
    if (mounted) {
      final enabled = await PrayerNotificationService.checkNotificationsEnabled();
      if (!enabled && mounted) {
        _showNotificationPermissionDialog();
      }
    }
  }

  void _showNotificationPermissionDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F254E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: Color(0xFF10B981), size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "تفعيل إشعارات وأذان الصلاة",
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          "تنبيه مهم: إشعارات التطبيق معطلة حالياً في إعدادات الهاتف.\n\nلكي يظهر إشعار وقت الصلاة ويُسمع صوت الأذان في وقته الدقيق حتى عند إغلاق التطبيق، يرجى تفعيل (السماح بالإشعارات) من إعدادات الهاتف.",
          style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("لاحقاً", style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: const Icon(Icons.settings, size: 18),
            label: const Text("تفعيل الآن في الإعدادات", style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () async {
              Navigator.pop(ctx);
              await PrayerNotificationService.openNotificationSettings();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSavedWilaya = prefs.containsKey('selected_wilaya');
    final savedCode = prefs.getInt('selected_wilaya') ?? 16;
    final savedCommuneId = prefs.getInt('selected_commune_id');

    final wilaya = AlgeriaWilayas.getWilayaByCode(savedCode);
    Commune? commune;

    if (savedCode >= 1000) {
      final city = WorldCitiesData.getCityByCode(savedCode);
      if (city != null) {
        commune = Commune(
          id: city.code,
          wilayaCode: city.code,
          nameAr: city.nameAr,
          nameFr: city.nameFr,
          latitude: city.latitude,
          longitude: city.longitude,
          type: city.countryAr,
        );
      }
    } else if (savedCommuneId != null) {
      commune = AlgeriaCommunes.allCommunes.firstWhere(
        (c) => c.id == savedCommuneId,
        orElse: () => AlgeriaCommunes.getCommunesByWilaya(savedCode).firstOrNull ?? AlgeriaCommunes.allCommunes[0],
      );
    } else {
      commune = AlgeriaCommunes.getCommunesByWilaya(savedCode).firstOrNull ?? AlgeriaCommunes.allCommunes[0];
    }

    setState(() {
      _selectedWilaya = wilaya;
      _selectedCommune = commune;
    });

    PrayerNotificationService.scheduleAllPrayerNotifications();

    if (!hasSavedWilaya) {
      _tryAutoDetectLocation();
    }
  }

  Future<void> _tryAutoDetectLocation() async {
    try {
      final detected = await LocationService.detectLocation();
      if (detected != null && mounted) {
        _updateLocation(detected.wilaya, detected.commune);
      }
    } catch (_) {}
  }

  void _updateLocation(Wilaya wilaya, Commune? commune) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_wilaya', wilaya.code);
    if (commune != null) {
      await prefs.setInt('selected_commune_id', commune.id);
    }
    setState(() {
      _selectedWilaya = wilaya;
      _selectedCommune = commune;
    });
    PrayerNotificationService.scheduleAllPrayerNotifications();
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _showCommuneSearchDialog() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String query = "";
        int selectedTab = 0; // 0 = Algeria, 1 = World Cities
        int? selectedFilterWilaya = _selectedWilaya.code;

        return StatefulBuilder(
          builder: (context, setModalState) {
            List<Commune> filteredCommunes = [];
            List<WorldCity> filteredWorldCities = [];

            if (selectedTab == 0) {
              if (query.isNotEmpty) {
                filteredCommunes = AlgeriaCommunes.searchCommunes(query);
              } else if (selectedFilterWilaya != null && selectedFilterWilaya! < 1000) {
                filteredCommunes = AlgeriaCommunes.getCommunesByWilaya(selectedFilterWilaya!);
              } else {
                filteredCommunes = AlgeriaCommunes.allCommunes;
              }
            } else {
              filteredWorldCities = WorldCitiesData.searchCities(query);
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          "اختيار البلدية أو القرية أو الدشرة (الجزائر والعالم)",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.my_location, color: Color(0xFF10B981)),
                        tooltip: "تحديد الموقع تلقائياً بالـ GPS",
                        onPressed: () async {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("جاري تحديد موقعك عبر الأقمار الصناعية... 🛰️")),
                          );
                          await _tryAutoDetectLocation();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Segmented Tabs: Algeria vs World Cities
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedTab = 0;
                                query = "";
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: selectedTab == 0 ? const Color(0xFF10B981) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "🇩🇿 الجزائر (58 ولاية)",
                                style: TextStyle(
                                  color: selectedTab == 0 ? Colors.black : Colors.white70,
                                  fontWeight: selectedTab == 0 ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedTab = 1;
                                query = "";
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: selectedTab == 1 ? const Color(0xFF10B981) : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "🌍 عواصم ومدن العالم",
                                style: TextStyle(
                                  color: selectedTab == 1 ? Colors.black : Colors.white70,
                                  fontWeight: selectedTab == 1 ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Search box
                  TextField(
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: selectedTab == 0
                          ? "ابحث عن اسم البلدية أو القرية أو الدشرة..."
                          : "ابحث عن عاصمة أو مدينة حول العالم (مكة، باريس، لندن، نيويورك...)",
                      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF10B981)),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        query = val.trim();
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  if (selectedTab == 0) ...[
                    // Wilayas chip row for Algeria
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: AlgeriaWilayas.wilayas.map((w) {
                          final isSel = selectedFilterWilaya == w.code;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: ChoiceChip(
                              label: Text("${w.code}. ${w.nameAr}"),
                              selected: isSel,
                              selectedColor: const Color(0xFF10B981),
                              backgroundColor: const Color(0xFF0F172A),
                              labelStyle: TextStyle(
                                color: isSel ? Colors.black : Colors.white,
                                fontSize: 12,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (_) {
                                setModalState(() {
                                  selectedFilterWilaya = w.code;
                                  query = "";
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const Divider(color: Color(0xFF334155), height: 14),

                    // Communes and Localities list
                    Expanded(
                      child: ListView.separated(
                        itemCount: filteredCommunes.length,
                        separatorBuilder: (_, __) => const Divider(color: Color(0xFF334155), height: 1),
                        itemBuilder: (context, idx) {
                          final commune = filteredCommunes[idx];
                          final wilayaObj = AlgeriaWilayas.getWilayaByCode(commune.wilayaCode);
                          final isSelected = _selectedCommune?.id == commune.id;
                          final subText = commune.parentCommuneAr != null
                              ? "${commune.type} • بلدية ${commune.parentCommuneAr} • ولاية ${wilayaObj.nameAr}"
                              : "${commune.type} • ولاية ${wilayaObj.nameAr}";

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected ? const Color(0xFF10B981) : const Color(0xFF0F172A),
                              child: Icon(
                                commune.parentCommuneAr != null ? Icons.holiday_village : Icons.location_city,
                                color: isSelected ? Colors.black : const Color(0xFF34D399),
                                size: 18,
                              ),
                            ),
                            title: Text(
                              commune.nameAr,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                color: isSelected ? const Color(0xFF34D399) : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Text(
                              subText,
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                            ),
                            trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF10B981)) : null,
                            onTap: () {
                              _updateLocation(wilayaObj, commune);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF065F46),
                                  content: Text("تم اختيار: ${commune.nameAr} (${commune.type}) 📍"),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ] else ...[
                    // World Cities List
                    const Divider(color: Color(0xFF334155), height: 14),
                    Expanded(
                      child: ListView.separated(
                        itemCount: filteredWorldCities.length,
                        separatorBuilder: (_, __) => const Divider(color: Color(0xFF334155), height: 1),
                        itemBuilder: (context, idx) {
                          final city = filteredWorldCities[idx];
                          final isSelected = _selectedWilaya.code == city.code;
                          final lang = LanguageService.languageCode;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected ? const Color(0xFF10B981) : const Color(0xFF0F172A),
                              child: Icon(
                                Icons.public,
                                color: isSelected ? Colors.black : const Color(0xFF34D399),
                                size: 18,
                              ),
                            ),
                            title: Text(
                              city.getDisplayName(lang),
                              textDirection: LanguageService.textDirection,
                              style: TextStyle(
                                color: isSelected ? const Color(0xFF34D399) : Colors.white,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Text(
                              "UTC+${city.timeZone.toInt()} • Lat: ${city.latitude.toStringAsFixed(2)}, Lng: ${city.longitude.toStringAsFixed(2)}",
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                            ),
                            trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF10B981)) : null,
                            onTap: () {
                              final wilayaObj = city.toWilaya();
                              final communeObj = Commune(
                                id: city.code,
                                wilayaCode: city.code,
                                nameAr: city.nameAr,
                                nameFr: city.nameFr,
                                latitude: city.latitude,
                                longitude: city.longitude,
                                type: city.countryAr,
                              );
                              _updateLocation(wilayaObj, communeObj);
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF065F46),
                                  content: Text("تم اختيار: ${city.getDisplayName(lang)} 📍"),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LanguageService.currentLocale,
      builder: (context, activeLocale, _) {
        return ValueListenableBuilder<AppThemeColor>(
          valueListenable: ThemeService.currentTheme,
          builder: (context, activeTheme, _) {
            final screens = [
              NextPrayerScreen(
                key: ValueKey('next_prayer_${activeLocale.languageCode}'),
                currentWilaya: _selectedWilaya,
                currentCommune: _selectedCommune,
                onOpenDrawer: _openDrawer,
                onSearchWilaya: _showCommuneSearchDialog,
                onLocationChanged: _updateLocation,
              ),
              PrayerTimesScreen(
                key: ValueKey('prayer_times_${activeLocale.languageCode}'),
                currentWilaya: _selectedWilaya,
                currentCommune: _selectedCommune,
                onOpenDrawer: _openDrawer,
              ),
              ServicesScreen(
                key: ValueKey('services_${activeLocale.languageCode}'),
                currentWilaya: _selectedWilaya,
                currentCommune: _selectedCommune,
                onOpenDrawer: _openDrawer,
              ),
              QiblaScreen(
                key: ValueKey('qibla_${activeLocale.languageCode}'),
                currentWilaya: _selectedWilaya,
                onOpenDrawer: _openDrawer,
              ),
            ];

            return Directionality(
              textDirection: LanguageService.textDirection,
              child: Scaffold(
                key: _scaffoldKey,
                drawer: AppDrawer(
                  currentWilaya: _selectedWilaya,
                  currentCommune: _selectedCommune,
                  onLocationChanged: _updateLocation,
                ),
                body: Column(
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: PrayerNotificationService.notificationsEnabledNotifier,
                      builder: (context, enabled, _) {
                        if (enabled) return const SizedBox.shrink();
                        return SafeArea(
                          bottom: false,
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF991B1B), Color(0xFFDC2626)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.notifications_off, color: Colors.white, size: 26),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        "⚠️ إشعارات الأذان معطلة في الهاتف!",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "يرجى السماح بالإشعارات لسماع الأذان وظهور التنبيه.",
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF991B1B),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: () async {
                                    await PrayerNotificationService.openNotificationSettings();
                                  },
                                  child: const Text(
                                    "تفعيل الآن",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: IndexedStack(
                        index: _currentIndex,
                        children: screens,
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                    color: activeTheme.darkPrimary,
                    border: Border(top: BorderSide(color: activeTheme.accent.withValues(alpha: 0.4), width: 1.5)),
                  ),
                  child: BottomNavigationBar(
                    currentIndex: _currentIndex,
                    backgroundColor: activeTheme.darkPrimary,
                    selectedItemColor: activeTheme.accent,
                    unselectedItemColor: Colors.white70,
                    selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    unselectedLabelStyle: const TextStyle(fontSize: 11),
                    type: BottomNavigationBarType.fixed,
                    onTap: (index) {
                      AppFeedback.tap();
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    items: [
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.schedule),
                        activeIcon: Icon(Icons.schedule, color: activeTheme.accent, size: 26),
                        label: LanguageService.tr('tab_next_prayer'),
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.format_list_bulleted),
                        activeIcon: Icon(Icons.format_list_bulleted, color: activeTheme.accent, size: 26),
                        label: LanguageService.tr('tab_prayer_times'),
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.grid_view_rounded),
                        activeIcon: Icon(Icons.grid_view_rounded, color: activeTheme.accent, size: 26),
                        label: LanguageService.tr('tab_services'),
                      ),
                      BottomNavigationBarItem(
                        icon: const Icon(Icons.explore_outlined),
                        activeIcon: Icon(Icons.explore, color: activeTheme.accent, size: 26),
                        label: LanguageService.tr('tab_qibla'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
