package com.mihrab.algeria.mihrab_app

import android.app.AlarmManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.app.NotificationManager
import android.media.AudioManager
import androidx.core.app.NotificationManagerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.mihrab.algeria.mihrab_app/settings"

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            @Suppress("DEPRECATION")
            window.addFlags(
                android.view.WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                android.view.WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                android.view.WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
            )
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "areNotificationsEnabled" -> {
                    val areEnabled = NotificationManagerCompat.from(this).areNotificationsEnabled()
                    result.success(areEnabled)
                }
                "openNotificationSettings" -> {
                    try {
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
                    } catch (e: Exception) {
                        try {
                            val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                                data = Uri.fromParts("package", packageName, null)
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e2: Exception) {
                            result.error("ERROR", e2.message, null)
                        }
                    }
                }
                "isBatteryOptimizationIgnored" -> {
                    try {
                        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                        val isIgnoring = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            pm.isIgnoringBatteryOptimizations(packageName)
                        } else true
                        result.success(isIgnoring)
                    } catch (e: Exception) {
                        result.success(true)
                    }
                }
                "requestIgnoreBatteryOptimizations" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val intent = Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                                data = Uri.parse("package:$packageName")
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "canScheduleExactAlarms" -> {
                    try {
                        val am = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                        val canSchedule = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            am.canScheduleExactAlarms()
                        } else true
                        result.success(canSchedule)
                    } catch (e: Exception) {
                        result.success(true)
                    }
                }
                "openExactAlarmSettings" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                                data = Uri.parse("package:$packageName")
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "isDndAccessGranted" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                            result.success(nm.isNotificationPolicyAccessGranted)
                        } else {
                            result.success(true)
                        }
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "openDndSettings" -> {
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val intent = Intent(Settings.ACTION_NOTIFICATION_POLICY_ACCESS_SETTINGS).apply {
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(true)
                        } else {
                            result.success(true)
                        }
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "setRingerMode" -> {
                    try {
                        val mode = call.argument<String>("mode") ?: "silent"
                        val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                        val nm = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                        } else null

                        val hasAccess = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && nm != null) {
                            nm.isNotificationPolicyAccessGranted
                        } else true

                        if (!hasAccess) {
                            result.success(false)
                            return@setMethodCallHandler
                        }

                        when (mode) {
                            "silent" -> {
                                try {
                                    am.ringerMode = AudioManager.RINGER_MODE_SILENT
                                } catch (_: Exception) {
                                    try {
                                        am.ringerMode = AudioManager.RINGER_MODE_VIBRATE
                                    } catch (_: Exception) {}
                                }
                                try {
                                    am.setStreamVolume(AudioManager.STREAM_RING, 0, 0)
                                    am.setStreamVolume(AudioManager.STREAM_NOTIFICATION, 0, 0)
                                } catch (_: Exception) {}
                                result.success(true)
                            }
                            "vibrate" -> {
                                try {
                                    am.ringerMode = AudioManager.RINGER_MODE_VIBRATE
                                } catch (_: Exception) {
                                    try {
                                        am.setStreamVolume(AudioManager.STREAM_RING, 0, 0)
                                    } catch (_: Exception) {}
                                }
                                result.success(true)
                            }
                            "normal" -> {
                                try {
                                    am.ringerMode = AudioManager.RINGER_MODE_NORMAL
                                } catch (_: Exception) {}
                                val maxVol = am.getStreamMaxVolume(AudioManager.STREAM_RING)
                                try {
                                    am.setStreamVolume(AudioManager.STREAM_RING, (maxVol * 0.7).toInt(), 0)
                                    am.setStreamVolume(AudioManager.STREAM_NOTIFICATION, (maxVol * 0.7).toInt(), 0)
                                } catch (_: Exception) {}
                                result.success(true)
                            }
                            else -> result.error("INVALID_MODE", "Unknown mode: $mode", null)
                        }
                    } catch (e: Exception) {
                        result.success(false)
                    }
                }
                "getRingerMode" -> {
                    try {
                        val am = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                        val modeStr = when (am.ringerMode) {
                            AudioManager.RINGER_MODE_SILENT -> "silent"
                            AudioManager.RINGER_MODE_VIBRATE -> "vibrate"
                            else -> "normal"
                        }
                        result.success(modeStr)
                    } catch (e: Exception) {
                        result.success("normal")
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}


