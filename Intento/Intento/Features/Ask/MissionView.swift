import SwiftUI

struct MissionView: View {
    let container: AppContainer
    let seed: MissionSeed
    let onItemsAdded: () -> Void

    @Environment(GlobalCartViewModel.self) private var globalCart
    @State private var ask: AskViewModel
    @State private var cart: CartViewModel?
    @State private var didStart = false
    @State private var showAddedConfirmation = false

    init(container: AppContainer, seed: MissionSeed, onItemsAdded: @escaping () -> Void) {
        self.container = container
        self.seed = seed
        self.onItemsAdded = onItemsAdded
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
        .overlay {
            if showAddedConfirmation {
                addedOverlay
            }
        }
        .task {
            guard !didStart else { return }
            didStart = true
            await ask.submit()
            startCartIfReady()
        }
    }

    private var readyContent: some View {
        VStack(spacing: 0) {
            if let cart {
                CartContentView(vm: cart, onAddToCart: addToGlobalCart)
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
            Text("Try rephrasing your request.")
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

    private var addedOverlay: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(AppColor.Semantic.success)
            Text("Items added to cart!")
                .textStyle(.headingXS)
                .foregroundStyle(AppColor.Semantic.textPrimary)
        }
        .padding(AppSpacing.xxl)
        .background(
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(AppColor.Semantic.surface)
        )
        .appShadow(AppShadow.md)
        .transition(.scale.combined(with: .opacity))
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

    private func addToGlobalCart() {
        guard let cart else { return }
        for item in cart.cart.items {
            for _ in 0..<item.quantity {
                globalCart.add(item.product)
            }
        }
        withAnimation(.spring(duration: 0.4)) {
            showAddedConfirmation = true
        }
        ask.haptics.play(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            showAddedConfirmation = false
            onItemsAdded()
        }
    }
}
