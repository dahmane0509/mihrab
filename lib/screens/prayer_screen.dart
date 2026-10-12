import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/algeria_wilayas.dart';
import '../data/algeria_communes.dart';
import '../services/prayer_service.dart';
import '../services/prayer_notification_service.dart';
import '../services/adhan_audio_service.dart';
import '../services/location_service.dart';
import '../services/theme_service.dart';
import 'settings_screen.dart';
import 'qibla_screen.dart';
import 'quran_screen.dart';
import 'adhkar_screen.dart';
import 'live_broadcast_screen.dart';

class PrayerScreen extends StatefulWidget {
  final Wilaya currentWilaya;
  final Commune? currentCommune;
  final void Function(Wilaya, Commune?) onLocationChanged;

  const PrayerScreen({
    super.key,
    required this.currentWilaya,
    this.currentCommune,
    required this.onLocationChanged,
  });

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  late Timer _timer;
  late DateTime _now;
  late Wilaya _wilaya;
  Commune? _commune;
  final Map<String, bool> _prayerNotifications = {
    "الفجر": true,
    "الشروق": false,
    "الظهر": true,
    "العصر": true,
    "المغرب": true,
    "العشاء": true,
  };

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _wilaya = widget.currentWilaya;
    _commune = widget.currentCommune ??
        AlgeriaCommunes.getCommunesByWilaya(_wilaya.code).firstOrNull ??
        AlgeriaCommunes.allCommunes[0];

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });

    _loadNotificationPreferences();
  }

  @override
  void didUpdateWidget(covariant PrayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentWilaya != widget.currentWilaya || oldWidget.currentCommune != widget.currentCommune) {
      setState(() {
        _wilaya = widget.currentWilaya;
        _commune = widget.currentCommune ??
            AlgeriaCommunes.getCommunesByWilaya(_wilaya.code).firstOrNull ??
            AlgeriaCommunes.allCommunes[0];
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (final prayer in _prayerNotifications.keys) {
        _prayerNotifications[prayer] = prefs.getBool('notif_$prayer') ?? true;
      }
    });
  }

  Future<void> _togglePrayerNotification(String prayerName) async {
    final prefs = await SharedPreferences.getInstance();
    final current = _prayerNotifications[prayerName] ?? true;
    final updated = !current;

    setState(() {
      _prayerNotifications[prayerName] = updated;
    });
    await prefs.setBool('notif_$prayerName', updated);
    PrayerNotificationService.scheduleAllPrayerNotifications();

    if (!mounted) return;
    AdhanAudioService.playNotificationChime();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: updated ? const Color(0xFF065F46) : const Color(0xFF334155),
        duration: const Duration(seconds: 2),
        content: Text(
          updated
              ? "تم تفعيل التنبيه والأذان لصلاة $prayerName 🔔"
              : "تم كتم صوت التنبيه لصلاة $prayerName 🔕",
        ),
      ),
    );
  }

  Future<void> _detectGpsLocation() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF065F46),
        duration: Duration(seconds: 3),
        content: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            ),
            SizedBox(width: 14),
            Text("جاري الاتصال بالأقمار الصناعية (GPS) وكشف موقعك..."),
          ],
        ),
      ),
    );

    final detected = await LocationService.detectLocation();
    if (detected != null) {
      setState(() {
        _wilaya = detected.wilaya;
        _commune = detected.commune;
      });
      widget.onLocationChanged(detected.wilaya, detected.commune);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('selected_wilaya', detected.wilaya.code);
      await prefs.setInt('selected_commune_id', detected.commune.id);

      if (!mounted) return;
      AdhanAudioService.playNotificationChime();
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF065F46),
          duration: const Duration(seconds: 4),
          content: Text("تم تحديد موقعك بدقة: بلدية ${_commune?.nameAr} - ولاية ${_wilaya.nameAr} 📍"),
        ),
      );
    }
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
        int? selectedFilterWilaya = _wilaya.code;

        return StatefulBuilder(
          builder: (context, setModalState) {
            List<Commune> filteredCommunes;
            if (query.isNotEmpty) {
              filteredCommunes = AlgeriaCommunes.searchCommunes(query);
            } else if (selectedFilterWilaya != null) {
              filteredCommunes = AlgeriaCommunes.getCommunesByWilaya(selectedFilterWilaya!);
            } else {
              filteredCommunes = AlgeriaCommunes.allCommunes;
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                  const Text(
                    "اختيار البلدية والولاية (بلديات الجزائر الـ 1541)",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  // Search field
                  TextField(
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "ابحث عن اسم البلدية (مثال: النعامة، مشرية، عين الصفراء...)",
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
                  const SizedBox(height: 10),

                  // Wilaya quick filter chip row
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
                  const Divider(color: Color(0xFF334155), height: 16),

                  // Communes list
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredCommunes.length,
                      separatorBuilder: (_, __) => const Divider(color: Color(0xFF334155), height: 1),
                      itemBuilder: (context, idx) {
                        final commune = filteredCommunes[idx];
                        final wilayaObj = AlgeriaWilayas.getWilayaByCode(commune.wilayaCode);
                        final isSelected = _commune?.id == commune.id;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isSelected ? const Color(0xFF10B981) : const Color(0xFF0F172A),
                            child: Text(
                              "${commune.wilayaCode}",
                              style: TextStyle(
                                color: isSelected ? Colors.black : const Color(0xFF34D399),
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          title: Text(
                            "${commune.nameAr} (${commune.nameFr})",
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: isSelected ? const Color(0xFF34D399) : Colors.white,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            "ولاية ${wilayaObj.nameAr} • خط العرض: ${commune.latitude.toStringAsFixed(2)}°",
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                          trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF10B981)) : null,
                          onTap: () async {
                            setState(() {
                              _wilaya = wilayaObj;
                              _commune = commune;
                            });
                            widget.onLocationChanged(wilayaObj, commune);

                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setInt('selected_wilaya', wilayaObj.code);
                            await prefs.setInt('selected_commune_id', commune.id);

                            if (!context.mounted) return;
                            Navigator.pop(ctx);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: const Color(0xFF065F46),
                                duration: const Duration(seconds: 2),
                                content: Text("تم ضبط الموقع على: بلدية ${commune.nameAr} (${wilayaObj.nameAr})"),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static String formatShortTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }

  String _formatRemaining(Duration d) {
    if (d.isNegative) return "الآن";
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    if (hours > 0) {
      return "$hours س و $minutes د";
    }
    return "$minutes د و $seconds ث";
  }

  @override
  Widget build(BuildContext context) {
    final communeToUse = _commune ??
        AlgeriaCommunes.getCommunesByWilaya(_wilaya.code).firstOrNull ??
        AlgeriaCommunes.allCommunes[0];

    final times = PrayerCalculationService.calculateTimesForCommune(
      commune: communeToUse,
      date: _now,
    );
    final nextPrayer = PrayerCalculationService.getNextPrayer(times, _now);

    return ValueListenableBuilder<AppThemeColor>(
      valueListenable: ThemeService.currentTheme,
      builder: (context, theme, _) {
        return Scaffold(
          backgroundColor: theme.background,
          appBar: AppBar(
            backgroundColor: theme.darkPrimary,
            elevation: 0,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, color: theme.accent, size: 20),
                const SizedBox(width: 6),
                Text(
                  "بلدية ${communeToUse.nameAr} • ولاية ${_wilaya.nameAr}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.my_location, color: theme.accent),
              tooltip: "كشف موقعك التلقائي (GPS)",
              onPressed: _detectGpsLocation,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.swap_vert, color: Colors.white),
                tooltip: "تغيير البلدية والولاية",
                onPressed: _showCommuneSearchDialog,
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                tooltip: "الإعدادات العامة",
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SettingsScreen(
                        selectedWilayaCode: _wilaya.code,
                        onWilayaChanged: (code) {
                          final newW = AlgeriaWilayas.getWilayaByCode(code);
                          final newC = AlgeriaCommunes.getCommunesByWilaya(code).firstOrNull;
                          setState(() {
                            _wilaya = newW;
                            _commune = newC;
                          });
                          widget.onLocationChanged(newW, newC);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Active Adhan Playing Banner
                ValueListenableBuilder<bool>(
                  valueListenable: AdhanAudioService.isPlayingNotifier,
                  builder: (context, isAudioActive, _) {
                    if (!isAudioActive) return const SizedBox.shrink();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade900,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.amber.withValues(alpha: 0.3), blurRadius: 10),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.volume_up, color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "صوت الأذان يرتفع الآن 🕌",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                ValueListenableBuilder<String>(
                                  valueListenable: AdhanAudioService.currentPlayingTitle,
                                  builder: (context, title, _) {
                                    return Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12));
                                  },
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              AdhanAudioService.stopAdhan();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Color(0xFF1E293B),
                                  content: Text("تم إيقاف صوت الأذان ⏹️"),
                                ),
                              );
                            },
                            child: const Text("إيقاف"),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Next Prayer Countdown Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.darkPrimary, theme.cardBackground],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: theme.accent.withValues(alpha: 0.4), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: theme.accent.withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: theme.accent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.accent),
                            ),
                            child: Text(
                              PrayerService.calculateTimesForCommune(communeToUse, _now)['hijri_date'] ?? "",
                              style: TextStyle(color: theme.accent, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            PrayerService.calculateTimesForCommune(communeToUse, _now)['gregorian_date'] ?? "",
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        formatShortTime(nextPrayer.time),
                        style: TextStyle(
                          color: theme.accent,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          "الصلاة القادمة: ${nextPrayer.nameAr} بعد ${_formatRemaining(nextPrayer.remaining)}",
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: nextPrayer.progress,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Audio Actions on Next Prayer Card
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.accent,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            ),
                            icon: const Icon(Icons.volume_up, size: 20),
                            label: const Text("سماع الأذان الآن", style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () {
                              AdhanAudioService.playAdhan();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF065F46),
                                  duration: const Duration(seconds: 4),
                                  content: const Text("يرتفع الآن صوت الأذان المبارك 🕌"),
                                  action: SnackBarAction(
                                    label: "إيقاف",
                                    textColor: const Color(0xFFFDE68A),
                                    onPressed: () => AdhanAudioService.stopAdhan(),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: theme.accent),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            icon: const Icon(Icons.music_note, size: 18),
                            label: const Text("التكبيرات"),
                            onPressed: () {
                              AdhanAudioService.playTakbeer();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Color(0xFF065F46),
                                  duration: Duration(seconds: 2),
                                  content: Text("تشغيل تكبيرات الصلاة والعيد 🕋"),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Navigation Cards (Quran, Adhkar, Live Broadcast, Qibla)
                Row(
                  children: [
                    _buildQuickAction(
                      title: "القرآن الكريم",
                      subtitle: "قراءة وسماع",
                      icon: Icons.menu_book,
                      theme: theme,
                      onTap: () {
                        AdhanAudioService.playNotificationChime();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const QuranScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildQuickAction(
                      title: "البث المباشر",
                      subtitle: "مكة والمدينة",
                      icon: Icons.live_tv,
                      theme: theme,
                      isLive: true,
                      onTap: () {
                        AdhanAudioService.playNotificationChime();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const LiveBroadcastScreen()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildQuickAction(
                      title: "حصن المسلم",
                      subtitle: "أذكار وسبحة",
                      icon: Icons.favorite,
                      theme: theme,
                      onTap: () {
                        AdhanAudioService.playNotificationChime();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const AdhkarScreen()),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    _buildQuickAction(
                      title: "بوصلة القبلة",
                      subtitle: "تحديد الكعبة",
                      icon: Icons.explore,
                      theme: theme,
                      onTap: () {
                        AdhanAudioService.playNotificationChime();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => QiblaScreen(currentWilaya: _wilaya),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Prayer Times Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: theme.accent),
                        icon: const Icon(Icons.edit_location, size: 18),
                        label: Text(
                          "تغيير البلدية (${communeToUse.nameAr})",
                          overflow: TextOverflow.ellipsis,
                        ),
                        onPressed: _showCommuneSearchDialog,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "مواقيت الصلاة اليوم",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Interactive Prayer Tiles with Notification Bell
                _buildPrayerTile("الفجر", times.fajr, nextPrayer.nameAr == "الفجر", theme),
                _buildPrayerTile("الشروق", times.sunrise, false, theme, isSunrise: true),
                _buildPrayerTile("الظهر", times.dhuhr, nextPrayer.nameAr == "الظهر", theme),
                _buildPrayerTile("العصر", times.asr, nextPrayer.nameAr == "العصر", theme),
                _buildPrayerTile("المغرب", times.maghrib, nextPrayer.nameAr == "المغرب", theme),
                _buildPrayerTile("العشاء", times.isha, nextPrayer.nameAr == "العشاء", theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickAction({
    required String title,
    required String subtitle,
    required IconData icon,
    required AppThemeColor theme,
    required VoidCallback onTap,
    bool isLive = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: theme.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isLive ? Colors.redAccent.withValues(alpha: 0.5) : const Color(0xFF334155)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isLive ? Colors.red.withValues(alpha: 0.2) : theme.darkPrimary,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: isLive ? Colors.redAccent : theme.accent, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrayerTile(
    String name,
    DateTime time,
    bool isNext,
    AppThemeColor theme, {
    bool isSunrise = false,
  }) {
    final String formatted = formatShortTime(time);
    final isNotifEnabled = _prayerNotifications[name] ?? true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isNext ? theme.darkPrimary.withValues(alpha: 0.6) : theme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNext ? theme.accent : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Notification Bell Toggle Icon
              if (!isSunrise)
                IconButton(
                  icon: Icon(
                    isNotifEnabled ? Icons.notifications_active : Icons.notifications_off_outlined,
                    color: isNotifEnabled ? theme.accent : Colors.white30,
                    size: 22,
                  ),
                  tooltip: isNotifEnabled ? "كتم التنبيه" : "تفعيل التنبيه",
                  onPressed: () => _togglePrayerNotification(name),
                )
              else
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(Icons.wb_sunny, color: Colors.amber, size: 22),
                ),
              const SizedBox(width: 4),
              Text(
                name,
                style: TextStyle(
                  color: isNext ? theme.accent : Colors.white,
                  fontSize: 16,
                  fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                formatted,
                style: TextStyle(
                  color: isNext ? theme.accent : Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              if (!isSunrise) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.volume_up_outlined, color: Colors.white38, size: 18),
                  tooltip: "سماع الأذان",
                  onPressed: () {
                    AdhanAudioService.playAdhan();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF065F46),
                        duration: const Duration(seconds: 4),
                        content: Text("سماع أذان صلاة $name 🕌"),
                        action: SnackBarAction(
                          label: "إيقاف",
                          textColor: const Color(0xFFFDE68A),
                          onPressed: () => AdhanAudioService.stopAdhan(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
