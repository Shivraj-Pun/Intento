import SwiftUI

struct UnderstandingView: View {
    let prompt: String
    @State private var animate = false

    var body: some View {
        VStack(spacing: AppSpacing.xxl) {
            Spacer()

            Image(systemName: "sparkles")
                .font(.system(size: 44))
                .foregroundStyle(AppColor.Semantic.brandStrong)
                .symbolEffect(.variableColor.iterative, isActive: true)

            VStack(spacing: AppSpacing.sm) {
                Text("Understanding your request")
                    .textStyle(.headingXS)
                    .foregroundStyle(AppColor.Semantic.textPrimary)
                Text("\u{201C}\(prompt)\u{201D}")
                    .textStyle(.bodyMRegular)
                    .foregroundStyle(AppColor.Semantic.textSecondary)
                    .multilineTextAlignment(.center)
            }

            FlowLayout(spacing: AppSpacing.sm) {
                ForEach(0..<5, id: \.self) { index in
                    Capsule()
                        .fill(AppColor.Semantic.surfaceMuted)
                        .frame(width: placeholderWidths[index], height: 30)
                        .opacity(animate ? 0.4 : 1.0)
                        .animation(
                            .easeInOut(duration: 0.8).repeatForever().delay(Double(index) * 0.12),
                            value: animate
                        )
                }
            }
            .frame(maxWidth: 320)

            Spacer()
        }
        .padding(Theme.screenPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.Semantic.background.ignoresSafeArea())
        .onAppear { animate = true }
    }

    private let placeholderWidths: [CGFloat] = [90, 120, 70, 140, 100]
}
