# توثيق تراخيص ومصادر الأصول الصوتية — تطبيق مِحْرَاب (Mihrab App)
**Audio Assets Licensing, Attribution & Google Play Compliance Notice**

يُوثّق هذا الملف كافة الأصول والملفات الصوتية المدمجة محلياً داخل حزمة تطبيق **«مِحْرَاب» (Mihrab App)** أو المستدعاة عبر البث السحابي، وذلك لضمان الشفافية الكاملة والتوافق التام مع سياسات الملكية الفكرية وحقوق النشر الخاصة بمتجر **Google Play** ومتجر **Apple App Store**.

---

## 1. طبيعة التطبيق والغرض من الاستخدام (Nature of Use)
تطبيق **«مِحْرَاب»** هو تطبيق إسلامي خدمي مجاني غير ربحي (خُلوّ تام من الإعلانات التجارية أو الاشتراكات المدفوعة)، يهدف إلى خدمة المصلين عبر تقديم مواقيت الصلاة، التلاوات القرآنية، والأذكار الشرعية. جميع الملفات الصوتية المستخدمة في التطبيق تندرج تحت إحدى الفئات القانونية الثلاث التالية:
1. **التراث الإسلامي العام والمشاع الإبداعي (Public Domain & Creative Commons / Waqf):** التلاوات القرآنية التاريخية وشعيرة الأذان العام المرفوعة من المساجد الجامعة، والمودعة في الأرشيفات الإسلامية المفتوحة للاستخدام الحر غير التجاري.
2. **منصات البث الإسلامي المفتوحة (Open Islamic APIs & CDNs):** منصات توفر واجهات برمجية (APIs) وروابط بث مجانية ومصرحاً بها لتطبيقات الهواتف الذكية.
3. **مؤثرات صوتية خاصة بالتطبيق (Original / Royalty-Free App Sounds):** نغمات التنبيه القصيرة المولّدة رقمياً خصيصاً لواجهة التطبيق.

---

## 2. جدول الملفات الصوتية المدمجة محلياً (Bundled Local Audio Assets)

### أ) مجلد `assets/audio/`
| اسم الملف | الحجم | الوصف والمحتوى | المصدر والترخيص (License & Attribution) |
| :--- | :--- | :--- | :--- |
| `abdulbasit_3_39.mp3` | 442 KB | تلاوة الآية 39 من سورة آل عمران: ﴿فَنَادَتْهُ الْمَلَائِكَةُ وَهُوَ قَائِمٌ يُصَلِّي فِي الْمِحْرَابِ...﴾ بصوت القارئ الشيخ عبد الباسط عبد الصمد (رحمه الله). | **ملك عام / وقف إسلامي مفتوح (Public Domain / Open Quranic Waqf)** — مأخوذ من الأرشيف القرآني المفتوح (EveryAyah / MP3Quran) المسموح بإعادة توزيعه مجاناً في التطبيقات القرآنية. |
| `mihrab_verse.mp3` | 442 KB | نسخة مطابقة لتلاوة الآية الافتتاحية (سورة آل عمران: 39) بصوت الشيخ عبد الباسط عبد الصمد لضمان التوافق عبر كافة الشاشات. | **ملك عام / وقف إسلامي مفتوح (Public Domain / Open Quranic Waqf)** — نفس مصدر وترخيص `abdulbasit_3_39.mp3`. |
| `adhan.mp3` | 666 KB | تسجيل صوت الأذان الجزائري الرسمي (صيغة MP3 مضغوطة للتشغيل السريع دون إنترنت). | **مشاع عام / شعيرة عامة (Public Broadcast / CC0-Equivalent Islamic Archive)** — مأخوذ من الأرشيف المفتوح لأصوات الأذان (`Kiwifu/adhan-mp3` / Archive.org) للاستخدام الحر غير التجاري. |
| `adhan.wav` | 4.26 MB | نسخة صوتية غير مضغوطة (WAV) من الأذان الافتراضي للتوافق مع محركات الصوت المحلية. | **مشاع عام / شعيرة عامة (Public Broadcast / Open Islamic Archive)** — نفس مصدر وترخيص `adhan.mp3`. |
| `takbeer.wav` | 339 KB | مقطع تكبيرات الأذان والعيد (الله أكبر، الله أكبر). | **مشاع عام / أرشيف إسلامي مفتوح (Public Domain / Royalty-Free Islamic Audio)** — متاح للاستخدام الحر في تطبيقات التنبيه للصلاة. |
| `notification.mp3` | 64 KB | نغمة تنبيه صوتية قصيرة وهادئة لإشعارات التطبيق (صيغة MP3). | **تسجيل رقمي خاص بالتطبيق / خالي الحقوق (Original Synthesized Chime / CC0 1.0 Public Domain)** — مؤثر صوتي مولّد برمجياً ومملوك للتطبيق. |
| `notification.wav` | 62 KB | نغمة التنبيه القصيرة بصيغة WAV للتوافق مع إشعارات النظام. | **تسجيل رقمي خاص بالتطبيق / خالي الحقوق (Original Synthesized Chime / CC0 1.0 Public Domain)**. |

