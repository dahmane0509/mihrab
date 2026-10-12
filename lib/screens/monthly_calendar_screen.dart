import 'package:flutter/material.dart';
import '../data/algeria_wilayas.dart';
import '../services/prayer_service.dart';

class MonthlyCalendarScreen extends StatefulWidget {
  final Wilaya currentWilaya;

  const MonthlyCalendarScreen({super.key, required this.currentWilaya});

  @override
  State<MonthlyCalendarScreen> createState() => _MonthlyCalendarScreenState();
}

class _MonthlyCalendarScreenState extends State<MonthlyCalendarScreen> {
  final DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF064E3B),
        title: Text("مواقيت شهر ${_currentMonth.month} / ${_currentMonth.year}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: const Color(0xFF1E293B),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("ولاية ${widget.currentWilaya.nameAr}", style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                const Text("إمساكية ومواقيت كامل الشهر", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: daysInMonth,
              itemBuilder: (context, index) {
                final day = index + 1;
                final date = DateTime(_currentMonth.year, _currentMonth.month, day);
                final times = PrayerService.calculateTimesForWilaya(widget.currentWilaya, date);
                final isToday = DateTime.now().day == day && DateTime.now().month == _currentMonth.month;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isToday ? const Color(0xFF065F46).withValues(alpha: 0.5) : (index % 2 == 0 ? const Color(0xFF0F172A) : const Color(0xFF1E293B)),
                    border: isToday ? Border.all(color: const Color(0xFFD4AF37)) : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("$day", style: TextStyle(color: isToday ? const Color(0xFFFDE68A) : Colors.white, fontWeight: FontWeight.bold)),
                      Text("ف: ${times['fajr']}", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      Text("ظ: ${times['dhuhr']}", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      Text("ع: ${times['asr']}", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      Text("م: ${times['maghrib']}", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                      Text("عش: ${times['isha']}", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
