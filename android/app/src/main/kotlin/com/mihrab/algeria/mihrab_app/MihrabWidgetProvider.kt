package com.mihrab.algeria.mihrab_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.RemoteViews
import java.util.Calendar

class MihrabWidgetProvider : AppWidgetProvider() {

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        try {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, MihrabWidgetProvider::class.java))
            for (id in ids) {
                updateSingleWidget(context, manager, id)
            }
        } catch (e: Exception) {
            Log.e("MihrabWidget", "Error in onReceive: ${e.message}")
        }
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateSingleWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private const val PREFS_NAME = "MihrabWidgetPrefs"

        fun updateWidgetData(
            context: Context,
            prayerName: String,
            prayerTime: String,
            remaining: String,
            location: String
        ) {
            try {
                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                prefs.edit()
                    .putString("prayer_name", prayerName)
                    .putString("prayer_time", prayerTime)
                    .putString("remaining", remaining)
                    .putString("location", location)
                    .apply()

                val manager = AppWidgetManager.getInstance(context)
                val ids = manager.getAppWidgetIds(ComponentName(context, MihrabWidgetProvider::class.java))
                for (id in ids) {
                    updateSingleWidget(context, manager, id)
                }
            } catch (e: Exception) {
                Log.e("MihrabWidget", "Error in updateWidgetData: ${e.message}")
            }
        }

        private fun computeDynamicRemaining(prayerTime: String, fallbackRemaining: String): String {
            return try {
                val parts = prayerTime.trim().split(":")
                if (parts.size < 2) return fallbackRemaining
                val targetHour = parts[0].toInt()
                val targetMin = parts[1].take(2).toInt()
                val now = Calendar.getInstance()
                val nowMins = now.get(Calendar.HOUR_OF_DAY) * 60 + now.get(Calendar.MINUTE)
                var diff = (targetHour * 60 + targetMin) - nowMins
                if (diff < 0) diff += 24 * 60
                val h = diff / 60
                val m = diff % 60
                if (h > 0) "متبقي ${h} س و ${m} د" else "متبقي ${m} دقيقة"
            } catch (_: Exception) {
                fallbackRemaining
            }
        }

        fun updateSingleWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            try {
                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                val prayerName = prefs.getString("prayer_name", "") ?: ""
                val prayerTime = prefs.getString("prayer_time", "--:--") ?: "--:--"
                val savedRemaining = prefs.getString("remaining", "") ?: ""
                val location = prefs.getString("location", "") ?: ""

                val views = RemoteViews(context.packageName, R.layout.widget_mihrab_prayer)

                if (prayerName.isNotEmpty() && prayerTime != "--:--") {
                    views.setTextViewText(R.id.widget_prayer_name, "الصلاة القادمة: $prayerName")
                    views.setTextViewText(R.id.widget_prayer_time, prayerTime)
                    val dynamicRem = computeDynamicRemaining(prayerTime, savedRemaining)
                    views.setTextViewText(
                        R.id.widget_remaining,
                        if (dynamicRem.isNotEmpty()) dynamicRem else "حافظ على صلاتك"
                    )
                    views.setTextViewText(
                        R.id.widget_location,
                        if (location.isNotEmpty()) "📍 $location" else "مِحْراب • مواقيت الصلاة"
                    )
                } else {
                    views.setTextViewText(R.id.widget_prayer_name, "مِحْراب • مواقيت الصلاة")
                    views.setTextViewText(R.id.widget_prayer_time, "--:--")
                    views.setTextViewText(R.id.widget_remaining, "افتح التطبيق لتحديث المواقيت")
                    views.setTextViewText(R.id.widget_location, "مواقيت الصلاة في الجزائر")
                }

                val intent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val pendingFlags = if ( android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                } else {
                    PendingIntent.FLAG_UPDATE_CURRENT
                }
                val pendingIntent = PendingIntent.getActivity(context, 0, intent, pendingFlags)
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e: Exception) {
                Log.e("MihrabWidget", "Error updating widget $appWidgetId: ${e.message}")
            }
        }
    }
}
