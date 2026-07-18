import SwiftUI
import Combine

struct OrderHistoryView: View {
    let cartService: CartPersisting
    let user: AppUser
    
    @State private var pastOrders: [Cart] = []
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if pastOrders.isEmpty {
                ContentUnavailableView(
                    "No Previous Orders",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Orders you check out will appear here.")
                )
            } else {
                List {
                    ForEach(pastOrders) { order in
                        Section {
                            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                HStack {
                                    Text(orderTitle(for: order))
                                        .textStyle(.headingXS)
                                        .foregroundStyle(AppColor.Semantic.textPrimary)
                                        .lineLimit(2)
                                    Spacer()
                                    Text(order.subtotal.formatted(currencyCode: "INR", localeIdentifier: "en_IN"))
                                        .textStyle(.bodySMedium)
                                        .foregroundStyle(AppColor.Semantic.brandStrong)
                                }
                                
                                Text(order.createdAt.formatted(date: .abbreviated, time: .shortened))
                                    .textStyle(.caption)
                                    .foregroundStyle(AppColor.Semantic.textSecondary)
                                
                                Divider()
                                    .padding(.vertical, AppSpacing.xs)
                                
                                ForEach(order.items) { item in
                                    HStack(spacing: AppSpacing.sm) {
                                        Text("\(item.quantity)x")
                                            .textStyle(.bodySMedium)
                                            .foregroundStyle(AppColor.Semantic.textSecondary)
                                            .frame(width: 28, alignment: .leading)
                                        
                                        Text(item.product.displayTitle)
                                            .textStyle(.bodySRegular)
                                            .foregroundStyle(AppColor.Semantic.textPrimary)
                                            .lineLimit(1)
                                        
                                        Spacer()
                                        
                                        Text(item.lineTotal.formatted(currencyCode: "INR", localeIdentifier: "en_IN"))
                                            .textStyle(.bodySRegular)
                                            .foregroundStyle(AppColor.Semantic.textSecondary)
                                    }
                                }
                            }
                            .padding(.vertical, AppSpacing.xs)
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Order History")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadOrders()
        }
    }
    
    private func loadOrders() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            pastOrders = try await cartService.pastOrders(userID: user.id)
        } catch {
            print("[Intento] ⚠️ Failed to load past orders: \(error)")
        }
    }
    
    private func orderTitle(for cart: Cart) -> String {
        if let first = cart.items.first {
            if cart.items.count == 1 {
                return first.product.displayTitle
            } else {
                return "\(first.product.displayTitle) & \(cart.items.count - 1) other\(cart.items.count - 1 == 1 ? "" : "s")"
            }
        }
        return "Quick Order"
    }
}
