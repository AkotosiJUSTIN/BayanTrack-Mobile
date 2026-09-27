package com.example.bayantrack_mobile

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.util.SizeF
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
        private const val KEY_QUICK_REPORT_STATUS = "quick_report_status"
        private const val KEY_QUICK_REPORT_STATUS_UPDATED_AT =
            "quick_report_status_updated_at"
        private const val MEDIUM_MIN_WIDTH_DP = 180
        private const val MEDIUM_MIN_HEIGHT_DP = 150
        private const val EXPANDED_MIN_WIDTH_DP = 280
        private const val EXPANDED_MIN_HEIGHT_DP = 205
        private const val SUBMITTING_TTL_MILLIS = 2 * 60 * 1000L
        private const val SUBMITTED_TTL_MILLIS = 5 * 60 * 1000L
        private const val STATUS_READY = "ready"
        private const val STATUS_SUBMITTING = "submitting"
        private const val STATUS_SUBMITTED = "submitted"
        private const val STATUS_FAILED = "failed"
        private const val STATUS_NETWORK_UNAVAILABLE = "networkUnavailable"
        private const val STATUS_LOCATION_REQUIRED = "locationRequired"
        private const val QUICK_REPORT_DESTINATION = "quick_report"
        private const val EMERGENCY_REPORT_DESTINATION = "emergency_report"
        private const val NOTIFICATIONS_DESTINATION = "notifications"

        fun updateState(
            context: Context,
            locale: String?,
            authenticated: Boolean,
            unreadCount: Int,
            quickReportStatus: String,
        ) {
            val safeLocale = if (locale == "fil") "fil" else "en"
            val safeUnreadCount = if (authenticated) unreadCount.coerceAtLeast(0) else 0
            val preferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val safeQuickReportStatus = if (authenticated) {
                normalizeQuickReportStatus(quickReportStatus)
            } else STATUS_READY
            val previousStatus = preferences.getString(KEY_QUICK_REPORT_STATUS, null)
            val editor = preferences.edit()
                .putString(KEY_LOCALE, safeLocale)
                .putBoolean(KEY_AUTHENTICATED, authenticated)
                .putInt(KEY_UNREAD_COUNT, safeUnreadCount)
                .putString(KEY_QUICK_REPORT_STATUS, safeQuickReportStatus)
            if (previousStatus != safeQuickReportStatus) {
                editor.putLong(KEY_QUICK_REPORT_STATUS_UPDATED_AT, System.currentTimeMillis())
            }
            editor.apply()

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
            val preferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val filipino = preferences.getString(KEY_LOCALE, "en") == "fil"
            val authenticated = preferences.getBoolean(KEY_AUTHENTICATED, false)
            val unreadCount = preferences.getInt(KEY_UNREAD_COUNT, 0).coerceAtLeast(0)
            val quickReportStatus = currentQuickReportStatus(preferences)
            val views = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                RemoteViews(
                    mapOf(
                        SizeF(110f, 110f) to widgetViews(
                            context,
                            R.layout.widget_bayantrack_small,
                            false,
                            filipino,
                            authenticated,
                            unreadCount,
                            quickReportStatus,
                        ),
                        SizeF(180f, 150f) to widgetViews(
                            context,
                            R.layout.widget_bayantrack_medium,
                            false,
                            filipino,
                            authenticated,
                            unreadCount,
                            quickReportStatus,
                        ),
                        SizeF(280f, EXPANDED_MIN_HEIGHT_DP.toFloat()) to widgetViews(
                            context,
                            R.layout.widget_bayantrack_medium,
                            true,
                            filipino,
                            authenticated,
                            unreadCount,
                            quickReportStatus,
                        ),
                    ),
                )
            } else {
                val width = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0) ?: 0
                val height = options?.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0) ?: 0
                val useMediumLayout =
                    width >= MEDIUM_MIN_WIDTH_DP && height >= MEDIUM_MIN_HEIGHT_DP
                val showSecondaryActions =
                    width >= EXPANDED_MIN_WIDTH_DP && height >= EXPANDED_MIN_HEIGHT_DP
                widgetViews(
                    context,
                    if (useMediumLayout) {
                        R.layout.widget_bayantrack_medium
                    } else {
                        R.layout.widget_bayantrack_small
                    },
                    showSecondaryActions,
                    filipino,
                    authenticated,
                    unreadCount,
                    quickReportStatus,
                )
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }

        private fun widgetViews(
            context: Context,
            layoutId: Int,
            showSecondaryActions: Boolean,
            filipino: Boolean,
            authenticated: Boolean,
            unreadCount: Int,
            quickReportStatus: String,
        ): RemoteViews {
            val useMediumLayout = layoutId == R.layout.widget_bayantrack_medium
            val views = RemoteViews(context.packageName, layoutId)
            val quickReportLabel = when {
                !authenticated -> "Sign in"
                quickReportStatus == STATUS_SUBMITTING -> "Sending…"
                quickReportStatus == STATUS_SUBMITTED -> "Sent"
                quickReportStatus == STATUS_FAILED -> "Retry"
                quickReportStatus == STATUS_NETWORK_UNAVAILABLE -> "Offline"
                quickReportStatus == STATUS_LOCATION_REQUIRED -> "Set location"
                else -> "Report now"
            }
            val quickReportMessage = when {
                !authenticated -> "Sign in to report."
                quickReportStatus == STATUS_SUBMITTING -> "Submitting report…"
                quickReportStatus == STATUS_SUBMITTED -> "Report submitted."
                quickReportStatus == STATUS_FAILED -> "Couldn't send. Tap to retry."
                quickReportStatus == STATUS_NETWORK_UNAVAILABLE -> "Offline. Tap to retry."
                quickReportStatus == STATUS_LOCATION_REQUIRED ->
                    "Choose a real incident location."
                else -> "Ready when you are."
            }
            val notificationsLabel = if (filipino) "Mga Notification" else "Notifications"

            views.setTextViewText(
                R.id.widget_brand,
                if (useMediumLayout) "BayanTrack" else "Quick Report",
            )
            views.setTextViewText(R.id.widget_quick_report, quickReportLabel)
            views.setContentDescription(
                R.id.widget_quick_report,
                "$quickReportMessage $quickReportLabel",
            )
            views.setOnClickPendingIntent(
                R.id.widget_quick_report,
                navigationPendingIntent(context, QUICK_REPORT_DESTINATION, 1001),
            )

            if (useMediumLayout) {
                views.setTextViewText(R.id.widget_title, "Quick Report")
                views.setTextViewText(R.id.widget_status, quickReportMessage)
                views.setTextViewText(R.id.widget_emergency_report, "Emergency")
                views.setContentDescription(
                    R.id.widget_emergency_report,
                    "Emergency Report",
                )
                views.setOnClickPendingIntent(
                    R.id.widget_emergency_report,
                    navigationPendingIntent(context, EMERGENCY_REPORT_DESTINATION, 1002),
                )
                views.setTextViewText(R.id.widget_notifications_label, notificationsLabel)
                views.setContentDescription(
                    R.id.widget_notifications,
                    if (authenticated && unreadCount > 0) {
                        "$notificationsLabel, $unreadCount unread"
                    } else {
                        notificationsLabel
                    },
                )
                views.setOnClickPendingIntent(
                    R.id.widget_notifications,
                    navigationPendingIntent(context, NOTIFICATIONS_DESTINATION, 1003),
                )
                views.setTextViewText(R.id.widget_unread_count, unreadCount.toString())
                views.setViewVisibility(
                    R.id.widget_unread_count,
                    if (authenticated && unreadCount > 0) View.VISIBLE else View.GONE,
                )
                views.setViewVisibility(
                    R.id.widget_secondary_actions,
                    if (showSecondaryActions) View.VISIBLE else View.GONE,
                )
            }

            return views
        }

        private fun normalizeQuickReportStatus(status: String?): String =
            when (status) {
                STATUS_SUBMITTING,
                STATUS_SUBMITTED,
                STATUS_FAILED,
                STATUS_NETWORK_UNAVAILABLE,
                STATUS_LOCATION_REQUIRED -> status ?: STATUS_READY
                else -> STATUS_READY
            }

        private fun currentQuickReportStatus(preferences: SharedPreferences): String {
            val status = normalizeQuickReportStatus(
                preferences.getString(KEY_QUICK_REPORT_STATUS, STATUS_READY),
            )
            val ttl = when (status) {
                STATUS_SUBMITTING -> SUBMITTING_TTL_MILLIS
                STATUS_SUBMITTED -> SUBMITTED_TTL_MILLIS
                else -> return status
            }
            val now = System.currentTimeMillis()
            val updatedAt = preferences.getLong(KEY_QUICK_REPORT_STATUS_UPDATED_AT, now)
            val age = now - updatedAt
            if (age in 0L until ttl) return status

            preferences.edit()
                .putString(KEY_QUICK_REPORT_STATUS, STATUS_READY)
                .putLong(KEY_QUICK_REPORT_STATUS_UPDATED_AT, now)
                .apply()
            return STATUS_READY
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
