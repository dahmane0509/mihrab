class AdhanVoice {
  final String id;
  final String titleAr;
  final String subtitleAr;

  const AdhanVoice({
    required this.id,
    required this.titleAr,
    required this.subtitleAr,
  });
}

class AppSettings {
  static const List<AdhanVoice> adhanVoices = [
    AdhanVoice(
      id: "algiers_great_mosque",
      titleAr: "أذان جامع الجزائر (الجامع الأعظم)",
      subtitleAr: "الصوت الرسمي لجامع الجزائر",
    ),
    AdhanVoice(
      id: "algerian_traditional",
      titleAr: "الأذان الجزائري الأصيل (المقام المغاربي)",
      subtitleAr: "أذان إذاعة وتلفزيون الجزائر",
    ),
    AdhanVoice(
      id: "makkah",
      titleAr: "أذان المسجد الحرام (مكة المكرمة)",
      subtitleAr: "أذان الحرم المكي الشريف",
    ),
    AdhanVoice(
      id: "madinah",
      titleAr: "أذان المسجد النبوي (المدينة المنورة)",
      subtitleAr: "أذان الحرم النبوي الشريف",
    ),
    AdhanVoice(
      id: "al_aqsa",
      titleAr: "أذان المسجد الأقصى المبارك",
      subtitleAr: "أذان القدس الشريف",
    ),
  ];

  static const List<int> reminderMinutesOptions = [0, 5, 10, 15, 20, 30];
}
