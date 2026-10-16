import 'package:flutter/material.dart';
import 'package:mihrab_app/services/auto_adhkar_service.dart';
import 'package:mihrab_app/services/theme_service.dart';

class AutoAdhkarScreen extends StatefulWidget {
  const AutoAdhkarScreen({super.key});

  @override
  State<AutoAdhkarScreen> createState() => _AutoAdhkarScreenState();
}

class _AutoAdhkarScreenState extends State<AutoAdhkarScreen> {
  bool _enabled = false;
  int _intervalMinutes = 15;
  bool _soundEnabled = false;
  String _selectedCategory = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  void _loadState() {
    setState(() {
      _enabled = AutoAdhkarService.isEnabled;
      _intervalMinutes = AutoAdhkarService.intervalMinutes;
      _soundEnabled = AutoAdhkarService.soundEnabled;
    });
  }

  void _toggleMasterSwitch(bool value) async {
    setState(() {
      _enabled = value;
      AutoAdhkarService.isEnabled = value;
    });
    await AutoAdhkarService.saveSettings();
  }

  void _changeInterval(int minutes) async {
    setState(() {
      _intervalMinutes = minutes;
      AutoAdhkarService.intervalMinutes = minutes;
    });
    await AutoAdhkarService.saveSettings();
  }

  void _toggleSound(bool value) async {
    setState(() {
      _soundEnabled = value;
      AutoAdhkarService.soundEnabled = value;
    });
    await AutoAdhkarService.saveSettings();
  }

  void _toggleItem(AdhkarItem item, bool value) async {
    setState(() {
      item.isEnabled = value;
    });
    await AutoAdhkarService.toggleDhikr(item.id, value);
  }

  void _selectAll(bool select) async {
    setState(() {
      for (var item in AutoAdhkarService.allAdhkar) {
        item.isEnabled = select;
      }
    });
    await AutoAdhkarService.saveSettings();
  }

