import SwiftUI

struct CartItemRow: View {
    let item: CartItem
    let priceText: String
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    let onReplace: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            ProductThumbnail(category: item.product.category)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(item.product.displayTitle)
                    .textStyle(.bodyMMedium)
                    .foregroundStyle(AppColor.Semantic.textPrimary)
                    .lineLimit(2)

                Text(item.product.packSize.displayLabel)
                    .textStyle(.caption)
                    .foregroundStyle(AppColor.Semantic.textTertiary)

                if let record = item.substitution {
                    HStack(spacing: AppSpacing.sm) {
                        SubstitutionBadge(record: record)
                        Button("Change", action: onReplace)
                            .textStyle(.caption)
                            .foregroundStyle(AppColor.Semantic.brandStrong)
                    }
                    .padding(.top, 2)
                }

                Text(priceText)
                    .textStyle(.bodyMBold)
                    .foregroundStyle(AppColor.Semantic.textPrimary)
                    .padding(.top, 2)
            }

            Spacer(minLength: AppSpacing.sm)

            QuantityStepper(quantity: item.quantity, onIncrement: onIncrement, onDecrement: onDecrement)
        }
        .padding(.vertical, AppSpacing.xs)
    }
}

struct QuantityStepper: View {
    let quantity: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Button(action: onDecrement) {
                Image(systemName: quantity <= 1 ? "trash" : "minus")
                    .font(.footnote.weight(.semibold))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .foregroundStyle(AppColor.Semantic.brandStrong)

            Text("\(quantity)")
                .textStyle(.bodyMBold)
                .frame(minWidth: 20)
                .contentTransition(.numericText())

            Button(action: onIncrement) {
                Image(systemName: "plus")
                    .font(.footnote.weight(.semibold))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .foregroundStyle(AppColor.Semantic.brandStrong)
        }
        .padding(.horizontal, AppSpacing.xs)
        .padding(.vertical, 2)
        .background(
            Capsule(style: .continuous).fill(AppColor.Primary.s50)
        )
        .overlay(
            Capsule(style: .continuous).strokeBorder(AppColor.Primary.s200, lineWidth: 1)
        )
    }
}
