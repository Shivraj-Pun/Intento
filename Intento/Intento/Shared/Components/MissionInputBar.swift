import SwiftUI

struct MissionInputBar: View {
    @Binding var text: String
    var isListening: Bool = false
    let placeholder: String
    var onMic: (() -> Void)? = nil
    var onSubmit: (() -> Void)? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppColor.Semantic.textTertiary)

            TextField(placeholder, text: $text, axis: .vertical)
                .textStyle(.bodyMRegular)
                .focused($isFocused)
                .lineLimit(1...4)
                .submitLabel(.go)
                .onSubmit { onSubmit?() }

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppColor.Semantic.textTertiary)
                }
                .buttonStyle(.plain)
            }

            if let onMic = onMic {
                Button(action: onMic) {
                    Image(systemName: isListening ? "waveform.circle.fill" : "mic.fill")
                        .font(.title3)
                        .foregroundStyle(isListening ? AppColor.Semantic.error : AppColor.Semantic.brandStrong)
                        .symbolEffect(.pulse, isActive: isListening)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isListening ? "Stop listening" : "Dictate")
            }


        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.vertical, AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(AppColor.Semantic.surface)
        )
    }
}
