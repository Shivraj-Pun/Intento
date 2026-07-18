import SwiftUI

struct CartTabView: View {
    @Bindable var globalCart: GlobalCartViewModel
    @State private var orderConfirmation: OrderConfirmation?

    var body: some View {
        List {
            if globalCart.isEmpty {
                ContentUnavailableView(
                    "Your cart is empty",
                    systemImage: "cart",
                    description: Text("Browse categories to add items.")
                )
                .listRowSeparator(.hidden)
            } else {
                ForEach(globalCart.items) { item in
                    CartItemRow(
                        item: item,
                        priceText: item.lineTotal.formatted(currencyCode: "INR", localeIdentifier: "en_IN"),
                        onIncrement: { globalCart.increment(item) },
                        onDecrement: { globalCart.decrement(item) },
                        onReplace: { }
                    )
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            globalCart.remove(item)
                        } label: {
                            Label("Remove", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Intento")
        .safeAreaInset(edge: .bottom) {
            if !globalCart.isEmpty {
                VStack(spacing: AppSpacing.md) {
                    HStack {
                        Text("Total")
                            .textStyle(.headingM)
                            .foregroundColor(AppColor.Semantic.textPrimary)
                        Spacer()
                        Text(globalCart.subtotal.formatted(currencyCode: "INR", localeIdentifier: "en_IN"))
                            .textStyle(.headingL)
                            .foregroundColor(AppColor.Semantic.brandStrong)
                    }
                    
                    Button {
                        orderConfirmation = globalCart.placeOrder()
                    } label: {
                        Text("Place Order")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(AppButtonStyle(variant: .primary, size: .regular))
                }
                .padding(AppSpacing.lg)
                .background(AppColor.Semantic.surface)
                .appShadow(AppShadow.sm)
            }
        }
        .fullScreenCover(item: $orderConfirmation) { confirmation in
            NavigationStack {
                OrderConfirmationView(confirmation: confirmation) {
                    orderConfirmation = nil
                }
            }
        }
    }
}
