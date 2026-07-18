import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @Environment(GlobalCartViewModel.self) private var globalCart
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                // Image Placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.cardRadius)
                        .fill(AppColor.Semantic.surface)
                        .frame(height: 250)
                    
                    Image(systemName: product.category.iconName)
                        .font(.system(size: 80))
                        .foregroundColor(AppColor.Semantic.brandStrong)
                }
                .padding(.horizontal, Theme.screenPadding)

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(product.displayTitle)
                        .textStyle(.headingL)
                        .foregroundColor(AppColor.Semantic.textPrimary)
                    
                    Text(product.packSize.displayLabel)
                        .textStyle(.bodyMRegular)
                        .foregroundColor(AppColor.Semantic.textSecondary)

                    Text(product.price.formatted(currencyCode: "INR", localeIdentifier: "en_IN"))
                        .textStyle(.headingM)
                        .foregroundColor(AppColor.Semantic.textPrimary)
                        .padding(.top, AppSpacing.sm)
                }
                .padding(.horizontal, Theme.screenPadding)
                
                // Add to Cart Button
                Button {
                    globalCart.add(product)
                    dismiss()
                } label: {
                    Text("Add to Cart")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(AppButtonStyle(variant: .primary, size: .regular))
                .padding(.horizontal, Theme.screenPadding)
                .padding(.top, AppSpacing.xl)
            }
            .padding(.vertical, AppSpacing.lg)
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .background(AppColor.Semantic.background.ignoresSafeArea())
    }
}
