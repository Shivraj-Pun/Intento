import SwiftUI
import SwiftData

@main
struct IntentoApp: App {
    @State private var container: AppContainer
    private let modelContainer: ModelContainer

    init() {
        let config = AppConfig.bootstrap()
        let schema = Schema([SavedMissionEntity.self, UserPreferenceEntity.self, AppUser.self])

        let resolvedContainer: ModelContainer
        let store: PersonalizationStoring
        let authService: AuthServicing
        do {
            let modelContainer = try ModelContainer(for: schema)
            resolvedContainer = modelContainer
            store = SwiftDataPersonalizationStore(context: modelContainer.mainContext)
            authService = MockSwiftDataAuthService(modelContext: modelContainer.mainContext)
        } catch {
            let fallback = try! ModelContainer(
                for: schema,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            resolvedContainer = fallback
            store = InMemoryPersonalizationStore()
            authService = MockSwiftDataAuthService(modelContext: fallback.mainContext) // Or a different mock if needed
        }

        self.modelContainer = resolvedContainer
        _container = State(initialValue: AppContainer(config: config, personalization: store, auth: authService))
    }

    @State private var showSplash = true
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ZStack {
                AppCoordinatorView(container: container)
                    .modelContainer(modelContainer)
                
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                triggerSplash()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active, oldPhase == .background {
                    triggerSplash()
                }
            }
        }
    }
    
    private func triggerSplash() {
        showSplash = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showSplash = false
            }
        }
    }
}
