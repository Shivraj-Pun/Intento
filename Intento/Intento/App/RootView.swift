import SwiftUI

struct RootView: View {
    let container: AppContainer

    @State private var path: [AppRoute] = []
    @State private var pending = PendingMissionCenter.shared
    @State private var globalCart: GlobalCartViewModel
    
    @State private var selectedTab: Int = 0

    init(container: AppContainer) {
        self.container = container
        _globalCart = State(initialValue: container.makeGlobalCartViewModel())
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $path) {
                AskTabView(
                    container: container,
                    onSubmit: { prompt in path.append(.mission(MissionSeed(prompt: prompt))) },
                    onOpenSettings: { path.append(.settings) }
                )
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .mission(let seed):
                        MissionView(
                            container: container,
                            seed: seed,
                            onItemsAdded: {
                                path.removeAll()
                                selectedTab = 2
                            }
                        )
                    case .order(let confirmation):
                        OrderConfirmationView(confirmation: confirmation) {
                            path.removeAll()
                        }
                    case .settings:
                        SettingsView(
                            viewModel: container.makePersonalizationViewModel(),
                            config: container.config,
                            authService: container.auth,
                            cartService: container.cartService
                        )
                    }
                }
            }
            .tabItem {
                Label("Ask", systemImage: "sparkles")
            }
            .tag(0)

            NavigationStack {
                AppHomeView(container: container, selectedTab: $selectedTab)
            }
            .tabItem {
                Label("Shop", systemImage: "house")
            }
            .tag(1)
            
            NavigationStack {
                CartTabView(globalCart: globalCart)
            }
            .tabItem {
                Label("Cart", systemImage: "cart")
            }
            .badge(globalCart.items.count > 0 ? globalCart.items.count : 0)
            .tag(2)
        }
        .environment(globalCart)
        .tint(AppColor.Semantic.brandStrong)
        .onChange(of: pending.pendingPrompt) { _, newValue in
            handlePending(newValue)
        }
        .onAppear { handlePending(pending.pendingPrompt) }
        .task {
            await globalCart.loadIfNeeded()
        }
    }

    private func handlePending(_ prompt: String?) {
        guard let prompt, !prompt.isEmpty else { return }

        // Consume structured mission data if available
        let mission = pending.consume()
        let resolvedPrompt = mission?.prompt ?? prompt

        selectedTab = 0 // Switch to Ask tab

        // Build a richer prompt that embeds Siri parameters so the intent extractor can use them
        var enrichedPrompt = resolvedPrompt
        if let count = mission?.peopleCount, !resolvedPrompt.lowercased().contains("\(count) people") {
            enrichedPrompt += " for \(count) people"
        }
        if let budget = mission?.budget, !resolvedPrompt.lowercased().contains("budget") {
            enrichedPrompt += " within ₹\(budget) budget"
        }
        if let dietary = mission?.dietaryConstraints, !dietary.isEmpty {
            let joined = dietary.joined(separator: ", ")
            if !resolvedPrompt.lowercased().contains(joined.lowercased()) {
                enrichedPrompt += " (\(joined))"
            }
        }

        path.append(.mission(MissionSeed(prompt: enrichedPrompt)))
    }
}
