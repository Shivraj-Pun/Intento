import SwiftUI

struct BudgetSummaryBar: View {
    let itemCount: Int
    let totalText: String
    let budgetText: String?
    let status: BudgetStatus
    let etaMinutes: Int?
    let isCheckingOut: Bool
    let isDisabled: Bool
    let onCheckout: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(alignment: .center, spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(totalText)
                        .textStyle(.headingXS)
                        .foregroundStyle(AppColor.Semantic.textPrimary)
                        .contentTransition(.numericText())

                    HStack(spacing: AppSpacing.xs) {
                        Circle()
                            .fill(AppColor.color(for: status))
                            .frame(width: 8, height: 8)
                        Text(statusText)
                            .textStyle(.caption)
                            .foregroundStyle(AppColor.Semantic.textSecondary)
                        if let etaMinutes {
                            Text("· \(etaMinutes) min")
                                .textStyle(.caption)
                                .foregroundStyle(AppColor.Semantic.textTertiary)
                        }
                    }
                }

                Spacer()

                Button(action: onCheckout) {
                    if isCheckingOut {
                        ProgressView()
                            .frame(maxWidth: 140)
                    } else {
                        Text("Checkout · \(itemCount)")
                    }
                }
                .buttonStyle(AppButtonStyle(variant: .primary))
                .disabled(isDisabled || isCheckingOut)
            }
            .padding(.horizontal, Theme.screenPadding)
            .padding(.vertical, AppSpacing.md)
            .background(AppColor.Semantic.surface)
        }
    }

    private var statusText: String {
        if let budgetText {
            return "\(status.displayName) · \(budgetText)"
        }
        return status.displayName
    }
}
