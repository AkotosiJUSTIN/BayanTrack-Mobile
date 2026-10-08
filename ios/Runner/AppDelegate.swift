import Flutter
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let widgetChannelName = "bayantrack/widget"
  private let widgetSuiteName = "group.com.example.bayantrackMobile"
  private var widgetChannel: FlutterMethodChannel?
  private var pendingWidgetDestination: String?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: widgetChannelName,
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] call, result in
        guard let self else { return }
        switch call.method {
        case "getInitialWidgetDestination":
          result(self.takePendingWidgetDestination())
        case "acknowledgeWidgetDestination":
          if let destination = call.arguments as? String,
             destination == self.pendingWidgetDestination {
            self.pendingWidgetDestination = nil
          }
          result(nil)
        case "updateState":
          self.updateWidgetState(call.arguments)
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
      widgetChannel = channel
    }
    if let url = launchOptions?[.url] as? URL {
      routeWidgetURL(url, notifyFlutter: false)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    if routeWidgetURL(url, notifyFlutter: true) { return true }
    return super.application(app, open: url, options: options)
  }

  private func routeWidgetURL(_ url: URL, notifyFlutter: Bool) -> Bool {
    guard url.scheme?.lowercased() == "bayantrack" else { return false }
    let destination: String?
    switch url.host?.lowercased() {
    case "fast-report": destination = "fast_report"
    case "home": destination = "open_app"
    default: destination = nil
    }
    guard let destination else { return false }
    pendingWidgetDestination = destination
    if notifyFlutter {
      widgetChannel?.invokeMethod("widgetDestination", arguments: destination)
    }
    return true
  }

  private func takePendingWidgetDestination() -> String? {
    let destination = pendingWidgetDestination
    pendingWidgetDestination = nil
    return destination
  }

  private func updateWidgetState(_ arguments: Any?) {
    guard let state = arguments as? [String: Any],
          let defaults = UserDefaults(suiteName: widgetSuiteName) else { return }
    defaults.set(state["locale"] as? String ?? "en", forKey: "locale")
    defaults.set(state["authenticated"] as? Bool ?? false, forKey: "authenticated")
    defaults.set(
      state["quickReportStatus"] as? String ?? "ready",
      forKey: "fast_report_status"
    )
    defaults.set(Date().timeIntervalSince1970, forKey: "fast_report_status_updated_at")
    if #available(iOS 14.0, *) {
      WidgetCenter.shared.reloadAllTimelines()
    }
  }
}
