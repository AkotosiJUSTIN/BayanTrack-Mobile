import SwiftUI
import WidgetKit

private let widgetSuiteName = "group.com.example.bayantrackMobile"

struct FastReportEntry: TimelineEntry {
  let date: Date
  let locale: String
  let authenticated: Bool
  let status: String
}

struct FastReportProvider: TimelineProvider {
  func placeholder(in context: Context) -> FastReportEntry {
    FastReportEntry(date: Date(), locale: "en", authenticated: true, status: "ready")
  }

  func getSnapshot(in context: Context, completion: @escaping (FastReportEntry) -> Void) {
    completion(currentEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<FastReportEntry>) -> Void) {
    let entry = currentEntry()
    completion(Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(300))))
  }

  private func currentEntry() -> FastReportEntry {
    let defaults = UserDefaults(suiteName: widgetSuiteName)
    var status = defaults?.string(forKey: "fast_report_status") ?? "ready"
    let updatedAt = defaults?.double(forKey: "fast_report_status_updated_at") ?? 0
    let age = Date().timeIntervalSince1970 - updatedAt
    if status == "submitting" && age > 120 { status = "ready" }
    if status == "submitted" && age > 300 { status = "ready" }
    return FastReportEntry(
      date: Date(),
      locale: defaults?.string(forKey: "locale") ?? "en",
      authenticated: defaults?.bool(forKey: "authenticated") ?? false,
      status: status
    )
  }
}

struct BayanTrackWidgetView: View {
  @Environment(\.widgetFamily) private var family
  let entry: FastReportEntry

  private var isFilipino: Bool { entry.locale == "fil" }

  private var statusLabel: String {
    guard entry.authenticated else { return isFilipino ? "Mag-sign in" : "Sign in" }
    switch entry.status {
    case "submitting": return isFilipino ? "Isinusumite" : "Submitting"
    case "submitted": return isFilipino ? "Naisumite" : "Submitted"
    case "failed": return isFilipino ? "Nabigo" : "Failed"
    case "networkUnavailable": return isFilipino ? "Offline / Subukan muli" : "Offline / Retry"
    default: return isFilipino ? "Handa" : "Ready"
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Label("BayanTrack", systemImage: "location.shield.fill")
        .font(.caption.bold())
      Text("Emergency Report")
        .font(.headline)
      Text(statusLabel)
        .font(.caption)
        .foregroundStyle(.secondary)
      Spacer(minLength: 0)
      Link(destination: URL(string: "bayantrack://fast-report")!) {
        Label("Emergency Report", systemImage: "bolt.fill")
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      if family != .systemSmall {
        Link(destination: URL(string: "bayantrack://home")!) {
          Text(isFilipino ? "Buksan ang BayanTrack" : "Open BayanTrack")
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
      }
    }
    .padding()
    .background(Color(.systemBackground))
  }
}

@main
struct BayanTrackWidget: Widget {
  let kind = "BayanTrackFastReportWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: FastReportProvider()) { entry in
      BayanTrackWidgetView(entry: entry)
    }
    .configurationDisplayName("BayanTrack Emergency Report")
    .description("Open an Emergency Report or the BayanTrack dashboard.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
