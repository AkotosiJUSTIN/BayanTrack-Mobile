package com.example.bayantrack_mobile

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingWidgetDestination: String? = null
    private var widgetChannel: MethodChannel? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        pendingWidgetDestination = intent?.getStringExtra(
            BayanTrackWidgetProvider.EXTRA_WIDGET_DESTINATION,
        )
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        widgetChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "bayantrack/widget")
            .also { channel ->
                channel.setMethodCallHandler { call, result ->
                    when (call.method) {
                        "getInitialWidgetDestination" -> result.success(takeInitialWidgetDestination())
                        "updateState" -> {
                            val state = call.arguments as? Map<*, *>
                            val locale = state?.get("locale") as? String
                            val authenticated = state?.get("authenticated") as? Boolean ?: false
                            val unreadCount = (state?.get("unreadCount") as? Number)?.toInt() ?: 0
                            val quickReportStatus = state?.get("quickReportStatus") as? String
                                ?: "ready"
                            BayanTrackWidgetProvider.updateState(
                                context = this,
                                locale = locale,
                                authenticated = authenticated,
                                unreadCount = unreadCount,
                                quickReportStatus = quickReportStatus,
                            )
                            result.success(null)
                        }
                        else -> result.notImplemented()
                    }
                }
            }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val destination = intent.getStringExtra(
            BayanTrackWidgetProvider.EXTRA_WIDGET_DESTINATION,
        ) ?: return
        pendingWidgetDestination = destination
        widgetChannel?.invokeMethod(
            BayanTrackWidgetProvider.METHOD_WIDGET_DESTINATION,
            destination,
        )
    }

    private fun takeInitialWidgetDestination(): String? {
        val destination = pendingWidgetDestination
            ?: intent?.getStringExtra(BayanTrackWidgetProvider.EXTRA_WIDGET_DESTINATION)
        pendingWidgetDestination = null
        intent?.removeExtra(BayanTrackWidgetProvider.EXTRA_WIDGET_DESTINATION)
        return destination
    }
}
