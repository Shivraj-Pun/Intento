import SwiftUI

struct OrderConfirmationView: View {
    let confirmation: OrderConfirmation
    let onDone: () -> Void

    @State private var appear = false

    var body: some View {
        VStack(spacing: AppSpacing.xxl) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 72))
                .foregroundStyle(AppColor.Semantic.success)
                .scaleEffect(appear ? 1 : 0.6)
                .opacity(appear ? 1 : 0)

            VStack(spacing: AppSpacing.xs) {
                Text("Order placed")
                    .textStyle(.headingM)
                    .foregroundStyle(AppColor.Semantic.textPrimary)
                Text(confirmation.orderNumber)
                    .textStyle(.code)
                    .foregroundStyle(AppColor.Semantic.textSecondary)
            }

            VStack(spacing: AppSpacing.md) {
                summaryRow("Items", "\(confirmation.itemCount)")
                Divider()
                summaryRow("Total", confirmation.total.displayString)
                if let eta = confirmation.etaMinutes {
                    Divider()
                    summaryRow("Arriving in", "\(eta) min")
                }
            }
            .padding(AppSpacing.lg)
            .background(
                RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                    .fill(AppColor.Semantic.surface)
            )
            .appShadow(AppShadow.sm)

            Spacer()

            Button("Done", action: onDone)
                .buttonStyle(AppButtonStyle(variant: .primary, size: .regular, fullWidth: true))
        }
        .padding(Theme.screenPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.Semantic.background.ignoresSafeArea())
        .navigationTitle("Confirmation")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { appear = true }
        }
    }

    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .textStyle(.bodyMRegular)
                .foregroundStyle(AppColor.Semantic.textSecondary)
            Spacer()
            Text(value)
                .textStyle(.bodyMBold)
                .foregroundStyle(AppColor.Semantic.textPrimary)
        }
    }
}
