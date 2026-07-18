import SwiftUI

struct MissionInputBar: View {
    @Binding var text: String
    let isListening: Bool
    let placeholder: String
    let onMic: () -> Void
    let onSubmit: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "sparkle.magnifyingglass")
                .foregroundStyle(AppColor.Semantic.textTertiary)

            TextField(placeholder, text: $text, axis: .vertical)
                .textStyle(.bodyMRegular)
                .focused($isFocused)
                .lineLimit(1...4)
                .submitLabel(.go)
                .onSubmit(onSubmit)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColor.Semantic.textTertiary)
                }
                .buttonStyle(.plain)
            }

            Button(action: onMic) {
                Image(systemName: isListening ? "waveform.circle.fill" : "mic.fill")
                    .font(.title3)
                    .foregroundStyle(isListening ? AppColor.Semantic.error : AppColor.Semantic.brandStrong)
                    .symbolEffect(.pulse, isActive: isListening)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isListening ? "Stop listening" : "Dictate")

            Button(action: onSubmit) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title)
                    .foregroundStyle(text.isEmpty ? AppColor.Semantic.textTertiary : AppColor.Semantic.brandStrong)
            }
            .buttonStyle(.plain)
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                .fill(AppColor.Semantic.surface)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.xl, style: .continuous)
                .strokeBorder(isFocused ? AppColor.Primary.s500 : AppColor.Semantic.border, lineWidth: 1.5)
        )
        .appShadow(AppShadow.sm)
    }
}
