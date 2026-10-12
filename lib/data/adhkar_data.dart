class DhikrItem {
  final String text;
  final String? virtue;
  final int targetCount;
  int currentCount;

  // Compatibility getters
  String get textAr => text;
  String? get fadl => virtue;

  DhikrItem({
    required this.text,
    this.virtue,
    required this.targetCount,
    this.currentCount = 0,
  });
}

class DhikrCategory {
  final String id;
  final String titleAr;
  final String iconName;
  final List<DhikrItem> items;

  DhikrCategory({
    required this.id,
    required this.titleAr,
    required this.iconName,
    required this.items,
  });
}

// Typedef alias for compatibility
typedef AdhkarCategory = DhikrCategory;

class AdhkarRepository {
  static List<DhikrCategory> getCategories() {
    return [
      DhikrCategory(
        id: "morning",
        titleAr: "أذكار الصباح",
        iconName: "wb_sunny",
        items: [
          DhikrItem(
            text: "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.",
            virtue: "من قالها حين يصبح وحين يمسي كفته من كل شيء.",
            targetCount: 1,
          ),
          DhikrItem(
            text: "اللَّهُمَّ أَنْتَ رَبِّي لاَ إِلَهَ إِلاَّ أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لاَ يَغْفِرُ الذُّنُوبَ إِلاَّ أَنْتَ.",
            virtue: "سيد الاستغفار، من قالها موقناً بها ومات دخل الجنة.",
            targetCount: 1,
          ),
          DhikrItem(
            text: "بِسْمِ اللَّهِ الَّذِي لاَ يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الأَرْضِ وَلاَ فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ.",
            virtue: "لم يضره شيء.",
            targetCount: 3,
          ),
          DhikrItem(
            text: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، عَدَدَ خَلْقِهِ، وَرِضَا نَفْسِهِ، وَزِنَةَ عَرْشِهِ، وَمِدَادَ كَلِمَاتِهِ.",
            virtue: "تعدل ساعات من الذكر.",
            targetCount: 3,
          ),
          DhikrItem(
            text: "اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لاَ إِلَهَ إِلاَّ أَنْتَ.",
            virtue: "دعاء العافية والوقاية من الكفر والفقر وعذاب القبر.",
            targetCount: 3,
          ),
        ],
      ),
      DhikrCategory(
        id: "evening",
        titleAr: "أذكار المساء",
        iconName: "nights_stay",
        items: [
          DhikrItem(
            text: "أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ.",
            virtue: "حفظ وبركة المساء.",
            targetCount: 1,
          ),
          DhikrItem(
            text: "أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ.",
            virtue: "لم تضره لدغة ولا هم في ليلته.",
            targetCount: 3,
          ),
          DhikrItem(
            text: "اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ.",
            targetCount: 1,
          ),
          DhikrItem(
            text: "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ (100 مرة).",
            virtue: "حُطَّت خطاياه وإن كانت مثل زبد البحر.",
            targetCount: 100,
          ),
        ],
      ),
      DhikrCategory(
        id: "after_prayer",
        titleAr: "أذكار بعد الصلاة",
        iconName: "mosque",
        items: [
          DhikrItem(
            text: "أَسْتَغْفِرُ اللَّهَ (3 مرات)، اللَّهُمَّ أَنْتَ السَّلاَمُ وَمِنْكَ السَّلاَمُ، تَبَارَكْتَ يَا ذَا الْجَلاَلِ وَالإِكْرَامِ.",
            targetCount: 1,
          ),
          DhikrItem(
            text: "سُبْحَانَ اللَّهِ",
            targetCount: 33,
          ),
          DhikrItem(
            text: "الْحَمْدُ لِلَّهِ",
            targetCount: 33,
          ),
          DhikrItem(
            text: "اللَّهُ أَكْبَرُ",
            targetCount: 33,
          ),
          DhikrItem(
            text: "لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.",
            virtue: "تمام المائة، غفرت خطاياه وإن كانت مثل زبد البحر.",
            targetCount: 1,
          ),
          DhikrItem(
            text: "اللَّهُ لاَ إِلَهَ إِلاَّ هُوَ الْحَيُّ الْقَيُّومُ لاَ تَأْخُذُهُ سِنَةٌ وَلاَ نَوْمٌ (آية الكرسي).",
            virtue: "من قرأها دبر كل صلاة مكتوبة لم يمنعه من دخول الجنة إلا أن يموت.",
            targetCount: 1,
          ),
        ],
      ),
      DhikrCategory(
        id: "sleep",
        titleAr: "أذكار النوم والاستيقاظ",
        iconName: "bedtime",
        items: [
          DhikrItem(
            text: "بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي، وَبِكَ أَرْفَعُهُ، فَإِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ.",
            virtue: "حفظ النفس والروح عند النوم.",
            targetCount: 1,
          ),
          DhikrItem(
            text: "اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ.",
            virtue: "يقال عند وضع اليد اليمنى تحت الخد الأيمن.",
            targetCount: 3,
          ),
          DhikrItem(
            text: "الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ.",
            virtue: "ذكر الاستيقاظ من النوم.",
            targetCount: 1,
          ),
        ],
      ),
    ];
  }
}
