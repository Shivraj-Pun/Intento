import SwiftUI

struct AssumptionChipView: View {
    let field: AssumptionField
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: AppSpacing.xs) {
                if field.wasInferred {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                }
                Text(field.displayLabel)
                    .textStyle(.label)
                    .foregroundStyle(AppColor.Semantic.textSecondary)
                Text(field.valueText)
                    .textStyle(.bodySMedium)
                    .foregroundStyle(AppColor.Semantic.textPrimary)
                Image(systemName: "pencil")
                    .font(.caption2)
                    .foregroundStyle(AppColor.Semantic.textTertiary)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                Capsule(style: .continuous)
                    .fill(field.wasInferred ? AppColor.Primary.s100 : AppColor.Secondary.s200)
            )
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(
                        field.wasInferred ? AppColor.Primary.s400 : Color.clear,
                        style: StrokeStyle(lineWidth: 1, dash: field.wasInferred ? [4, 3] : [])
                    )
            )
            .foregroundStyle(field.wasInferred ? AppColor.Primary.s800 : AppColor.Semantic.textSecondary)
        }
        .buttonStyle(.plain)
    }
}

struct QuickMissionChipView: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "wand.and.stars")
                    .font(.footnote)
                Text(title)
                    .textStyle(.bodySMedium)
                    .lineLimit(1)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .foregroundStyle(AppColor.Primary.s800)
            .background(
                Capsule(style: .continuous).fill(AppColor.Primary.s100)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ConfidenceBadge: View {
    let level: ConfidenceLevel
    let score: Double

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Circle()
                .fill(AppColor.color(for: level))
                .frame(width: 8, height: 8)
            Text("\(Int(score * 100))% understood")
                .textStyle(.caption)
                .foregroundStyle(AppColor.Semantic.textSecondary)
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(Capsule().fill(AppColor.Semantic.surfaceMuted))
    }
}

struct SubstitutionBadge: View {
    let record: SubstitutionRecord

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.caption2)
            Text("Substituted · \(record.reason.displayName)")
                .textStyle(.caption)
        }
        .foregroundStyle(AppColor.Warning.s700)
    }
}
