import SwiftUI

struct AskTabView: View {
    let container: AppContainer
    let onSubmit: (String) -> Void
    let onOpenSettings: () -> Void

    @State private var vm: HomeViewModel
    @State private var ask: AskViewModel
    @State private var placeholderIndex = 0
    @State private var showingAllRecents = false

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
                inputSection
                quickMissions
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
                .textStyle(.headingXS)
                .foregroundStyle(AppColor.Semantic.textPrimary)
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
    private var recents: some View {
        if !vm.recentMissions.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Text("Recent missions")
                        .textStyle(.headingXS)
                        .foregroundStyle(AppColor.Semantic.textPrimary)
                    Spacer()
                    if vm.recentMissions.count > 5 {
                        Button(showingAllRecents ? "View less" : "View all") {
                            withAnimation {
                                showingAllRecents.toggle()
                            }
                        }
                        .textStyle(.buttonM)
                        .foregroundStyle(AppColor.Semantic.brandStrong)
                    }
                }
                
                VStack(spacing: 0) {
                    let displayed = showingAllRecents ? vm.recentMissions : Array(vm.recentMissions.prefix(5))
                    ForEach(Array(displayed.enumerated()), id: \.element.id) { index, mission in
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
                        
                        if index < displayed.count - 1 {
                            Divider()
                                .padding(.leading, 52) // roughly aligns with text (icon + spacing)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: Theme.cardRadius, style: .continuous)
                        .fill(AppColor.Semantic.surface)
                )
                .appShadow(AppShadow.xs)
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
        .contentShape(Rectangle())
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
