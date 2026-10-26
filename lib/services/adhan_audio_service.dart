import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdhanAudioService {
  static final AudioPlayer _player = AudioPlayer();
  static final AudioPlayer _chimePlayer = AudioPlayer();
  static final ValueNotifier<bool> isPlayingNotifier = ValueNotifier<bool>(false);

  /// روابط الأذان الأونلاين المصححة بالكامل من مستودع Kiwifu/adhan-mp3 (بدون أي رابط 404)
  static const Map<String, String> adhanOnlineUrls = {
    'algeria_grand_mosque':
        'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Waled_Mahsas_2_-_Algeria_(%D9%88%D9%84%D9%8A%D8%AF_%D9%85%D8%AD%D8%B3%D8%A7%D8%B3_-_%D8%A7%D9%84%D8%AC%D8%B2%D8%A7%D8%A6%D8%B1).mp3',
    'traditional_algerian':
        'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Riad_Al_Djazairi_-_Algeria_(%D8%B1%D9%8A%D8%A7%D8%B6_%D8%A7%D9%84%D8%AC%D8%B2%D8%A7%D8%A6%D8%B1%D9%8A_-_%D8%A7%D9%84%D8%AC%D8%B2%D8%A7%D8%A6%D8%B1).mp3',
    'constantine_algeria':
        'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Haj_Sulaiman_Mukhtar_-_Algeria_(%D8%AD%D8%A7%D8%AC_%D8%B3%D9%84%D9%8A%D9%85%D8%A7%D9%86_%D9%85%D8%AE%D8%AA%D8%A7%D8%B1_-_%D8%A7%D9%84%D8%AC%D8%B2%D8%A7%D8%A6%D8%B1).mp3',
    'tlemcen_algeria':
        'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Adhan_Fajr_Algeria_(%D8%A3%D8%B0%D8%A7%D9%86_%D8%A7%D9%84%D9%81%D8%AC%D8%B1_%D8%A7%D9%84%D8%AC%D8%B2%D8%A7%D8%A6%D8%B1).mp3',
    'makkah':
        'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Ali_Ibn_Ahmad_Mala_HQ.mp3',
    'madinah':
        'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Adhan_Al_Haram_Al_Madani_-_Al_Madinah_1_(%D8%A3%D8%B0%D8%A7%D9%86_%D8%A7%D9%84%D8%AD%D8%B1%D9%85_%D8%A7%D9%84%D9%85%D8%AF%D9%86%D9%8A_-_%D8%A7%D9%84%D9%85%D8%AF%D9%8A%D9%86%D8%A9_%D8%A7%D9%84%D9%85%D9%86%D9%88%D8%B1%D8%A9).mp3',
    'al_aqsa':
        'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Najee_Qazaz_-_Al_Aqsa_Jerusalem_(%D9%86%D8%A7%D8%AC%D9%8A_%D9%82%D8%B2%D8%A7%D8%B2_-_%D8%A7%D9%84%D9%85%D8%B3%D8%AC%D8%AF_%D8%A7%D9%84%D8%A3%D9%82%D8%B5%D9%89_%D8%A7%D9%84%D9%82%D8%AF%D8%B3).mp3',
    'abdulbasit':
        'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Abdulbasit_Abdusamad_1_-_Egypt_(%D8%B9%D8%A8%D8%AF_%D8%A7%D9%84%D8%A8%D8%A7%D8%B3%D8%B7_%D8%B9%D8%A8%D8%AF_%D8%A7%D9%84%D8%B5%D9%85%D8%AF_-_%D9%85%D8%B5%D8%B1).mp3',
    'husary':
        'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Mahmoud_Khalil_Al_Hussary_-_Cairo_(%D9%85%D8%AD%D9%85%D9%88%D8%AF_%D8%AE%D9%84%D9%8A%D9%84_%D8%A7%D9%84%D8%AD%D8%B5%D8%B1%D9%8A_-_%D8%A7%D9%84%D9%82%D8%A7%D9%87%D8%B1%D8%A9).mp3',
    'rifat':
        'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Muhammad_Refaat_-_Cairo_(%D9%85%D8%AD%D9%85%D8%AF_%D8%B1%D9%81%D8%B9%D8%AA_-_%D8%A7%D9%84%D9%82%D8%A7%D9%87%D8%B1%D8%A9).mp3',
    'banna':
        'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Mahmoud_Ali_Al_Banna_-_Cairo_(%D9%85%D8%AD%D9%85%D9%88%D8%AF_%D8%B9%D9%84%D9%8A_%D8%A7%D9%84%D8%A8%D9%86%D8%A7_-_%D8%A7%D9%84%D9%82%D8%A7%D9%87%D8%B1%D8%A9).mp3',
    'shaisha':
        'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Abul_Ainain_Shuaisha_-_Cairo_(%D8%A3%D8%A8%D9%88_%D8%A7%D9%84%D8%B9%D9%8A%D9%86%D9%8A%D9%86_%D8%B4%D8%B9%D9%8A%D8%B4%D8%B9_-_%D8%A7%D9%84%D9%82%D8%A7%D9%87%D8%B1%D8%A9).mp3',
    'qatami':
        'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Nasser_Al_Qatami_-_HQ_(%D9%86%D8%A7%D8%B5%D8%B1_%D8%A7%D9%84%D9%82%D8%B7%D8%A7%D9%85%D9%8A).mp3',
    'zitouna_tunisia':
        'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Adhan_Tunisia_(%D8%A3%D8%B0%D8%A7%D9%86_%D8%AA%D9%88%D9%86%D8%B3).mp3',
    'qarawiyyin_morocco':
        'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Kamal_Muhammad_Al_Marush_2_-_Morocco_(%D9%83%D9%85%D8%A7%D9%84_%D9%85%D8%AD%D9%85%D8%AF_%D8%A7%D9%84%D9%85%D8%B1%D8%B9%D9%88%D8%B4_-_%D8%A7%D9%84%D9%85%D8%BA%D8%B1%D8%A8).mp3',
    'umayyad_syria':
        'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Adhan_Syria_(%D8%A3%D8%B0%D8%A7%D9%86_%D8%B3%D9%88%D8%B1%D9%8A%D8%A7).mp3',
    'blue_mosque_turkey':
        'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Adhan_Turkey_1_(%D8%A3%D8%B0%D8%A7%D9%86_%D8%AA%D8%B1%D9%83%D9%8A%D8%A7).mp3',
    'sheikh_zayed_uae':
        'https://raw.githubusercontent.com/Kiwifu/adhan-mp3/main/Adhan_Dubai_UAE_(%D8%A3%D8%B0%D8%A7%D9%86_%D8%AF%D8%A8%D9%8A_%D8%A7%D9%84%D8%A5%D9%85%D8%A7%D8%B1%D8%A7%D8%AA).mp3',
  };

  static Future<void> playAdhan({String? soundId}) async {
    try {
      await _player.stop();
      final prefs = await SharedPreferences.getInstance();
      final selected = soundId ?? prefs.getString('adhan_sound') ?? 'algeria_grand_mosque';

      if (selected == 'takbeer_only') {
        await _player.play(AssetSource('audio/takbeer.wav'));
        isPlayingNotifier.value = true;
        return;
      }

      final cached = await _getCachedAudioFile(selected);
      if (cached != null && await cached.exists()) {
        await _player.play(DeviceFileSource(cached.path));
        isPlayingNotifier.value = true;
        return;
      }

      final url = adhanOnlineUrls[selected];
      if (url != null) {
        _downloadAudioAsync(selected, url);
      }

      // تشغيل الأذان المحلي المدمج مباشرة بدون تأخير وبمسار AssetSource الصحيح
      await _player.play(AssetSource('audio/adhan.mp3'));
      isPlayingNotifier.value = true;
    } catch (e) {
      debugPrint('playAdhan error: $e');
      isPlayingNotifier.value = false;
    }
  }

  static Future<void> playNotificationChime() async {
    try {
      await _chimePlayer.stop();
      await _chimePlayer.play(AssetSource('audio/notification.mp3'));
    } catch (e) {
      debugPrint('Chime mp3 error: $e');
      SystemSound.play(SystemSoundType.alert);
    }
  }

  static Future<void> stopAdhan() async {
    try {
      await _player.stop();
      await _chimePlayer.stop();
    } finally {
      isPlayingNotifier.value = false;
    }
  }

  static Future<File?> _getCachedAudioFile(String id) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return File('${dir.path}/adhan_$id.mp3');
    } catch (_) {
      return null;
    }
  }

  static Future<void> _downloadAudioAsync(String id, String url) async {
    try {
      final file = await _getCachedAudioFile(id);
      if (file == null || await file.exists()) return;
      final resp = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 20));
      if (resp.statusCode == 200 && resp.bodyBytes.length > 10000) {
        await file.writeAsBytes(resp.bodyBytes, flush: true);
      }
    } catch (e) {
      debugPrint('Download adhan cache notice: $e');
    }
  }
}
