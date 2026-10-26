# حزمة الإصلاحات الشاملة لتطبيق مِحْراب (Mihrab App)

تحتوي هذه الحزمة على جميع الملفات المصححة والجاهزة للنسخ مباشرة إلى مجلد مشروعك على الحاسوب (`C:\mihrab\`):

1. **`android/app/src/main/res/raw/`**:
   - يحتوي على ملفات الصوت (`athan.mp3`, `adhan.mp3`, `notification.mp3`, `takbeer.wav`) التي كانت مفقودة من موارد أندرويد الأصلية وتسببت في خطأ `invalid_sound` عند جدولة إشعارات الأذان.
   - يحتوي على ملف `keep.xml` لمنع أداة R8 (`shrinkResources`) من حذف ملفات الصوت أثناء بناء نسخة `release`.
2. **`assets/audio/`**:
   - ملفات الصوت بعد إصلاح الترويسة المزدوجة في `adhan.mp3` وتحويل `adhan.wav` و `notification.wav` إلى صيغة PCM WAV حقيقية بدلاً من ملفات MP3 بامتداد خاطئ.
3. **`android/app/src/main/AndroidManifest.xml`**:
   - إزالة تكرار إذن `WAKE_LOCK` وإضافة استعلامات `mailto` و `geo` لدعم فتح البريد والخرائط في أندرويد 11+.
4. **`android/app/src/main/kotlin/com/mihrab/algeria/mihrab_app/MainActivity.kt`**:
   - فحص آمن لوجود `R.raw.athan` قبل ربطه بقناة الإشعارات، ومنع إبقاء الشاشة مضاءة دائماً عند الفتح العادي للتطبيق.
5. **`android/app/src/main/kotlin/com/mihrab/algeria/mihrab_app/MihrabWidgetProvider.kt`**:
   - حساب الوقت المتبقي للصلاة القادمة ديناميكياً في ودجت الشاشة الرئيسية.
6. **`lib/services/quran_audio_reciters_service.dart`**:
   - تصحيح روابط جميع القراء الـ 12 الافتراضيين للقرآن الكريم من النطاق الوهمي `cdn.mp3quran.net` إلى خوادم `server6..14.mp3quran.net` الرسمية.
7. **`lib/services/adhan_audio_service.dart`**:
   - تصحيح الروابط الـ 7 المعطلة (404) في مستودع `Kiwifu/adhan-mp3` وتصحيح مسار `AssetSource`.
