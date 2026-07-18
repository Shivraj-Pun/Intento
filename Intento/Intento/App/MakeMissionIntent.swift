import AppIntents

struct MakeMissionIntent: AppIntent {
    static var title: LocalizedStringResource = "Make a shopping cart"
    static var description = IntentDescription("Describe a shopping goal and Intento builds the cart.")
    static var openAppWhenRun = true

    @Parameter(title: "Request", requestValueDialog: "What should I shop for?")
    var request: String

    init() {}

    init(request: String) {
        self.request = request
    }

    @MainActor
    func perform() async throws -> some IntentResult {
        PendingMissionCenter.shared.submit(request)
        return .result()
    }
}

struct IntentoShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: MakeMissionIntent(),
            phrases: [
                "Start a shopping mission with \(.applicationName)",
                "Make a cart with \(.applicationName)",
                "Shop with \(.applicationName)"
            ],
            shortTitle: "Make a cart",
            systemImageName: "cart.badge.plus"
        )
    }
}
