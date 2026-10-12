import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/adhkar_data.dart';
import '../services/theme_service.dart';
import '../services/adhan_audio_service.dart';
import 'auto_adhkar_screen.dart';

class AdhkarScreen extends StatefulWidget {
  const AdhkarScreen({super.key});

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final categories = AdhkarRepository.getCategories();
  int _tasbeehCount = 0;
  String _selectedTasbeehDhikr = "سبحان الله وبحمده";

  final List<String> _tasbeehPresets = [
    "سبحان الله وبحمده",
    "سبحان الله العظيم",
    "الحمد لله رب العالمين",
    "لا إله إلا الله وحده لا شريك له",
    "الله أكبر كبيراً",
    "لا حول ولا قوة إلا بالله العلي العظيم",
    "أستغفر الله العظيم وأتوب إليه",
    "اللهم صل وسلم على نبينا محمد",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length + 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _incrementDhikr(DhikrItem item) {
    if (item.currentCount < item.targetCount) {
      HapticFeedback.lightImpact();
      setState(() {
        item.currentCount++;
      });

      if (item.currentCount == item.targetCount) {
        AdhanAudioService.playNotificationChime();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF065F46),
            duration: const Duration(seconds: 2),
            content: Text("هنيئاً لك! أتممت قراءة الذكر (${item.targetCount} مرات) تقبل الله منك ✨"),
          ),
        );
      }
    }
  }

  void _resetDhikr(DhikrItem item) {
    setState(() {
      item.currentCount = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF1E293B),
        duration: Duration(seconds: 1),
        content: Text("تمت إعادة تصفير العداد 🔄"),
      ),
    );
  }

  void _copyDhikr(String text) {
    Clipboard.setData(ClipboardData(text: text));
    AdhanAudioService.playNotificationChime();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF065F46),
        duration: Duration(seconds: 2),
        content: Text("تم نسخ الذكر إلى الحافظة بنجاح 📋"),
      ),
    );
  }

  void _shareDhikr(String text) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF1E293B),
        duration: Duration(seconds: 2),
        content: Text("تم تجهيز الذكر للمشاركة مع أصدقائك 📤"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeColor>(
      valueListenable: ThemeService.currentTheme,
      builder: (context, theme, _) {
        return Scaffold(
          backgroundColor: theme.background,
          appBar: AppBar(
            backgroundColor: theme.darkPrimary,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "حصن المسلم والسبحة الإلكترونية",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.auto_awesome, color: Color(0xFFF59E0B)),
                tooltip: "أذكار الشاشة التلقائية أثناء التصفح",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(builder: (_) => const AutoAdhkarScreen()),
                ),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: theme.accent,
              indicatorWeight: 3,
              labelColor: theme.accent,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: [
                ...categories.map((c) => Tab(text: c.titleAr)),
                const Tab(text: "السبحة الإلكترونية 📿"),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              ...categories.map((cat) => _buildDhikrList(cat, theme)),
              _buildTasbeehCounter(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDhikrList(DhikrCategory category, AppThemeColor theme) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: category.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = category.items[index];
        final isCompleted = item.currentCount >= item.targetCount;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isCompleted ? theme.darkPrimary.withValues(alpha: 0.5) : theme.cardBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isCompleted ? theme.accent : const Color(0xFF334155),
              width: isCompleted ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                item.text,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  height: 1.8,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (item.virtue != null && item.virtue!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  item.virtue!,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(color: theme.accent, fontSize: 12, height: 1.5),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, color: Colors.white54, size: 20),
                        tooltip: "نسخ الذكر",
                        onPressed: () => _copyDhikr(item.text),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_rounded, color: Colors.white54, size: 20),
                        tooltip: "مشاركة الذكر",
                        onPressed: () => _shareDhikr(item.text),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white54, size: 20),
                        tooltip: "إعادة العداد",
                        onPressed: () => _resetDhikr(item),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted ? const Color(0xFF10B981) : theme.accent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onPressed: () => _incrementDhikr(item),
                    child: Text(
                      isCompleted ? "اكتمل ✔" : "${item.currentCount} / ${item.targetCount}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTasbeehCounter(AppThemeColor theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Selectable Dhikr Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.cardBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: DropdownButton<String>(
              value: _selectedTasbeehDhikr,
              dropdownColor: theme.cardBackground,
              isExpanded: true,
              underline: const SizedBox(),
              icon: Icon(Icons.keyboard_arrow_down, color: theme.accent),
              items: _tasbeehPresets.map((d) {
                return DropdownMenuItem<String>(
                  value: d,
                  child: Text(d, style: const TextStyle(color: Colors.white, fontSize: 14)),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedTasbeehDhikr = val;
                    _tasbeehCount = 0;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: theme.darkPrimary,
                      duration: const Duration(seconds: 1),
                      content: Text("تم اختيار: $val"),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 36),

          // Big Interactive Ring Counter
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              setState(() {
                _tasbeehCount++;
              });
              if (_tasbeehCount % 33 == 0) {
                AdhanAudioService.playNotificationChime();
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: const Color(0xFF065F46),
                    duration: const Duration(seconds: 2),
                    content: Text("ما شاء الله! بلغت $_tasbeehCount تسبيحة 📿 تقبل الله منك!"),
                  ),
                );
              }
            },
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [theme.darkPrimary, theme.cardBackground],
                ),
                border: Border.all(color: theme.accent, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: theme.accent.withValues(alpha: 0.3),
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$_tasbeehCount",
                    style: TextStyle(
                      color: theme.accent,
                      fontSize: 54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "انقر للتسبيح",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 36),

          // Reset button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF334155),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text("تصفير العداد", style: TextStyle(color: Colors.white)),
            onPressed: () {
              setState(() {
                _tasbeehCount = 0;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color(0xFF1E293B),
                  duration: Duration(seconds: 1),
                  content: Text("تم تصفير السبحة الإلكترونية 🔄"),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
