import WidgetKit
import SwiftUI
import AppIntents

struct MissionEntry: TimelineEntry {
    let date: Date
    let missions: [String]
}

struct MissionProvider: TimelineProvider {
    private let missions = [
        "Weekly grocery restock",
        "Movie night for 4",
        "Healthy breakfast for 2"
    ]

    func placeholder(in context: Context) -> MissionEntry {
        MissionEntry(date: Date(), missions: missions)
    }

    func getSnapshot(in context: Context, completion: @escaping (MissionEntry) -> Void) {
        completion(MissionEntry(date: Date(), missions: missions))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MissionEntry>) -> Void) {
        let entry = MissionEntry(date: Date(), missions: missions)
        completion(Timeline(entries: [entry], policy: .never))
    }
}

struct IntentoMissionsWidget: Widget {
    let kind = "IntentoMissionsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MissionProvider()) { entry in
            MissionWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Quick Missions")
        .description("Start a shopping mission from your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct MissionWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: MissionEntry

    private let brand = Color(red: 0.95, green: 0.75, blue: 0.14)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "cart.fill").foregroundStyle(brand)
                Text("Intento").font(.headline)
            }

            if family == .systemSmall {
                Text("Ask for anything.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button(intent: MakeMissionIntent(request: entry.missions.first ?? "Weekly restock")) {
                    Label("Start", systemImage: "sparkles")
                        .font(.caption.bold())
                }
                .buttonStyle(.borderedProminent)
                .tint(brand)
            } else {
                ForEach(entry.missions.prefix(3), id: \.self) { mission in
                    Button(intent: MakeMissionIntent(request: mission)) {
                        HStack {
                            Text(mission).font(.subheadline)
                            Spacer()
                            Image(systemName: "chevron.right").font(.caption)
                        }
                    }
                    .buttonStyle(.plain)
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
