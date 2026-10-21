package com.mihrab.algeria.mihrab_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import android.widget.RemoteViews

class MihrabWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        try {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, MihrabWidgetProvider::class.java)
            val allWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
            if (allWidgetIds != null && allWidgetIds.isNotEmpty()) {
                for (widgetId in allWidgetIds) {
                    updateAppWidget(context, appWidgetManager, widgetId)
                }
            }
        } catch (e: Exception) {
            Log.e("MihrabWidget", "Error in onReceive: ${e.message}")
        }
    }

    companion object {
        private const val PREFS_NAME = "MihrabWidgetPrefs"
        private const val KEY_PRAYER_NAME = "prayer_name"
        private const val KEY_PRAYER_TIME = "prayer_time"
        private const val KEY_REMAINING = "remaining"
        private const val KEY_LOCATION = "location"

        fun updateWidgetData(context: Context, prayerName: String, prayerTime: String, remaining: String, location: String) {
            try {
                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                prefs.edit()
                    .putString(KEY_PRAYER_NAME, prayerName)
                    .putString(KEY_PRAYER_TIME, prayerTime)
                    .putString(KEY_REMAINING, remaining)
                    .putString(KEY_LOCATION, location)
                    .apply()

                val appWidgetManager = AppWidgetManager.getInstance(context)
                val thisWidget = ComponentName(context, MihrabWidgetProvider::class.java)
                val allWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)
                if (allWidgetIds != null && allWidgetIds.isNotEmpty()) {
                    for (widgetId in allWidgetIds) {
                        updateAppWidget(context, appWidgetManager, widgetId)
                    }
                }
            } catch (e: Exception) {
                Log.e("MihrabWidget", "Error in updateWidgetData: ${e.message}")
            }
        }

        fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            try {
                val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                val prayerName = prefs.getString(KEY_PRAYER_NAME, null)
                val prayerTime = prefs.getString(KEY_PRAYER_TIME, null)
                val remaining = prefs.getString(KEY_REMAINING, null)
                val location = prefs.getString(KEY_LOCATION, null)

                val views = RemoteViews(context.packageName, R.layout.widget_mihrab_prayer)

                if (prayerName.isNullOrEmpty() || prayerTime.isNullOrEmpty()) {
                    // Elegant fallback when app has not run or data is missing on device boot
                    views.setTextViewText(R.id.widget_prayer_name, "مِحْراب • مواقيت الصلاة")
                    views.setTextViewText(R.id.widget_prayer_time, "--:--")
                    views.setTextViewText(R.id.widget_remaining, "افتح التطبيق لتحديث المواقيت")
                    views.setTextViewText(R.id.widget_location, "مواقيت الصلاة في الجزائر")
                } else {
                    views.setTextViewText(R.id.widget_prayer_name, "الصلاة القادمة: $prayerName")
                    views.setTextViewText(R.id.widget_prayer_time, prayerTime)
                    views.setTextViewText(R.id.widget_remaining, if (remaining.isNullOrEmpty()) "محراب" else remaining)
                    views.setTextViewText(R.id.widget_location, if (location.isNullOrEmpty()) "مِحْراب • مواقيت الصلاة" else location)
                }

                // Safe Intent to launch Mihrab app when widget is tapped
                val intent = Intent(context, MainActivity::class.java).apply {
                    flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                }
                val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                } else {
                    PendingIntent.FLAG_UPDATE_CURRENT
                }
                val pendingIntent = PendingIntent.getActivity(context, 0, intent, flags)
                views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

                appWidgetManager.updateAppWidget(appWidgetId, views)
            } catch (e: Exception) {
                Log.e("MihrabWidget", "Error updating widget $appWidgetId: ${e.message}")
            }
        }
    }
}
