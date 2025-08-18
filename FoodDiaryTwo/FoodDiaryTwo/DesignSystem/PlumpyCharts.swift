//
//  PlumpyCharts.swift
//  FoodDiaryTwo
//
//  Minimalist chart components in Plumpy style: soft shapes, rounded bars,
//  smooth lines with subtle area fill and gentle animations.
//

import SwiftUI

// MARK: - Chart Palette

enum PlumpyChartPalette {
    static let accentBlue = Color(hex: "#8CB7FF")     // пастельный голубой
    static let normalGreen = Color(hex: "#8AD6B2")    // пастельный зелёный
    static let overCoral = Color(hex: "#FF9E9E")      // пастельный коралловый
    static let emptyGray = Color(hex: "#E5E7EB")      // светло-серый
}

// MARK: - Shapes

struct RoundedTopRectangle: Shape {
    let radius: CGFloat
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let r = min(radius, min(rect.width, rect.height) / 2)
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + r))
        path.addArc(center: CGPoint(x: rect.minX + r, y: rect.minY + r), radius: r, startAngle: .degrees(180), endAngle: .degrees(90), clockwise: true)
        path.addLine(to: CGPoint(x: rect.maxX - r, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - r, y: rect.minY + r), radius: r, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: true)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Data Models

struct PlumpyBarDataPoint: Identifiable, Equatable {
    let id = UUID()
    let label: String
    let value: Double
}

// MARK: - Bar Chart

struct PlumpyBarChart: View {
    let data: [PlumpyBarDataPoint]
    let maxValue: Double
    let barColor: Color
    let emptyColor: Color
    let highlightMinMax: Bool

    init(
        data: [PlumpyBarDataPoint],
        maxValue: Double? = nil,
        barColor: Color = PlumpyChartPalette.accentBlue,
        emptyColor: Color = PlumpyChartPalette.emptyGray,
        highlightMinMax: Bool = false
    ) {
        self.data = data
        let mv = max(1, data.map { $0.value }.max() ?? 1)
        self.maxValue = maxValue ?? mv
        self.barColor = barColor
        self.emptyColor = emptyColor
        self.highlightMinMax = highlightMinMax
    }

    var body: some View {
        GeometryReader { proxy in
            let count = max(data.count, 1)
            let spacing = PlumpyTheme.Spacing.small
            let available = max(0, proxy.size.width - spacing * CGFloat(count - 1))
            let barWidth = max(6, available / CGFloat(count))
            let minValue = data.map { $0.value }.min() ?? 0
            let maxValueLocal = data.map { $0.value }.max() ?? 0

            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(Array(data.enumerated()), id: \.offset) { idx, point in
                    VStack(spacing: PlumpyTheme.Spacing.tiny) {
                        let height = CGFloat(point.value / max(maxValue, 1)) * max(4, proxy.size.height - 28)
                        let isEmpty = point.value <= 0
                        let isMin = highlightMinMax && point.value == minValue
                        let isMax = highlightMinMax && point.value == maxValueLocal
                        let color: Color = isEmpty ? emptyColor : (isMax ? PlumpyChartPalette.overCoral : (isMin ? PlumpyChartPalette.normalGreen : barColor))

                        RoundedTopRectangle(radius: PlumpyTheme.Radius.small)
                            .fill(color)
                            .frame(width: barWidth, height: max(4, height))
                            .shadow(color: PlumpyTheme.shadow.opacity(0.04), radius: PlumpyTheme.Shadow.small.radius, x: PlumpyTheme.Shadow.small.x, y: PlumpyTheme.Shadow.small.y)
                            .animation(PlumpyTheme.Animation.smooth, value: point.value)

                        Text(point.label)
                            .font(PlumpyTheme.Typography.caption2)
                            .foregroundColor(PlumpyTheme.textSecondary)
                            .frame(width: max(barWidth, 16))
                    }
                    .frame(width: max(barWidth, 16))
                }
            }
        }
    }
}

// MARK: - Line Chart (smooth with area)

struct PlumpyLineChart: View {
    let values: [Double]
    let labels: [String]
    let lineColor: Color
    let areaOpacity: Double

