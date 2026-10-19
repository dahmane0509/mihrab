import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../services/prayer_tracker_service.dart';
import '../services/app_feedback.dart';

class PrayerTrackerCard extends StatelessWidget {
  final bool isAr;

  const PrayerTrackerCard({
    super.key,
    this.isAr = true,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeColor>(
      valueListenable: ThemeService.currentTheme,
      builder: (context, theme, _) {
        return ValueListenableBuilder<Map<String, bool>>(
          valueListenable: PrayerTrackerService.todayPrayersNotifier,
          builder: (context, todayMap, _) {
            final completedCount = todayMap.values.where((v) => v == true).length;
            final isAllDone = completedCount == 5;

            return ValueListenableBuilder<int>(
              valueListenable: PrayerTrackerService.streakNotifier,
              builder: (context, streak, _) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: theme.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isAllDone
                          ? const Color(0xFF10B981).withValues(alpha: 0.6)
                          : theme.accent.withValues(alpha: 0.25),
                      width: isAllDone ? 1.5 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isAllDone
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.fact_check_outlined,
                              color: theme.accent,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr ? "متتبع الصلوات اليومية" : "Daily Prayer Tracker",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  isAr
                                      ? "سجّل صلواتك في وقتها واحرص على استمرار السلسلة"
                                      : "Log your prayers on time and keep the streak",
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 10.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Streak Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFEA580C), Color(0xFFF97316)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF97316).withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: Colors.white,
                                  size: 15,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  isAr ? "$streak يوم" : "$streak days",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Progress Bar & Count
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: completedCount / 5.0,
                                minHeight: 6,
                                backgroundColor: Colors.white.withValues(alpha: 0.08),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isAllDone ? const Color(0xFF10B981) : theme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "$completedCount / 5",
                            style: TextStyle(
                              color: isAllDone ? const Color(0xFF34D399) : theme.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 5 Prayer Buttons
                      Row(
                        children: PrayerTrackerService.prayerKeys.map((key) {
                          final isDone = todayMap[key] == true;
                          final name = isAr
                              ? (PrayerTrackerService.prayerNamesAr[key] ?? key)
                              : (PrayerTrackerService.prayerNamesEn[key] ?? key);

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: Material(
                                color: isDone
                                    ? const Color(0xFF065F46)
                                    : const Color(0xFF0F172A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isDone
                                        ? const Color(0xFF10B981)
                                        : Colors.white.withValues(alpha: 0.12),
                                    width: isDone ? 1.4 : 1.0,
                                  ),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () async {
                                    AppFeedback.select();
                                    await PrayerTrackerService.togglePrayer(key);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isDone
                                              ? Icons.check_circle_rounded
                                              : Icons.radio_button_unchecked_rounded,
                                          color: isDone
                                              ? const Color(0xFF34D399)
                                              : Colors.white38,
                                          size: 18,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          name,
                                          style: TextStyle(
                                            color: isDone
                                                ? Colors.white
                                                : const Color(0xFF94A3B8),
                                            fontSize: 11,
                                            fontWeight: isDone
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      // Completion Congratulatory Banner
                      if (isAllDone) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF064E3B).withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF10B981).withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Text("✨", style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  isAr
                                      ? "هنيئاً لك! أتممت صلواتك الخمس اليوم، تقبل الله طاعاتكم."
                                      : "Masha'Allah! All 5 prayers completed today.",
                                  style: const TextStyle(
                                    color: Color(0xFF6EE7B7),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
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
      },
    );
  }
}
