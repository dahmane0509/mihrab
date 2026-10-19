package com.mihrab.algeria.mihrab_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews

class MihrabWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private const val PREFS_NAME = "MihrabWidgetPrefs"
        private const val KEY_PRAYER_NAME = "prayer_name"
        private const val KEY_PRAYER_TIME = "prayer_time"
        private const val KEY_REMAINING = "remaining"
        private const val KEY_LOCATION = "location"

        fun updateWidgetData(context: Context, prayerName: String, prayerTime: String, remaining: String, location: String) {
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
            for (widgetId in allWidgetIds) {
                updateAppWidget(context, appWidgetManager, widgetId)
            }
        }

        private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val prayerName = prefs.getString(KEY_PRAYER_NAME, "الصلاة القادمة") ?: "الصلاة القادمة"
            val prayerTime = prefs.getString(KEY_PRAYER_TIME, "--:--") ?: "--:--"
            val remaining = prefs.getString(KEY_REMAINING, "محراب") ?: "محراب"
            val location = prefs.getString(KEY_LOCATION, "مواقيت الصلاة") ?: "مواقيت الصلاة"

            val views = RemoteViews(context.packageName, R.layout.widget_mihrab_prayer)
            views.setTextViewText(R.id.widget_prayer_name, "الصلاة القادمة: $prayerName")
            views.setTextViewText(R.id.widget_prayer_time, prayerTime)
            views.setTextViewText(R.id.widget_remaining, remaining)
            views.setTextViewText(R.id.widget_location, location)

            // Intent to launch Mihrab app when widget is tapped
            val intent = Intent(context, MainActivity::class.java)
            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
            val pendingIntent = PendingIntent.getActivity(context, 0, intent, flags)
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
