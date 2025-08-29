//
//  PlumpyCharts.swift
//  FoodDiaryTwo
//
//  Minimalist chart components aligned with Plumpy design system
//

import SwiftUI

struct PlumpyLineChart: View {
    let values: [Double]
    let labels: [String]
    let lineColor: Color
    let areaOpacity: Double
    let showDots: Bool

    @State private var selectedIndex: Int? = nil

    init(
        values: [Double],
        labels: [String],
        lineColor: Color = PlumpyTheme.primaryAccent,
        areaOpacity: Double = 0.14,
        showDots: Bool = true
    ) {
        self.values = values
        self.labels = labels
        self.lineColor = lineColor
        self.areaOpacity = areaOpacity
        self.showDots = showDots
    }

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let count = max(values.count, 1)
            let minValue = values.min() ?? 0
            let maxValue = values.max() ?? 1
            let range = max(maxValue - minValue, 1)
            let horizontalPadding: CGFloat = PlumpyTheme.Spacing.medium
            let verticalPadding: CGFloat = PlumpyTheme.Spacing.medium
            let stepX = (width - horizontalPadding * 2) / CGFloat(max(count - 1, 1))

            ZStack {
                // Grid
                VStack(spacing: 0) {
                    ForEach(0..<5, id: \.self) { idx in
                        Rectangle()
                            .fill(PlumpyTheme.neutral200.opacity(0.6))
                            .frame(height: 1)
                            .frame(maxWidth: .infinity)
                        if idx < 4 { Spacer() }
                    }
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)

                // Area fill
                path(in: geo.size, stepX: stepX, minValue: minValue, range: range, horizontalPadding: horizontalPadding, verticalPadding: verticalPadding)
                    .fill(lineColor.opacity(areaOpacity))

                // Line stroke
                linePath(in: geo.size, stepX: stepX, minValue: minValue, range: range, horizontalPadding: horizontalPadding, verticalPadding: verticalPadding)
                    .stroke(lineColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))

                // Dots
                if showDots {
                    ForEach(Array(values.enumerated()), id: \.offset) { index, _ in
                        let p = pointFor(index: index, size: geo.size, stepX: stepX, minValue: minValue, range: range, hPad: horizontalPadding, vPad: verticalPadding)
                        Circle()
                            .fill(lineColor)
                            .frame(width: selectedIndex == index ? 8 : 4, height: selectedIndex == index ? 8 : 4)
                            .position(p)
                    }
                }

                // X axis labels (sparse, provided by caller)
                ForEach(Array(labels.enumerated()), id: \.offset) { index, label in
                    if !label.isEmpty {
                        let x = horizontalPadding + CGFloat(index) * stepX
                        let y = height - verticalPadding * 0.4
                        Text(label)
                            .font(PlumpyTheme.Typography.caption2)
                            .foregroundColor(PlumpyTheme.textSecondary)
                            .position(x: x, y: y)
                    }
                }

                // Tooltip
                if let selectedIndex = selectedIndex, values.indices.contains(selectedIndex) {
                    let p = pointFor(index: selectedIndex, size: geo.size, stepX: stepX, minValue: minValue, range: range, hPad: horizontalPadding, vPad: verticalPadding)
                    PlumpyChartTooltip(
                        title: labels.indices.contains(selectedIndex) ? labels[selectedIndex] : "",
                        value: Int(values[selectedIndex])
                    )
                    .position(x: p.x, y: max(PlumpyTheme.Spacing.huge, p.y - 28))
                }
            }
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 0).onChanged { g in
                let localX = max(horizontalPadding, min(width - horizontalPadding, g.location.x))
                let idx = Int(round((localX - horizontalPadding) / stepX))
                let clamped = min(max(idx, 0), max(count - 1, 0))
                if self.selectedIndex != clamped { self.selectedIndex = clamped }
            }.onEnded { _ in
                // keep tooltip for a short time or dismiss; we keep it for clarity
            })
        }
    }

    private func pointFor(index: Int, size: CGSize, stepX: CGFloat, minValue: Double, range: Double, hPad: CGFloat, vPad: CGFloat) -> CGPoint {
        let x = hPad + CGFloat(index) * stepX
        let normalized = (values[index] - minValue) / range
        let y = (size.height - vPad) - CGFloat(normalized) * (size.height - vPad * 2)
        return CGPoint(x: x, y: y)
    }

    private func linePath(in size: CGSize, stepX: CGFloat, minValue: Double, range: Double, horizontalPadding: CGFloat, verticalPadding: CGFloat) -> Path {
        var path = Path()
        guard !values.isEmpty else { return path }
        for i in values.indices {
            let p = pointFor(index: i, size: size, stepX: stepX, minValue: minValue, range: range, hPad: horizontalPadding, vPad: verticalPadding)
            if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
        }
        return path
    }

    private func path(in size: CGSize, stepX: CGFloat, minValue: Double, range: Double, horizontalPadding: CGFloat, verticalPadding: CGFloat) -> Path {
        var path = Path()
        guard !values.isEmpty else { return path }
        let bottomY = size.height - verticalPadding
        path.move(to: CGPoint(x: horizontalPadding, y: bottomY))
        for i in values.indices {
            let p = pointFor(index: i, size: size, stepX: stepX, minValue: minValue, range: range, hPad: horizontalPadding, vPad: verticalPadding)
            path.addLine(to: p)
        }
        path.addLine(to: CGPoint(x: horizontalPadding + CGFloat(max(values.count - 1, 0)) * stepX, y: bottomY))
        path.closeSubpath()
        return path
    }
}

private struct PlumpyChartTooltip: View {
    let title: String
    let value: Int
    @StateObject private var localizationManager = LocalizationManager.shared

    var body: some View {
        HStack(spacing: PlumpyTheme.Spacing.small) {
            Text(title)
                .font(PlumpyTheme.Typography.caption2)
                .foregroundColor(PlumpyTheme.textSecondary)
            Text("\(value) \(localizationManager.localizedString(.calUnit))")
                .font(PlumpyTheme.Typography.caption1)
                .fontWeight(.medium)
                .foregroundColor(PlumpyTheme.textPrimary)
        }
        .padding(.horizontal, PlumpyTheme.Spacing.small)
        .padding(.vertical, PlumpyTheme.Spacing.tiny)
        .background(PlumpyTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: PlumpyTheme.Radius.small))
        .overlay(
            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.small)
                .stroke(PlumpyTheme.neutral200, lineWidth: 1)
        )
        .shadow(
            color: PlumpyTheme.shadow.opacity(0.02),
            radius: PlumpyTheme.Shadow.small.radius,
            x: PlumpyTheme.Shadow.small.x,
            y: PlumpyTheme.Shadow.small.y
        )
    }
}


