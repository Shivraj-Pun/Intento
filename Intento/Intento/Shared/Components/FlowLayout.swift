import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = AppSpacing.sm

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        let rows = computeRows(maxWidth: maxWidth, subviews: subviews)
        let height = rows.reduce(0) { partial, row in
            partial + row.height + (row.isFirst ? 0 : spacing)
        }
        let width = rows.map(\.width).max() ?? 0
        return CGSize(width: min(width, maxWidth), height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let rows = computeRows(maxWidth: bounds.width, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for element in row.elements {
                let size = subviews[element.index].sizeThatFits(.unspecified)
                subviews[element.index].place(
                    at: CGPoint(x: x, y: y),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(size)
                )
                x += size.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct RowElement {
        let index: Int
        let width: CGFloat
    }

    private struct Row {
        var elements: [RowElement] = []
        var width: CGFloat = 0
        var height: CGFloat = 0
        var isFirst = false
    }

    private func computeRows(maxWidth: CGFloat, subviews: Subviews) -> [Row] {
        var rows: [Row] = []
        var current = Row(isFirst: true)
        var x: CGFloat = 0

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            if x + size.width > maxWidth, !current.elements.isEmpty {
                rows.append(current)
                current = Row()
                x = 0
            }
            current.elements.append(RowElement(index: index, width: size.width))
            current.width = max(current.width, x + size.width)
            current.height = max(current.height, size.height)
            x += size.width + spacing
        }
        if !current.elements.isEmpty { rows.append(current) }
        return rows
    }
}
