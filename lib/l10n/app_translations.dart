// Comprehensive Multi-Language System for Mihrab (محراب)
// Supported Languages: Arabic (ar - default RTL), English (en - LTR), French (fr - LTR)

class AppTranslations {
  static const Map<String, Map<String, String>> _translations = {
    // App Brand & General
    'app_name': {
      'ar': 'مِحْرَاب',
      'en': 'Mihrab',
      'fr': 'Mihrab',
    },
    'app_subtitle': {
      'ar': 'الرفيق الإسلامي الشامل للمسلم حول العالم',
      'en': 'Comprehensive Islamic Companion for Muslims Worldwide',
      'fr': 'Compagnon Islamique Complet pour les Musulmans du Monde',
    },
    'app_slogan': {
      'ar': 'صلاتك، قبلتك، قرآنك في كل مكان',
      'en': 'Your prayers, Qibla, and Quran anywhere',
      'fr': 'Vos prières, Qibla et Coran partout dans le monde',
    },

    // Navigation Tabs
    'tab_next_prayer': {
      'ar': 'الصلاة القادمة',
      'en': 'Next Prayer',
      'fr': 'Prochaine Prière',
    },
    'tab_prayer_times': {
      'ar': 'أوقات الصلاة',
      'en': 'Prayer Times',
      'fr': 'Horaires de Prière',
    },
    'tab_services': {
      'ar': 'الخدمات والميزات',
      'en': 'Services & Features',
      'fr': 'Services & Fonctions',
    },
    'tab_qibla': {
      'ar': 'بوصلة القبلة',
      'en': 'Qibla Compass',
      'fr': 'Boussole Qibla',
    },

    // Prayer Names
    'fajr': {
      'ar': 'الفجر',
      'en': 'Fajr',
      'fr': 'Fajr',
    },
    'sunrise': {
      'ar': 'الشروق',
      'en': 'Sunrise',
      'fr': 'Lever du soleil',
    },
    'dhuhr': {
      'ar': 'الظهر',
      'en': 'Dhuhr',
      'fr': 'Dhuhr',
    },
    'asr': {
      'ar': 'العصر',
      'en': 'Asr',
      'fr': 'Asr',
    },
    'maghrib': {
      'ar': 'المغرب',
      'en': 'Maghrib',
      'fr': 'Maghrib',
    },
    'isha': {
      'ar': 'العشاء',
      'en': 'Isha',
      'fr': 'Isha',
    },

    // Full Prayer Names
    'prayer_fajr': {
      'ar': 'صلاة الفجر',
      'en': 'Fajr Prayer',
      'fr': 'Prière du Fajr',
    },
    'prayer_sunrise': {
      'ar': 'شروق الشمس',
      'en': 'Sunrise',
      'fr': 'Lever du soleil',
    },
    'prayer_dhuhr': {
      'ar': 'صلاة الظهر',
      'en': 'Dhuhr Prayer',
      'fr': 'Prière du Dhuhr',
    },
    'prayer_asr': {
      'ar': 'صلاة العصر',
      'en': 'Asr Prayer',
      'fr': 'Prière de l\'Asr',
    },
    'prayer_maghrib': {
      'ar': 'صلاة المغرب',
      'en': 'Maghrib Prayer',
      'fr': 'Prière du Maghrib',
    },
    'prayer_isha': {
      'ar': 'صلاة العشاء',
      'en': 'Isha Prayer',
      'fr': 'Prière de l\'Isha',
    },

    // Next Prayer Screen
    'remaining_time': {
      'ar': 'الوقت المتبقي',
      'en': 'Remaining Time',
      'fr': 'Temps Restant',
    },
    'time_remaining_until': {
      'ar': 'متبقي على الأذان',
      'en': 'Time until Adhan',
      'fr': 'Temps avant l\'Adhan',
    },
    'play_adhan_audio': {
      'ar': 'سماع الصوت',
      'en': 'Play Sound',
      'fr': 'Écouter le Son',
    },
    'stop_audio': {
      'ar': 'إيقاف الصوت',
      'en': 'Stop Audio',
      'fr': 'Arrêter l\'audio',
    },
    'prayer_time_now': {
      'ar': 'حان الآن موعد',
      'en': 'It is now time for',
      'fr': 'C\'est l\'heure de',
    },
    'hours': {
      'ar': 'ساعة',
      'en': 'hours',
      'fr': 'heures',
    },
    'minutes': {
      'ar': 'دقيقة',
      'en': 'min',
      'fr': 'min',
    },
    'seconds': {
      'ar': 'ثانية',
      'en': 'sec',
      'fr': 'sec',
    },
    'state_prefix': {
      'ar': 'ولاية',
      'en': 'State / Province',
      'fr': 'Région / Wilaya',
    },
    'city_prefix': {
      'ar': 'بلدية / مدينة',
      'en': 'City',
      'fr': 'Ville / Commune',
    },

    // Prayer Times Screen
    'today_prayers': {
      'ar': 'مواقيت صلاة اليوم',
      'en': 'Today\'s Prayer Times',
      'fr': 'Horaires des Prières Aujourd\'hui',
    },
    'next_prayer_badge': {
      'ar': 'الصلاة القادمة',
      'en': 'Next Prayer',
      'fr': 'Prochaine Prière',
    },
    'adhan_alerts_enabled': {
      'ar': 'تنبيهات الأذان مفعلة',
      'en': 'Adhan Alerts Enabled',
      'fr': 'Alertes Adhan Activées',
    },
    'previous_day': {
      'ar': 'اليوم السابق',
      'en': 'Previous Day',
      'fr': 'Jour Précédent',
    },
    'next_day': {
      'ar': 'اليوم التالي',
      'en': 'Next Day',
      'fr': 'Jour Suivant',
    },
    'today': {
      'ar': 'اليوم',
      'en': 'Today',
      'fr': 'Aujourd\'hui',
    },

    // Qibla Screen
    'qibla_compass_title': {
      'ar': 'بوصلة القبلة الدقيقة',
      'en': 'Precise Qibla Compass',
      'fr': 'Boussole Qibla Précise',
    },
    'qibla_compass': {
      'ar': 'بوصلة القبلة',
      'en': 'Qibla Compass',
      'fr': 'Boussole Qibla',
    },
    'qibla_angle': {
      'ar': 'زاوية القبلة',
      'en': 'Qibla Angle',
      'fr': 'Angle de la Qibla',
    },
    'distance_to_makkah': {
      'ar': 'المسافة إلى مكة',
      'en': 'Distance to Makkah',
      'fr': 'Distance à La Mecque',
    },
    'east_direction': {
      'ar': 'شرقاً',
      'en': 'East',
      'fr': 'Est',
    },
    'kaaba_direction': {
      'ar': 'اتجاه الكعبة المشرفة',
      'en': 'Direction of the Kaaba',
      'fr': 'Direction de la Kaaba',
    },
    'facing_qibla': {
      'ar': 'أنت باتجاه القبلة تماماً 🕋',
      'en': 'You are facing the Qibla 🕋',
      'fr': 'Vous êtes face à la Qibla 🕋',
    },
    'facing_kaaba_success': {
      'ar': 'أنت الآن باتجاه القبلة مباشرة نحو الكعبة المشرفة ✓',
      'en': 'You are now directly facing the Qibla towards the Holy Kaaba ✓',
      'fr': 'Vous êtes maintenant face à la Qibla vers la Sainte Kaaba ✓',
    },
    'turn_right_by': {
      'ar': 'أدر هاتفك نحو اليمين بمقدار',
      'en': 'Rotate your phone right by',
      'fr': 'Tournez votre téléphone vers la droite de',
    },
    'turn_left_by': {
      'ar': 'أدر هاتفك نحو اليسار بمقدار',
      'en': 'Rotate your phone left by',
      'fr': 'Tournez votre téléphone vers la gauche de',
    },
    'point_head_north_east': {
      'ar': 'وجّه رأس الهاتف نحو زاوية',
      'en': 'Point top of phone towards angle',
      'fr': 'Pointez le haut du téléphone vers l\'angle',
    },
    'north_east': {
      'ar': 'شرق الشمال',
      'en': 'East of North',
      'fr': 'Est du Nord',
    },
    'qibla_marker': {
      'ar': 'القبلة',
      'en': 'Qibla',
      'fr': 'Qibla',
    },
    'qibla_flat_device_note': {
      'ar': 'احمل الهاتف أفقياً بعيداً عن المعادن والأجهزة الإلكترونية',
      'en': 'Hold phone flat, away from metals and electronic devices',
      'fr': 'Tenez le téléphone à plat, loin des métaux et appareils électroniques',
    },
    'qibla_calibration_title': {
      'ar': 'معايرة بوصلة القبلة',
      'en': 'Qibla Compass Calibration',
      'fr': 'Étalonnage de la Boussole Qibla',
    },
    'qibla_calibration_desc_title': {
      'ar': 'للحصول على أقصى دقة في تحديد القبلة المشرفة:',
      'en': 'For maximum accuracy in determining the Holy Qibla:',
      'fr': 'Pour une précision maximale dans la détermination de la Qibla :',
    },
    'qibla_calibration_step1': {
      'ar': '1. أمسك الهاتف بشكل أفقي تماماً ومستوٍ.',
      'en': '1. Hold phone completely horizontal and flat.',
      'fr': '1. Tenez le téléphone complètement à plat et horizontal.',
    },
    'qibla_calibration_step2': {
      'ar': '2. ابتعد عن الأجهزة الإلكترونية والمغناطيس والمعادن والسيارات.',
      'en': '2. Move away from electronic devices, magnets, metals, and vehicles.',
      'fr': '2. Éloignez-vous des appareils électroniques, aimants, métaux et véhicules.',
    },
    'qibla_calibration_step3': {
      'ar': '3. قم بتحريك الهاتف في الهواء على شكل الرقم ثمانية (∞) بالإنجليزية مرتين إلى ثلاث مرات لمعايرة مستشعر المغناطيسية.',
      'en': '3. Wave phone in the air in a figure-8 (∞) pattern 2-3 times to calibrate the magnetometer sensor.',
      'fr': '3. Déplacez le téléphone dans les airs en forme de 8 (∞) 2 à 3 fois pour étalonner le capteur.',
    },
    'understood': {
      'ar': 'تم، فهمت ذلك',
      'en': 'Understood',
      'fr': 'Compris',
    },
    'calibration_instructions_tooltip': {
      'ar': 'إرشادات معايرة البوصلة',
      'en': 'Compass calibration guide',
      'fr': 'Guide d\'étalonnage de la boussole',
    },
    'rotate_device_calibration': {
      'ar': 'قم بتدوير الهاتف بشكل 8 لمعايرة البوصلة',
      'en': 'Rotate device in figure-8 to calibrate compass',
      'fr': 'Tournez l\'appareil en forme de 8 pour calibrer',
    },
    'km_unit': {
      'ar': 'كم',
      'en': 'km',
      'fr': 'km',
    },

    // Services Screen
    'services_header_title': {
      'ar': 'الخدمات والميزات الإسلامية',
      'en': 'Islamic Services & Features',
      'fr': 'Services & Fonctions Islamiques',
    },
    'services_quran_title': {
      'ar': 'القرآن الكريم (قراءة واستماع)',
      'en': 'Holy Quran (Reading & Listening)',
      'fr': 'Saint Coran (Lecture & Écoute)',
    },
    'services_quran_subtitle': {
      'ar': '114 سورة كاملة مع تلاوات كبار القراء',
      'en': 'Complete 114 Surahs with famous reciters',
      'fr': '114 sourates complètes avec les plus grands récitateurs',
    },
    'services_adhkar_title': {
      'ar': 'حصن المسلم والسبحة الإلكترونية',
      'en': 'Fortress of the Muslim & Tasbih',
      'fr': 'Citadelle du Musulman & Chapelet',
    },
    'services_adhkar_subtitle': {
      'ar': 'أذكار الصباح والمساء والسبحة الذكية',
      'en': 'Morning & evening adhkar with smart counter',
      'fr': 'Invocations du matin et soir et chapelet électronique',
    },
    'services_auto_adhkar_title': {
      'ar': 'أذكار الشاشة التلقائية أثناء التصفح',
      'en': 'Automatic Screen Adhkar Notifications',
      'fr': 'Invocations automatiques à l\'écran',
    },
    'services_auto_adhkar_subtitle': {
      'ar': 'ظهور الأذكار والأدعية على الشاشة تلقائياً مع اختيار ما يظهر لك',
      'en': 'Dhikr pops up automatically while using device',
      'fr': 'Affichage automatique des invocations pendant la navigation',
    },
    'services_live_title': {
      'ar': 'البث المباشر (مكة، المدينة، الجزائر)',
      'en': 'Live Broadcast (Makkah, Madinah, Algeria)',
      'fr': 'Diffusion en Direct (Mecque, Médine, Algérie)',
    },
    'services_live_subtitle': {
      'ar': 'إذاعة القرآن الكريم الجزائرية وقنوات الحرمين 24/7',
      'en': 'Quran Radio & Two Holy Mosques channels 24/7',
      'fr': 'Radio du Saint Coran & Chaînes des Lieux Saints 24/7',
    },
    'services_card_creator_title': {
      'ar': 'أنشئ وشارك بطاقات قرآنية',
      'en': 'Create & Share Quran Cards',
      'fr': 'Créer & Partager des cartes coraniques',
    },
    'services_card_creator_subtitle': {
      'ar': 'تصميم ومشاركة آيات وأحاديث نبوية كصدقة جارية',
      'en': 'Design and share Ayahs & Hadiths easily',
      'fr': 'Concevez et partagez des versets et hadiths',
    },
    'services_events_title': {
      'ar': 'التقويم والمناسبات الإسلامية',
      'en': 'Islamic Calendar & Events',
      'fr': 'Calendrier & Événements Islamiques',
    },
    'services_events_subtitle': {
      'ar': 'التاريخ الهجري السنوي والأعياد والمناسبات الدينية',
      'en': 'Annual Hijri calendar and Islamic religious holidays',
      'fr': 'Calendrier hégirien et fêtes religieuses annuelles',
    },
    'services_mosques_title': {
      'ar': 'البحث عن المساجد وأماكن العبادة',
      'en': 'Nearby Mosques & Places of Worship',
      'fr': 'Recherche de Mosquées & Lieux de Culte',
    },
    'services_mosques_subtitle': {
      'ar': 'دليل أقرب المساجد ومعالم الجزائر والملاحة بالخريطة',
      'en': 'Nearest mosques directory and map navigation',
      'fr': 'Guide des mosquées proches et navigation sur carte',
    },
    'services_settings_title': {
      'ar': 'الإعدادات العامة والمظهر',
      'en': 'General Settings & Appearance',
      'fr': 'Paramètres Généraux & Apparence',
    },
    'services_settings_subtitle': {
      'ar': 'تخصيص ألوان التطبيق وصوت الأذان المعتمد',
      'en': 'Customize app theme, language, and adhan sounds',
      'fr': 'Personnaliser thème, langue et son de l\'adhan',
    },
    'services_share_title': {
      'ar': 'مشاركة التطبيق كصدقة جارية',
      'en': 'Share App as Ongoing Charity',
      'fr': 'Partager l\'application (Aumône continue)',
    },
    'services_share_subtitle': {
      'ar': 'دلّ على الخير وانشر تطبيق مِحْرَاب ليعم النفع والأجر',
      'en': 'Invite others and spread the blessings with Mihrab',
      'fr': 'Partagez Mihrab pour répandre le bien et les bénédictions',
    },

    // Drawer Menu
    'drawer_brand': {
      'ar': 'مِحْرَاب',
      'en': 'MIHRAB',
      'fr': 'MIHRAB',
    },
    'drawer_current_location': {
      'ar': 'موقعك الحالي',
      'en': 'Current Location',
      'fr': 'Emplacement actuel',
    },
    'drawer_play_adhan': {
      'ar': 'تشغيل صوت الأذان',
      'en': 'Play Adhan Sound',
      'fr': 'Écouter l\'Adhan',
    },
    'drawer_live': {
      'ar': 'البث المباشر (مكة، المدينة، الجزائر)',
      'en': 'Live Broadcast (Makkah, Madinah)',
      'fr': 'Diffusion en Direct (Mecque, Médine)',
    },
    'drawer_events': {
      'ar': 'المناسبات الإسلامية والتقويم',
      'en': 'Islamic Events & Calendar',
      'fr': 'Événements & Calendrier Islamiques',
    },
    'drawer_mosques': {
      'ar': 'المساجد القريبة ودليل المعالم',
      'en': 'Nearby Mosques & Landmarks',
      'fr': 'Mosquées proches & Lieux de Culte',
    },
    'drawer_settings': {
      'ar': 'الإعدادات وتخصيص المظهر',
      'en': 'Settings & Customization',
      'fr': 'Paramètres & Personnalisation',
    },
    'drawer_about': {
      'ar': 'عن تطبيق مِحْرَاب',
      'en': 'About Mihrab',
      'fr': 'À propos de Mihrab',
    },
    'drawer_change_location': {
      'ar': 'تغيير الموقع والمدينة 📍',
      'en': 'Change Location & City 📍',
      'fr': 'Changer de Lieu & Ville 📍',
    },
    'drawer_adhkar': {
      'ar': 'أذكار الشاشة التلقائية',
      'en': 'Automatic Screen Adhkar',
      'fr': 'Invocations Automatiques',
    },
    'drawer_play_adhan_sub': {
      'ar': 'استمع للأذان المعتمد الآن',
      'en': 'Listen to approved Adhan now',
      'fr': 'Écouter l\'Adhan approuvé',
    },
    'drawer_live_sub': {
      'ar': 'إذاعة القرآن وقنوات الحرمين',
      'en': 'Holy Quran radio & Haramain live',
      'fr': 'Radio du Coran & Chaînes des Lieux Saints',
    },
    'drawer_events_sub': {
      'ar': 'أعياد ومناسبات العام الهجري',
      'en': 'Holidays and occasions of Hijri year',
      'fr': 'Fêtes et occasions de l\'année hégirienne',
    },
    'drawer_mosques_sub': {
      'ar': 'أقرب المساجد والملاحة بالخريطة',
      'en': 'Nearest mosques and map navigation',
      'fr': 'Mosquées les plus proches et carte',
    },
    'drawer_adhkar_sub': {
      'ar': 'ظهور الأذكار أثناء تصفح الهاتف',
      'en': 'Adhkar popups while using device',
      'fr': 'Invocations pendant la navigation',
    },
    'drawer_settings_sub': {
      'ar': 'تغيير ألوان التطبيق وصوت الأذان',
      'en': 'Change colors, language, and adhan sounds',
      'fr': 'Changer couleurs, langue et sons de l\'adhan',
    },
    'drawer_about_sub': {
      'ar': 'الإصدار 1.0.0 (الجزائر - 1541 بلدية والقرى والمداشر)',
      'en': 'Version 1.0.0 (Algeria & Worldwide Cities)',
      'fr': 'Version 1.0.0 (Algérie & Villes du Monde)',
    },
    'drawer_app_language': {
      'ar': 'لغة التطبيق',
      'en': 'App Language',
      'fr': 'Langue de l\'application',
    },
    'next_prayer_title': {
      'ar': 'الصلاة القادمة',
      'en': 'Next Prayer',
      'fr': 'Prochaine Prière',
    },
    'remaining_prefix': {
      'ar': 'متبقي',
      'en': 'Remaining',
      'fr': 'Restant',
    },

    // Settings Screen
    'settings_title': {
      'ar': 'الإعدادات العامة وتخصيص المظهر',
      'en': 'General Settings & Appearance',
      'fr': 'Paramètres Généraux & Apparence',
    },
    'language_selector_title': {
      'ar': 'لغة التطبيق / App Language / Langue',
      'en': 'App Language',
      'fr': 'Langue de l\'application',
    },
    'language_selector_desc': {
      'ar': 'اختر لغة واجهة التطبيق (العربية، الإنجليزية، الفرنسية)',
      'en': 'Select interface language (Arabic, English, French)',
      'fr': 'Sélectionnez la langue (Arabe, Anglais, Français)',
    },
    'lang_arabic_name': {
      'ar': 'العربية (الافتراضية)',
      'en': 'Arabic (العربية)',
      'fr': 'Arabe (العربية)',
    },
    'lang_english_name': {
      'ar': 'English (الإنجليزية)',
      'en': 'English',
      'fr': 'Anglais (English)',
    },
    'lang_french_name': {
      'ar': 'Français (الفرنسية)',
      'en': 'French (Français)',
      'fr': 'Français',
    },

    // Themes
    'theme_section_title': {
      'ar': 'ألوان ومظهر التطبيق',
      'en': 'Theme & Color Palette',
      'fr': 'Thème & Couleurs',
    },
    'theme_emerald_name': {
      'ar': 'الأخضر الزمردي الأندلسي (الافتراضي)',
      'en': 'Andalusian Emerald (Default)',
      'fr': 'Émeraude Andalouse (Par défaut)',
    },
    'theme_royal_blue_name': {
      'ar': 'الأزرق الملكي القرطبي',
      'en': 'Cordoban Royal Blue',
      'fr': 'Bleu Royal de Cordoue',
    },
    'theme_desert_gold_name': {
      'ar': 'الصحراوي الذهبي (الرمال والواحات)',
      'en': 'Sahara Gold (Oasis & Dunes)',
      'fr': 'Or Saharien (Oasis & Dunes)',
    },
    'theme_black_gold_name': {
      'ar': 'الأسود والذهبي الفاخر',
      'en': 'Luxury Black & Gold',
      'fr': 'Noir & Or Luxueux',
    },

    // Mosque & Adhan Settings
    'auto_silent_mode': {
      'ar': 'الوضع الصامت التلقائي في المسجد',
      'en': 'Automatic Silent Mode in Mosque',
      'fr': 'Mode Silencieux Automatique à la Mosquée',
    },
    'auto_silent_mode_desc': {
      'ar': 'تفعيل الوضع الصامت تلقائياً أثناء وقت الصلاة واحترام حرمة المسجد',
      'en': 'Automatically silence device during prayer times in the mosque',
      'fr': 'Mise en silencieux automatique pendant la prière à la mosquée',
    },
    'adhan_sounds_section': {
      'ar': 'أصوات الأذان وتخصيص الصلوات',
      'en': 'Adhan Sounds & Customization',
      'fr': 'Sons de l\'Adhan & Personnalisation',
    },
    'advance_reminder_title': {
      'ar': 'تنبيه مسبق قبل دخول وقت الصلاة',
      'en': 'Pre-Adhan Reminder',
      'fr': 'Rappel avant l\'heure de prière',
    },
    'iqamah_reminder_title': {
      'ar': 'تنبيه موعد الإقامة بعد الأذان',
      'en': 'Iqamah Reminder Notification',
      'fr': 'Rappel de l\'Iqama après l\'Adhan',
    },
    'gps_auto_switch': {
      'ar': 'التحديد التلقائي للموقع بالـ GPS',
      'en': 'Automatic GPS Location Detection',
      'fr': 'Détection automatique de position GPS',
    },

    // Calculation Methods
    'calc_method_title': {
      'ar': 'طريقة حساب مواقيت الصلاة',
      'en': 'Prayer Times Calculation Method',
      'fr': 'Méthode de Calcul des Horaires',
    },
    'juristic_method_title': {
      'ar': 'المذهب الفقهي لحساب صلاة العصر',
      'en': 'Juristic Method for Asr (Madhab)',
      'fr': 'Méthode Juridique pour l\'Asr (Madhhab)',
    },
    'madhab_standard': {
      'ar': 'الجمهور (المالكي والشافعي والحنبلي) - ظل الشيء مثله',
      'en': 'Standard (Maliki, Shafi\'i, Hanbali) - Single shadow',
      'fr': 'Standard (Malékite, Chaféite, Hanbalite)',
    },
    'madhab_hanafi': {
      'ar': 'المذهب الحنفي - ظل الشيء مثليه',
      'en': 'Hanafi Method - Double shadow factor',
      'fr': 'Méthode Hanafite - Double ombre',
    },
    'timing_adjustments_title': {
      'ar': 'ضبط دقائق مواقيت الصلاة (تطابق مع مساجد الحي)',
      'en': 'Manual Timing Offsets (Match Local Mosque)',
      'fr': 'Ajustements manuels (Concordance avec la mosquée)',
    },

    // World Cities & Location Selection
    'location_selection_title': {
      'ar': 'اختيار الموقع والمدينة حول العالم',
      'en': 'Select Location & World City',
      'fr': 'Sélectionner la Ville & Emplacement',
    },
    'tab_algeria': {
      'ar': 'الجزائر (58 ولاية)',
      'en': 'Algeria (58 Provinces)',
      'fr': 'Algérie (58 Wilayas)',
    },
    'tab_world_cities': {
      'ar': 'مدن وعواصم العالم 🌍',
      'en': 'World Cities 🌍',
      'fr': 'Villes du Monde 🌍',
    },
    'tab_gps': {
      'ar': 'تحديد بالـ GPS 🛰️',
      'en': 'Auto GPS 🛰️',
      'fr': 'GPS Automatique 🛰️',
    },
    'search_commune_hint': {
      'ar': 'ابحث عن اسم البلدية أو القرية أو الدشرة...',
      'en': 'Search for commune, municipality, or village...',
      'fr': 'Rechercher une commune ou un village...',
    },
    'search_world_city_hint': {
      'ar': 'ابحث عن عاصمة أو مدينة حول العالم...',
      'en': 'Search for a city or country worldwide...',
      'fr': 'Rechercher une ville ou un pays dans le monde...',
    },
    'location_selected_feedback': {
      'ar': 'تم تحديد الموقع بنجاح: ',
      'en': 'Location successfully set: ',
      'fr': 'Emplacement défini avec succès: ',
    },
    'auto_gps_success': {
      'ar': 'تم تحديد موقعك بدقة عبر الأقمار الصناعية 📍',
      'en': 'Location accurately detected via GPS satellites 📍',
      'fr': 'Position détectée avec précision par satellite GPS 📍',
    },

    // Generic Actions & Alerts
    'cancel': {
      'ar': 'إلغاء',
      'en': 'Cancel',
      'fr': 'Annuler',
    },
    'confirm': {
      'ar': 'تأكيد',
      'en': 'Confirm',
      'fr': 'Confirmer',
    },
    'close': {
      'ar': 'إغلاق',
      'en': 'Close',
      'fr': 'Fermer',
    },
    'select': {
      'ar': 'اختيار',
      'en': 'Select',
      'fr': 'Sélectionner',
    },
    'save': {
      'ar': 'حفظ',
      'en': 'Save',
      'fr': 'Enregistrer',
    },
    'share': {
      'ar': 'مشاركة',
      'en': 'Share',
      'fr': 'Partager',
    },
    'copy': {
      'ar': 'نسخ',
      'en': 'Copy',
      'fr': 'Copier',
    },
    'copied': {
      'ar': 'تم النسخ بنجاح',
      'en': 'Copied successfully',
      'fr': 'Copié avec succès',
    },
    'menu': {
      'ar': 'القائمة الجانبية',
      'en': 'Menu',
      'fr': 'Menu',
    },

    // Nearby Mosques Screen
    'nearby_mosques_page_title': {
      'ar': 'البحث عن المساجد والأماكن القريبة',
      'en': 'Search Mosques & Places of Worship',
      'fr': 'Recherche de Mosquées & Lieux de Culte',
    },
    'nearby_mosques_gps_refresh': {
      'ar': 'تحديث GPS',
      'en': 'Refresh GPS',
      'fr': 'Actualiser GPS',
    },
    'nearby_mosques_near_btn': {
      'ar': 'المساجد القريبة 🗺️',
      'en': 'Nearby Mosques 🗺️',
      'fr': 'Mosquées Proches 🗺️',
    },
    'nearby_mosques_halal_btn': {
      'ar': 'أكل حلال 🍽️',
      'en': 'Halal Food 🍽️',
      'fr': 'Nourriture Halal 🍽️',
    },
    'nearby_mosques_grand_title': {
      'ar': 'أشهر الجوامع والمعالم الإسلامية الكبرى في الجزائر',
      'en': 'Famous Islamic Landmarks & Grand Mosques in Algeria',
      'fr': 'Grandes Mosquées & Monuments Islamiques en Algérie',
    },
    'nearby_mosques_etiquette_title': {
      'ar': 'آداب دخول المسجد وحرمة بيوت الله',
      'en': 'Mosque Etiquette & Reverence for Houses of Allah',
      'fr': 'Bienséances et Respect des Maisons d\'Allah',
    },
    'nearby_mosques_etiquette_hadith': {
      'ar': 'قال رسول الله ﷺ: «أَحَبُّ البِلادِ إلى اللهِ مَساجِدُها».',
      'en': 'The Prophet ﷺ said: "The most beloved of places to Allah are mosques."',
      'fr': 'Le Prophète ﷺ a dit : « Les lieux les plus aimés d\'Allah sont Ses mosquées. »',
    },
    'nearby_mosques_etiquette_1': {
      'ar': 'تقديم الرِجل اليمنى عند الدخول وقول: «اللهم افتح لي أبواب رحمتك».',
      'en': 'Enter with the right foot and pray: "O Allah, open for me the doors of Your mercy."',
      'fr': 'Entrer du pied droit en disant : « Ô Allah, ouvre-moi les portes de Ta miséricorde ».',
    },
    'nearby_mosques_etiquette_2': {
      'ar': 'صلاة ركعتين تحية المسجد قبل الجلوس.',
      'en': 'Pray two Rak\'ahs (Tahiyyat al-Masjid) before sitting.',
      'fr': 'Accomplir deux unités de prière de salutation avant de s\'asseoir.',
    },
    'nearby_mosques_etiquette_3': {
      'ar': 'خفض الصوت وتجنب الحديث في أمور الدنيا والبيع والشراء.',
      'en': 'Lower your voice and avoid worldly conversation or commercial deals.',
      'fr': 'Baisser la voix et s\'abstenir de discussions futiles ou de commerce.',
    },
    'nearby_mosques_etiquette_4': {
      'ar': 'تقديم الرِجل اليسرى عند الخروج وقول: «اللهم إني أسألك من فضلك».',
      'en': 'Exit with the left foot and pray: "O Allah, I ask You from Your bounty."',
      'fr': 'Sortir du pied gauche en disant : « Ô Allah, je Te demande de Ta grâce ».',
    },
    'nearby_mosques_dir_btn': {
      'ar': 'الاتجاهات 🧭',
      'en': 'Directions 🧭',
      'fr': 'Itinéraire 🧭',
    },
    'nearby_mosques_map_btn': {
      'ar': 'الخريطة 📍',
      'en': 'Map 📍',
      'fr': 'Carte 📍',
    },
    'nearby_mosques_details_btn': {
      'ar': 'تفاصيل المعلم ℹ️',
      'en': 'Details ℹ️',
      'fr': 'Détails ℹ️',
    },
    'nearby_mosques_loc_status_prefix': {
      'ar': 'موقعك: ',
      'en': 'Your Location: ',
      'fr': 'Votre position : ',
    },
    'nearby_mosques_searching_map': {
      'ar': 'جاري فتح الخريطة للبحث عن: ',
      'en': 'Opening map to search for: ',
      'fr': 'Ouverture de la carte pour : ',
    },

    // Islamic Events Screen
    'events_page_title': {
      'ar': 'التقويم والمناسبات الإسلامية',
      'en': 'Islamic Calendar & Events',
      'fr': 'Calendrier & Événements Islamiques',
    },
    'events_today_hijri': {
      'ar': 'اليوم في التقويم الهجري',
      'en': 'Today in Hijri Calendar',
      'fr': 'Aujourd\'hui dans le Calendrier Hégirien',
    },
    'events_blessed_day': {
      'ar': 'يوم مبارك وطاعة متقبلة بإذن الله',
      'en': 'A blessed day and accepted deeds by Allah\'s will',
      'fr': 'Une journée bénie et une dévotion exaucée',
    },
    'events_major_title': {
      'ar': 'الأعياد والمناسبات الإسلامية العظمى',
      'en': 'Major Islamic Holidays & Events',
      'fr': 'Fêtes & Grands Événements Islamiques',
    },
    'events_about_title': {
      'ar': 'حول التقويم والمناسبات',
      'en': 'About Islamic Calendar',
      'fr': 'À propos du Calendrier Islamique',
    },
    'events_about_desc': {
      'ar': 'يعتمد التقويم الهجري على دورات القمر، ويحدد مواقيت الشعائر والعبادات والأعياد الإسلامية المباركة.',
      'en': 'The Hijri calendar is lunar-based, determining sacred worship, fasts, and Islamic holidays.',
      'fr': 'Le calendrier hégirien se fonde sur les cycles lunaires pour rythmer les actes d\'adoration et les fêtes.',
    },

    // Settings Screen Extended
    'settings_theme_header': {
      'ar': 'لون ومظهر التطبيق (تخصيص كامل)',
      'en': 'App Theme & Colors',
      'fr': 'Thème & Couleurs de l\'Application',
    },
    'settings_theme_prompt': {
      'ar': 'اختر السمة واللون المفضل لديك للتطبيق:',
      'en': 'Choose your preferred theme and visual style:',
      'fr': 'Choisissez votre thème et style visuel préférés :',
    },
    'settings_calc_header': {
      'ar': 'طرق الحساب والمذاهب الفقهية',
      'en': 'Calculation & Juristic Methods',
      'fr': 'Méthodes de Calcul & Jurisprudence',
    },
    'settings_calc_prompt': {
      'ar': 'طريقة الحساب الفلكية:',
      'en': 'Astronomical Calculation Method:',
      'fr': 'Méthode de Calcul Astronomique :',
    },
    'settings_madhab_prompt': {
      'ar': 'المذهب الفقهي لحساب صلاة العصر:',
      'en': 'Juristic Method for Asr prayer:',
      'fr': 'Méthode Juridique pour la Prière du Asr :',
    },
    'settings_sync_mosque_header': {
      'ar': 'مزامنة مع المسجد (تعديل بالدقائق)',
      'en': 'Mosque Sync (Minute Adjustments)',
      'fr': 'Synchronisation Mosquée (Ajustement en minutes)',
    },
    'settings_sync_mosque_desc': {
      'ar': 'قم بمواءمة وقت كل صلاة بزيادة أو إنقاص الدقائق ليتطابق مع مسجد حيك تماماً:',
      'en': 'Adjust each prayer time to precisely match your local neighborhood mosque:',
      'fr': 'Ajustez chaque horaire pour concorder parfaitement avec votre mosquée locale :',
    },
    'settings_custom_adhan_header': {
      'ar': 'تخصيص أذان مختلف لكل صلاة',
      'en': 'Custom Adhan Voice Per Prayer',
      'fr': 'Personnaliser l\'Adhan par Prière',
    },
    'settings_default_adhan_header': {
      'ar': 'صوت الأذان الافتراضي العام',
      'en': 'Default General Adhan Sound',
      'fr': 'Son d\'Adhan Général par Défaut',
    },
    'settings_battery_header': {
      'ar': 'لضمان سماع الأذان عند قفل الهاتف (الخلفية)',
      'en': 'Ensure Adhan Sounds in Background / Locked Screen',
      'fr': 'Garantir l\'Adhan en Arrière-plan (Écran Verrouillé)',
    },
    'settings_battery_desc': {
      'ar': 'تقوم بعض الهواتف بإيقاف التنبيهات لتوفير الطاقة. لضمان دقة الأذان دائماً:\n1. اضبط توفير طاقة البطارية للتطبيق على «بدون قيود / No restrictions».\n2. فعّل خيار «التشغيل التلقائي / Autostart» في إعدادات التطبيق.\n3. تأكد من السماح بالإشعارات والمنبهات الدقيقة (Exact Alarms).',
      'en': 'Some devices terminate background alerts to save battery. To ensure timely Adhan:\n1. Set battery saver to "No restrictions".\n2. Enable "Autostart" in app settings.\n3. Allow Notifications and Exact Alarms.',
      'fr': 'Certains téléphones coupent les alertes en arrière-plan. Pour garantir l\'exactitude de l\'Adhan :\n1. Réglez la batterie sur « Aucune restriction ».\n2. Activez le « Démarrage automatique ».\n3. Autorisez les notifications et alarmes précises.',
    },
    'settings_battery_btn': {
      'ar': 'فتح إعدادات التطبيق بالهاتف',
      'en': 'Open App Settings on Device',
      'fr': 'Ouvrir les Paramètres de l\'Appareil',
    },
    'settings_test_adhan_title': {
      'ar': 'اختبار أذان الصلاة والإشعار',
      'en': 'Test Prayer Adhan & Notification',
      'fr': 'Tester l\'Adhan & Notification de Prière',
    },
    'settings_test_adhan_desc': {
      'ar': 'تجربة ظهور إشعار دخول وقت الصلاة وسماع صوت الأذان فورياً',
      'en': 'Instantly test prayer notification banner and play Adhan audio',
      'fr': 'Tester immédiatement la notification et le son de l\'Adhan',
    },
    'settings_test_adhan_btn': {
      'ar': 'اختبر الأذان والإشعار الآن',
      'en': 'Test Adhan & Notification Now',
      'fr': 'Tester l\'Adhan et l\'Alerte Maintenant',
    },
  };

  /// Retrieves translation for [key] in [languageCode], fallback to Arabic, then key itself.
  static String get(String key, [String languageCode = 'ar']) {
    final langMap = _translations[key];
    if (langMap == null) return key;

    final translated = langMap[languageCode] ?? langMap['ar'];
    return translated ?? key;
  }

  /// Whether current language code is Right-to-Left (Arabic)
  static bool isRtl(String languageCode) => languageCode == 'ar';
}
