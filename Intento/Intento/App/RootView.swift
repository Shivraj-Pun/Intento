import SwiftUI

struct RootView: View {
    let container: AppContainer

    @State private var path: [AppRoute] = []
    @State private var pending = PendingMissionCenter.shared

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(
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
                        onOrderPlaced: { confirmation in path.append(.order(confirmation)) }
                    )
                case .order(let confirmation):
                    OrderConfirmationView(confirmation: confirmation) {
                        path.removeAll()
                    }
                case .settings:
                    SettingsView(viewModel: container.makePersonalizationViewModel(), config: container.config)
                }
            }
        }
        .tint(AppColor.Semantic.brandStrong)
        .onChange(of: pending.pendingPrompt) { _, newValue in
            handlePending(newValue)
        }
        .onAppear { handlePending(pending.pendingPrompt) }
    }

    private func handlePending(_ prompt: String?) {
        guard let prompt, !prompt.isEmpty else { return }
        pending.pendingPrompt = nil
        path.append(.mission(MissionSeed(prompt: prompt)))
    }
}
