import SwiftUI

struct AssumptionChipsBar: View {
    let assumptions: [AssumptionField]
    let confidence: Double
    let confidenceLevel: ConfidenceLevel
    let onEdit: (AssumptionField, String) -> Void

    @State private var editingField: AssumptionField?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text("Here's what I understood")
                    .textStyle(.label)
                    .foregroundStyle(AppColor.Semantic.textSecondary)
                Spacer()
                ConfidenceBadge(level: confidenceLevel, score: confidence)
            }

            FlowLayout(spacing: AppSpacing.sm) {
                ForEach(assumptions) { field in
                    AssumptionChipView(field: field) {
                        editingField = field
                    }
                }
            }
        }
        .padding(.horizontal, Theme.screenPadding)
        .padding(.vertical, AppSpacing.md)
        .background(AppColor.Semantic.surface)
        .sheet(item: $editingField) { field in
            AssumptionEditorView(field: field) { newValue in
                onEdit(field, newValue)
            }
        }
    }
}
