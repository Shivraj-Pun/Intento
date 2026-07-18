import SwiftUI

struct MissionView: View {
    let container: AppContainer
    let seed: MissionSeed
    let onOrderPlaced: (OrderConfirmation) -> Void

    @State private var ask: AskViewModel
    @State private var cart: CartViewModel?
    @State private var didStart = false

    init(container: AppContainer, seed: MissionSeed, onOrderPlaced: @escaping (OrderConfirmation) -> Void) {
        self.container = container
        self.seed = seed
        self.onOrderPlaced = onOrderPlaced
        _ask = State(initialValue: container.makeAskViewModel(initialText: seed.prompt))
    }

    var body: some View {
        Group {
            switch ask.phase {
            case .idle, .understanding:
                UnderstandingView(prompt: seed.prompt)
            case .failed:
                failedState
            case .ready:
                readyContent
            }
        }
        .navigationTitle("Your cart")
        .navigationBarTitleDisplayMode(.inline)
        .background(AppColor.Semantic.background.ignoresSafeArea())
        .task {
            guard !didStart else { return }
            didStart = true
            await ask.submit()
            startCartIfReady()
        }
    }

    private var readyContent: some View {
        VStack(spacing: 0) {
            AssumptionChipsBar(
                assumptions: ask.assumptions,
                confidence: ask.confidence,
                confidenceLevel: ask.confidenceLevel,
                onEdit: handleEdit
            )
            Divider()
            if let cart {
                CartContentView(vm: cart, onOrderPlaced: onOrderPlaced)
            } else if ask.needsClarification {
                clarificationPrompt
            } else {
                Color.clear.onAppear { startCartIfReady() }
            }
        }
    }

    private var clarificationPrompt: some View {
        VStack(spacing: AppSpacing.lg) {
            Spacer()
            Image(systemName: "questionmark.bubble")
                .font(.largeTitle)
                .foregroundStyle(AppColor.Semantic.warning)
            Text("I'm not fully sure I got that")
                .textStyle(.headingXS)
                .foregroundStyle(AppColor.Semantic.textPrimary)
            Text("Tweak the chips above so the cart is right, then build it.")
                .textStyle(.bodyMRegular)
                .foregroundStyle(AppColor.Semantic.textSecondary)
                .multilineTextAlignment(.center)
            Button("Build cart anyway") { startCart() }
                .buttonStyle(AppButtonStyle(variant: .primary))
            Spacer()
        }
        .padding(Theme.screenPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var failedState: some View {
        ContentUnavailableView {
            Label("Couldn't understand that", systemImage: "exclamationmark.triangle")
        } description: {
            Text(ask.errorMessage ?? "Please try again.")
        } actions: {
            Button("Try again") {
                Task {
                    await ask.submit()
                    startCartIfReady()
                }
            }
            .buttonStyle(AppButtonStyle(variant: .primary))
        }
    }

    private func startCartIfReady() {
        guard cart == nil, ask.phase == .ready, !ask.needsClarification, ask.intent != nil else { return }
        startCart()
    }

    private func startCart() {
        guard let intent = ask.intent else { return }
        let viewModel = container.makeCartViewModel(intent: intent)
        viewModel.start()
        cart = viewModel
    }

    private func handleEdit(_ field: AssumptionField, _ newValue: String) {
        ask.updateAssumption(field, to: newValue)
        guard let intent = ask.intent else { return }
        if let cart {
            cart.regenerate(with: intent)
        } else {
            startCartIfReady()
        }
    }
}