  void _showAddCustomDhikrDialog(AppThemeColor theme) {
    final textController = TextEditingController();
    final virtueController = TextEditingController();
    String category = 'أدعية مخصصة';

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: theme.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.add_circle, color: theme.accent, size: 24),
              const SizedBox(width: 8),
              const Text(
                "إضافة ذكر أو دعاء مخصص",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "اكتب الذكر أو الدعاء الذي ترغب أن يظهر لك على شاشة هاتفك:",
                  style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: textController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "مثال: اللَّهُمَّ رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً...",
                    hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF334155)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.accent),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text("التصنيف:", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF334155)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    'أدعية مخصصة',
                    'أدعية نبوية',
                    'تفريج الكرب',
                    'تيسير الأمور',
                    'حفظ وتحصين',
                    'استغفار وتوبة',
                  ].map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => category = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: virtueController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: "الفضل أو الملاحظة (اختياري)",
                    labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    hintText: "مثال: دعاء مبارك لتفريج الهموم",
                    hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                    filled: true,
                    fillColor: const Color(0xFF0F172A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF334155)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("إلغاء", style: TextStyle(color: Color(0xFF94A3B8))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                final text = textController.text.trim();
                if (text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text("يرجى كتابة نص الذكر أو الدعاء أولاً"),
                    ),
                  );
                  return;
                }
                final virtue = virtueController.text.trim();
                await AutoAdhkarService.addCustomDhikr(
                  text: text,
                  category: category,
                  virtue: virtue.isNotEmpty ? virtue : 'دعاء مخصص تم حفظه',
                );
                setState(() {});
                if (!mounted || !ctx.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xFF065F46),
                    content: Text("تمت إضافة الذكر بنجاح وإدراجه في دورة الظهور ✅"),
                  ),
                );
              },
              child: const Text("حفظ الذكر", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _testTriggerDhikr(AppThemeColor theme, [AdhkarItem? specific]) async {
    final item = specific ?? AutoAdhkarService.getRandomEnabledDhikr();
    if (item == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text("يرجى تفعيل ذكر واحد على الأقل للظهور"),
        ),
      );
      return;
    }

    // Display actual heads-up notification on user's device screen
    await AutoAdhkarService.showFloatingDhikrNotification(specificItem: item);

    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: theme.accent.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF475569),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_active, color: theme.accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  "معاينة الذكر المنبثق على الشاشة",
                  style: TextStyle(color: theme.accent, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4AF37), width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.category,
                      style: const TextStyle(color: Color(0xFF854D0E), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                  if (item.virtue.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      item.virtue,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primary,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("حسناً", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeColor>(
      valueListenable: ThemeService.currentTheme,
      builder: (context, theme, _) {
        final allItems = AutoAdhkarService.allAdhkar;
        final filteredItems = _selectedCategory == 'الكل'
            ? allItems
            : allItems.where((i) => i.category == _selectedCategory).toList();

        final enabledCount = allItems.where((i) => i.isEnabled).length;

        final categories = ['الكل', ...{...allItems.map((i) => i.category)}];

        return Scaffold(
          backgroundColor: theme.background,
          appBar: AppBar(
            backgroundColor: theme.cardBackground,
            elevation: 0,
            title: const Text(
              "أذكار وأدعية الشاشة التلقائية",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.add, color: theme.accent),
                tooltip: "إضافة ذكر أو دعاء مخصص",
                onPressed: () => _showAddCustomDhikrDialog(theme),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: theme.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("إضافة ذكر جديد", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () => _showAddCustomDhikrDialog(theme),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Master Toggle Hero Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primary.withValues(alpha: 0.35), theme.cardBackground],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.accent.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.auto_awesome, color: theme.accent, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ظهور الأذكار التلقائي على الشاشة",
                                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "تذكيرك بذكر الله والأدعية أثناء تصفح الهاتف والإنترنت",
                                style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _enabled,
                          activeThumbColor: theme.accent,
                          activeTrackColor: theme.primary,
                          onChanged: _toggleMasterSwitch,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: Color(0xFF334155), height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: theme.accent, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              "الأذكار المفعلة: $enabledCount من ${allItems.length}",
                              style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 12),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => _testTriggerDhikr(theme),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: theme.primary.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: theme.accent.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.play_circle_outline, color: theme.accent, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  "اختبر الظهور الآن",
                                  style: TextStyle(color: theme.accent, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Frequency & Sound Settings
              _buildSectionHeader("إعدادات التكرار والتنبيه", Icons.timer, theme.accent),
              const SizedBox(height: 8),
              Material(
                color: theme.cardBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFF334155)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "معدل ظهور الذكر على الشاشة أثناء التصفح:",
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        {'mins': 5, 'label': 'كل 5 دقائق (سريع)'},
                        {'mins': 10, 'label': 'كل 10 دقائق'},
                        {'mins': 15, 'label': 'كل 15 دقيقة (مستحسن)'},
                        {'mins': 30, 'label': 'كل 30 دقيقة'},
                        {'mins': 60, 'label': 'كل ساعة'},
                        {'mins': 120, 'label': 'كل ساعتين'},
                      ].map((item) {
                        final mins = item['mins'] as int;
                        final label = item['label'] as String;
                        final isSelected = _intervalMinutes == mins;
                        return ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          selectedColor: theme.primary,
                          backgroundColor: const Color(0xFF0F172A),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (_) => _changeInterval(mins),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: Color(0xFF334155), height: 1),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _soundEnabled,
                      activeThumbColor: theme.accent,
                      title: const Text("نغمة تنبيه صوتية عند ظهور الذكر", style: TextStyle(color: Colors.white, fontSize: 13)),
                      subtitle: const Text("تشغيل صوت هادئ مع الإشعار المنبثق", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                      onChanged: _toggleSound,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

              // 3. Selection & Filtering Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader("اختر الأذكار والأدعية التي تظهر لك", Icons.format_list_bulleted, theme.accent),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => _selectAll(true),
                        child: Text("تحديد الكل", style: TextStyle(color: theme.accent, fontSize: 11)),
                      ),
                      TextButton(
                        onPressed: () => _selectAll(false),
                        child: const Text("إلغاء الكل", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Category filter pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((cat) {
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: FilterChip(
                        label: Text(cat),
                        selected: isSel,
                        selectedColor: theme.primary,
                        backgroundColor: const Color(0xFF1E293B),
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : const Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              // 4. Adhkar Items List
              ...filteredItems.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: item.isEnabled ? const Color(0xFF1E293B) : const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: item.isEnabled
                          ? theme.accent.withValues(alpha: 0.35)
                          : const Color(0xFF334155),
                      width: item.isEnabled ? 1.2 : 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: item.isEnabled,
                            activeColor: theme.primary,
                            checkColor: Colors.white,
                            onChanged: (val) {
                              if (val != null) _toggleItem(item, val);
                            },
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: theme.primary.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item.category,
                                        style: TextStyle(color: theme.accent, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    if (item.isCustom) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.blueAccent.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          "مضاف من طرفك",
                                          style: TextStyle(color: Colors.lightBlueAccent, fontSize: 9),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.text,
                                  style: TextStyle(
                                    color: item.isEnabled ? Colors.white : const Color(0xFF94A3B8),
                                    fontSize: 14,
                                    fontWeight: item.isEnabled ? FontWeight.bold : FontWeight.normal,
                                    height: 1.5,
                                  ),
                                ),
                                if (item.virtue.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    item.virtue,
                                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_red_eye_outlined, color: theme.accent, size: 18),
                                tooltip: "معاينة الظهور",
                                onPressed: () => _testTriggerDhikr(theme, item),
                              ),
                              if (item.isCustom)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                  tooltip: "حذف الذكر المخصص",
                                  onPressed: () async {
                                    await AutoAdhkarService.deleteCustomDhikr(item.id);
                                    setState(() {});
                                  },
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color accentColor) {
    return Row(
      children: [
        Icon(icon, color: accentColor, size: 18),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
