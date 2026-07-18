import SwiftUI
import SwiftData

@main
struct IntentoApp: App {
    @State private var container: AppContainer
    private let modelContainer: ModelContainer

    init() {
        let config = AppConfig.bootstrap()
        let schema = Schema([SavedMissionEntity.self, UserPreferenceEntity.self, AppUser.self])

        let authService: AuthServicing = SupabaseAuthService()

        let resolvedContainer: ModelContainer
        let localStore: PersonalizationStoring
        do {
            let modelContainer = try ModelContainer(for: schema)
            resolvedContainer = modelContainer
            localStore = SwiftDataPersonalizationStore(context: modelContainer.mainContext)
        } catch {
            let fallback = try! ModelContainer(
                for: schema,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
            resolvedContainer = fallback
            localStore = InMemoryPersonalizationStore()
        }

        // Missions persist to Supabase; preferences delegate to the local store.
        let store: PersonalizationStoring = SupabasePersonalizationStore(
            client: SupabaseManager.client,
            auth: authService,
            local: localStore
        )

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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showSplash = false
            }
        }
    }
}
