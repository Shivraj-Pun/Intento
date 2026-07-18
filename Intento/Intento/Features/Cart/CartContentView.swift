import SwiftUI

struct CartContentView: View {
    let vm: CartViewModel
    let onOrderPlaced: (OrderConfirmation) -> Void

    @State private var replacingItem: CartItem?

    var body: some View {
        List {
            if vm.phase == .generating {
                Section {
                    generatingBanner
                }
            }

            optionsSection

            if !vm.visibleSustainabilitySuggestions.isEmpty {
                sustainabilitySection
            }

            if vm.nutritionAware {
                nutritionSection
            }

            ForEach(vm.cart.categories) { category in
                Section(category.displayName) {
                    ForEach(vm.cart.items(in: category)) { item in
                        CartItemRow(
                            item: item,
                            priceText: vm.format(item.lineTotal),
                            onIncrement: { vm.increment(item) },
                            onDecrement: { vm.decrement(item) },
                            onReplace: { replacingItem = item }
                        )
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                vm.remove(item)
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                }
            }

            if vm.phase == .ready && vm.cart.isEmpty {
                emptyState
            }
        }
        .listStyle(.insetGrouped)
        .animation(.easeInOut(duration: 0.25), value: vm.cart.items.count)
        .safeAreaInset(edge: .bottom) {
            BudgetSummaryBar(
                itemCount: vm.cart.itemCount,
                totalText: vm.format(vm.cart.subtotal),
                budgetText: vm.cart.budget.map { vm.format($0) },
                status: vm.budgetStatus,
                etaMinutes: vm.cart.estimatedETAMinutes,
                isCheckingOut: vm.isCheckingOut,
                isDisabled: vm.cart.isEmpty,
                onCheckout: checkout
            )
        }
        .sheet(item: $replacingItem) { item in
            AlternativesSheet(vm: vm, item: item)
        }
    }

    private var generatingBanner: some View {
        HStack(spacing: AppSpacing.md) {
            ProgressView()
            VStack(alignment: .leading, spacing: 2) {
                Text("Building your cart")
                    .textStyle(.bodyMMedium)
                    .foregroundStyle(AppColor.Semantic.textPrimary)
                Text("Adding items, prices and ETA")
                    .textStyle(.caption)
                    .foregroundStyle(AppColor.Semantic.textSecondary)
            }
        }
    }

    private var optionsSection: some View {
        Section {
            if vm.cart.budget != nil {
                Toggle(isOn: Binding(get: { vm.fitToBudget }, set: { _ in vm.toggleFitToBudget() })) {
                    Label("Fit to budget", systemImage: "indianrupeesign.circle")
                }
                .tint(AppColor.Semantic.brandStrong)
            }
            Toggle(isOn: Binding(get: { vm.nutritionAware }, set: { vm.setNutritionAware($0) })) {
                Label("Healthier swaps", systemImage: "heart.text.square")
            }
            .tint(AppColor.Semantic.brandStrong)
        }
    }

    private var sustainabilitySection: some View {
        Section("Sustainable options") {
            ForEach(vm.visibleSustainabilitySuggestions) { suggestion in
                HStack(spacing: AppSpacing.md) {
                    Image(systemName: "leaf.fill")
                        .foregroundStyle(AppColor.Semantic.success)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(suggestion.suggestedName)
                            .textStyle(.bodySMedium)
                            .foregroundStyle(AppColor.Semantic.textPrimary)
                        if let message = suggestion.message {
                            Text(message)
                                .textStyle(.caption)
                                .foregroundStyle(AppColor.Semantic.textSecondary)
                        }
                    }
                    Spacer()
                    Button("Swap") {
                        Task { await vm.applySuggestion(suggestion) }
                    }
                    .buttonStyle(AppButtonStyle(variant: .secondary, size: .small))
                }
                .swipeActions {
                    Button {
                        vm.dismissSuggestion(suggestion)
                    } label: {
                        Label("Dismiss", systemImage: "xmark")
                    }
                }
            }
        }
    }

    private var nutritionSection: some View {
        Section("Healthier swaps") {
            let candidates = vm.cart.items.filter { $0.product.healthierAlternativeSKU != nil }
            if candidates.isEmpty {
                Text("Your cart already looks healthy.")
                    .textStyle(.bodySRegular)
                    .foregroundStyle(AppColor.Semantic.textSecondary)
            } else {
                ForEach(candidates) { item in
                    NutritionSwapRow(vm: vm, item: item)
                }
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "Your cart is empty",
            systemImage: "cart",
            description: Text("Adjust the assumptions above or start a new mission.")
        )
    }

    private func checkout() {
        Task {
            await vm.checkout()
            if let confirmation = vm.orderConfirmation {
                onOrderPlaced(confirmation)
            }
        }
    }
}

private struct NutritionSwapRow: View {
    let vm: CartViewModel
    let item: CartItem
    @State private var alternative: Product?
    @State private var isLoading = false

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "heart.fill")
                .foregroundStyle(AppColor.Semantic.success)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.product.displayTitle)
                    .textStyle(.bodySMedium)
                    .foregroundStyle(AppColor.Semantic.textPrimary)
                if let alternative {
                    Text("Try \(alternative.displayTitle)")
                        .textStyle(.caption)
                        .foregroundStyle(AppColor.Semantic.textSecondary)
                }
            }
            Spacer()
            if let alternative {
                Button("Swap") { vm.replace(item, with: alternative) }
                    .buttonStyle(AppButtonStyle(variant: .secondary, size: .small))
            } else if isLoading {
                ProgressView()
            }
        }
        .task {
            isLoading = true
            alternative = await vm.healthierAlternative(for: item)
            isLoading = false
        }
    }
}

private struct AlternativesSheet: View {
    let vm: CartViewModel
    let item: CartItem
    @Environment(\.dismiss) private var dismiss
    @State private var products: [Product] = []
    @State private var isLoading = true

    var body: some View {
        NavigationStack {
            List {
                if isLoading {
                    HStack { Spacer(); ProgressView(); Spacer() }
                } else if products.isEmpty {
                    Text("No alternatives available right now.")
                        .foregroundStyle(AppColor.Semantic.textSecondary)
                } else {
                    ForEach(products) { product in
                        Button {
                            vm.replace(item, with: product)
                            dismiss()
                        } label: {
                            HStack(spacing: AppSpacing.md) {
                                ProductThumbnail(category: product.category, size: 38)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(product.displayTitle)
                                        .textStyle(.bodyMMedium)
                                        .foregroundStyle(AppColor.Semantic.textPrimary)
                                    Text(product.packSize.displayLabel)
                                        .textStyle(.caption)
                                        .foregroundStyle(AppColor.Semantic.textTertiary)
                                }
                                Spacer()
                                Text(vm.format(product.price))
                                    .textStyle(.bodyMMedium)
                                    .foregroundStyle(AppColor.Semantic.textPrimary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Choose a replacement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .task {
                products = await vm.alternatives(for: item)
                isLoading = false
            }
        }
    }
}
