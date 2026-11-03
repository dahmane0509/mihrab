// Comprehensive Multi-Language System for Mihrab (محراب)
// Supported Languages: Arabic (ar - default RTL), English (en - LTR), French (fr - LTR), Italian (it - LTR), etc.

class AppTranslations {
  static const Map<String, Map<String, String>> _translations = {
    // App Brand & General
    'app_name': {
      'ar': 'مِحْرَاب',
      'en': 'Mihrab',
      'fr': 'Mihrab',
      'it': 'Mihrab',
    },
    'app_subtitle': {
      'ar': 'الرفيق الإسلامي الشامل للمسلم حول العالم',
      'en': 'Comprehensive Islamic Companion for Muslims Worldwide',
      'fr': 'Compagnon Islamique Complet pour les Musulmans du Monde',
      'it': 'Compagno Islamico Completo per i Musulmani nel Mondo',
    },
    'app_slogan': {
      'ar': 'صلاتك، قبلتك، قرآنك في كل مكان',
      'en': 'Your prayers, Qibla, and Quran anywhere',
      'fr': 'Vos prières, Qibla et Coran partout dans le monde',
      'it': 'Le tue preghiere, la Qibla e il Corano ovunque',
    },

    // Navigation Tabs
    'tab_next_prayer': {
      'ar': 'الصلاة القادمة',
      'en': 'Next Prayer',
      'fr': 'Prochaine Prière',
      'it': 'Prossima Preghiera',
    },
    'tab_prayer_times': {
      'ar': 'أوقات الصلاة',
      'en': 'Prayer Times',
      'fr': 'Horaires de Prière',
      'it': 'Orari di Preghiera',
    },
    'tab_services': {
      'ar': 'الخدمات والميزات',
      'en': 'Services & Features',
      'fr': 'Services & Fonctions',
      'it': 'Servizi & Funzioni',
    },
    'tab_qibla': {
      'ar': 'بوصلة القبلة',
      'en': 'Qibla Compass',
      'fr': 'Boussole Qibla',
      'it': 'Bussola Qibla',
    },

    // Prayer Names
    'fajr': {
      'ar': 'الفجر',
      'en': 'Fajr',
      'fr': 'Fajr',
      'it': 'Fajr',
    },
    'sunrise': {
      'ar': 'الشروق',
      'en': 'Sunrise',
      'fr': 'Lever du soleil',
      'it': 'Alba',
    },
    'dhuhr': {
      'ar': 'الظهر',
      'en': 'Dhuhr',
      'fr': 'Dhuhr',
      'it': 'Dhuhr',
    },
    'asr': {
      'ar': 'العصر',
      'en': 'Asr',
      'fr': 'Asr',
      'it': 'Asr',
    },
    'maghrib': {
      'ar': 'المغرب',
      'en': 'Maghrib',
      'fr': 'Maghrib',
      'it': 'Maghrib',
    },
    'isha': {
      'ar': 'العشاء',
      'en': 'Isha',
      'fr': 'Isha',
      'it': 'Isha',
    },

    // Full Prayer Names
    'prayer_fajr': {
      'ar': 'صلاة الفجر',
      'en': 'Fajr Prayer',
      'fr': 'Prière du Fajr',
      'it': 'Preghiera del Fajr',
    },
    'prayer_sunrise': {
      'ar': 'شروق الشمس',
      'en': 'Sunrise',
      'fr': 'Lever du soleil',
      'it': 'Alba (Shuruq)',
    },
    'prayer_dhuhr': {
      'ar': 'صلاة الظهر',
      'en': 'Dhuhr Prayer',
      'fr': 'Prière du Dhuhr',
      'it': 'Preghiera del Dhuhr',
    },
    'prayer_asr': {
      'ar': 'صلاة العصر',
      'en': 'Asr Prayer',
      'fr': 'Prière de l\'Asr',
      'it': 'Preghiera dell\'Asr',
    },
    'prayer_maghrib': {
      'ar': 'صلاة المغرب',
      'en': 'Maghrib Prayer',
      'fr': 'Prière du Maghrib',
      'it': 'Preghiera del Maghrib',
    },
    'prayer_isha': {
      'ar': 'صلاة العشاء',
      'en': 'Isha Prayer',
      'fr': 'Prière de l\'Isha',
      'it': 'Preghiera dell\'Isha',
    },

    // Next Prayer Screen
    'remaining_time': {
      'ar': 'الوقت المتبقي',
      'en': 'Remaining Time',
      'fr': 'Temps Restant',
      'it': 'Tempo Rimanente',
    },
    'time_remaining_until': {
      'ar': 'متبقي على الأذان',
      'en': 'Time until Adhan',
      'fr': 'Temps avant l\'Adhan',
      'it': 'Tempo prima dell\'Adhan',
    },
    'play_adhan_audio': {
      'ar': 'سماع الصوت',
      'en': 'Play Sound',
      'fr': 'Écouter le Son',
      'it': 'Ascolta Audio',
    },
    'stop_audio': {
      'ar': 'إيقاف الصوت',
      'en': 'Stop Audio',
      'fr': 'Arrêter l\'audio',
      'it': 'Ferma Audio',
    },
    'prayer_time_now': {
      'ar': 'حان الآن موعد',
      'en': 'It is now time for',
      'fr': 'C\'est l\'heure de',
      'it': 'È arrivata l\'ora di',
    },
    'hours': {
      'ar': 'ساعة',
      'en': 'hours',
      'fr': 'heures',
      'it': 'ore',
    },
    'minutes': {
      'ar': 'دقيقة',
      'en': 'min',
      'fr': 'min',
      'it': 'min',
    },
    'seconds': {
      'ar': 'ثانية',
      'en': 'sec',
      'fr': 'sec',
      'it': 'sec',
    },
    'state_prefix': {
      'ar': 'ولاية',
      'en': 'State / Province',
      'fr': 'Région / Wilaya',
      'it': 'Provincia',
    },
    'city_prefix': {
      'ar': 'بلدية / مدينة',
      'en': 'City',
      'fr': 'Ville / Commune',
      'it': 'Città / Comune',
    },

    // Prayer Times Screen
    'today_prayers': {
      'ar': 'مواقيت صلاة اليوم',
      'en': 'Today\'s Prayer Times',
      'fr': 'Horaires des Prières Aujourd\'hui',
      'it': 'Orari di Preghiera di Oggi',
    },
    'next_prayer_badge': {
      'ar': 'الصلاة القادمة',
      'en': 'Next Prayer',
      'fr': 'Prochaine Prière',
      'it': 'Prossima Preghiera',
    },
    'adhan_alerts_enabled': {
      'ar': 'تنبيهات الأذان مفعلة',
      'en': 'Adhan Alerts Enabled',
      'fr': 'Alertes Adhan Activées',
      'it': 'Notifiche Adhan Attive',
    },
    'previous_day': {
      'ar': 'اليوم السابق',
      'en': 'Previous Day',
      'fr': 'Jour Précédent',
      'it': 'Giorno Precedente',
    },
    'next_day': {
      'ar': 'اليوم التالي',
      'en': 'Next Day',
      'fr': 'Jour Suivant',
      'it': 'Giorno Successivo',
    },
    'today': {
      'ar': 'اليوم',
      'en': 'Today',
      'fr': 'Aujourd\'hui',
      'it': 'Oggi',
    },

    // Qibla Screen
    'qibla_compass_title': {
      'ar': 'بوصلة القبلة الدقيقة',
      'en': 'Precise Qibla Compass',
      'fr': 'Boussole Qibla Précise',
      'it': 'Bussola Qibla Precisa',
    },
    'qibla_compass': {
      'ar': 'بوصلة القبلة',
      'en': 'Qibla Compass',
      'fr': 'Boussole Qibla',
      'it': 'Bussola Qibla',
    },
    'qibla_angle': {
      'ar': 'زاوية القبلة',
      'en': 'Qibla Angle',
      'fr': 'Angle de la Qibla',
      'it': 'Angolo della Qibla',
    },
    'distance_to_makkah': {
      'ar': 'المسافة إلى مكة',
      'en': 'Distance to Makkah',
      'fr': 'Distance à La Mecque',
      'it': 'Distanza da La Mecca',
    },
    'east_direction': {
      'ar': 'شرقاً',
      'en': 'East',
      'fr': 'Est',
      'it': 'Est',
    },
    'kaaba_direction': {
      'ar': 'اتجاه الكعبة المشرفة',
      'en': 'Direction of the Kaaba',
      'fr': 'Direction de la Kaaba',
      'it': 'Direzione della Kaaba',
    },
    'facing_qibla': {
      'ar': 'أنت باتجاه القبلة تماماً 🕋',
      'en': 'You are facing the Qibla 🕋',
      'fr': 'Vous êtes face à la Qibla 🕋',
      'it': 'Sei rivolto verso la Qibla 🕋',
    },
    'facing_kaaba_success': {
      'ar': 'أنت الآن باتجاه القبلة مباشرة نحو الكعبة المشرفة ✓',
      'en': 'You are now directly facing the Qibla towards the Holy Kaaba ✓',
      'fr': 'Vous êtes maintenant face à la Qibla vers la Sainte Kaaba ✓',
      'it': 'Sei orientato direttamente verso la Sacra Kaaba ✓',
    },
    'turn_right_by': {
      'ar': 'أدر هاتفك نحو اليمين بمقدار',
      'en': 'Rotate your phone right by',
      'fr': 'Tournez votre téléphone vers la droite de',
      'it': 'Ruota il telefono a destra di',
    },
    'turn_left_by': {
      'ar': 'أدر هاتفك نحو اليسار بمقدار',
      'en': 'Rotate your phone left by',
      'fr': 'Tournez votre téléphone vers la gauche de',
      'it': 'Ruota il telefono a sinistra di',
    },
    'point_head_north_east': {
      'ar': 'وجّه رأس الهاتف نحو زاوية',
      'en': 'Point top of phone towards angle',
      'fr': 'Pointez le haut du téléphone vers l\'angle',
      'it': 'Punta la parte superiore verso l\'angolo',
    },
    'north_east': {
      'ar': 'شرق الشمال',
      'en': 'East of North',
      'fr': 'Est du Nord',
      'it': 'Nord-Est',
    },
    'qibla_marker': {
      'ar': 'القبلة',
      'en': 'Qibla',
      'fr': 'Qibla',
      'it': 'Qibla',
    },
    'qibla_flat_device_note': {
      'ar': 'احمل الهاتف أفقياً بعيداً عن المعادن والأجهزة الإلكترونية',
      'en': 'Hold phone flat, away from metals and electronic devices',
      'fr': 'Tenez le téléphone à plat, loin des métaux et appareils électroniques',
      'it': 'Tieni il telefono in piano, lontano da metalli e dispositivi elettronici',
    },
    'qibla_calibration_title': {
      'ar': 'معايرة بوصلة القبلة',
      'en': 'Qibla Compass Calibration',
      'fr': 'Étalonnage de la Boussole Qibla',
      'it': 'Calibrazione della Bussola Qibla',
    },
    'qibla_calibration_desc_title': {
      'ar': 'للحصول على أقصى دقة في تحديد القبلة المشرفة:',
      'en': 'For maximum accuracy in determining the Holy Qibla:',
      'fr': 'Pour une précision maximale dans la détermination de la Qibla :',
      'it': 'Per la massima precisione nella determinazione della Sacra Qibla:',
    },
    'qibla_calibration_step1': {
      'ar': '1. أمسك الهاتف بشكل أفقي تماماً ومستوٍ.',
      'en': '1. Hold phone completely horizontal and flat.',
      'fr': '1. Tenez le téléphone complètement à plat et horizontal.',
      'it': '1. Tieni il telefono completamente orizzontale e piatto.',
    },
    'qibla_calibration_step2': {
      'ar': '2. ابتعد عن الأجهزة الإلكترونية والمغناطيس والمعادن والسيارات.',
      'en': '2. Move away from electronic devices, magnets, metals, and vehicles.',
      'fr': '2. Éloignez-vous des appareils électroniques, aimants, métaux et véhicules.',
      'it': '2. Allontanati da dispositivi elettronici, magneti, metalli e automobili.',
    },
    'qibla_calibration_step3': {
      'ar': '3. قم بتحريك الهاتف في الهواء على شكل الرقم ثمانية (∞) بالإنجليزية مرتين إلى ثلاث مرات لمعايرة مستشعر المغناطيسية.',
      'en': '3. Wave phone in the air in a figure-8 (∞) pattern 2-3 times to calibrate the magnetometer sensor.',
      'fr': '3. Déplacez le téléphone dans les airs en forme de 8 (∞) 2 à 3 fois pour étalonner le capteur.',
      'it': '3. Muovi il telefono in aria a forma di 8 (∞) 2-3 volte per calibrare il sensore magnetico.',
    },
    'understood': {
      'ar': 'تم، فهمت ذلك',
      'en': 'Understood',
      'fr': 'Compris',
      'it': 'Ho capito',
    },
    'calibration_instructions_tooltip': {
      'ar': 'إرشادات معايرة البوصلة',
      'en': 'Compass calibration guide',
      'fr': 'Guide d\'étalonnage de la boussole',
      'it': 'Guida calibrazione bussola',
    },
    'rotate_device_calibration': {
      'ar': 'قم بتدوير الهاتف بشكل 8 لمعايرة البوصلة',
      'en': 'Rotate device in figure-8 to calibrate compass',
      'fr': 'Tournez l\'appareil en forme de 8 pour calibrer',
      'it': 'Ruota il telefono a forma di 8 per calibrare',
    },
    'km_unit': {
      'ar': 'كم',
      'en': 'km',
      'fr': 'km',
      'it': 'km',
    },

    // Services Screen
    'services_header_title': {
      'ar': 'الخدمات والميزات الإسلامية',
      'en': 'Islamic Services & Features',
      'fr': 'Services & Fonctions Islamiques',
      'it': 'Servizi e Funzioni Islamiche',
    },
    'services_quran_title': {
      'ar': 'القرآن الكريم (قراءة واستماع)',
      'en': 'Holy Quran (Reading & Listening)',
      'fr': 'Saint Coran (Lecture & Écoute)',
      'it': 'Sacro Corano (Lettura e Ascolto)',
    },
    'services_quran_subtitle': {
      'ar': '114 سورة كاملة مع تلاوات كبار القراء',
      'en': 'Complete 114 Surahs with famous reciters',
      'fr': '114 sourates complètes avec les plus grands récitateurs',
      'it': '114 Sure complete con grandi recitatori',
    },
    'services_adhkar_title': {
      'ar': 'حصن المسلم والسبحة الإلكترونية',
      'en': 'Fortress of the Muslim & Tasbih',
      'fr': 'Citadelle du Musulman & Chapelet',
      'it': 'Fortezza del Musulmano e Tasbih',
    },
    'services_adhkar_subtitle': {
      'ar': 'أذكار الصباح والمساء والسبحة الذكية',
      'en': 'Morning & evening adhkar with smart counter',
      'fr': 'Invocations du matin et soir et chapelet électronique',
      'it': 'Invocazioni del mattino e della sera con rosario digitale',
    },
    'services_auto_adhkar_title': {
      'ar': 'أذكار الشاشة التلقائية أثناء التصفح',
      'en': 'Automatic Screen Adhkar Notifications',
      'fr': 'Invocations automatiques à l\'écran',
      'it': 'Invocazioni Automatiche sullo Schermo',
    },
    'services_auto_adhkar_subtitle': {
      'ar': 'ظهور الأذكار والأدعية على الشاشة تلقائياً مع اختيار ما يظهر لك',
      'en': 'Dhikr pops up automatically while using device',
      'fr': 'Affichage automatique des invocations pendant la navigation',
      'it': 'Visualizzazione automatica di Dhikr e suppliche sullo schermo',
    },
    'services_live_title': {
      'ar': 'البث المباشر (مكة، المدينة، الجزائر)',
      'en': 'Live Broadcast (Makkah, Madinah, Algeria)',
      'fr': 'Diffusion en Direct (Mecque, Médine, Algérie)',
      'it': 'Diretta TV (Mecca, Medina, Algeria)',
    },
    'services_live_subtitle': {
      'ar': 'إذاعة القرآن الكريم الجزائرية وقنوات الحرمين 24/7',
      'en': 'Quran Radio & Two Holy Mosques channels 24/7',
      'fr': 'Radio du Saint Coran & Chaînes des Lieux Saints 24/7',
      'it': 'Radio del Sacro Corano e canali dei Luoghi Santi 24/7',
    },
    'services_card_creator_title': {
      'ar': 'أنشئ وشارك بطاقات قرآنية',
      'en': 'Create & Share Quran Cards',
      'fr': 'Créer & Partager des cartes coraniques',
      'it': 'Crea e Condividi Carte Coraniche',
    },
    'services_card_creator_subtitle': {
      'ar': 'تصميم ومشاركة آيات وأحاديث نبوية كصدقة جارية',
      'en': 'Design and share Ayahs & Hadiths easily',
      'fr': 'Concevez et partagez des versets et hadiths',
      'it': 'Crea e condividi versetti e Hadith come carità continua',
    },
    'services_events_title': {
      'ar': 'التقويم والمناسبات الإسلامية',
      'en': 'Islamic Calendar & Events',
      'fr': 'Calendrier & Événements Islamiques',
      'it': 'Calendario ed Eventi Islamici',
    },
    'services_events_subtitle': {
      'ar': 'التاريخ الهجري السنوي والأعياد والمناسبات الدينية',
      'en': 'Annual Hijri calendar and Islamic religious holidays',
      'fr': 'Calendrier hégirien et fêtes religieuses annuelles',
      'it': 'Calendario annuale Hijri e festività religiose islamiche',
    },
    'services_mosques_title': {
      'ar': 'البحث عن المساجد وأماكن العبادة',
      'en': 'Nearby Mosques & Places of Worship',
      'fr': 'Recherche de Mosquées & Lieux de Culte',
      'it': 'Cerca Moschee e Luoghi di Culto',
    },
    'services_mosques_subtitle': {
      'ar': 'دليل أقرب المساجد ومعالم الجزائر والملاحة بالخريطة',
      'en': 'Nearest mosques directory and map navigation',
      'fr': 'Guide des mosquées proches et navigation sur carte',
      'it': 'Guida alle moschee vicine e navigazione su mappa',
    },
    'services_settings_title': {
      'ar': 'الإعدادات العامة والمظهر',
      'en': 'General Settings & Appearance',
      'fr': 'Paramètres Généraux & Apparence',
      'it': 'Impostazioni Generali e Aspetto',
    },
    'services_settings_subtitle': {
      'ar': 'تخصيص ألوان التطبيق وصوت الأذان المعتمد',
      'en': 'Customize app theme, language, and adhan sounds',
      'fr': 'Personnaliser thème, langue et son de l\'adhan',
      'it': 'Personalizza tema, lingue e suoni dell\'Adhan',
    },
    'services_share_title': {
      'ar': 'مشاركة التطبيق كصدقة جارية',
      'en': 'Share App as Ongoing Charity',
      'fr': 'Partager l\'application (Aumône continue)',
      'it': 'Condividi l\'App come Carità Continua',
    },
    'services_share_subtitle': {
      'ar': 'دلّ على الخير وانشر تطبيق مِحْرَاب ليعم النفع والأجر',
      'en': 'Invite others and spread the blessings with Mihrab',
      'fr': 'Partagez Mihrab pour répandre le bien et les bénédictions',
      'it': 'Invita al bene e condividi Mihrab per diffondere la grazia',
    },

    // Drawer Menu
    'drawer_brand': {
      'ar': 'مِحْرَاب',
      'en': 'MIHRAB',
      'fr': 'MIHRAB',
      'it': 'MIHRAB',
    },
    'drawer_current_location': {
      'ar': 'موقعك الحالي',
      'en': 'Current Location',
      'fr': 'Emplacement actuel',
      'it': 'Posizione attuale',
    },
    'drawer_play_adhan': {
      'ar': 'تشغيل صوت الأذان',
      'en': 'Play Adhan Sound',
      'fr': 'Écouter l\'Adhan',
      'it': 'Ascolta Adhan',
    },
    'drawer_live': {
      'ar': 'البث المباشر (مكة، المدينة، الجزائر)',
      'en': 'Live Broadcast (Makkah, Madinah)',
      'fr': 'Diffusion en Direct (Mecque, Médine)',
      'it': 'Diretta TV (Mecca, Medina)',
    },
    'drawer_events': {
      'ar': 'المناسبات الإسلامية والتقويم',
      'en': 'Islamic Events & Calendar',
      'fr': 'Événements & Calendrier Islamiques',
      'it': 'Eventi Islamici e Calendario',
    },
    'drawer_mosques': {
      'ar': 'المساجد القريبة ودليل المعالم',
      'en': 'Nearby Mosques & Landmarks',
      'fr': 'Mosquées proches & Lieux de Culte',
      'it': 'Moschee Vicine e Monumenti',
    },
    'drawer_settings': {
      'ar': 'الإعدادات وتخصيص المظهر',
      'en': 'Settings & Customization',
      'fr': 'Paramètres & Personnalisation',
      'it': 'Impostazioni e Personalizzazione',
    },
    'drawer_about': {
      'ar': 'عن تطبيق مِحْرَاب',
      'en': 'About Mihrab',
      'fr': 'À propos de Mihrab',
      'it': 'Informazioni su Mihrab',
    },
    'drawer_change_location': {
      'ar': 'تغيير الموقع والمدينة 📍',
      'en': 'Change Location & City 📍',
      'fr': 'Changer de Lieu & Ville 📍',
      'it': 'Cambia Posizione e Città 📍',
    },
    'drawer_adhkar': {
      'ar': 'أذكار الشاشة التلقائية',
      'en': 'Automatic Screen Adhkar',
      'fr': 'Invocations Automatiques',
      'it': 'Invocazioni Automatiche a Schermo',
    },
    'drawer_play_adhan_sub': {
      'ar': 'استمع للأذان المعتمد الآن',
      'en': 'Listen to approved Adhan now',
      'fr': 'Écouter l\'Adhan approuvé',
      'it': 'Ascolta l\'Adhan approvato adesso',
    },
    'drawer_live_sub': {
      'ar': 'إذاعة القرآن وقنوات الحرمين',
      'en': 'Holy Quran radio & Haramain live',
      'fr': 'Radio du Coran & Chaînes des Lieux Saints',
      'it': 'Radio del Corano e diretta Haramain',
    },
    'drawer_events_sub': {
      'ar': 'أعياد ومناسبات العام الهجري',
      'en': 'Holidays and occasions of Hijri year',
      'fr': 'Fêtes et occasions de l\'année hégirienne',
      'it': 'Festività ed eventi dell\'anno Hijri',
    },
    'drawer_mosques_sub': {
      'ar': 'أقرب المساجد والملاحة بالخريطة',
      'en': 'Nearest mosques and map navigation',
      'fr': 'Mosquées les plus proches et carte',
      'it': 'Moschee più vicine e mappa navigabile',
    },
    'drawer_adhkar_sub': {
      'ar': 'ظهور الأذكار أثناء تصفح الهاتف',
      'en': 'Adhkar popups while using device',
      'fr': 'Invocations pendant la navigation',
      'it': 'Visualizzazione Dhikr durante l\'uso del telefono',
    },
    'drawer_settings_sub': {
      'ar': 'لغات التطبيق (20 لغة عالمية)، المظهر، وتنبيهات الأذان',
      'en': 'Languages (20 world languages), theme, and adhan alerts',
      'fr': 'Langues (20 langues mondiales), thème et alertes adhan',
      'it': 'Lingue (20 lingue mondiali), tema e avvisi adhan',
    },
    'drawer_about_sub': {
      'ar': 'الإصدار 1.0.4 — موثوقية تقنية ومصادر شرعية وفلكية معتمدة',
      'en': 'Version 1.0.4 — Certified Technical & Astronomical Sources',
      'fr': 'Version 1.0.4 — Sources Techniques et Astronomiques Certifiées',
      'it': 'Versione 1.0.4 — Fonti Tecniche e Astronomiche Certificate',
    },
    'drawer_app_language': {
      'ar': 'لغة التطبيق',
      'en': 'App Language',
      'fr': 'Langue de l\'application',
      'it': 'Lingua dell\'Applicazione',
    },
    'next_prayer_title': {
      'ar': 'الصلاة القادمة',
      'en': 'Next Prayer',
      'fr': 'Prochaine Prière',
      'it': 'Prossima Preghiera',
    },
    'remaining_prefix': {
      'ar': 'متبقي',
      'en': 'Remaining',
      'fr': 'Restant',
      'it': 'Mancano',
    },

    // Settings Screen Core
    'settings_title': {
      'ar': 'الإعدادات العامة وتخصيص المظهر',
      'en': 'General Settings & Appearance',
      'fr': 'Paramètres Généraux & Apparence',
      'it': 'Impostazioni Generali e Aspetto',
    },
    'language_selector_title': {
      'ar': 'لغة التطبيق (20 لغة عالمية)',
      'en': 'App Language (20 World Languages)',
      'fr': 'Langue de l\'Application (20 Langues)',
      'it': 'Lingua dell\'Applicazione (20 Lingue Mondiali)',
    },
    'language_selector_desc': {
      'ar': 'اختر لغة واجهة التطبيق المفضلة لديك من بين 20 لغة عالمية مع دعم كامل للاتجاه',
      'en': 'Choose your preferred app interface language with full RTL/LTR support',
      'fr': 'Choisissez votre langue d\'interface préférée parmi 20 langues mondiales',
      'it': 'Scegli la lingua preferita dell\'interfaccia con supporto completo RTL/LTR',
    },
    'language_popular': {
      'ar': 'اللغات الأكثر استخداماً:',
      'en': 'Most popular languages:',
      'fr': 'Langues les plus utilisées :',
      'it': 'Lingue più utilizzate:',
    },
    'language_browse_all': {
      'ar': 'تصفح واختيار من جميع اللغات (20 لغة عالمية) 🌐',
      'en': 'Browse and select from all languages (20 World Languages) 🌐',
      'fr': 'Parcourir et choisir parmi toutes les langues (20 Langues) 🌐',
      'it': 'Sfoglia e scegli tra tutte le lingue (20 Lingue Mondiali) 🌐',
    },
    'language_modal_title': {
      'ar': 'لغات العالم المدعومة',
      'en': 'Supported World Languages',
      'fr': 'Langues du Monde Supportées',
      'it': 'Lingue del Mondo Supportate',
    },
    'language_search_hint': {
      'ar': 'ابحث عن اللغة (مثال: Turkish, اردو, Français, Italiano)...',
      'en': 'Search language (e.g., Italian, Turkish, Français)...',
      'fr': 'Rechercher une langue (ex: Italien, Turc, Français)...',
      'it': 'Cerca lingua (es. Italiano, Turkish, Français)...',
    },
    'language_not_found': {
      'ar': 'لم يتم العثور على لغات مطابقة للبحث',
      'en': 'No languages matched your search',
      'fr': 'Aucune langue ne correspond à la recherche',
      'it': 'Nessuna lingua trovata per la ricerca',
    },
    'language_active': {
      'ar': 'نشطة',
      'en': 'Active',
      'fr': 'Active',
      'it': 'Attiva',
    },
    'language_set_feedback': {
      'ar': 'تم اعتماد لغة التطبيق: ',
      'en': 'App language updated to: ',
      'fr': 'Langue de l\'application définie sur : ',
      'it': 'Lingua dell\'applicazione aggiornata a: ',
    },

    // Themes
    'settings_theme_header': {
      'ar': 'لون ومظهر التطبيق (تخصيص كامل)',
      'en': 'App Theme & Colors',
      'fr': 'Thème & Couleurs de l\'Application',
      'it': 'Tema e Aspetto dell\'Applicazione',
    },
    'settings_theme_prompt': {
      'ar': 'اختر السمة واللون المفضل لديك للتطبيق:',
      'en': 'Choose your preferred theme and visual style:',
      'fr': 'Choisissez votre thème et style visuel préférés :',
      'it': 'Scegli il tuo tema e stile visivo preferito:',
    },
    'theme_section_title': {
      'ar': 'ألوان ومظهر التطبيق',
      'en': 'Theme & Color Palette',
      'fr': 'Thème & Couleurs',
      'it': 'Tema e Palette Colori',
    },
    'theme_emerald_name': {
      'ar': 'الأخضر الزمردي الأندلسي (الافتراضي)',
      'en': 'Andalusian Emerald (Default)',
      'fr': 'Émeraude Andalouse (Par défaut)',
      'it': 'Smeraldo Andaluso (Predefinito)',
    },
    'theme_royal_blue_name': {
      'ar': 'الأزرق الملكي القرطبي',
      'en': 'Cordoban Royal Blue',
      'fr': 'Bleu Royal de Cordoue',
      'it': 'Blu Reale di Cordova',
    },
    'theme_desert_gold_name': {
      'ar': 'الصحراوي الذهبي (الرمال والواحات)',
      'en': 'Sahara Gold (Oasis & Dunes)',
      'fr': 'Or Saharien (Oasis & Dunes)',
      'it': 'Oro del Sahara (Oasi e Dune)',
    },
    'theme_black_gold_name': {
      'ar': 'الأسود والذهبي الفاخر',
      'en': 'Luxury Black & Gold',
      'fr': 'Noir & Or Luxueux',
      'it': 'Nero e Oro Lussuoso',
    },

    // Location & GPS Settings
    'settings_location_header': {
      'ar': 'الموقع والتحديد التلقائي',
      'en': 'Location & Auto-Detection',
      'fr': 'Localisation & Détection Automatique',
      'it': 'Posizione e Rilevamento Automatico',
    },
    'settings_current_wilaya': {
      'ar': 'الولاية أو المدينة المحددة حالياً',
      'en': 'Currently Selected Province or City',
      'fr': 'Wilaya ou Ville Actuellement Sélectionnée',
      'it': 'Provincia o Città Attualmente Selezionata',
    },
    'settings_auto_gps_title': {
      'ar': 'التحديد التلقائي للموقع (GPS)',
      'en': 'Automatic Location Detection (GPS)',
      'fr': 'Détection Automatique de la Position (GPS)',
      'it': 'Rilevamento Automatico della Posizione (GPS)',
    },
    'settings_auto_gps_desc': {
      'ar': 'كشف الولاية والبلدية بدقة عبر الأقمار الصناعية وحساب المواقيت آلياً',
      'en': 'Accurately detect province/city via satellite and calculate timings',
      'fr': 'Détecter la commune via satellite et calculer les horaires automatiquement',
      'it': 'Rileva provincia e comune via satellite e calcola gli orari automaticamente',
    },
    'settings_detecting_location': {
      'ar': 'جاري كشف موقعك وتحديد ولايتك...',
      'en': 'Detecting your location via GPS...',
      'fr': 'Détection de votre position GPS en cours...',
      'it': 'Rilevamento della posizione GPS in corso...',
    },
    'settings_location_detected': {
      'ar': 'تم تحديد موقعك بدقة: ',
      'en': 'Location detected accurately: ',
      'fr': 'Position détectée avec précision : ',
      'it': 'Posizione rilevata con precisione: ',
    },

    // Calculation Methods & Madhab
    'settings_calc_header': {
      'ar': 'طرق الحساب والمذاهب الفقهية',
      'en': 'Calculation & Juristic Methods',
      'fr': 'Méthodes de Calcul & Jurisprudence',
      'it': 'Metodi di Calcolo e Scuole Giuridiche',
    },
    'settings_calc_prompt': {
      'ar': 'طريقة الحساب الفلكية:',
      'en': 'Astronomical Calculation Method:',
      'fr': 'Méthode de Calcul Astronomique :',
      'it': 'Metodo di Calcolo Astronomico:',
    },
    'settings_madhab_prompt': {
      'ar': 'المذهب الفقهي لحساب صلاة العصر:',
      'en': 'Juristic Method for Asr prayer:',
      'fr': 'Méthode Juridique pour la Prière du Asr :',
      'it': 'Scuola Giuridica (Madhab) per l\'Asr:',
    },
    'calc_method_title': {
      'ar': 'طريقة حساب مواقيت الصلاة',
      'en': 'Prayer Times Calculation Method',
      'fr': 'Méthode de Calcul des Horaires',
      'it': 'Metodo di Calcolo degli Orari di Preghiera',
    },
    'juristic_method_title': {
      'ar': 'المذهب الفقهي لحساب صلاة العصر',
      'en': 'Juristic Method for Asr (Madhab)',
      'fr': 'Méthode Juridique pour l\'Asr (Madhhab)',
      'it': 'Scuola Giuridica per l\'Asr (Madhab)',
    },
    'madhab_standard': {
      'ar': 'الجمهور (المالكي والشافعي والحنبلي) - ظل الشيء مثله',
      'en': 'Standard (Maliki, Shafi\'i, Hanbali) - Single shadow',
      'fr': 'Standard (Malékite, Chaféite, Hanbalite)',
      'it': 'Standard (Malikita, Shafiita, Hanbalita) - Ombra singola',
    },
    'madhab_hanafi': {
      'ar': 'المذهب الحنفي - ظل الشيء مثليه',
      'en': 'Hanafi Method - Double shadow factor',
      'fr': 'Méthode Hanafite - Double ombre',
      'it': 'Metodo Hanafita - Ombra doppia',
    },

    // Mosque Sync (Offsets)
    'settings_sync_mosque_header': {
      'ar': 'مزامنة مع المسجد (تعديل بالدقائق)',
      'en': 'Mosque Sync (Minute Adjustments)',
      'fr': 'Synchronisation Mosquée (Ajustement en minutes)',
      'it': 'Sincronizzazione con la Moschea (Minuti)',
    },
    'settings_sync_mosque_desc': {
      'ar': 'قم بمواءمة وقت كل صلاة بزيادة أو إنقاص الدقائق ليتطابق مع مسجد حيك تماماً:',
      'en': 'Adjust each prayer time to precisely match your local neighborhood mosque:',
      'fr': 'Ajustez chaque horaire pour concorder parfaitement avec votre mosquée locale :',
      'it': 'Regola i minuti di ogni preghiera per sincronizzarti perfettamente con la tua moschea:',
    },
    'settings_minute_short': {
      'ar': 'د',
      'en': 'm',
      'fr': 'm',
      'it': 'm',
    },

    // Custom & Default Adhans
    'settings_custom_adhan_header': {
      'ar': 'تخصيص أذان مختلف لكل صلاة',
      'en': 'Custom Adhan Voice Per Prayer',
      'fr': 'Personnaliser l\'Adhan par Prière',
      'it': 'Personalizza Voce Adhan per Ogni Preghiera',
    },
    'settings_default_adhan_header': {
      'ar': 'صوت الأذان',
      'en': 'Adhan Sound',
      'fr': 'Son de l\'Adhan',
      'it': 'Suono dell\'Adhan',
    },
    'settings_select_adhan_dialog_title': {
      'ar': 'اختر صوت أذان',
      'en': 'Select Adhan voice for',
      'fr': 'Sélectionner l\'appel à la prière pour',
      'it': 'Scegli la voce dell\'Adhan per',
    },
    'settings_adhan_assigned': {
      'ar': 'تم اعتماد صوت الأذان بنجاح لصلاة: ',
      'en': 'Adhan voice set successfully for: ',
      'fr': 'Son d\'Adhan assigné avec succès à : ',
      'it': 'Voce dell\'Adhan impostata con successo per: ',
    },
    'listen_sample': {
      'ar': 'استماع لعينة الصوت',
      'en': 'Listen to audio sample',
      'fr': 'Écouter l\'échantillon audio',
      'it': 'Ascolta campione audio',
    },
    'playing_sample': {
      'ar': 'جاري تشغيل عينة: ',
      'en': 'Playing sample: ',
      'fr': 'Lecture de l\'extrait : ',
      'it': 'Riproduzione del campione: ',
    },

    // Adhan Voice Titles & Descriptions (All 11 Adhans)
    'adhan_algeria_grand_mosque_name': {
      'ar': 'أذان جامع الجزائر (الجامع الأعظم)',
      'en': 'Adhan of Djamaâ el Djazaïr (Algiers Grand Mosque)',
      'fr': 'Adhan de la Grande Mosquée d\'Alger (Djamaâ el Djazaïr)',
      'it': 'Adhan Grande Moschea di Algeri (Djamaâ el Djazaïr)',
    },
    'adhan_algeria_grand_mosque_desc': {
      'ar': 'الأذان الرسمي لجامع الجزائر',
      'en': 'Official Adhan of the Grand Mosque of Algiers',
      'fr': 'L\'Adhan officiel de la Grande Mosquée d\'Alger',
      'it': 'L\'Adhan ufficiale della Grande Moschea di Algeri',
    },
    'adhan_traditional_algerian_name': {
      'ar': 'الأذان الجزائري الأصيل (المقام المغاربي)',
      'en': 'Authentic Algerian Adhan (Maghrebi Maqam)',
      'fr': 'Adhan Traditionnel Algérien (Maqam Maghrébin)',
      'it': 'Adhan Tradizionale Algerino (Stile Maghrebino)',
    },
    'adhan_traditional_algerian_desc': {
      'ar': 'أذان الإذاعة والتلفزيون الجزائري',
      'en': 'Adhan of Algerian National Radio & Television',
      'fr': 'Adhan de la Radio et Télévision Algérienne',
      'it': 'Adhan della Radio e Televisione Algerina',
    },
    'adhan_makkah_name': {
      'ar': 'أذان المسجد الحرام (مكة المكرمة)',
      'en': 'Adhan of the Holy Mosque (Makkah Al-Mukarramah)',
      'fr': 'Adhan de la Mosquée Sacrée (La Mecque)',
      'it': 'Adhan della Sacra Moschea (La Mecca)',
    },
    'adhan_makkah_desc': {
      'ar': 'الشيخ علي ملا',
      'en': 'Sheikh Ali Mulla',
      'fr': 'Cheikh Ali Mulla',
      'it': 'Sceicco Ali Mulla',
    },
    'adhan_madinah_name': {
      'ar': 'أذان المسجد النبوي (المدينة المنورة)',
      'en': 'Adhan of the Prophet\'s Mosque (Al-Madinah Al-Munawwarah)',
      'fr': 'Adhan de la Mosquée du Prophète (Médine)',
      'it': 'Adhan della Moschea del Profeta (Medina)',
    },
    'adhan_madinah_desc': {
      'ar': 'الشيخ عصام بخاري',
      'en': 'Sheikh Essam Bukhari',
      'fr': 'Cheikh Essam Boukhari',
      'it': 'Sceicco Essam Bukhari',
    },
    'adhan_al_aqsa_name': {
      'ar': 'أذان المسجد الأقصى المبارك',
      'en': 'Adhan of the Blessed Al-Aqsa Mosque',
      'fr': 'Adhan de la Mosquée Al-Aqsa Bénie',
      'it': 'Adhan della Benedetta Moschea di Al-Aqsa',
    },
    'adhan_al_aqsa_desc': {
      'ar': 'القدس الشريف - الشيخ ناجي قزاز',
      'en': 'Al-Quds (Jerusalem) - Sheikh Naji Qazzaz',
      'fr': 'Jérusalem (Al-Qods) - Cheikh Naji Qazzaz',
      'it': 'Al-Quds (Gerusalemme) - Sceicco Naji Qazzaz',
    },
    'adhan_abdulbasit_name': {
      'ar': 'أذان الشيخ عبد الباسط عبد الصمد',
      'en': 'Adhan of Sheikh Abdul Basit Abdul Samad',
      'fr': 'Adhan de Cheikh Abdul Basit Abdul Samad',
      'it': 'Adhan dello Sceicco Abdul Basit Abdul Samad',
    },
    'adhan_abdulbasit_desc': {
      'ar': 'أذان مصر التاريخي النادر',
      'en': 'Rare historic Egyptian recording',
      'fr': 'Rare enregistrement historique égyptien',
      'it': 'Rara registrazione storica egiziana',
    },
    'adhan_rifat_name': {
      'ar': 'أذان الشيخ محمد رفعت',
      'en': 'Adhan of Sheikh Muhammad Rifat',
      'fr': 'Adhan de Cheikh Muhammad Rifat',
      'it': 'Adhan dello Sceicco Muhammad Rifat',
    },
    'adhan_rifat_desc': {
      'ar': 'قيثارة السماء',
      'en': 'Harp of the Sky',
      'fr': 'La harpe du ciel',
      'it': 'La cetra del cielo',
    },
    'adhan_husary_name': {
      'ar': 'أذان الشيخ محمود خليل الحصري',
      'en': 'Adhan of Sheikh Mahmoud Khalil Al-Husary',
      'fr': 'Adhan de Cheikh Mahmoud Khalil Al-Hussary',
      'it': 'Adhan dello Sceicco Mahmoud Khalil Al-Husary',
    },
    'adhan_husary_desc': {
      'ar': 'شيخ عموم المقارئ المصرية',
      'en': 'Dean of Egyptian reciters',
      'fr': 'Doyen des récitateurs égyptiens',
      'it': 'Maestro dei recitatori egiziani',
    },
    'adhan_banna_name': {
      'ar': 'أذان الشيخ محمود علي البنا',
      'en': 'Adhan of Sheikh Mahmoud Ali Al-Banna',
      'fr': 'Adhan de Cheikh Mahmoud Ali Al-Banna',
      'it': 'Adhan dello Sceicco Mahmoud Ali Al-Banna',
    },
    'adhan_banna_desc': {
      'ar': 'أداء خاشع ومؤثر',
      'en': 'Deeply reverent recitation',
      'fr': 'Récitation pieuse et émouvante',
      'it': 'Recitazione toccante e devota',
    },
    'adhan_shaisha_name': {
      'ar': 'أذان الشيخ أبو العينين شعيشع',
      'en': 'Adhan of Sheikh Abul Ainain Shuaisha',
      'fr': 'Adhan de Cheikh Aboul Aynaïn Chouaïcha',
      'it': 'Adhan dello Sceicco Abul Ainain Shuaisha',
    },
    'adhan_shaisha_desc': {
      'ar': 'التسجيل المصري العريق',
      'en': 'Distinguished historic Egyptian recording',
      'fr': 'Enregistrement égyptien prestigieux',
      'it': 'Prestigiosa registrazione storica egiziana',
    },
    'adhan_takbeer_only_name': {
      'ar': 'تكبيرات الأذان والعيد',
      'en': 'Takbeerat of Adhan & Eid',
      'fr': 'Takbeerat de l\'Adhan et de l\'Aïd',
      'it': 'Takbeerat dell\'Adhan e dell\'Eid',
    },
    'adhan_takbeer_only_desc': {
      'ar': 'المسجد الحرام - تكبيرات الحرم المكي',
      'en': 'Holy Mosque of Makkah Takbeerat',
      'fr': 'Takbeerat de la Mosquée Sacrée de La Mecque',
      'it': 'Masjid Al-Haram - Takbeerat di La Mecca',
    },

    // Advance Reminder & Iqamah
    'settings_advance_reminder_header': {
      'ar': 'التنبيه المسبق ووقت الإقامة',
      'en': 'Advance Reminder & Iqamah Time',
      'fr': 'Rappel Anticipé & Heure de l\'Iqama',
      'it': 'Promemoria Anticipato e Tempo di Iqama',
    },
    'settings_advance_reminder_prompt': {
      'ar': 'تنبيه هادئ قبل الأذان للاستعداد والوضوء:',
      'en': 'Gentle alert before Adhan for preparation & Wudu:',
      'fr': 'Rappel doux avant l\'Adhan pour les ablutions :',
      'it': 'Promemoria discreto prima dell\'Adhan per prepararsi all\'abluzione (Wudu):',
    },
    'settings_no_reminder': {
      'ar': 'بدون تنبيه',
      'en': 'No reminder',
      'fr': 'Sans rappel',
      'it': 'Nessun promemoria',
    },
    'settings_minutes_unit': {
      'ar': 'دقيقة',
      'en': 'minutes',
      'fr': 'minutes',
      'it': 'minuti',
    },
    'settings_iqamah_title': {
      'ar': 'تنبيه وقت الإقامة',
      'en': 'Iqamah Time Notification',
      'fr': 'Alerte Heure de l\'Iqama',
      'it': 'Promemoria Tempo di Iqama',
    },
    'settings_iqamah_desc': {
      'ar': 'إشعار لطيف عند حلول وقت إقامة الصلاة في المسجد',
      'en': 'Gentle alert when congregational prayer commences in mosque',
      'fr': 'Notification douce à l\'heure de la prière en congrégation',
      'it': 'Notifica delicata quando arriva il tempo della preghiera comunitaria nella moschea',
    },

    // Auto Silent Mosque Mode
    'auto_silent_mode': {
      'ar': 'الوضع الصامت التلقائي في المسجد',
      'en': 'Automatic Silent Mode in Mosque',
      'fr': 'Mode Silencieux Automatique à la Mosquée',
      'it': 'Modalità Silenziosa Automatica nella Moschea',
    },
    'auto_silent_mode_title': {
      'ar': 'كتم صوت الهاتف تلقائياً أثناء الصلاة',
      'en': 'Automatically silence phone during prayer',
      'fr': 'Mettre le téléphone en silencieux pendant la prière',
      'it': 'Disattiva suoneria automaticamente durante la preghiera',
    },
    'auto_silent_mode_desc': {
      'ar': 'تحويل الهاتف لوضع الصامت تلقائياً بعد الأذان لمدة 25 دقيقة أثناء صلاة الجماعة وإعادته بعدها.',
      'en': 'Automatically switch phone to silent mode after Adhan for 25 minutes during congregation prayer, then restore.',
      'fr': 'Passe automatiquement en silencieux pendant 25 minutes après l\'Adhan lors de la prière en groupe, puis rétablit.',
      'it': 'Imposta il telefono in modalità silenziosa per 25 minuti durante la preghiera comunitaria e ripristina la suoneria al termine.',
    },
    'settings_test_silent_btn': {
      'ar': 'تجربة كتم الصوت الآن 🔕',
      'en': 'Test Silent Mode Now 🔕',
      'fr': 'Tester le Mode Silencieux 🔕',
      'it': 'Prova modalità silenziosa adesso 🔕',
    },
    'settings_test_silent_active': {
      'ar': 'تم كتم صوت الهاتف بنجاح 🔕 (تجربة لمدة 4 ثوانٍ...)',
      'en': 'Phone silenced successfully 🔕 (Testing for 4 seconds...)',
      'fr': 'Téléphone mis en silencieux 🔕 (Test pendant 4 secondes...)',
      'it': 'Telefono silenziato con successo 🔕 (Test per 4 secondi...)',
    },
    'settings_test_silent_restored': {
      'ar': 'تمت استعادة الوضع العام للهاتف 🔔 بنجاح!',
      'en': 'Normal ringer restored 🔔 successfully!',
      'fr': 'Sonnerie normale rétablie 🔔 avec succès !',
      'it': 'Suoneria normale ripristinata con successo 🔔!',
    },
    'dnd_permission_dialog_title': {
      'ar': 'إذن كتم الصوت التلقائي',
      'en': 'Silent Mode Access Permission',
      'fr': 'Autorisation Mode Silencieux',
      'it': 'Autorizzazione Modalità Silenziosa',
    },
    'dnd_permission_dialog_desc': {
      'ar': 'يحتاج التطبيق إلى إذن الوصول إلى سياسة عدم الإزعاج (Do Not Disturb) من إعدادات النظام ليتمكن من تحويل الهاتف للوضع الصامت أثناء الصلاة وإعادته للوضع العام تلقائياً.',
      'en': 'The app requires "Do Not Disturb" (Notification Policy Access) in system settings to automatically silence the device during prayer and restore ringer afterwards.',
      'fr': 'L\'application nécessite l\'autorisation « Ne pas déranger » pour basculer automatiquement en mode silencieux pendant la prière puis rétablir le volume.',
      'it': 'L\'applicazione richiede l\'autorizzazione «Accesso a Non Disturbare (Do Not Disturb)» nelle impostazioni per disattivare la suoneria durante la preghiera e ripristinarla.',
    },
    'grant_permission': {
      'ar': 'فتح الإعدادات لمنح الإذن',
      'en': 'Open Settings to Grant',
      'fr': 'Ouvrir les Paramètres',
      'it': 'Apri Impostazioni per Autorizzare',
    },

    // Test Adhan & Notifications Card
    'settings_test_adhan_title': {
      'ar': 'اختبار أذان الصلاة والإشعار',
      'en': 'Test Prayer Adhan & Notification',
      'fr': 'Tester l\'Adhan & Notification de Prière',
      'it': 'Test dell\'Adhan e Notifica',
    },
    'settings_test_adhan_desc': {
      'ar': 'تجربة ظهور إشعار دخول وقت الصلاة وسماع صوت الأذان فورياً',
      'en': 'Instantly test prayer notification banner and play Adhan audio',
      'fr': 'Tester immédiatement la notification et le son de l\'Adhan',
      'it': 'Prova istantaneamente la notifica e ascolta la voce dell\'Adhan',
    },
    'settings_test_adhan_btn': {
      'ar': 'اختبر الأذان والإشعار الآن',
      'en': 'Test Adhan & Notification Now',
      'fr': 'Tester l\'Adhan et l\'Alerte Maintenant',
      'it': 'Prova Adhan e Notifica Adesso',
    },
    'settings_test_adhan_sent': {
      'ar': 'تم إطلاق إشعار وأذان صلاة الظهر في 🕌: ',
      'en': 'Notification and Adhan launched for Dhuhr in 🕌: ',
      'fr': 'Notification et appel à la prière du Dhuhr lancés à 🕌 : ',
      'it': 'Notifica e Adhan avviati per il Dhuhr a 🕌: ',
    },

    // Battery Optimization Card
    'settings_battery_header': {
      'ar': 'لضمان سماع الأذان عند قفل الهاتف (الخلفية)',
      'en': 'Ensure Adhan Sounds in Background / Locked Screen',
      'fr': 'Garantir l\'Adhan en Arrière-plan (Écran Verrouillé)',
      'it': 'Per garantire l\'Adhan a schermo bloccato (Background)',
    },
    'settings_battery_desc': {
      'ar': 'تقوم بعض الهواتف بإيقاف التنبيهات لتوفير الطاقة. لضمان دقة الأذان دائماً:\n1. اضبط توفير طاقة البطارية للتطبيق على «بدون قيود / No restrictions».\n2. فعّل خيار «التشغيل التلقائي / Autostart» في إعدادات التطبيق.\n3. تأكد من السماح بالإشعارات والمنبهات الدقيقة (Exact Alarms).',
      'en': 'Some devices terminate background alerts to save battery. To ensure timely Adhan:\n1. Set battery saver to "No restrictions".\n2. Enable "Autostart" in app settings.\n3. Allow Notifications and Exact Alarms.',
      'fr': 'Certains téléphones coupent les alertes en arrière-plan. Pour garantir l\'exactitude de l\'Adhan :\n1. Réglez la batterie sur « Aucune restriction ».\n2. Activez le « Démarrage automatique ».\n3. Autorisez les notifications et alarmes précises.',
      'it': 'Alcuni telefoni interrompono le notifiche in background per risparmiare batteria. Per garantire l\'Adhan:\n1. Imposta la batteria su «Nessuna restrizione».\n2. Attiva «Avvio automatico».\n3. Consenti notifiche e allarmi esatti.',
    },
    'settings_battery_btn': {
      'ar': 'فتح إعدادات التطبيق بالهاتف',
      'en': 'Open App Settings on Device',
      'fr': 'Ouvrir les Paramètres de l\'Appareil',
      'it': 'Apri Impostazioni App nel Telefono',
    },
    'settings_battery_samsung_title': {
      'ar': 'استثناء تحسين البطارية (سامسونج وأندرويد)',
      'en': 'Battery Optimization Exemption (Samsung & Android)',
      'fr': 'Exemption d\'optimisation de batterie (Samsung & Android)',
      'it': 'Esenzione ottimizzazione batteria (Samsung e Android)',
    },
    'settings_battery_exempted': {
      'ar': 'مُستثنى ✓',
      'en': 'Exempted ✓',
      'fr': 'Exempté ✓',
      'it': 'Esente ✓',
    },
    'settings_battery_required': {
      'ar': 'مطلوب ⚠️',
      'en': 'Required ⚠️',
      'fr': 'Requis ⚠️',
      'it': 'Richiesto ⚠️',
    },
    'settings_battery_samsung_desc': {
      'ar': 'توقف هواتف سامسونج التطبيقات في الخلفية تلقائياً لتوفير الطاقة، مما قد يعطل الأذان عند قفل الشاشة. يرجى تفعيل الاستثناء لضمان الرنين دائماً.',
      'en': 'Samsung and Android phones stop background apps to save energy, which may prevent Adhan when locked. Please allow exemption to guarantee alerts.',
      'fr': 'Les téléphones Samsung et Android arrêtent les applications en arrière-plan pour économiser la batterie. Activez l\'exemption pour garantir l\'Adhan.',
      'it': 'I telefoni Samsung e Android interrompono le app in background per risparmiare energia. Attiva l\'esenzione per garantire l\'Adhan.',
    },
    'settings_battery_request_btn': {
      'ar': 'إعفاء التطبيق من تحسين البطارية الآن',
      'en': 'Exempt App from Battery Optimization Now',
      'fr': 'Exempter l\'application de la batterie maintenant',
      'it': 'Esonera l\'app dall\'ottimizzazione adesso',
    },
    'settings_test_section_header': {
      'ar': 'اختبار وتجربة الأذان',
      'en': 'Test & Experience Adhan',
      'fr': 'Test & Vérification de l\'Adhan',
      'it': 'Test dell\'Adhan e Notifiche',
    },
    'settings_test_section_desc': {
      'ar': 'اختبر عمل الأذان والإشعارات والتنبيه بدقة للتأكد من وصول النداء في وقته:',
      'en': 'Accurately test Adhan, notifications, and alerts to ensure timely call to prayer:',
      'fr': 'Testez l\'Adhan, les alertes et notifications pour vous assurer de sonner à l\'heure :',
      'it': 'Testa l\'Adhan e le notifiche per assicurarti che arrivino in orario:',
    },
    'settings_test_play_btn': {
      'ar': 'سماع صوت الأذان المختار',
      'en': 'Listen to Selected Adhan',
      'fr': 'Écouter l\'Adhan sélectionné',
      'it': 'Ascolta l\'Adhan selezionato',
    },
    'settings_test_prayer_notif_btn': {
      'ar': 'تجربة تنبيه وإشعار الأذان الفوري 🔔',
      'en': 'Test Instant Adhan Alert & Notification 🔔',
      'fr': 'Tester la notification et l\'Adhan immédiat 🔔',
      'it': 'Test notifica e Adhan immediato 🔔',
    },
    'settings_test_doze_btn': {
      'ar': 'تجربة في وضع السبات (بعد 10 ثوانٍ) ⏳',
      'en': 'Test in Sleep / Doze Mode (after 10s) ⏳',
      'fr': 'Tester en mode veille prolongée (après 10s) ⏳',
      'it': 'Test in modalità sonno profondo (dopo 10s) ⏳',
    },
    'settings_test_doze_snackbar': {
      'ar': '⏳ تم ضبط التنبيه بعد 10 ثوانٍ! يرجى قفل شاشة الهاتف الآن لتجربة التنبيه في وضع السبات.',
      'en': '⏳ Alert set for 10 seconds! Please lock your phone now to test sleep mode notification.',
      'fr': '⏳ Alerte réglée dans 10 secondes ! Verrouillez l\'écran pour tester en veille.',
      'it': '⏳ Allarme impostato tra 10 secondi! Blocca lo schermo per testare la notifica.',
    },
    'settings_test_prayer_notif_err': {
      'ar': '⚠️ إشعارات التطبيق معطلة في الهاتف! اضغط لتفعيلها',
      'en': '⚠️ App notifications are disabled! Tap to enable',
      'fr': '⚠️ Les notifications de l\'application sont désactivées !',
      'it': '⚠️ Le notifiche dell\'app sono disattivate!',
    },
    'settings_test_offline_msg': {
      'ar': 'يتطلب الاستماع للأذان بصوت المؤذن اتصالاً بالإنترنت أو استخدام الأذان المدمج 📶',
      'en': 'Listening to this reciter Adhan requires internet connection or built-in audio 📶',
      'fr': 'La lecture de cet adhan requiert une connexion internet ou l\'audio intégré 📶',
      'it': 'L\'ascolto dell\'Adhan richiede una connessione a Internet 📶',
    },
    'settings_test_playing_now': {
      'ar': 'يرتفع الآن صوت الأذان المبارك في الهاتف 🕌',
      'en': 'Blessed Adhan is now playing on device 🕌',
      'fr': 'L\'appel béni à la prière retentit sur le téléphone 🕌',
      'it': 'L\'Adhan benedetto sta suonando sul dispositivo 🕌',
    },

    // About App Card
    'settings_about_app': {
      'ar': 'تطبيق مِحْراب • مواقيت الصلاة والقرآن',
      'en': 'Mihrab App • Prayer Times & Quran',
      'fr': 'Application Mihrab • Horaires de Prière & Coran',
      'it': 'Applicazione Mihrab • Orari di Preghiera e Sacro Corano',
    },
    'settings_about_version': {
      'ar': 'الإصدار 1.0.4 (الجزائر) • مجاني 100% وبدون أي إعلانات',
      'en': 'Version 1.0.4 (Algeria) • 100% Free & No Ads',
      'fr': 'Version 1.0.4 (Algérie) • 100% Gratuit et Sans Publicités',
      'it': 'Versione 1.0.4 (Algeria) • 100% Gratuito e Senza Pubblicità',
    },

    // World Cities & Location Selection
    'location_selection_title': {
      'ar': 'اختيار الموقع والمدينة حول العالم',
      'en': 'Select Location & World City',
      'fr': 'Sélectionner la Ville & Emplacement',
      'it': 'Seleziona Posizione e Città',
    },
    'tab_algeria': {
      'ar': 'الجزائر (58 ولاية)',
      'en': 'Algeria (58 Provinces)',
      'fr': 'Algérie (58 Wilayas)',
      'it': 'Algeria (58 Province)',
    },
    'tab_world_cities': {
      'ar': 'مدن وعواصم العالم 🌍',
      'en': 'World Cities 🌍',
      'fr': 'Villes du Monde 🌍',
      'it': 'Città del Mondo 🌍',
    },
    'tab_gps': {
      'ar': 'تحديد بالـ GPS 🛰️',
      'en': 'Auto GPS 🛰️',
      'fr': 'GPS Automatique 🛰️',
      'it': 'GPS Automatico 🛰️',
    },
    'search_commune_hint': {
      'ar': 'ابحث عن اسم البلدية أو القرية أو الدشرة...',
      'en': 'Search for commune, municipality, or village...',
      'fr': 'Rechercher une commune ou un village...',
      'it': 'Cerca comune, municipio o villaggio...',
    },
    'search_world_city_hint': {
      'ar': 'ابحث عن عاصمة أو مدينة حول العالم...',
      'en': 'Search for a city or country worldwide...',
      'fr': 'Rechercher une ville ou un pays dans le monde...',
      'it': 'Cerca una città o paese nel mondo...',
    },
    'location_selected_feedback': {
      'ar': 'تم تحديد الموقع بنجاح: ',
      'en': 'Location successfully set: ',
      'fr': 'Emplacement défini avec succès: ',
      'it': 'Posizione impostata con successo: ',
    },
    'auto_gps_success': {
      'ar': 'تم تحديد موقعك بدقة عبر الأقمار الصناعية 📍',
      'en': 'Location accurately detected via GPS satellites 📍',
      'fr': 'Position détectée avec précision par satellite GPS 📍',
      'it': 'Posizione rilevata con precisione via satellite GPS 📍',
    },

    // Generic Actions & Alerts
    'cancel': {
      'ar': 'إلغاء',
      'en': 'Cancel',
      'fr': 'Annuler',
      'it': 'Annulla',
    },
    'confirm': {
      'ar': 'تأكيد',
      'en': 'Confirm',
      'fr': 'Confirmer',
      'it': 'Conferma',
    },
    'close': {
      'ar': 'إغلاق',
      'en': 'Close',
      'fr': 'Fermer',
      'it': 'Chiudi',
    },
    'select': {
      'ar': 'اختيار',
      'en': 'Select',
      'fr': 'Sélectionner',
      'it': 'Seleziona',
    },
    'save': {
      'ar': 'حفظ',
      'en': 'Save',
      'fr': 'Enregistrer',
      'it': 'Salva',
    },
    'share': {
      'ar': 'مشاركة',
      'en': 'Share',
      'fr': 'Partager',
      'it': 'Condividi',
    },
    'copy': {
      'ar': 'نسخ',
      'en': 'Copy',
      'fr': 'Copier',
      'it': 'Copia',
    },
    'copied': {
      'ar': 'تم النسخ بنجاح',
      'en': 'Copied successfully',
      'fr': 'Copié avec succès',
      'it': 'Copiato con successo',
    },
    'menu': {
      'ar': 'القائمة الجانبية',
      'en': 'Menu',
      'fr': 'Menu',
      'it': 'Menu',
    },
    'listen': {
      'ar': 'استماع',
      'en': 'Listen',
      'fr': 'Écouter',
      'it': 'Ascolta',
    },
    'stop': {
      'ar': 'إيقاف',
      'en': 'Stop',
      'fr': 'Arrêter',
      'it': 'Ferma',
    },
    'active': {
      'ar': 'نشطة',
      'en': 'Active',
      'fr': 'Active',
      'it': 'Attiva',
    },

    // Nearby Mosques Screen
    'nearby_mosques_page_title': {
      'ar': 'البحث عن المساجد والأماكن القريبة',
      'en': 'Search Mosques & Places of Worship',
      'fr': 'Recherche de Mosquées & Lieux de Culte',
      'it': 'Cerca Moschee e Luoghi di Culto',
    },
    'nearby_mosques_gps_refresh': {
      'ar': 'تحديث GPS',
      'en': 'Refresh GPS',
      'fr': 'Actualiser GPS',
      'it': 'Aggiorna GPS',
    },
    'nearby_mosques_near_btn': {
      'ar': 'المساجد القريبة 🗺️',
      'en': 'Nearby Mosques 🗺️',
      'fr': 'Mosquées Proches 🗺️',
      'it': 'Moschee Vicine 🗺️',
    },
    'nearby_mosques_halal_btn': {
      'ar': 'أكل حلال 🍽️',
      'en': 'Halal Food 🍽️',
      'fr': 'Nourriture Halal 🍽️',
      'it': 'Cibo Halal 🍽️',
    },
    'nearby_mosques_grand_title': {
      'ar': 'أشهر الجوامع والمعالم الإسلامية الكبرى في الجزائر',
      'en': 'Famous Islamic Landmarks & Grand Mosques in Algeria',
      'fr': 'Grandes Mosquées & Monuments Islamiques en Algérie',
      'it': 'Grandi Moschee e Monumenti Islamici in Algeria',
    },
    'nearby_mosques_etiquette_title': {
      'ar': 'آداب دخول المسجد وحرمة بيوت الله',
      'en': 'Mosque Etiquette & Reverence for Houses of Allah',
      'fr': 'Bienséances et Respect des Maisons d\'Allah',
      'it': 'Etichetta della Moschea e Rispetto per le Case di Allah',
    },
    'nearby_mosques_etiquette_hadith': {
      'ar': 'قال رسول الله ﷺ: «أَحَبُّ البِلادِ إلى اللهِ مَساجِدُها».',
      'en': 'The Prophet ﷺ said: "The most beloved of places to Allah are mosques."',
      'fr': 'Le Prophète ﷺ a dit : « Les lieux les plus aimés d\'Allah sont Ses mosquées. »',
      'it': 'Il Profeta ﷺ ha detto: «I luoghi più amati da Allah sono le Sue moschee.»',
    },
    'nearby_mosques_etiquette_1': {
      'ar': 'تقديم الرِجل اليمنى عند الدخول وقول: «اللهم افتح لي أبواب رحمتك».',
      'en': 'Enter with the right foot and pray: "O Allah, open for me the doors of Your mercy."',
      'fr': 'Entrer du pied droit en disant : « Ô Allah, ouvre-moi les portes de Ta miséricorde ».',
      'it': 'Entrare con il piede destro dicendo: «O Allah, aprimi le porte della Tua misericordia».',
    },
    'nearby_mosques_etiquette_2': {
      'ar': 'صلاة ركعتين تحية المسجد قبل الجلوس.',
      'en': 'Pray two Rak\'ahs (Tahiyyat al-Masjid) before sitting.',
      'fr': 'Accomplir deux unités de prière de salutation avant de s\'asseoir.',
      'it': 'Compiere due Rak\'ah (Tahiyyat al-Masjid) prima di sedersi.',
    },
    'nearby_mosques_etiquette_3': {
      'ar': 'خفض الصوت وتجنب الحديث في أمور الدنيا والبيع والشراء.',
      'en': 'Lower your voice and avoid worldly conversation or commercial deals.',
      'fr': 'Baisser la voix et s\'abstenir de discussions futiles ou de commerce.',
      'it': 'Abbassare la voce ed evitare conversazioni mondane o commerciali.',
    },
    'nearby_mosques_etiquette_4': {
      'ar': 'تقديم الرِجل اليسرى عند الخروج وقول: «اللهم إني أسألك من فضلك».',
      'en': 'Exit with the left foot and pray: "O Allah, I ask You from Your bounty."',
      'fr': 'Sortir du pied gauche en disant : « Ô Allah, je Te demande de Ta grâce ».',
      'it': 'Uscire con il piede sinistro dicendo: «O Allah, Ti chiedo dalla Tua grazia».',
    },
    'nearby_mosques_dir_btn': {
      'ar': 'الاتجاهات 🧭',
      'en': 'Directions 🧭',
      'fr': 'Itinéraire 🧭',
      'it': 'Indicazioni 🧭',
    },
    'nearby_mosques_map_btn': {
      'ar': 'الخريطة 📍',
      'en': 'Map 📍',
      'fr': 'Carte 📍',
      'it': 'Mappa 📍',
    },
    'nearby_mosques_details_btn': {
      'ar': 'تفاصيل المعلم ℹ️',
      'en': 'Details ℹ️',
      'fr': 'Détails ℹ️',
      'it': 'Dettagli ℹ️',
    },
    'nearby_mosques_loc_status_prefix': {
      'ar': 'موقعك: ',
      'en': 'Your Location: ',
      'fr': 'Votre position : ',
      'it': 'La tua posizione: ',
    },
    'nearby_mosques_searching_map': {
      'ar': 'جاري فتح الخريطة للبحث عن: ',
      'en': 'Opening map to search for: ',
      'fr': 'Ouverture de la carte pour : ',
      'it': 'Apertura mappa per cercare: ',
    },

    // Islamic Events Screen
    'events_page_title': {
      'ar': 'التقويم والمناسبات الإسلامية',
      'en': 'Islamic Calendar & Events',
      'fr': 'Calendrier & Événements Islamiques',
      'it': 'Calendario ed Eventi Islamici',
    },
    'events_today_hijri': {
      'ar': 'اليوم في التقويم الهجري',
      'en': 'Today in Hijri Calendar',
      'fr': 'Aujourd\'hui dans le Calendrier Hégirien',
      'it': 'Oggi nel Calendario Hijri',
    },
    'events_blessed_day': {
      'ar': 'يوم مبارك وطاعة متقبلة بإذن الله',
      'en': 'A blessed day and accepted deeds by Allah\'s will',
      'fr': 'Une journée bénie et une dévotion exaucée',
      'it': 'Un giorno benedetto e atti accettati con la volontà di Allah',
    },
    'events_major_title': {
      'ar': 'الأعياد والمناسبات الإسلامية العظمى',
      'en': 'Major Islamic Holidays & Events',
      'fr': 'Fêtes & Grands Événements Islamiques',
      'it': 'Principali Festività ed Eventi Islamici',
    },
    'events_about_title': {
      'ar': 'حول التقويم والمناسبات',
      'en': 'About Islamic Calendar',
      'fr': 'À propos du Calendrier Islamique',
      'it': 'Informazioni sul Calendario Islamico',
    },
    'events_about_desc': {
      'ar': 'يعتمد التقويم الهجري على دورات القمر، ويحدد مواقيت الشعائر والعبادات والأعياد الإسلامية المباركة.',
      'en': 'The Hijri calendar is lunar-based, determining sacred worship, fasts, and Islamic holidays.',
      'fr': 'Le calendrier hégirien se fonde sur les cycles lunaires pour rythmer les actes d\'adoration et les fêtes.',
      'it': 'Il calendario Hijri si basa sui cicli lunari e determina orari di culto, digiuni e festività sacre.',
    },
    // Quran Translation & Reader
    'quran_translation_toggle': {
      'ar': 'عرض الترجمة',
      'en': 'Show Translation',
      'fr': 'Afficher la Traduction',
      'it': 'Mostra Traduzione',
      'es': 'Mostrar traducción',
      'de': 'Übersetzung anzeigen',
      'tr': 'Tercümeyi Göster',
    },
    'quran_translation_loading': {
      'ar': 'جاري تحميل الترجمة المعتمدة...',
      'en': 'Loading verified translation...',
      'fr': 'Chargement de la traduction vérifiée...',
      'it': 'Caricamento della traduzione verificata...',
      'es': 'Cargando traducción verificada...',
      'de': 'Verifizierte Übersetzung wird geladen...',
      'tr': 'Doğrulanmış tercüme yükleniyor...',
    },
    'quran_translation_edition': {
      'ar': 'الترجمة المعتمدة',
      'en': 'Verified Translation',
      'fr': 'Traduction Vérifiée',
      'it': 'Traduzione Verificata',
      'es': 'Traducción verificada',
      'de': 'Verifizierte Übersetzung',
      'tr': 'Doğrulanmış Tercüme',
    },

    // Support, Feedback & App Updates
    'settings_support_header': {
      'ar': 'التحديثات والتطوير والدعم',
      'en': 'Updates & Community Support',
      'fr': 'Mises à jour et Support',
    },
    'settings_check_updates_title': {
      'ar': 'التحقق من التحديثات',
      'en': 'Check for Updates',
      'fr': 'Vérifier les mises à jour',
    },
    'settings_check_updates_subtitle': {
      'ar': 'فحص أحدث إصدار لمحراب وتحديثات أصوات الأذان والمواقيت',
      'en': 'Check for the latest Mihrab release, Adhan sounds, and prayer fixes',
      'fr': 'Vérifier la dernière version de Mihrab, appels de prière et horaires',
    },
    'settings_report_bug_title': {
      'ar': 'بلّغ عن خطأ',
      'en': 'Report a Bug',
      'fr': 'Signaler un bug',
    },
    'settings_report_bug_subtitle': {
      'ar': 'مساعدتنا في إصلاح أي مشكلة تقنية أو خلل في الأذان والتنبيهات',
      'en': 'Help us fix technical issues, notification bugs, or audio errors',
      'fr': 'Aidez-nous à corriger les anomalies techniques ou de notification',
    },
    'settings_suggest_feature_title': {
      'ar': 'اقترح ميزة جديدة',
      'en': 'Request a Feature',
      'fr': 'Suggérer une fonctionnalité',
    },
    'settings_suggest_feature_subtitle': {
      'ar': 'شاركنا أفكارك لتطوير محراب وإضافة قراء أو خدمات إسلامية جديدة',
      'en': 'Share your ideas to improve Mihrab or request new reciters and features',
      'fr': 'Partagez vos idées pour enrichir Mihrab ou suggérer de nouveaux récitateurs',
    },
    'settings_current_version': {
      'ar': 'الإصدار الحالي',
      'en': 'Current Version',
      'fr': 'Version actuelle',
    },
    'settings_latest_version_dialog_title': {
      'ar': 'تطبيق محراب محدث بالكامل',
      'en': 'Mihrab is Up to Date',
      'fr': 'Mihrab est à jour',
    },
    'settings_latest_version_dialog_msg': {
      'ar': 'أنت تستخدم أحدث إصدار متوفر لتطبيق محراب مع جميع الميزات المحدثة.',
      'en': 'You are already using the latest available release of Mihrab with all active features.',
      'fr': 'Vous utilisez déjà la dernière version disponible de Mihrab avec toutes ses fonctionnalités.',
    },
    'settings_update_available_title': {
      'ar': 'يتوفر إصدار جديد لمحراب!',
      'en': 'New Update Available!',
      'fr': 'Nouvelle mise à jour disponible !',
    },
    'settings_update_now_btn': {
      'ar': 'تحديث الآن',
      'en': 'Update Now',
      'fr': 'Mettre à jour',
    },
    'settings_check_now_btn': {
      'ar': 'فحص الآن',
      'en': 'Check Now',
      'fr': 'Vérifier',
    },
    'settings_checking_updates': {
      'ar': 'جاري التحقق من التحديثات...',
      'en': 'Checking for updates...',
      'fr': 'Vérification des mises à jour...',
    },

    // Theme & Appearance
    'theme_name_emerald': {
      'ar': 'الأخضر الزمردي الأندلسي (الافتراضي)',
      'en': 'Andalusian Emerald (Default)',
      'fr': 'Émeraude Andalouse (Par défaut)',
    },
    'theme_name_royal_blue': {
      'ar': 'الأزرق الملكي القرطبي',
      'en': 'Cordoban Royal Blue',
      'fr': 'Bleu Royal de Cordoue',
    },
    'theme_name_amber_desert': {
      'ar': 'الصحراوي الذهبي (الرمال والواحات)',
      'en': 'Sahara Gold (Oasis & Dunes)',
      'fr': 'Or Saharien (Oasis & Dunes)',
    },
    'theme_name_midnight': {
      'ar': 'الأسود والذهبي الفاخر',
      'en': 'Luxury Black & Gold',
      'fr': 'Noir & Or Luxueux',
    },

    // Adhan Voice Names & Locations
    'adhan_constantine_algeria_name': {
      'ar': 'أذان قسنطينة (عاصمة الشرق الجزائري)',
      'en': 'Constantine Adhan (Eastern Algeria)',
      'fr': 'Adhan de Constantine (Est Algérien)',
    },
    'adhan_constantine_algeria_desc': {
      'ar': 'أذان قسنطيني أصيل - الحاج سليمان مختار',
      'en': 'Authentic Constantine Adhan - Haj Sulaiman Mukhtar',
      'fr': 'Adhan constantinois authentique - Hadj Slimane Mokhtar',
    },
    'adhan_tlemcen_algeria_name': {
      'ar': 'أذان فجر تلمسان (المدينة العتيقة)',
      'en': 'Tlemcen Fajr Adhan (Ancient City)',
      'fr': 'Adhan de Tlemcen pour le Fajr',
    },
    'adhan_tlemcen_algeria_desc': {
      'ar': 'أذان فجر مغاربي عذب ونادر من تلمسان',
      'en': 'Rare melodious Maghrebi Fajr Adhan from Tlemcen',
      'fr': 'Rare et mélodieux Adhan du Fajr de Tlemcen',
    },
    'adhan_waled_mahzas_name': {
      'ar': 'أذان الشيخ وليد مهساس (الجزائر)',
      'en': 'Sheikh Walid Mehsas (Algeria)',
      'fr': 'Cheikh Walid Mehsas (Algérie)',
    },
    'adhan_waled_mahzas_desc': {
      'ar': 'صوت خاشع ومؤثر من الجزائر',
      'en': 'Touching Algerian Adhan recitation',
      'fr': "Appel émouvant d'Algérie",
    },
    'adhan_zitouna_tunisia_name': {
      'ar': 'أذان جامع الزيتونة المعمور (تونس)',
      'en': 'Al-Zaytouna Mosque Adhan (Tunisia)',
      'fr': 'Adhan de la Mosquée Zitouna (Tunisie)',
    },
    'adhan_zitouna_tunisia_desc': {
      'ar': 'الأذان التونسي المغاربي الخاشع',
      'en': 'Reverent Tunisian Maghrebi Adhan',
      'fr': 'Adhan maghrébin tunisien recueilli',
    },
    'adhan_qarawiyyin_morocco_name': {
      'ar': 'أذان جامع القرويين (فاس - المغرب)',
      'en': 'Al-Qarawiyyin Mosque Adhan (Fez - Morocco)',
      'fr': 'Adhan de la Mosquée Al Quaraouiyine (Fès - Maroc)',
    },
    'adhan_qarawiyyin_morocco_desc': {
      'ar': 'الأذان المغربي الأصيل - كمال المرعوش',
      'en': 'Authentic Moroccan Adhan - Kamal Al-Maroush',
      'fr': 'Adhan marocain authentique - Kamal El Marrouch',
    },
    'adhan_umayyad_syria_name': {
      'ar': 'أذان الجامع الأموي (دمشق - الشام)',
      'en': 'Umayyad Mosque Adhan (Damascus - Syria)',
      'fr': 'Adhan de la Mosquée des Omeyyades (Damas)',
    },
    'adhan_umayyad_syria_desc': {
      'ar': 'أذان الجامع الأموي الكبير بدمشق',
      'en': 'Adhan of the Great Umayyad Mosque in Damascus',
      'fr': 'Adhan de la Grande Mosquée des Omeyyades à Damas',
    },
    'adhan_blue_mosque_turkey_name': {
      'ar': 'أذان مسجد السلطان أحمد (إسطنبول - تركيا)',
      'en': 'Blue Mosque Adhan (Istanbul - Turkey)',
      'fr': 'Adhan de la Mosquée Bleue (Istanbul)',
    },
    'adhan_blue_mosque_turkey_desc': {
      'ar': 'أذان عثماني بالمقام الصبا',
      'en': 'Ottoman Adhan in Saba Maqam',
      'fr': 'Adhan ottoman en mode Saba',
    },
    'adhan_sheikh_zayed_uae_name': {
      'ar': 'أذان جامع الشيخ زايد الكبير (أبوظبي)',
      'en': 'Sheikh Zayed Grand Mosque Adhan (Abu Dhabi)',
      'fr': 'Adhan de la Grande Mosquée Cheikh Zayed (Abou Dabi)',
    },
    'adhan_sheikh_zayed_uae_desc': {
      'ar': 'أذان مهيب خاشع من الإمارات',
      'en': 'Majestic reverent Adhan from UAE',
      'fr': 'Majestueux Adhan des Émirats',
    },
    'adhan_qatami_name': {
      'ar': 'أذان الشيخ ناصر القطامي',
      'en': 'Sheikh Nasser Al-Qatami',
      'fr': 'Cheikh Nasser Al-Qatami',
    },
    'adhan_qatami_desc': {
      'ar': 'أذان نجد الشجي والمؤثر',
      'en': 'Melodious Riyadh Adhan',
      'fr': 'Adhan mélodieux de Riyad',
    },
    'adhan_custom_label': {
      'ar': 'أذان مخصص مضاف',
      'en': 'Custom added Adhan',
      'fr': 'Adhan personnalisé ajouté',
    },
    'adhan_standard_label': {
      'ar': 'أذان معتمد',
      'en': 'Standard Adhan',
      'fr': 'Adhan standard',
    },

    // Settings Screen Extras
    'settings_startup_recitation_title': {
      'ar': 'تلاوة بداية التطبيق',
      'en': 'Startup Verse Recitation',
      'fr': 'Récitation au Démarrage',
    },
    'settings_startup_recitation_desc': {
      'ar': 'تشغيل آية المحراب بصوت الشيخ عبد الباسط عند فتح التطبيق',
      'en': 'Play Mihrab verse by Sheikh Abdulbasit when opening app',
      'fr': "Récitation du verset de Mihrab par Cheikh Abdulbasit à l'ouverture",
    },
    'settings_add_custom_adhan_btn': {
      'ar': 'إضافة صوت أذان آخر ➕',
      'en': 'Add another Adhan sound ➕',
      'fr': 'Ajouter un autre Adhan ➕',
    },
    'settings_dnd_not_granted_title': {
      'ar': 'إذن كتم الصوت غير ممنوح في نظام أندرويد',
      'en': 'Do Not Disturb permission not granted on Android',
      'fr': 'Autorisation « Ne pas déranger » non accordée sur Android',
    },
    'settings_dnd_not_granted_desc': {
      'ar': 'لكي يعمل الكتم التلقائي بنجاح، يجب منح التطبيق إذن «الوصول إلى عدم الإزعاج» من إعدادات الهاتف.',
      'en': 'For auto-silence to work, grant the app "Do Not Disturb" access in phone settings.',
      'fr': 'Pour que le mode silencieux fonctionne, autorisez « Ne pas déranger » dans les paramètres.',
    },
    'settings_grant_dnd_btn': {
      'ar': 'منح إذن كتم الصوت في إعدادات النظام ⚙️',
      'en': 'Grant DND Permission in System Settings ⚙️',
      'fr': "Accorder l'autorisation dans les paramètres ⚙️",
    },
    'settings_dnd_granted': {
      'ar': 'إذن كتم الصوت مفعّل في النظام - الوضع الصامت جاهز للعمل.',
      'en': 'DND permission active - Silent mode is ready.',
      'fr': 'Autorisation active - Le mode silencieux est prêt.',
    },
    'settings_silent_type_label': {
      'ar': 'نوع الوضع أثناء الصلاة:',
      'en': 'Mode type during prayer:',
      'fr': 'Type de mode pendant la prière :',
    },
    'settings_silent_mode_full': {
      'ar': 'صامت تماماً 🔕',
      'en': 'Completely Silent 🔕',
      'fr': 'Totalement Silencieux 🔕',
    },
    'settings_silent_mode_vibrate': {
      'ar': 'اهتزاز فقط 📳',
      'en': 'Vibrate Only 📳',
      'fr': 'Vibreur Uniquement 📳',
    },
    'settings_silent_duration_label': {
      'ar': 'مدة كتم الصوت بعد الأذان:',
      'en': 'Silence duration after Adhan:',
      'fr': "Durée du mode silencieux après l'Adhan :",
    },
    'settings_testing_silent': {
      'ar': 'جاري التجربة (الهاتف مكتوم الآن)...',
      'en': 'Testing (Phone silenced now)...',
      'fr': 'Test en cours (Téléphone silencieux)...',
    },
    'settings_test_silent_label': {
      'ar': 'تجربة كتم الصوت الآن (لمدة 5 ثوانٍ) 🧪',
      'en': 'Test Silent Mode Now (for 5 seconds) 🧪',
      'fr': 'Tester le mode silencieux (pendant 5 s) 🧪',
    },
    'settings_auto_adhkar_title': {
      'ar': 'تفعيل أذكار الشاشة التلقائية',
      'en': 'Enable Auto Screen Dhikr',
      'fr': "Activer les Rappels Automatiques à l'Écran",
    },
    'settings_auto_adhkar_desc': {
      'ar': 'إظهار ذكر أو دعاء مأثور على شاشة الهاتف دورياً أثناء استخدام الهاتف لتظل رطباً بذكر الله',
      'en': 'Periodically display authentic Dhikr on screen while browsing to keep remembering Allah',
      'fr': "Afficher périodiquement des invocations à l'écran pour garder le souvenir d'Allah",
    },
    'settings_auto_adhkar_enabled_toast': {
      'ar': 'تم تفعيل أذكار الشاشة التلقائية 📿',
      'en': 'Auto Screen Dhikr enabled 📿',
      'fr': "Rappels automatiques à l'écran activés 📿",
    },
    'settings_auto_adhkar_interval_label': {
      'ar': 'فترة التكرار الزمني:',
      'en': 'Repeat interval:',
      'fr': 'Intervalle de répétition :',
    },
    'settings_customize_adhkar_btn': {
      'ar': 'تخصيص مكتبة الأذكار وإضافة أدعية خاصة',
      'en': 'Customize Dhikr Library & Add Prayers',
      'fr': "Personnaliser la bibliothèque d'invocations",
    },
    'minute_x': {
      'ar': 'دقيقة',
      'en': 'min',
      'fr': 'min',
    },
    'every_x_minutes': {
      'ar': 'كل {0} دقيقة',
      'en': 'Every {0} min',
      'fr': 'Toutes les {0} min',
    },
    'wilaya_prefix': {
      'ar': 'ولاية',
      'en': 'Province',
      'fr': 'Wilaya',
    },
    'commune_prefix': {
      'ar': 'بلدية',
      'en': 'Municipality',
      'fr': 'Commune',
    },

    // Quran Card Creator Screen
    'card_creator_title': {
      'ar': 'صانع ومشارك البطاقات القرآنية',
      'en': 'Quranic Card Maker & Sharing',
      'fr': 'Créateur & Partage de Cartes Coraniques',
    },
    'card_share_btn': {
      'ar': 'مشاركة عبر التطبيقات',
      'en': 'Share via Apps',
      'fr': 'Partager via les Applications',
    },
    'card_colors_header': {
      'ar': 'ألوان وخلفية البطاقة',
      'en': 'Card Colors & Background',
      'fr': 'Couleurs & Arrière-plan de la Carte',
    },
    'card_format_header': {
      'ar': 'تنسيق البطاقة',
      'en': 'Card Formatting',
      'fr': 'Formatage de la Carte',
    },
    'card_content_header': {
      'ar': 'محتوى البطاقة (آيات، أحاديث، نص مخصص)',
      'en': 'Card Content (Verses, Hadiths, Custom)',
      'fr': 'Contenu de la Carte (Versets, Hadiths, Personnalisé)',
    },
    'card_theme_emerald': {
      'ar': 'زمردي مِحراب',
      'en': 'Mihrab Emerald',
      'fr': 'Émeraude Mihrab',
    },
    'card_theme_royal_navy': {
      'ar': 'كحلي ملكي',
      'en': 'Royal Navy',
      'fr': 'Bleu Nuit Royal',
    },
    'card_theme_andalusian_garnet': {
      'ar': 'عقيق أندلسي',
      'en': 'Andalusian Garnet',
      'fr': 'Grenat Andalou',
    },
    'card_theme_sahara_night': {
      'ar': 'سواد الصحراء',
      'en': 'Sahara Night',
      'fr': 'Nuit Saharienne',
    },
    'card_theme_pure_gold': {
      'ar': 'ذهب خالص',
      'en': 'Pure Gold',
      'fr': 'Or Pur',
    },
    'card_font_size': {
      'ar': 'حجم الخط:',
      'en': 'Font size:',
      'fr': 'Taille de police :',
    },
    'size_small': {
      'ar': 'صغير',
      'en': 'Small',
      'fr': 'Petit',
    },
    'size_medium': {
      'ar': 'متوسط',
      'en': 'Medium',
      'fr': 'Moyen',
    },
    'size_large': {
      'ar': 'كبير',
      'en': 'Large',
      'fr': 'Grand',
    },
    'card_show_bismillah': {
      'ar': 'إظهار البسملة (﷽):',
      'en': 'Show Bismillah (﷽):',
      'fr': 'Afficher la Basmala (﷽) :',
    },
    'card_show_footer': {
      'ar': 'تذييل البطاقة (صدقة جارية):',
      'en': 'Card Footer (Charity notice):',
      'fr': 'Pied de page (Aumône continue) :',
    },
    'card_cat_quran': {
      'ar': 'آيات قرآنية',
      'en': 'Quranic Verses',
      'fr': 'Versets Coraniques',
    },
    'card_cat_hadith': {
      'ar': 'أحاديث نبوية',
      'en': 'Prophetic Hadiths',
      'fr': 'Hadiths Prophétiques',
    },
    'card_cat_supplications': {
      'ar': 'أدعية مأثورة',
      'en': 'Supplications & Adhkar',
      'fr': 'Invocations & Adhkar',
    },
    'card_cat_custom': {
      'ar': 'اكتب نصك الخاص',
      'en': 'Write Custom Text',
      'fr': 'Rédiger Votre Propre Texte',
    },
    'card_custom_text_label': {
      'ar': 'نص البطاقة الخاص بك:',
      'en': 'Your custom card text:',
      'fr': 'Votre texte de carte :',
    },
    'card_custom_text_hint': {
      'ar': 'اكتب الآية، الحديث، أو الدعاء الذي ترغب بتصميمه ومشاركته...',
      'en': 'Type the verse, hadith, or prayer to design and share...',
      'fr': 'Saisissez le verset, hadith ou invocation à concevoir...',
    },
    'card_custom_ref_label': {
      'ar': 'المصدر أو المرجع (اختياري):',
      'en': 'Source or reference (optional):',
      'fr': 'Source ou référence (optionnel) :',
    },
    'card_custom_ref_hint': {
      'ar': 'مثال: [سورة البقرة: 255] أو [صحيح مسلم]',
      'en': 'e.g. [Surah Al-Baqarah: 255] or [Sahih Muslim]',
      'fr': 'Ex. : [Sourate Al-Baqarah : 255] ou [Sahih Muslim]',
    },
    'card_error_empty': {
      'ar': 'الرجاء إدخال نص للبطاقة قبل المشاركة',
      'en': 'Please enter card text before sharing',
      'fr': 'Veuillez saisir un texte avant de partager',
    },
    'card_share_subject': {
      'ar': 'بطاقة إسلامية - تطبيق مِـحْـرَابْ الجزائر',
      'en': 'Islamic Card - Mihrab App',
      'fr': 'Carte Islamique - Application Mihrab',
    },
    'card_copied': {
      'ar': 'تم نسخ محتوى البطاقة للحافظة لمشاركتها 📋',
      'en': 'Card text copied to clipboard 📋',
      'fr': 'Texte de la carte copié dans le presse-papiers 📋',
    },
    'card_copied_full': {
      'ar': 'تم نسخ محتوى البطاقة بالكامل إلى الحافظة بنجاح 📋✨',
      'en': 'Card content fully copied to clipboard 📋✨',
      'fr': 'Contenu de la carte copié avec succès 📋✨',
    },
    'card_preview_placeholder': {
      'ar': '«أدخل نص البطاقة القرآنية هنا»',
      'en': '«Enter card text here»',
      'fr': '«Saisissez le texte de la carte ici»',
    },
    'card_footer_text': {
      'ar': 'صدقة جارية — تطبيق مِـحْـرَابْ الجزائر',
      'en': 'Sadaqah Jariyah — Mihrab App',
      'fr': 'Aumône continue — Application Mihrab',
    },

    // Live Broadcast Screen
    'live_broadcast_title': {
      'ar': 'البث المباشر الإسلامي',
      'en': 'Islamic Live Broadcast',
      'fr': 'Direct Islamique & Radios',
    },
    'live_badge_24_7': {
      'ar': 'مباشر 24/7',
      'en': 'Live 24/7',
      'fr': 'En direct 24/7',
    },
    'live_stations_header': {
      'ar': 'إذاعات وقنوات حية',
      'en': 'Live Radios & Channels',
      'fr': 'Radios & Chaînes en Direct',
    },
    'live_stations_desc': {
      'ar': 'استمع مباشرة إلى إذاعة القرآن الكريم الجزائرية وبث الحرم المكي والحرم النبوي الشريف بأعلى جودة صوت نقية.',
      'en': 'Listen live to Algerian Quran Radio, Makkah Haram, and Madinah Holy Mosque broadcasts in crystal clear audio.',
      'fr': 'Écoutez en direct la radio coranique algérienne et les diffusions des Saintes Mosquées de La Mecque et Médine.',
    },
    'live_stream_btn': {
      'ar': 'بث حي',
      'en': 'Live Stream',
      'fr': 'Direct',
    },
    'live_watch_video_btn': {
      'ar': 'مشاهدة البث المرئي المباشر (فيديو 24/7) 📺',
      'en': 'Watch Live Video Stream (24/7) 📺',
      'fr': 'Regarder la diffusion vidéo en direct (24/7) 📺',
    },
    'live_status_playing': {
      'ar': 'البث المباشر يعمل الآن 🔴',
      'en': 'Live stream is playing now 🔴',
      'fr': 'Diffusion en direct en cours 🔴',
    },
    'live_status_connecting': {
      'ar': 'جاري الاتصال بالبث...',
      'en': 'Connecting to stream...',
      'fr': 'Connexion au direct en cours...',
    },
    'live_stop_tooltip': {
      'ar': 'إيقاف البث',
      'en': 'Stop Broadcast',
      'fr': 'Arrêter le direct',
    },
    'live_opening_video': {
      'ar': 'جاري فتح البث المرئي المباشر... 📺',
      'en': 'Opening live video stream... 📺',
      'fr': 'Ouverture du flux vidéo en direct... 📺',
    },
    'live_open_video_failed': {
      'ar': 'تعذر فتح البث تلقائياً. يرجى التأكد من توفر تطبيق YouTube أو متصفح إنترنت.',
      'en': 'Unable to open video stream. Ensure YouTube or a web browser is installed.',
      'fr': "Impossible d'ouvrir le direct vidéo. Vérifiez YouTube ou un navigateur.",
    },
    'live_connecting': {
      'ar': 'جاري الاتصال بالبث المباشر: ',
      'en': 'Connecting to live broadcast: ',
      'fr': 'Connexion au direct : ',
    },
    'live_connection_error': {
      'ar': 'تعذر الاتصال بالبث المباشر حالياً، يرجى التحقق من اتصال الإنترنت ⚠️',
      'en': 'Unable to connect to live stream, please check your internet connection ⚠️',
      'fr': 'Impossible de se connecter au direct, vérifiez votre connexion Internet ⚠️',
    },
    'live_stopped': {
      'ar': 'تم إيقاف البث المباشر ⏹️',
      'en': 'Live broadcast stopped ⏹️',
      'fr': 'Diffusion en direct arrêtée ⏹️',
    },

    // Channel Titles, Subtitles, Locations
    'live_channel_algeria_coran_title': {
      'ar': 'إذاعة القرآن الكريم الجزائرية',
      'en': 'Algerian Holy Quran Radio',
      'fr': 'Radio Algérienne du Saint Coran',
    },
    'live_channel_algeria_coran_sub': {
      'ar': 'البوابة الرسمية للبث المباشر لإذاعة القرآن الجزائرية والتلاوات',
      'en': 'Official live stream of Algerian Quran Radio and recitations',
      'fr': 'Portail officiel du direct de la radio coranique algérienne',
    },
    'live_channel_algeria_coran_loc': {
      'ar': 'الجزائر العاصمة 🇩🇿',
      'en': 'Algiers 🇩🇿',
      'fr': 'Alger 🇩🇿',
    },
    'live_channel_makkah_live_title': {
      'ar': 'قناة القرآن الكريم - مكة المكرمة',
      'en': 'Holy Quran TV - Makkah',
      'fr': 'Chaîne du Saint Coran - La Mecque',
    },
    'live_channel_makkah_live_sub': {
      'ar': 'بث حي ومباشر من المسجد الحرام بمكة المكرمة على مدار الساعة 🕋',
      'en': '24/7 live stream from the Grand Mosque in Makkah 🕋',
      'fr': 'Direct 24/7 de la Grande Mosquée de La Mecque 🕋',
    },
    'live_channel_makkah_live_loc': {
      'ar': 'مكة المكرمة 🕋',
      'en': 'Makkah Al-Mukarramah 🕋',
      'fr': 'La Mecque 🕋',
    },
    'live_channel_general_quran_title': {
      'ar': 'إذاعة القرآن الكريم العامة',
      'en': 'General Holy Quran Radio',
      'fr': 'Radio Générale du Saint Coran',
    },
    'live_channel_general_quran_sub': {
      'ar': 'تلاوات متواصلة على مدار 24 ساعة بأصوات كبار قراء العالم الإسلامي',
      'en': '24/7 continuous recitations by renowned Islamic reciters',
      'fr': 'Récitations 24/7 des grands récitateurs du monde musulman',
    },
    'live_channel_general_quran_loc': {
      'ar': 'العالم الإسلامي 🕌',
      'en': 'Islamic World 🕌',
      'fr': 'Monde Islamique 🕌',
    },
    'live_channel_minshawi_radio_title': {
      'ar': 'إذاعة الشيخ محمد صديق المنشاوي',
      'en': 'Sheikh Muhammad Siddiq Al-Minshawi Radio',
      'fr': 'Radio Cheikh Al-Minshawi',
    },
    'live_channel_minshawi_radio_sub': {
      'ar': 'تلاوات خاشعة ومجودة على مدار الساعة للصوت الباكي',
      'en': 'Reverent tajweed recitations around the clock by the weeping voice',
      'fr': 'Récitations pieuses et émouvantes en continu',
    },
    'live_channel_minshawi_radio_loc': {
      'ar': 'مصر والعالم الإسلامي 🎙️',
      'en': 'Egypt & Islamic World 🎙️',
      'fr': 'Égypte & Monde Islamique 🎙️',
    },
    'live_channel_hussary_radio_title': {
      'ar': 'إذاعة الشيخ محمود خليل الحصري',
      'en': 'Sheikh Mahmoud Khalil Al-Hussary Radio',
      'fr': 'Radio Cheikh Al-Hussary',
    },
    'live_channel_hussary_radio_sub': {
      'ar': 'تلاوات محكمة ومتقنة على مدار الساعة لشيخ المقارئ المصرية',
      'en': 'Flawless tajweed recitations by the dean of Egyptian reciters',
      'fr': 'Récitations impeccables du doyen des récitateurs égyptiens',
    },
    'live_channel_hussary_radio_loc': {
      'ar': 'مصر والعالم الإسلامي 🎙️',
      'en': 'Egypt & Islamic World 🎙️',
      'fr': 'Égypte & Monde Islamique 🎙️',
    },
    'live_channel_maher_radio_title': {
      'ar': 'إذاعة الشيخ ماهر المعيقلي',
      'en': 'Sheikh Maher Al-Muaiqly Radio',
      'fr': 'Radio Cheikh Maher Al-Muaiqly',
    },
    'live_channel_maher_radio_sub': {
      'ar': 'تلاوات ندية خاشعة لإمام وخطيب المسجد الحرام',
      'en': 'Reverent recitations by the Imam of the Grand Mosque',
      'fr': "Récitations émouvantes de l'imam de la Mosquée Sacrée",
    },
    'live_channel_maher_radio_loc': {
      'ar': 'مكة المكرمة 🕋',
      'en': 'Makkah Al-Mukarramah 🕋',
      'fr': 'La Mecque 🕋',
    },
    'live_channel_alajmy_radio_title': {
      'ar': 'إذاعة الشيخ أحمد العجمي',
      'en': 'Sheikh Ahmad Al-Ajmy Radio',
      'fr': 'Radio Cheikh Ahmad Al-Ajmy',
    },
    'live_channel_alajmy_radio_sub': {
      'ar': 'تلاوات مرتلة عذبة متواصلة على مدار اليوم',
      'en': 'Melodious tartil recitations throughout the day',
      'fr': 'Récitations mélodieuses en continu',
    },
    'live_channel_alajmy_radio_loc': {
      'ar': 'العالم الإسلامي 🎙️',
      'en': 'Islamic World 🎙️',
      'fr': 'Monde Islamique 🎙️',
    },
    'live_channel_albaqarah_radio_title': {
      'ar': 'إذاعة سورة البقرة المباركة',
      'en': 'Surah Al-Baqarah Radio',
      'fr': 'Radio Sourate Al-Baqarah',
    },
    'live_channel_albaqarah_radio_sub': {
      'ar': 'بث متواصل لسورة البقرة لطرد الشياطين وبركة البيوت',
      'en': 'Continuous recitation of Surah Al-Baqarah for home blessing',
      'fr': 'Diffusion continue de Sourate Al-Baqarah pour la bénédiction du foyer',
    },
    'live_channel_albaqarah_radio_loc': {
      'ar': 'بث متواصل 📖',
      'en': 'Continuous Broadcast 📖',
      'fr': 'Diffusion Continue 📖',
    },
    'live_channel_roqiah_radio_title': {
      'ar': 'إذاعة الرقية الشرعية',
      'en': 'Ruqyah Shariyyah Radio',
      'fr': 'Radio Roqya Chariya',
    },
    'live_channel_roqiah_radio_sub': {
      'ar': 'آيات الرقية الشرعية والأدعية النبوية للشفاء والحفظ',
      'en': 'Verses and prophetic prayers for healing and protection',
      'fr': 'Versets et invocations pour la guérison et la protection',
    },
    'live_channel_roqiah_radio_loc': {
      'ar': 'بث متواصل 🛡️',
      'en': 'Continuous Broadcast 🛡️',
      'fr': 'Diffusion Continue 🛡️',
    },
    'live_channel_adhkar_radio_title': {
      'ar': 'إذاعة أذكار الصباح والمساء',
      'en': 'Morning & Evening Adhkar Radio',
      'fr': 'Radio Invocations Matin & Soir',
    },
    'live_channel_adhkar_radio_sub': {
      'ar': 'حصن المسلم وأذكار اليوم والليلة بأصوات ندية',
      'en': 'Fortress of the Muslim: daily dhikr in serene voices',
      'fr': 'La citadelle du musulman : invocations du jour et de la nuit',
    },
    'live_channel_adhkar_radio_loc': {
      'ar': 'بث متواصل 📿',
      'en': 'Continuous Broadcast 📿',
      'fr': 'Diffusion Continue 📿',
    },
    'live_channel_tafsir_radio_title': {
      'ar': 'إذاعة تفسير القرآن الكريم',
      'en': 'Quran Tafsir Radio',
      'fr': 'Radio Tafsir du Coran',
    },
    'live_channel_tafsir_radio_sub': {
      'ar': 'المختصر في تفسير القرآن الكريم وتوضيح معاني الآيات',
      'en': 'Concise explanation and meanings of the Holy Quran',
      'fr': 'Explication concise des sens des versets du Coran',
    },
    'live_channel_tafsir_radio_loc': {
      'ar': 'الإذاعة التعليمية 📖',
      'en': 'Educational Radio 📖',
      'fr': 'Radio Éducative 📖',
    },

    // Auto Adhkar Screen
    'auto_adhkar_page_title': {
      'ar': 'أذكار وأدعية الشاشة التلقائية',
      'en': 'Auto Screen Dhikr & Duas',
      'fr': 'Rappels & Invocations Automatiques',
    },
    'auto_adhkar_add_tooltip': {
      'ar': 'إضافة ذكر أو دعاء مخصص',
      'en': 'Add custom Dhikr or supplication',
      'fr': 'Ajouter une invocation personnalisée',
    },
    'auto_adhkar_add_btn': {
      'ar': 'إضافة ذكر جديد',
      'en': 'Add New Dhikr',
      'fr': 'Ajouter un Dhikr',
    },
    'auto_adhkar_card_title': {
      'ar': 'ظهور الأذكار التلقائي على الشاشة',
      'en': 'Automatic Screen Dhikr Popups',
      'fr': 'Affichage Automatique des Invocations',
    },
    'auto_adhkar_card_desc': {
      'ar': 'تذكيرك بذكر الله والأدعية أثناء تصفح الهاتف والإنترنت',
      'en': 'Reminding you of Allah while browsing your phone & web',
      'fr': "Rappels spirituels pendant l'utilisation de votre téléphone",
    },
    'auto_adhkar_enabled_prefix': {
      'ar': 'الأذكار المفعلة: ',
      'en': 'Active Dhikrs: ',
      'fr': 'Invocations actives : ',
    },
    'of_total': {
      'ar': 'من',
      'en': 'of',
      'fr': 'sur',
    },
    'auto_adhkar_test_btn': {
      'ar': 'اختبر الظهور الآن',
      'en': 'Test Popup Now',
      'fr': "Tester l'Affichage",
    },
    'auto_adhkar_settings_header': {
      'ar': 'إعدادات التكرار والتنبيه',
      'en': 'Interval & Sound Settings',
      'fr': 'Paramètres de Fréquence & Alerte',
    },
    'auto_adhkar_freq_title': {
      'ar': 'معدل ظهور الذكر على الشاشة أثناء التصفح:',
      'en': 'Frequency of Dhikr appearance:',
      'fr': "Fréquence d'affichage du dhikr :",
    },
    'freq_5_min': {
      'ar': 'كل 5 دقائق (سريع)',
      'en': 'Every 5 min (Fast)',
      'fr': 'Toutes les 5 min (Rapide)',
    },
    'freq_10_min': {
      'ar': 'كل 10 دقائق',
      'en': 'Every 10 min',
      'fr': 'Toutes les 10 min',
    },
    'freq_15_min': {
      'ar': 'كل 15 دقيقة (مستحسن)',
      'en': 'Every 15 min (Recommended)',
      'fr': 'Toutes les 15 min (Recommandé)',
    },
    'freq_30_min': {
      'ar': 'كل 30 دقيقة',
      'en': 'Every 30 min',
      'fr': 'Toutes les 30 min',
    },
    'freq_60_min': {
      'ar': 'كل ساعة',
      'en': 'Every hour',
      'fr': 'Toutes les heures',
    },
    'freq_120_min': {
      'ar': 'كل ساعتين',
      'en': 'Every 2 hours',
      'fr': 'Toutes les 2 heures',
    },
    'auto_adhkar_sound_title': {
      'ar': 'نغمة تنبيه صوتية عند ظهور الذكر',
      'en': 'Sound alert when Dhikr appears',
      'fr': "Sonnerie d'alerte à l'affichage",
    },
    'auto_adhkar_sound_desc': {
      'ar': 'تشغيل صوت هادئ مع الإشعار المنبثق',
      'en': 'Play a gentle tone with the popup notification',
      'fr': 'Émettre un son doux avec la notification',
    },
    'auto_adhkar_select_list_header': {
      'ar': 'اختر الأذكار والأدعية التي تظهر لك',
      'en': 'Select Dhikrs & Duas to Display',
      'fr': 'Choisissez les Invocations à Afficher',
    },
    'select_all': {
      'ar': 'تحديد الكل',
      'en': 'Select All',
      'fr': 'Tout sélectionner',
    },
    'deselect_all': {
      'ar': 'إلغاء الكل',
      'en': 'Deselect All',
      'fr': 'Tout désélectionner',
    },
    'all_filter': {
      'ar': 'الكل',
      'en': 'All',
      'fr': 'Tous',
    },
    'auto_adhkar_user_added': {
      'ar': 'مضاف من طرفك',
      'en': 'Added by you',
      'fr': 'Ajouté par vous',
    },
    'auto_adhkar_preview_tooltip': {
      'ar': 'معاينة الظهور',
      'en': 'Preview Popup',
      'fr': "Aperçu de l'affichage",
    },
    'auto_adhkar_delete_tooltip': {
      'ar': 'حذف الذكر المخصص',
      'en': 'Delete Custom Dhikr',
      'fr': 'Supprimer ce dhikr',
    },
    'auto_adhkar_preview_title': {
      'ar': 'معاينة الذكر المنبثق على الشاشة',
      'en': 'Screen Popup Preview',
      'fr': "Aperçu du Rappel à l'Écran",
    },
    'ok': {
      'ar': 'حسناً',
      'en': 'OK',
      'fr': "D'accord",
    },
    'auto_adhkar_dialog_add_title': {
      'ar': 'إضافة ذكر أو دعاء مخصص',
      'en': 'Add Custom Dhikr or Prayer',
      'fr': 'Ajouter une invocation personnalisée',
    },
    'auto_adhkar_dialog_prompt': {
      'ar': 'اكتب الذكر أو الدعاء الذي ترغب أن يظهر لك على شاشة هاتفك:',
      'en': 'Type the Dhikr or supplication you wish to appear on your screen:',
      'fr': 'Saisissez le dhikr ou l\'invocation que vous souhaitez voir apparaître :',
    },
    'auto_adhkar_dialog_hint': {
      'ar': 'مثال: اللَّهُمَّ رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً...',
      'en': 'e.g. Allahumma Rabbana atina fid-dunya hasanah...',
      'fr': 'Ex. : Allahoumma Rabbana atina fid-dounya hasanah...',
    },
    'category_label': {
      'ar': 'التصنيف:',
      'en': 'Category:',
      'fr': 'Catégorie :',
    },
    'auto_adhkar_virtue_label': {
      'ar': 'الفضل أو الملاحظة (اختياري)',
      'en': 'Virtue or Note (Optional)',
      'fr': 'Bienfait ou Note (Optionnel)',
    },
    'auto_adhkar_virtue_hint': {
      'ar': 'مثال: دعاء مبارك لتفريج الهموم',
      'en': 'e.g. Blessed supplication for relief of distress',
      'fr': 'Ex. : Invocation bénie pour dissiper les soucis',
    },
    'auto_adhkar_save_btn': {
      'ar': 'حفظ الذكر',
      'en': 'Save Dhikr',
      'fr': 'Enregistrer',
    },
    'auto_adhkar_error_empty': {
      'ar': 'يرجى كتابة نص الذكر أو الدعاء أولاً',
      'en': 'Please type the Dhikr or prayer text first',
      'fr': "Veuillez d'abord saisir le texte du dhikr",
    },
    'auto_adhkar_added_success': {
      'ar': 'تمت إضافة الذكر بنجاح وإدراجه في دورة الظهور ✅',
      'en': 'Dhikr added successfully and queued for display ✅',
      'fr': "Invocation ajoutée avec succès au cycle d'affichage ✅",
    },
    'auto_adhkar_none_enabled': {
      'ar': 'يرجى تفعيل ذكر واحد على الأقل للظهور',
      'en': 'Please enable at least one Dhikr to display',
      'fr': 'Veuillez activer au moins une invocation à afficher',
    },

    // Adhkar Categories
    'adhkar_cat_tasbih': {
      'ar': 'تسبيح وتحميد',
      'en': 'Praise & Glorification',
      'fr': 'Louange & Glorification',
    },
    'adhkar_cat_istighfar': {
      'ar': 'استغفار وتوبة',
      'en': 'Forgiveness & Repentance',
      'fr': 'Pardon & Repentir',
    },
    'adhkar_cat_prophet': {
      'ar': 'الصلاة على النبي',
      'en': 'Prayers upon the Prophet',
      'fr': 'Prières sur le Prophète',
    },
    'adhkar_cat_tawakkul': {
      'ar': 'حوقلة وتوكل',
      'en': 'Trust & Reliance on Allah',
      'fr': 'Confiance & Remise à Allah',
    },
    'adhkar_cat_relief': {
      'ar': 'تفريج الكرب',
      'en': 'Relief from Distress',
      'fr': 'Soulagement de la Détresse',
    },
    'adhkar_cat_baqiyat': {
      'ar': 'الباقيات الصالحات',
      'en': 'Enduring Good Deeds',
      'fr': 'Bonnes Œuvres Durables',
    },
    'adhkar_cat_prophetic_dua': {
      'ar': 'أدعية نبوية',
      'en': 'Prophetic Supplications',
      'fr': 'Invocations Prophétiques',
    },
    'adhkar_cat_comprehensive_dua': {
      'ar': 'أدعية جامعة',
      'en': 'Comprehensive Prayers',
      'fr': 'Invocations Complètes',
    },
    'adhkar_cat_protection': {
      'ar': 'حفظ وتحصين',
      'en': 'Protection & Refuge',
      'fr': 'Protection & Préservation',
    },
    'adhkar_cat_ease': {
      'ar': 'تيسير الأمور',
      'en': 'Facilitation of Affairs',
      'fr': 'Facilitation des Affaires',
    },
    'adhkar_cat_custom': {
      'ar': 'أدعية مخصصة',
      'en': 'Custom Supplications',
      'fr': 'Invocations Personnalisées',
    },
    'gps_auto_switch': {
      'ar': 'التحديد التلقائي عبر الأقمار الصناعية (GPS)',
      'en': 'Automatic Satellite Detection (GPS)',
      'fr': 'Détection Automatique par Satellite (GPS)',
    },
    'add': {
      'ar': 'إضافة',
      'en': 'Add',
      'fr': 'Ajouter',
    },
    'playing': {
      'ar': 'يعمل',
      'en': 'Playing',
      'fr': 'En cours',
    },
    'delete': {
      'ar': 'حذف',
      'en': 'Delete',
      'fr': 'Supprimer',
    },
    'enable': {
      'ar': 'تفعيل',
      'en': 'Enable',
      'fr': 'Activer',
    },
    'settings_prayer_notif_test': {
      'ar': 'صلاة تجريبية (فحص الإشعارات)',
      'en': 'Test Prayer (Notification Check)',
      'fr': 'Prière Test (Vérification des notifications)',
    },
    'settings_later_btn': {
      'ar': 'لاحقاً',
      'en': 'Later',
      'fr': 'Plus tard',
    },
  };

  /// Retrieves translation for [key] in [languageCode], fallback to English, Arabic, then key itself.
  static String get(String key, [String languageCode = 'ar']) {
    final langMap = _translations[key];
    if (langMap == null) return key;

    final translated = langMap[languageCode] ?? langMap['en'] ?? langMap['ar'];
    return translated ?? key;
  }

  /// Whether current language code is Right-to-Left (Arabic, Urdu, Persian)
  static bool isRtl(String languageCode) =>
      languageCode == 'ar' || languageCode == 'ur' || languageCode == 'fa';
}
