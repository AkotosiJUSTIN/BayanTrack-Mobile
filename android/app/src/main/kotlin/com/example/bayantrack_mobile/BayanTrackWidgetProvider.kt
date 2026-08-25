package com.example.bayantrack_mobile

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews

class BayanTrackWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        appWidgetIds.forEach { appWidgetId ->
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        updateWidget(context, appWidgetManager, appWidgetId, newOptions)
    }

    companion object {
        const val ACTION_WIDGET_NAVIGATE =
            "com.example.bayantrack_mobile.action.WIDGET_NAVIGATE"
        const val EXTRA_WIDGET_DESTINATION =
            "com.example.bayantrack_mobile.extra.WIDGET_DESTINATION"
        const val METHOD_WIDGET_DESTINATION = "widgetDestination"

        private const val PREFS_NAME = "bayantrack_widget_state"
        private const val KEY_LOCALE = "locale"
        private const val KEY_AUTHENTICATED = "authenticated"
        private const val KEY_UNREAD_COUNT = "unread_count"
        private const val MEDIUM_MIN_WIDTH_DP = 180
        private const val MEDIUM_MIN_HEIGHT_DP = 120
        private const val QUICK_REPORT_DESTINATION = "quick_report"
        private const val NOTIFICATIONS_DESTINATION = "notifications"

        fun updateState(
            context: Context,
            locale: String?,
            authenticated: Boolean,
            unreadCount: Int,
        ) {
            val safeLocale = if (locale == "fil") "fil" else "en"
            val safeUnreadCount = if (authenticated) unreadCount.coerceAtLeast(0) else 0
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .putString(KEY_LOCALE, safeLocale)
                .putBoolean(KEY_AUTHENTICATED, authenticated)
                .putInt(KEY_UNREAD_COUNT, safeUnreadCount)
                .apply()

            updateAll(context)
        }

        private fun updateAll(context: Context) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val componentName = ComponentName(context, BayanTrackWidgetProvider::class.java)
            appWidgetManager.getAppWidgetIds(componentName).forEach { appWidgetId ->
                updateWidget(context, appWidgetManager, appWidgetId)
            }
        }

        private fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            options: Bundle? = appWidgetManager.getAppWidgetOptions(appWidgetId),
        ) {
            val width = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0) ?: 0
            val height = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0) ?: 0
            val useMediumLayout =
                width >= MEDIUM_MIN_WIDTH_DP && height >= MEDIUM_MIN_HEIGHT_DP
            val layoutId = if (useMediumLayout) {
                R.layout.widget_bayantrack_medium
            } else {
                R.layout.widget_bayantrack_small
            }
            val views = RemoteViews(context.packageName, layoutId)
            val preferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val filipino = preferences.getString(KEY_LOCALE, "en") == "fil"
            val authenticated = preferences.getBoolean(KEY_AUTHENTICATED, false)
            val unreadCount = preferences.getInt(KEY_UNREAD_COUNT, 0).coerceAtLeast(0)
            val quickReportLabel = "Quick Report"
            val notificationsLabel = if (filipino) "Mga Notification" else "Notifications"

            views.setTextViewText(R.id.widget_brand, "BayanTrack")
            views.setTextViewText(R.id.widget_quick_report, quickReportLabel)
            views.setContentDescription(R.id.widget_quick_report, quickReportLabel)
            views.setOnClickPendingIntent(
                R.id.widget_quick_report,
                navigationPendingIntent(context, QUICK_REPORT_DESTINATION, 1001),
            )

            if (useMediumLayout) {
                views.setTextViewText(R.id.widget_notifications_label, notificationsLabel)
                views.setContentDescription(R.id.widget_notifications, notificationsLabel)
                views.setOnClickPendingIntent(
                    R.id.widget_notifications,
                    navigationPendingIntent(context, NOTIFICATIONS_DESTINATION, 1002),
                )
                views.setTextViewText(R.id.widget_unread_count, unreadCount.toString())
                views.setViewVisibility(
                    R.id.widget_unread_count,
                    if (authenticated && unreadCount > 0) View.VISIBLE else View.GONE,
                )
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun navigationPendingIntent(
            context: Context,
            destination: String,
            requestCode: Int,
        ): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                action = ACTION_WIDGET_NAVIGATE
                data = Uri.parse("bayantrack://widget/$destination")
                putExtra(EXTRA_WIDGET_DESTINATION, destination)
                addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            }
            return PendingIntent.getActivity(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }
    }
}