### ب) مجلد موارد أندرويد الخام `android/app/src/main/res/raw/`
تُستخدم هذه الملفات حصرياً من قِبل نظام الإشعارات المحلي في أندرويد (`flutter_local_notifications` Notification Channels) لتشغيل صوت الأذان أو التنبيه عند إغلاق التطبيق:
* `res/raw/adhan.mp3` و `res/raw/athan.mp3` (666 KB): نسخة مطابقة لملف `assets/audio/adhan.mp3`.
* `res/raw/takbeer.wav` (339 KB): نسخة مطابقة لملف `assets/audio/takbeer.wav`.
* `res/raw/notification.mp3` (64 KB): نسخة مطابقة لملف `assets/audio/notification.mp3`.

---

## 3. مصادر البث الصوتي السحابي (Online Streaming Sources & APIs)

عند اتصال المستخدم بالإنترنت واختياره الاستماع إلى المصحف المرتل الكامل أو الإذاعات القرآنية أو أصوات مؤذنين إضافيين، يعتمد التطبيق على المصادر المفتوحة التالية دون تضمين ملفاتها داخل الحزمة الثنائية للتطبيق:

1. **شبكة القرآن الكريم الصوتية (MP3Quran.net Open CDN):**
   * **النطاقات المستخدمة:** `https://server*.mp3quran.net/*`
   * **الترخيص:** توفر منصة **MP3Quran.net** واجهة برمجية (API) وروابط بث مباشر مجانية ومفتوحة للمطورين لاستخدامها في التطبيقات الإسلامية غير الربحية كوقف خيري رقمي.
2. **واجهة إذاعات القرآن الكريم (QuranGo Radio API):**
   * **النطاقات المستخدمة:** `https://qurango.net/radio/*`
   * **الترخيص:** واجهة برمجية عامة مفتوحة المصدر تتيح بث إذاعات القرآن الكريم والتلاوات المتواصلة مجاناً.
3. **مستودع الأذان المفتوح (Open Adhan Audio Repository):**
   * **النطاق المستخدم:** `https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/*`
   * **الترخيص:** مستودع مفتوح يضم تسجيلات الأذان التاريخية التي دخلت في الملك العام (مثل تسجيلات الشيخ محمد رفعت، الشيخ عبد الباسط عبد الصمد، الشيخ محمود خليل الحصري، الشيخ محمود علي البنا، والشيخ أبو العينين شعيشع رحمهم الله) والتسجيلات الإذاعية العامة للأذان من المساجد الكبرى.

---

## 4. إقرار التوافق مع سياسات متجر Google Play (Google Play Policy Compliance Statement)

> **Notice for Google Play Review Team:**
> All audio files bundled within **Mihrab (`com.mihrab.algeria.mihrab_app`)** or streamed via its interfaces are strictly non-commercial religious liturgy (Islamic Call to Prayer / Adhan and Quranic Recitations) or original synthesized notification chimes (`notification.mp3` / `notification.wav`).
> - Historical Quranic recitations (e.g., Sheikh Abdul Basit Abdul Samad, Surah Ali 'Imran 3:39) and traditional Adhan recordings are part of the public Islamic heritage / Waqf and are distributed under open, non-commercial free-use terms via **Tanzil**, **EveryAyah**, and **MP3Quran.net**.
> - UI notification chimes are original synthesized audio assets dedicated to this application under **CC0 1.0 Universal (Public Domain Dedication)**.
> - No copyrighted commercial music tracks or unauthorized third-party proprietary audio recordings are bundled or monetized in this application.
