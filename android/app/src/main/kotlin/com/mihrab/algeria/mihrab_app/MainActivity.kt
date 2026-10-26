package com.mihrab.algeria.mihrab_app

import android.app.AlarmManager
import android.app.KeyguardManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.PowerManager
import android.provider.Settings
import android.view.WindowManager
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val SETTINGS_CHANNEL = "com.mihrab.algeria.mihrab_app/settings"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // تفعيل إيقاظ الشاشة فقط إذا تم فتح التطبيق من منبه الأذان وليس عند كل تشغيل عادي
        if (intent?.getBooleanExtra("from_adhan_alarm", false) == true) {
            wakeAndUnlockScreen()
        }
        createAdhanNotificationChannel()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.getBooleanExtra("from_adhan_alarm", false)) {
            wakeAndUnlockScreen()
        }
    }

    private fun createAdhanNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "mihrab_adhan_channel_v10"
            val channelName = "أذان ومواقيت الصلاة"
            val channelDesc = "تنبيهات وأذان الصلوات الخمس في موعدها الدقيق بصوت الأذان الكامل والتنبيه الصوتي"

            val channel = NotificationChannel(
                channelId,
                channelName,
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = channelDesc
                enableLights(true)
                lightColor = 0xFF00FF00.toInt()
                enableVibration(true)
                vibrationPattern = longArrayOf(0, 1000, 500, 1000)
                lockscreenVisibility = Notification.VISIBILITY_PUBLIC
                setBypassDnd(true)

                // التحقق الآمن من وجود ملف الصوت في res/raw/athan قبل ربطه بالقناة
                val rawId = resources.getIdentifier("athan", "raw", packageName)
                val soundUri = if (rawId != 0) {
                    Uri.parse("android.resource://$packageName/$rawId")
                } else {
                    RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                }

                val audioAttributes = AudioAttributes.Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .build()
                setSound(soundUri, audioAttributes)
            }

            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }

    fun wakeAndUnlockScreen() {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                setShowWhenLocked(true)
                setTurnScreenOn(true)
                val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as? KeyguardManager
                keyguardManager?.requestDismissKeyguard(this, null)
            } else {
                @Suppress("DEPRECATION")
                window.addFlags(
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                    WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                )
            }
            val powerManager = getSystemService(Context.POWER_SERVICE) as? PowerManager
            @Suppress("DEPRECATION")
            val wakeLock = powerManager?.newWakeLock(
                PowerManager.SCREEN_BRIGHT_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP or PowerManager.ON_AFTER_RELEASE,
                "mihrab:AdhanWakeLock"
            )
            wakeLock?.acquire(15_000L)
        } catch (_: Exception) {}
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SETTINGS_CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "areNotificationsEnabled" -> {
                        val enabled = NotificationManagerCompat.from(this).areNotificationsEnabled()
                        result.success(enabled)
                    }
                    "openNotificationSettings" -> {
                        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                                putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                            }
                        } else {
                            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                                data = Uri.fromParts("package", packageName, null)
                            }
                        }
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(intent)
                        result.success(true)
                    }
                    "canScheduleExactAlarms" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                            result.success(alarmManager.canScheduleExactAlarms())
                        } else {
                            result.success(true)
                        }
                    }
                    "openExactAlarmSettings" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                                data = Uri.parse("package:$packageName")
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                        }
                        result.success(true)
                    }
                    "isBatteryOptimizationIgnored" -> {
                        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                        result.success(pm.isIgnoringBatteryOptimizations(packageName))
                    }
                    "requestIgnoreBatteryOptimizations" -> {
                        try {
                            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                                data = Uri.parse("package:$packageName")
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (_: Exception) {
                            val fallback = Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(fallback)
                            result.success(true)
                        }
                    }
                    "isDndAccessGranted" -> {
                        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                        result.success(nm.isNotificationPolicyAccessGranted)
                    }
                    "openDndSettings" -> {
                        val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    }
                    "getRingerMode" -> {
                        val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                        val modeStr = when (am.ringerMode) {
                            AudioManager.RINGER_MODE_SILENT -> "silent"
                            AudioManager.RINGER_MODE_VIBRATE -> "vibrate"
                            else -> "normal"
                        }
                        result.success(modeStr)
                    }
                    "setRingerMode" -> {
                        val mode = call.argument<String>("mode") ?: "normal"
                        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                        if (!nm.isNotificationPolicyAccessGranted) {
                            result.success(false)
                            return@setMethodCallHandler
                        }
                        val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                        when (mode) {
                            "silent" -> {
                                am.ringerMode = AudioManager.RINGER_MODE_SILENT
                                result.success(true)
                            }
                            "vibrate" -> {
                                am.ringerMode = AudioManager.RINGER_MODE_VIBRATE
                                result.success(true)
                            }
                            "normal" -> {
                                am.ringerMode = AudioManager.RINGER_MODE_NORMAL
                                val maxRing = am.getStreamMaxVolume(AudioManager.STREAM_RING)
                                am.setStreamVolume(AudioManager.STREAM_RING, (maxRing * 0.7).toInt().coerceAtLeast(1), 0)
                                result.success(true)
                            }
                            else -> result.error("INVALID_MODE", "Unknown mode: $mode", null)
                        }
                    }
                    "updateWidget" -> {
                        val prayerName = call.argument<String>("prayerName") ?: "الصلاة القادمة"
                        val prayerTime = call.argument<String>("prayerTime") ?: "--:--"
                        val remaining = call.argument<String>("remaining") ?: ""
                        val location = call.argument<String>("location") ?: ""
                        MihrabWidgetProvider.updateWidgetData(this, prayerName, prayerTime, remaining, location)
                        result.success(true)
                    }
                    "pinWidget" -> {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            val appWidgetManager = getSystemService(AppWidgetManager::class.java)
                            val provider = ComponentName(this, MihrabWidgetProvider::class.java)
                            if (appWidgetManager != null && appWidgetManager.isRequestPinAppWidgetSupported) {
                                appWidgetManager.requestPinAppWidget(provider, null, null)
                                result.success(true)
                            } else {
                                result.success(false)
                            }
                        } else {
                            result.success(false)
                        }
                    }
                    "wakeScreen" -> {
                        wakeAndUnlockScreen()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) {
                result.error("ERROR", e.message, null)
            }
        }
    }
}
