import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_feedback.dart';

class MakkahLiveScreen extends StatelessWidget {
  const MakkahLiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF064E3B),
        title: const Text("مكة والمدينة مباشر", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLiveCard(
            context: context,
            title: "بث مباشر: المسجد الحرام (مكة المكرمة)",
            subtitle: "قناة القرآن الكريم السعودية - البث الحي للكعبة المشرفة والصلوات",
            streamUrl: "https://www.youtube.com/@SaudiQuranTv/live",
            icon: Icons.mosque,
            color: const Color(0xFFD4AF37),
          ),
          const SizedBox(height: 16),
          _buildLiveCard(
            context: context,
            title: "بث مباشر: المسجد النبوي الشريف (المدينة المنورة)",
            subtitle: "قناة السنة النبوية السعودية - البث الحي للروضة الشريفة والمسجد النبوي",
            streamUrl: "https://www.youtube.com/@SaudiSunnahTv/live",
            icon: Icons.location_city,
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF34D399), size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "يتم نقل البث الفضائي المباشر للحرمين الشريفين على مدار 24 ساعة يومياً بدون انقطاع وبأعلى جودة.",
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String streamUrl,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.3), const Color(0xFF0F172A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 54),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text("مباشر LIVE", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF065F46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.play_circle_fill, color: Colors.white),
                    label: const Text("مشاهدة البث الآن", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      AppFeedback.tap();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF064E3B),
                          content: Text("جاري فتح البث المباشر لـ $title"),
                        ),
                      );
                      final uri = Uri.parse(streamUrl);
                      try {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } catch (_) {}
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
