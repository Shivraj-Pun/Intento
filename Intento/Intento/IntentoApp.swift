import SwiftUI
import SwiftData

@main
struct IntentoApp: App {
    @State private var container: AppContainer
    private let modelContainer: ModelContainer

    init() {
        let config = AppConfig.bootstrap()
        let schema = Schema([SavedMissionEntity.self, UserPreferenceEntity.self])

        let resolvedContainer: ModelContainer
        let store: PersonalizationStoring
        do {
            let modelContainer = try ModelContainer(for: schema)
            resolvedContainer = modelContainer
            store = SwiftDataPersonalizationStore(context: modelContainer.mainContext)
        } catch {
            let fallback = try! ModelContainer(
                for: schema,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            resolvedContainer = fallback
            store = InMemoryPersonalizationStore()
        }

        self.modelContainer = resolvedContainer
        _container = State(initialValue: AppContainer(config: config, personalization: store))
    }

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .modelContainer(modelContainer)
        }
    }
}
