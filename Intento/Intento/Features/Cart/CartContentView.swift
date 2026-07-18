import SwiftUI

struct CartContentView: View {
    let vm: CartViewModel
    let onAddToCart: () -> Void

    @State private var replacingItem: CartItem?

    var body: some View {
        List {
            if vm.phase == .generating {
                Section {
                    generatingBanner
                }
            }

            if vm.cart.budget != nil {
                Section {
                    Toggle(isOn: Binding(get: { vm.fitToBudget }, set: { _ in vm.toggleFitToBudget() })) {
                        Label("Fit to budget", systemImage: "indianrupeesign.circle")
                    }
                    .tint(AppColor.Semantic.brandStrong)
                }
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
            addToCartBar
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

    private var addToCartBar: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(alignment: .center, spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(vm.format(vm.cart.subtotal))
                        .textStyle(.headingXS)
                        .foregroundStyle(AppColor.Semantic.textPrimary)
                        .contentTransition(.numericText())

                    HStack(spacing: AppSpacing.xs) {
                        Text("\(vm.cart.itemCount) items")
                            .textStyle(.caption)
                            .foregroundStyle(AppColor.Semantic.textSecondary)
                        if let etaMinutes = vm.cart.estimatedETAMinutes {
                            Text("· \(etaMinutes) min")
                                .textStyle(.caption)
                                .foregroundStyle(AppColor.Semantic.textTertiary)
                        }
                    }
                }

                Spacer()

                Button(action: onAddToCart) {
                    Text("Add to Cart")
                }
                .buttonStyle(AppButtonStyle(variant: .primary))
                .disabled(vm.cart.isEmpty || vm.phase != .ready)
            }
            .padding(.horizontal, Theme.screenPadding)
            .padding(.vertical, AppSpacing.md)
            .background(AppColor.Semantic.surface)
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "Your cart is empty",
            systemImage: "cart",
            description: Text("Adjust the assumptions above or start a new mission.")
        )
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
