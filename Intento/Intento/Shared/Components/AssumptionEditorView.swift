import SwiftUI

struct AssumptionEditorView: View {
    let field: AssumptionField
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var textValue: String = ""
    @State private var selectedOptions: Set<String> = []

    var body: some View {
        NavigationStack {
            Form {
                switch field.editableType {
                case .number:
                    TextField(field.displayLabel, text: $textValue)
                        .keyboardType(.numberPad)
                case .currency:
                    HStack {
                        Text("₹")
                            .foregroundStyle(AppColor.Semantic.textSecondary)
                        TextField("Amount", text: $textValue)
                            .keyboardType(.numberPad)
                    }
                case .text:
                    TextField(field.displayLabel, text: $textValue, axis: .vertical)
                case .singleSelect:
                    ForEach(field.options, id: \.self) { option in
                        Button {
                            textValue = option
                        } label: {
                            HStack {
                                Text(option).foregroundStyle(AppColor.Semantic.textPrimary)
                                Spacer()
                                if textValue == option {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(AppColor.Semantic.brandStrong)
                                }
                            }
                        }
                    }
                case .multiSelect:
                    ForEach(field.options, id: \.self) { option in
                        Button {
                            toggle(option)
                        } label: {
                            HStack {
                                Text(option).foregroundStyle(AppColor.Semantic.textPrimary)
                                Spacer()
                                if selectedOptions.contains(option) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(AppColor.Semantic.brandStrong)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit \(field.displayLabel)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(resolvedValue)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents(detents)
        .onAppear(perform: prime)
    }

    private var detents: Set<PresentationDetent> {
        switch field.editableType {
        case .singleSelect, .multiSelect: [.medium, .large]
        default: [.height(200)]
        }
    }

    private var resolvedValue: String {
        switch field.editableType {
        case .multiSelect:
            field.options.filter { selectedOptions.contains($0) }.joined(separator: ", ")
        default:
            textValue
        }
    }

    private func prime() {
        textValue = field.valueText.filter { field.editableType == .number || field.editableType == .currency ? $0.isNumber : true }
        if field.editableType == .singleSelect { textValue = field.valueText }
        if field.editableType == .multiSelect {
            selectedOptions = Set(field.valueText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) })
        }
    }

    private func toggle(_ option: String) {
        if selectedOptions.contains(option) {
            selectedOptions.remove(option)
        } else {
            selectedOptions.insert(option)
        }
    }
}
