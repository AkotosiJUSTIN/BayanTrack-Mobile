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
        private const val MEDIUM_MIN_WIDTH_DP = 220
        private const val MEDIUM_MIN_HEIGHT_DP = 210
        private const val EXPANDED_MIN_WIDTH_DP = 220
        private const val EXPANDED_MIN_HEIGHT_DP = 250
        private const val SUBMITTING_TTL_MILLIS = 2 * 60 * 1000L
        private const val SUBMITTED_TTL_MILLIS = 5 * 60 * 1000L
        private const val STATUS_READY = "ready"
        private const val STATUS_SUBMITTING = "submitting"
        private const val STATUS_SUBMITTED = "submitted"
        private const val STATUS_FAILED = "failed"
        private const val STATUS_NETWORK_UNAVAILABLE = "networkUnavailable"
        private const val STATUS_LOCATION_REQUIRED = "locationRequired"
        private const val FAST_REPORT_DESTINATION = "fast_report"
        private const val OPEN_APP_DESTINATION = "open_app"

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
                            filipino,
                            authenticated,
                            unreadCount,
                            quickReportStatus,
                        ),
                        SizeF(
                            MEDIUM_MIN_WIDTH_DP.toFloat(),
                            MEDIUM_MIN_HEIGHT_DP.toFloat(),
                        ) to widgetViews(
                            context,
                            R.layout.widget_bayantrack_medium,
                            filipino,
                            authenticated,
                            unreadCount,
                            quickReportStatus,
                        ),
                        SizeF(
                            EXPANDED_MIN_WIDTH_DP.toFloat(),
                            EXPANDED_MIN_HEIGHT_DP.toFloat(),
                        ) to widgetViews(
                            context,
                            R.layout.widget_bayantrack_expanded,
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
                val useExpandedLayout =
                    width >= EXPANDED_MIN_WIDTH_DP && height >= EXPANDED_MIN_HEIGHT_DP
                widgetViews(
                    context,
                    when {
                        useExpandedLayout -> R.layout.widget_bayantrack_expanded
                        useMediumLayout -> R.layout.widget_bayantrack_medium
                        else -> R.layout.widget_bayantrack_small
                    },
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
            filipino: Boolean,
            authenticated: Boolean,
            unreadCount: Int,
            quickReportStatus: String,
        ): RemoteViews {
            val compact = layoutId == R.layout.widget_bayantrack_small
            val views = RemoteViews(context.packageName, layoutId)
            val fastReportLabel = when {
                !authenticated -> if (filipino) "Mag-sign in" else "Sign in"
                quickReportStatus == STATUS_SUBMITTING ->
                    if (filipino) "Isinusumite…" else "Submitting…"
                quickReportStatus == STATUS_SUBMITTED ->
                    if (filipino) "Naisumite" else "Submitted"
                quickReportStatus == STATUS_FAILED ->
                    if (filipino) "Subukan muli" else "Retry"
                quickReportStatus == STATUS_NETWORK_UNAVAILABLE ->
                    if (filipino) "Offline / Subukan muli" else "Offline / Retry"
                else -> "Emergency Report"
            }
            val compactInputLabel = when {
                !authenticated -> if (filipino) "Mag-sign in para mag-report" else "Sign in to report"
                quickReportStatus == STATUS_SUBMITTING ->
                    if (filipino) "Isinusumite…" else "Submitting…"
                quickReportStatus == STATUS_SUBMITTED ->
                    if (filipino) "Naisumite" else "Submitted"
                quickReportStatus == STATUS_FAILED ->
                    if (filipino) "Subukan muli" else "Retry"
                quickReportStatus == STATUS_NETWORK_UNAVAILABLE ->
                    if (filipino) "Offline / Subukan muli" else "Offline / Retry"
                else -> if (filipino) "Piliin ang insidente" else "Choose incident"
            }
            val compactSubmitLabel = if (filipino) "Buksan" else "Open"
            val fastReportStatus = when {
                !authenticated -> if (filipino) "Mag-sign in para mag-report" else "Sign in to report"
                quickReportStatus == STATUS_SUBMITTING ->
                    if (filipino) "Isinusumite" else "Submitting"
                quickReportStatus == STATUS_SUBMITTED ->
                    if (filipino) "Naisumite" else "Submitted"
                quickReportStatus == STATUS_FAILED ->
                    if (filipino) "Nabigo" else "Failed"
                quickReportStatus == STATUS_NETWORK_UNAVAILABLE ->
                    if (filipino) "Offline / Subukan muli" else "Offline / Retry"
                else -> if (filipino) "Handa" else "Ready"
            }
            val openAppLabel = if (filipino) "Buksan ang BayanTrack" else "Open BayanTrack"

            views.setTextViewText(R.id.widget_brand, "BayanTrack")
            views.setTextViewText(R.id.widget_title, "Emergency Report")
            views.setTextViewText(
                R.id.widget_quick_report,
                if (compact) compactInputLabel else fastReportLabel,
            )
            views.setContentDescription(
                R.id.widget_quick_report,
                if (compact) {
                    if (filipino) {
                        "Ilarawan ang insidente. Bubuksan ang fast report form."
                    } else {
                        "Describe the incident. Opens the fast report form."
                    }
                } else {
                    "$fastReportStatus. $fastReportLabel"
                },
            )
            views.setOnClickPendingIntent(
                R.id.widget_quick_report,
                navigationPendingIntent(context, FAST_REPORT_DESTINATION, 1001),
            )
            views.setOnClickPendingIntent(
                R.id.widget_root,
                navigationPendingIntent(context, OPEN_APP_DESTINATION, 1002),
            )

            if (compact) {
                views.setTextViewText(R.id.widget_quick_report_submit, compactSubmitLabel)
                views.setContentDescription(
                    R.id.widget_quick_report_submit,
                    if (filipino) {
                        "I-submit ang fast report. Bubuksan ang fast report form."
                    } else {
                        "Submit the fast report. Opens the fast report form."
                    },
                )
                views.setOnClickPendingIntent(
                    R.id.widget_quick_report_submit,
                    navigationPendingIntent(context, FAST_REPORT_DESTINATION, 1003),
                )
            } else {
                views.setTextViewText(R.id.widget_status, fastReportStatus)
                views.setContentDescription(
                    R.id.widget_location_row,
                    if (filipino) "Kukunin ang GPS sa app" else "GPS is collected in the app",
                )
                views.setViewVisibility(R.id.widget_notifications, View.GONE)
                views.setViewVisibility(R.id.widget_unread_count, View.GONE)
                views.setTextViewText(R.id.widget_emergency_report, openAppLabel)
                views.setContentDescription(
                    R.id.widget_emergency_report,
                    openAppLabel,
                )
                views.setOnClickPendingIntent(
                    R.id.widget_emergency_report,
                    navigationPendingIntent(context, OPEN_APP_DESTINATION, 1002),
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
                addFlags(
                    Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP,
                )
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
