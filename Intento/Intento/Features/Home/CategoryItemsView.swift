import SwiftUI

struct CategoryItemsView: View {
    let container: AppContainer
    let category: ProductCategory
    
    @State private var products: [Product] = []
    @State private var isLoading = true

    var body: some View {
        List {
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            } else if products.isEmpty {
                Text("No items found.")
                    .foregroundColor(AppColor.Semantic.textSecondary)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(products) { product in
                    NavigationLink(destination: ProductDetailView(product: product)) {
                        HStack(spacing: AppSpacing.md) {
                            ProductThumbnail(category: product.category, size: 50)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.displayTitle)
                                    .textStyle(.bodyMMedium)
                                    .foregroundColor(AppColor.Semantic.textPrimary)
                                Text(product.packSize.displayLabel)
                                    .textStyle(.caption)
                                    .foregroundColor(AppColor.Semantic.textTertiary)
                            }
                            Spacer()
                            Text(product.price.formatted(currencyCode: "INR", localeIdentifier: "en_IN"))
                                .textStyle(.bodyMMedium)
                                .foregroundColor(AppColor.Semantic.textPrimary)
                        }
                        .padding(.vertical, AppSpacing.sm)
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(category.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            isLoading = true
            products = (try? await container.catalog.products(in: category)) ?? []
            isLoading = false
        }
    }
}
