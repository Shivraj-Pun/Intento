import SwiftUI

struct SettingsView: View {
    let config: AppConfig

    @State private var vm: PersonalizationViewModel

    init(viewModel: PersonalizationViewModel, config: AppConfig) {
        _vm = State(initialValue: viewModel)
        self.config = config
    }

    var body: some View {
        Form {
            Section("Preferences") {
                Toggle(isOn: Binding(get: { vm.preference.nutritionAwareEnabled }, set: { vm.setNutritionAware($0) })) {
                    Label("Healthier swaps by default", systemImage: "heart.text.square")
                }
                Toggle(isOn: Binding(get: { vm.preference.sustainabilityNudgesEnabled }, set: { vm.setSustainabilityNudges($0) })) {
                    Label("Sustainability nudges", systemImage: "leaf")
                }
                Stepper(value: Binding(get: { vm.preference.defaultPeopleCount ?? 2 }, set: { vm.setDefaultPeople($0) }), in: 1...20) {
                    Label("Default people: \(vm.preference.defaultPeopleCount ?? 2)", systemImage: "person.2")
                }
            }

            Section("Restock reminder") {
                Picker("Cadence", selection: Binding(get: { vm.preference.restockCadenceDays ?? 0 }, set: { vm.setRestockCadence($0 == 0 ? nil : $0) })) {
                    Text("Off").tag(0)
                    Text("Weekly").tag(7)
                    Text("Fortnightly").tag(14)
                    Text("Monthly").tag(30)
                }
            }

            if !vm.preference.preferredProducts.isEmpty {
                Section("Learned favourites") {
                    ForEach(vm.preference.preferredProducts.sorted { $0.frequency > $1.frequency }) { product in
                        HStack {
                            Text(product.name)
                                .foregroundStyle(AppColor.Semantic.textPrimary)
                            Spacer()
                            Text("×\(product.frequency)")
                                .foregroundStyle(AppColor.Semantic.textTertiary)
                        }
                    }
                    Button(role: .destructive) {
                        vm.clearPreferredProducts()
                    } label: {
                        Label("Clear favourites", systemImage: "trash")
                    }
                }
            }

            Section("AI") {
                labeledRow("Provider", config.llmProvider.capitalized)
                labeledRow("Model", config.llmModel)
                labeledRow("Mode", config.useMockServices || !config.hasLLMKey ? "On-device mock" : "Live")
                Text("Set LLM_API_KEY in Environment.env and USE_MOCK_SERVICES=false to use \(config.llmProvider.capitalized).")
                    .textStyle(.caption)
                    .foregroundStyle(AppColor.Semantic.textTertiary)
            }
        }
        .navigationTitle("You")
        .navigationBarTitleDisplayMode(.inline)
        .task { await vm.load() }
    }

    private func labeledRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(AppColor.Semantic.textSecondary)
            Spacer()
            Text(value)
                .foregroundStyle(AppColor.Semantic.textPrimary)
        }
    }
}
