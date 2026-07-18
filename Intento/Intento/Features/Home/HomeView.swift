import SwiftUI

struct HomeView: View {
    let container: AppContainer
    let onSubmit: (String) -> Void
    let onOpenSettings: () -> Void

    @State private var vm: HomeViewModel
    @State private var ask: AskViewModel
    @State private var placeholderIndex = 0

    private let placeholders = [
        "Butter chicken for 4 under ₹900",
        "Movie night for 6",
        "Weekly restock for the family",
        "Healthy breakfast for two",
        "Everything for a baby's first week"
    ]

    init(container: AppContainer, onSubmit: @escaping (String) -> Void, onOpenSettings: @escaping () -> Void) {
        self.container = container
        self.onSubmit = onSubmit
        self.onOpenSettings = onOpenSettings
        _vm = State(initialValue: container.makeHomeViewModel())
        _ask = State(initialValue: container.makeAskViewModel())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xxl) {
                header
                inputSection
                quickMissions
                nudges
                recents
            }
            .padding(.horizontal, Theme.screenPadding)
            .padding(.vertical, AppSpacing.lg)
        }
        .background(AppColor.Semantic.background.ignoresSafeArea())
        .navigationTitle("Intento")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    ask.haptics.play(.selection)
                    onOpenSettings()
                } label: {
                    Image(systemName: "person.crop.circle")
                }
            }
        }
        .task { await vm.load() }
        .task { await rotatePlaceholders() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("What can I get you?")
                .textStyle(.headingM)
                .foregroundStyle(AppColor.Semantic.textPrimary)
            Text("Describe your mission and I'll build the cart.")
                .textStyle(.bodyMRegular)
                .foregroundStyle(AppColor.Semantic.textSecondary)
        }
    }

    private var inputSection: some View {
        MissionInputBar(
            text: $ask.inputText,
            isListening: ask.isListening,
            placeholder: placeholders[placeholderIndex],
            onMic: { Task { await ask.toggleVoice() } },
            onSubmit: submit
        )
    }

    private var quickMissions: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Quick missions")
                .textStyle(.label)
                .foregroundStyle(AppColor.Semantic.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(vm.quickMissions, id: \.self) { mission in
                        QuickMissionChipView(title: mission) {
                            ask.haptics.play(.selection)
                            onSubmit(mission)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    @ViewBuilder
    private var nudges: some View {
        let items = nudgeItems
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                ForEach(items) { item in
                    Button {
                        if let prompt = item.prompt {
                            ask.haptics.play(.selection)
                            onSubmit(prompt)
                        }
                    } label: {
                        HStack(spacing: AppSpacing.md) {
                            Image(systemName: item.icon)
                                .foregroundStyle(AppColor.Semantic.brandStrong)
                            Text(item.text)
                                .textStyle(.bodyMMedium)
                                .foregroundStyle(AppColor.Semantic.textPrimary)
                                .multilineTextAlignment(.leading)
                            Spacer()
                            if item.prompt != nil {
                                Image(systemName: "chevron.right")
                                    .font(.footnote)
                                    .foregroundStyle(AppColor.Semantic.textTertiary)
                            }
                        }
                        .padding(AppSpacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                                .fill(AppColor.Semantic.surface)
                        )
                        .appShadow(AppShadow.xs)
                    }
                    .buttonStyle(.plain)
                    .disabled(item.prompt == nil)
                }
            }
        }
    }

    @ViewBuilder
    private var recents: some View {
        if !vm.recentMissions.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Recent missions")
                    .textStyle(.label)
                    .foregroundStyle(AppColor.Semantic.textSecondary)
                ForEach(vm.recentMissions) { mission in
                    Button {
                        ask.haptics.play(.selection)
                        onSubmit(mission.rawIntentText.isEmpty ? mission.title : mission.rawIntentText)
                    } label: {
                        recentRow(mission)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            Task { await vm.deleteMission(mission) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }

    private func recentRow(_ mission: SavedMission) -> some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: "clock.arrow.circlepath")
                .foregroundStyle(AppColor.Semantic.textSecondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(mission.title)
                    .textStyle(.bodyMMedium)
                    .foregroundStyle(AppColor.Semantic.textPrimary)
                    .lineLimit(1)
                if let occasion = mission.occasion {
                    Text(occasion.displayName)
                        .textStyle(.caption)
                        .foregroundStyle(AppColor.Semantic.textTertiary)
                }
            }
            Spacer()
            Image(systemName: "arrow.up.right")
                .font(.footnote)
                .foregroundStyle(AppColor.Semantic.textTertiary)
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                .fill(AppColor.Semantic.surface)
        )
        .appShadow(AppShadow.xs)
    }

    private struct NudgeItem: Identifiable {
        let id = UUID()
        let icon: String
        let text: String
        let prompt: String?
    }

    private var nudgeItems: [NudgeItem] {
        var items: [NudgeItem] = []
        if let restock = vm.restockNudge {
            items.append(NudgeItem(icon: "arrow.clockwise.circle.fill", text: restock, prompt: "Weekly grocery restock"))
        }
        if let seasonal = vm.seasonalHint {
            items.append(NudgeItem(icon: "leaf.fill", text: seasonal, prompt: nil))
        }
        for hint in vm.preferenceHints {
            items.append(NudgeItem(icon: "heart.fill", text: hint, prompt: nil))
        }
        return items
    }

    private func submit() {
        let text = ask.inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        ask.stopVoice()
        ask.haptics.play(.selection)
        onSubmit(text)
        ask.inputText = ""
    }

    private func rotatePlaceholders() async {
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            withAnimation(.easeInOut) {
                placeholderIndex = (placeholderIndex + 1) % placeholders.count
            }
        }
    }
}