    init(values: [Double], labels: [String], lineColor: Color = PlumpyChartPalette.accentBlue, areaOpacity: Double = 0.15) {
        self.values = values
        self.labels = labels
        self.lineColor = lineColor
        self.areaOpacity = areaOpacity
    }

    var body: some View {
        GeometryReader { proxy in
            let count = max(values.count, 2)
            let maxVal = max(values.max() ?? 1, 1)
            let minVal = min(values.min() ?? 0, 0)
            let width = proxy.size.width
            let height = max(0, proxy.size.height - 24)
            let stepX = width / CGFloat(count - 1)

            let points: [CGPoint] = values.enumerated().map { (i, v) in
                let x = CGFloat(i) * stepX
                let y = height - CGFloat((v - minVal) / max(maxVal - minVal, 1)) * height
                return CGPoint(x: x, y: y)
            }

            ZStack(alignment: .bottomLeading) {
                // grid baseline
                Rectangle()
                    .fill(PlumpyTheme.neutral200.opacity(0.6))
                    .frame(height: 1)
                    .offset(y: height)

                // area
                if points.count >= 2 {
                    Path { path in
                        path.move(to: CGPoint(x: points.first!.x, y: height))
                        addSmoothLine(path: &path, points: points)
                        path.addLine(to: CGPoint(x: points.last!.x, y: height))
                        path.closeSubpath()
                    }
                    .fill(lineColor.opacity(areaOpacity))

                    // line
                    Path { path in
                        addSmoothLine(path: &path, points: points)
                    }
                    .stroke(lineColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .trim(from: 0, to: 1)
                    .animation(PlumpyTheme.Animation.smooth, value: values)
                }

                // x labels
                HStack(spacing: 0) {
                    ForEach(0..<count, id: \.self) { i in
                        Text(labels.indices.contains(i) ? labels[i] : "")
                            .font(PlumpyTheme.Typography.caption2)
                            .foregroundColor(PlumpyTheme.textSecondary)
                            .frame(width: stepX, alignment: .center)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func addSmoothLine(path: inout Path, points: [CGPoint]) {
        guard points.count > 1 else { return }
        path.move(to: points[0])
        for i in 1..<points.count {
            let prev = points[i - 1]
            let current = points[i]
            let mid = CGPoint(x: (prev.x + current.x) / 2, y: (prev.y + current.y) / 2)
            if i == 1 {
                path.addQuadCurve(to: mid, control: prev)
            } else {
                let prevMid = CGPoint(x: (points[i - 2].x + prev.x) / 2, y: (points[i - 2].y + prev.y) / 2)
                path.addCurve(to: mid, control1: prev, control2: prev)
            }
            if i == points.count - 1 {
                path.addQuadCurve(to: current, control: current)
            }
        }
    }
}

// MARK: - Simple Range Selector (two thumbs)

struct PlumpyRangeSelector: View {
    @Binding var lowerIndex: Int
    @Binding var upperIndex: Int
    let total: Int

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let step = width / CGFloat(max(total - 1, 1))
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.round)
                    .fill(PlumpyTheme.neutral200)
                    .frame(height: 6)
                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.round)
                    .fill(PlumpyChartPalette.accentBlue.opacity(0.4))
                    .frame(width: max(8, CGFloat(upperIndex - lowerIndex) * step), height: 6)
                    .offset(x: CGFloat(lowerIndex) * step)

                Circle()
                    .fill(PlumpyChartPalette.accentBlue)
                    .frame(width: 18, height: 18)
                    .offset(x: CGFloat(lowerIndex) * step - 9, y: -6)
                    .gesture(DragGesture().onChanged { g in
                        let idx = Int(round(max(0, min(width, g.location.x)) / step))
                        lowerIndex = min(idx, upperIndex)
                    })

                Circle()
                    .fill(PlumpyChartPalette.accentBlue)
                    .frame(width: 18, height: 18)
                    .offset(x: CGFloat(upperIndex) * step - 9, y: -6)
                    .gesture(DragGesture().onChanged { g in
                        let idx = Int(round(max(0, min(width, g.location.x)) / step))
                        upperIndex = max(idx, lowerIndex)
                    })
            }
        }
        .frame(height: 24)
    }
}


