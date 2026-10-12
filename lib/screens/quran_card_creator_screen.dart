import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../services/theme_service.dart';
import '../services/app_feedback.dart';

class QuranCardModel {
  final String title;
  final String text;
  final String reference;
  final String category;

  const QuranCardModel({
    required this.title,
    required this.text,
    required this.reference,
    required this.category,
  });
}

class CardThemePreset {
  final String name;
  final List<Color> gradientColors;
  final Color borderColor;
  final Color accentColor;

  const CardThemePreset({
    required this.name,
    required this.gradientColors,
    required this.borderColor,
    required this.accentColor,
  });
}

class QuranCardCreatorScreen extends StatefulWidget {
  const QuranCardCreatorScreen({super.key});

  @override
  State<QuranCardCreatorScreen> createState() => _QuranCardCreatorScreenState();
}

class _QuranCardCreatorScreenState extends State<QuranCardCreatorScreen> {
  static const List<CardThemePreset> _themePresets = [
    CardThemePreset(
      name: 'زمردي مِحراب',
      gradientColors: [Color(0xFF064E3B), Color(0xFF0F291E), Color(0xFF0A1F18)],
      borderColor: Color(0xFFD4AF37),
      accentColor: Color(0xFF10B981),
    ),
    CardThemePreset(
      name: 'كحلي ملكي',
      gradientColors: [Color(0xFF0F254E), Color(0xFF0C1938), Color(0xFF070F24)],
      borderColor: Color(0xFFF59E0B),
      accentColor: Color(0xFF38BDF8),
    ),
    CardThemePreset(
      name: 'عقيق أندلسي',
      gradientColors: [Color(0xFF4C0519), Color(0xFF2E0818), Color(0xFF180510)],
      borderColor: Color(0xFFFBBF24),
      accentColor: Color(0xFFFB7185),
    ),
    CardThemePreset(
      name: 'سواد الصحراء',
      gradientColors: [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF050B14)],
      borderColor: Color(0xFF38BDF8),
      accentColor: Color(0xFF0EA5E9),
    ),
    CardThemePreset(
      name: 'ذهب خالص',
      gradientColors: [Color(0xFF292524), Color(0xFF1C1917), Color(0xFF0C0A09)],
      borderColor: Color(0xFFFFD700),
      accentColor: Color(0xFFEAB308),
    ),
  ];

  static const List<QuranCardModel> _presetCards = [
    // آيات قرآنية
    QuranCardModel(
      title: 'طمأنينة القلب',
      text: '﴿الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ ۗ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ﴾',
      reference: 'سورة الرعد: 28',
      category: 'آيات قرآنية',
    ),
    QuranCardModel(
      title: 'بشارة اليسر والفرج',
      text: '﴿فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ۝ إِنَّ مَعَ الْعُسْرِ يُسْرًا﴾',
      reference: 'سورة الشرح: 5-6',
      category: 'آيات قرآنية',
    ),
    QuranCardModel(
      title: 'التوكل والكفاية',
      text: '﴿وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ ۚ إِنَّ اللَّهَ بَالِغُ أَمْرِهِ﴾',
      reference: 'سورة الطلاق: 3',
      category: 'آيات قرآنية',
    ),
    QuranCardModel(
      title: 'القرب والإجابة',
      text: '﴿وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ﴾',
      reference: 'سورة البقرة: 186',
      category: 'آيات قرآنية',
    ),
    QuranCardModel(
      title: 'سعة رحمة الله',
      text: '﴿قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ۚ إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا﴾',
      reference: 'سورة الزمر: 53',
      category: 'آيات قرآنية',
    ),
    QuranCardModel(
      title: 'الذكر والشكر',
      text: '﴿فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ﴾',
      reference: 'سورة البقرة: 152',
      category: 'آيات قرآنية',
    ),
    // أحاديث نبوية
    QuranCardModel(
      title: 'الكلمتان الحبيبتان',
      text: '«كَلِمَتَانِ خَفِيفَتَانِ عَلَى اللِّسَانِ، ثَقِيلَتَانِ فِي الْمِيزَانِ، حَبِيبَتَانِ إِلَى الرَّحْمَنِ: سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ»',
      reference: 'متفق عليه',
      category: 'أحاديث نبوية',
    ),
    QuranCardModel(
      title: 'نفع الناس والخير',
      text: '«أَحَبُّ النَّاسِ إِلَى اللَّهِ أَنْفَعُهُمْ لِلنَّاسِ، وَأَحَبُّ الأَعْمَالِ إِلَى اللَّهِ سُرُورٌ تُدْخِلُهُ عَلَى مُسْلِمٍ»',
      reference: 'صحيح الجامع',
      category: 'أحاديث نبوية',
    ),
    QuranCardModel(
      title: 'الصدقة الجارية',
      text: '«إِذَا مَاتَ ابْنُ آدَمَ انْقَطَعَ عَمَلُهُ إِلَّا مِنْ ثَلَاثٍ: صَدَقَةٍ جَارِيَةٍ، أَوْ عِلْمٍ يُنْتَفَعُ بِهِ، أَوْ وَلَدٍ صَالِحٍ يَدْعُو لَهُ»',
      reference: 'صحيح مسلم',
      category: 'أحاديث نبوية',
    ),
    QuranCardModel(
      title: 'فضل الاستغفار والتسبيح',
      text: '«مَنْ قَالَ: سُبْحَانَ اللَّهِ وَبِحَمْدِهِ فِي يَوْمٍ مِائَةَ مَرَّةٍ، حُطَّتْ خَطَايَاهُ وَإِنْ كَانَتْ مِثْلَ زَبَدِ الْبَحْرِ»',
      reference: 'صحيح البخاري',
      category: 'أحاديث نبوية',
    ),
    // أدعية وأذكار
    QuranCardModel(
      title: 'دعاء ذي النون للفرج',
      text: '«لَا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ»',
      reference: 'سورة الأنبياء: 87',
      category: 'أدعية مأثورة',
    ),
    QuranCardModel(
      title: 'سيد الاستغفار',
      text: '«اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ»',
      reference: 'صحيح البخاري',
      category: 'أدعية مأثورة',
    ),
    QuranCardModel(
      title: 'طلب العفو والعافية',
      text: '«اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ»',
      reference: 'سنن أبي داود وصححه الألباني',
      category: 'أدعية مأثورة',
    ),
  ];

  int _selectedThemeIndex = 0;
  String _selectedCategory = 'آيات قرآنية';
  late QuranCardModel _currentCard;
  bool _isCustomMode = false;
  double _fontSize = 18.0;
  bool _showBismillah = true;
  bool _showFooter = true;

  final TextEditingController _customTextController = TextEditingController();
  final TextEditingController _customRefController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentCard = _presetCards.first;
    _customTextController.text = _currentCard.text;
    _customRefController.text = _currentCard.reference;
  }

  @override
  void dispose() {
    _customTextController.dispose();
    _customRefController.dispose();
    super.dispose();
  }

  void _selectPreset(QuranCardModel card) {
    AppFeedback.tap();
    setState(() {
      _currentCard = card;
      _isCustomMode = false;
      _customTextController.text = card.text;
      _customRefController.text = card.reference;
    });
  }

  String _buildFormattedShareText() {
    final buffer = StringBuffer();
    if (_showBismillah) {
      buffer.writeln('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ');
      buffer.writeln();
    }
    final text = _isCustomMode ? _customTextController.text.trim() : _currentCard.text;
    buffer.writeln(text);
    buffer.writeln();

    final ref = _isCustomMode ? _customRefController.text.trim() : _currentCard.reference;
    if (ref.isNotEmpty) {
      buffer.writeln('[$ref]');
      buffer.writeln();
    }

    if (_showFooter) {
      buffer.writeln('✨ صدقة جارية — عبر تطبيق مِـحْـرَابْ الجزائر ✨');
    }

    return buffer.toString().trim();
  }

  Future<void> _shareCardText() async {
    AppFeedback.tap();
    final text = _buildFormattedShareText();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFFDC2626),
          content: Text('الرجاء إدخال نص للبطاقة قبل المشاركة'),
        ),
      );
      return;
    }

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          subject: 'بطاقة إسلامية - تطبيق مِـحْـرَابْ الجزائر',
        ),
      );
    } catch (_) {
      // Fallback to copy if native sharing fails on some devices
      await Clipboard.setData(ClipboardData(text: text));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF059669),
          content: Text('تم نسخ محتوى البطاقة للحافظة لمشاركتها 📋'),
        ),
      );
    }
  }

  Future<void> _copyCardText() async {
    AppFeedback.tap();
    final text = _buildFormattedShareText();
    if (text.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF059669),
        content: Text('تم نسخ محتوى البطاقة بالكامل إلى الحافظة بنجاح 📋✨'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themePreset = _themePresets[_selectedThemeIndex];

    return ValueListenableBuilder<AppThemeColor>(
      valueListenable: ThemeService.currentTheme,
      builder: (context, theme, _) {
        return Scaffold(
          backgroundColor: theme.background,
          appBar: AppBar(
            backgroundColor: theme.darkPrimary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'صانع ومشارك البطاقات القرآنية',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.white, size: 22),
                tooltip: 'نسخ النص',
                onPressed: _copyCardText,
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white, size: 22),
                tooltip: 'مشاركة البطاقة',
                onPressed: _shareCardText,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Live Card Preview
                _buildLiveCardPreview(themePreset),

                const SizedBox(height: 16),

                // 2. Action Buttons (Share & Copy)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 3,
                        ),
                        icon: const Icon(Icons.share, size: 20),
                        label: const Text(
                          'مشاركة عبر التطبيقات',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _shareCardText,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF334155), width: 1.5),
                          backgroundColor: theme.cardBackground,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.copy, size: 18, color: Color(0xFFD4AF37)),
                        label: const Text(
                          'نسخ',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _copyCardText,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // 3. Theme Palettes Selector
                _buildSectionHeader('ألوان وخلفية البطاقة', Icons.palette),
                const SizedBox(height: 10),
                _buildThemeSelector(),

                const SizedBox(height: 20),

                // 4. Customization Options (Font Size & Toggles)
                _buildSectionHeader('تنسيق البطاقة', Icons.tune),
                const SizedBox(height: 10),
                _buildFormattingOptions(theme),

                const SizedBox(height: 20),

                // 5. Card Content Categories (Presets vs Custom)
                _buildSectionHeader('محتوى البطاقة (آيات، أحاديث، نص مخصص)', Icons.menu_book),
                const SizedBox(height: 10),
                _buildCategoryChips(),

                const SizedBox(height: 12),

                // Content list or Custom editor
                if (_isCustomMode)
                  _buildCustomTextEditor(theme)
                else
                  _buildPresetsList(theme),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD4AF37), size: 19),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveCardPreview(CardThemePreset preset) {
    final text = _isCustomMode ? _customTextController.text.trim() : _currentCard.text;
    final ref = _isCustomMode ? _customRefController.text.trim() : _currentCard.reference;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: preset.gradientColors,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: preset.borderColor, width: 2.2),
        boxShadow: [
          BoxShadow(
            color: preset.borderColor.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle Islamic Ornamental corner accents
          Positioned(
            top: 10,
            right: 12,
            child: Text(
              '۞',
              style: TextStyle(
                color: preset.borderColor.withValues(alpha: 0.4),
                fontSize: 20,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 12,
            child: Text(
              '۞',
              style: TextStyle(
                color: preset.borderColor.withValues(alpha: 0.4),
                fontSize: 20,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_showBismillah) ...[
                  Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(
                      color: preset.borderColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 70,
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          preset.borderColor,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Text(
                  text.isEmpty ? '«أدخل نص البطاقة القرآنية هنا»' : text,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    color: Colors.white,
                    fontSize: _fontSize,
                    height: 1.9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (ref.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: preset.borderColor.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      ref,
                      style: const TextStyle(
                        color: Color(0xFFF1F5F9),
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                if (_showFooter) ...[
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, color: preset.borderColor, size: 12),
                      const SizedBox(width: 6),
                      Text(
                        'صدقة جارية — تطبيق مِـحْـرَابْ الجزائر',
                        style: TextStyle(
                          color: preset.borderColor.withValues(alpha: 0.85),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.auto_awesome, color: preset.borderColor, size: 12),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _themePresets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final p = _themePresets[index];
          final isSelected = index == _selectedThemeIndex;

          return InkWell(
            onTap: () {
              AppFeedback.tap();
              setState(() => _selectedThemeIndex = index);
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [p.gradientColors.first, p.gradientColors[1]]),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? p.borderColor : const Color(0xFF475569),
                  width: isSelected ? 2.2 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: p.borderColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    p.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormattingOptions(AppThemeColor theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'حجم الخط:',
                style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  _buildSizeButton('صغير', 16.0),
                  const SizedBox(width: 6),
                  _buildSizeButton('متوسط', 18.0),
                  const SizedBox(width: 6),
                  _buildSizeButton('كبير', 22.0),
                ],
              ),
            ],
          ),
          const Divider(color: Color(0xFF334155), height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'إظهار البسملة (﷽):',
                style: TextStyle(color: Colors.white, fontSize: 13.5),
              ),
              Switch.adaptive(
                value: _showBismillah,
                activeTrackColor: const Color(0xFF10B981),
                activeThumbColor: Colors.white,
                onChanged: (val) {
                  AppFeedback.tap();
                  setState(() => _showBismillah = val);
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'تذييل البطاقة (صدقة جارية):',
                style: TextStyle(color: Colors.white, fontSize: 13.5),
              ),
              Switch.adaptive(
                value: _showFooter,
                activeTrackColor: const Color(0xFF10B981),
                activeThumbColor: Colors.white,
                onChanged: (val) {
                  AppFeedback.tap();
                  setState(() => _showFooter = val);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSizeButton(String label, double size) {
    final isSelected = _fontSize == size;
    return InkWell(
      onTap: () {
        AppFeedback.tap();
        setState(() => _fontSize = size);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF10B981) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFF475569)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['آيات قرآنية', 'أحاديث نبوية', 'أدعية مأثورة', 'اكتب نصك الخاص'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = (_isCustomMode && cat == 'اكتب نصك الخاص') ||
              (!_isCustomMode && _selectedCategory == cat);

          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              selectedColor: const Color(0xFF10B981),
              backgroundColor: const Color(0xFF1E293B),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(color: isSelected ? const Color(0xFF10B981) : const Color(0xFF334155)),
              onSelected: (selected) {
                if (!selected) return;
                AppFeedback.tap();
                setState(() {
                  if (cat == 'اكتب نصك الخاص') {
                    _isCustomMode = true;
                  } else {
                    _isCustomMode = false;
                    _selectedCategory = cat;
                    final firstInCat = _presetCards.firstWhere((c) => c.category == cat);
                    _currentCard = firstInCat;
                    _customTextController.text = firstInCat.text;
                    _customRefController.text = firstInCat.reference;
                  }
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCustomTextEditor(AppThemeColor theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'نص البطاقة الخاص بك:',
            style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _customTextController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.6),
            decoration: InputDecoration(
              hintText: 'اكتب الآية، الحديث، أو الدعاء الذي ترغب بتصميمه ومشاركته...',
              hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF334155)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          const Text(
            'المصدر أو المرجع (اختياري):',
            style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _customRefController,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'مثال: [سورة البقرة: 255] أو [صحيح مسلم]',
              hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              filled: true,
              fillColor: const Color(0xFF0F172A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF334155)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetsList(AppThemeColor theme) {
    final filtered = _presetCards.where((c) => c.category == _selectedCategory).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final card = filtered[index];
        final isSelected = !_isCustomMode && _currentCard.text == card.text;

        return Material(
          color: theme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => _selectPreset(card),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? const Color(0xFF10B981) : const Color(0xFF334155),
                  width: isSelected ? 2.0 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.circle_outlined,
                        color: isSelected ? const Color(0xFF10B981) : const Color(0xFF64748B),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        card.title,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF10B981) : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        card.reference,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
