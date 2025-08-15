//
//  PlumpyProgressBar.swift
//  FoodDiaryTwo
//
//  Created by Plumpy UI Design System
//

import SwiftUI

struct PlumpyProgressBar: View {
    let value: Double
    let maxValue: Double
    let title: String?
    let subtitle: String?
    let showPercentage: Bool
    let style: PlumpyProgressBarStyle
    let size: PlumpyProgressBarSize
    let animated: Bool
    
    @State private var animatedValue: Double = 0
    
    enum PlumpyProgressBarStyle {
        case primary
        case secondary
        case accent
        case success
        case warning
        case error
        case custom(Color)
        
        var color: Color {
            switch self {
            case .primary:
                return PlumpyTheme.primaryAccent
            case .secondary:
                return PlumpyTheme.secondaryAccent
            case .accent:
                return PlumpyTheme.tertiaryAccent
            case .success:
                return PlumpyTheme.success
            case .warning:
                return PlumpyTheme.warning
            case .error:
                return PlumpyTheme.error
            case .custom(let color):
                return color
            }
        }
    }
    
    enum PlumpyProgressBarSize {
        case small
        case medium
        case large
        
        var height: CGFloat {
            switch self {
            case .small:
                return 8
            case .medium:
                return 12
            case .large:
                return 16
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small:
                return PlumpyTheme.Radius.small
            case .medium:
                return PlumpyTheme.Radius.medium
            case .large:
                return PlumpyTheme.Radius.large
            }
        }
    }
    
    init(
        value: Double,
        maxValue: Double = 100,
        title: String? = nil,
        subtitle: String? = nil,
        showPercentage: Bool = false,
        style: PlumpyProgressBarStyle = .primary,
        size: PlumpyProgressBarSize = .medium,
        animated: Bool = true
    ) {
        self.value = value
        self.maxValue = maxValue
        self.title = title
        self.subtitle = subtitle
        self.showPercentage = showPercentage
        self.style = style
        self.size = size
        self.animated = animated
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
            // Заголовок и процент
            if title != nil || showPercentage {
                HStack {
                    if let title = title {
                        Text(title)
                            .font(PlumpyTheme.Typography.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(PlumpyTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    if showPercentage {
                        Text("\(Int(progress * 100))%")
                            .font(PlumpyTheme.Typography.caption1)
                            .fontWeight(.semibold)
                            .foregroundColor(style.color)
                    }
                }
            }
            
            // Прогресс-бар
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Фон
                    RoundedRectangle(cornerRadius: size.cornerRadius)
                        .fill(PlumpyTheme.surfaceTertiary)
                        .frame(height: size.height)
                    
                    // Прогресс
                    RoundedRectangle(cornerRadius: size.cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    style.color,
                                    style.color.opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * progress,
                            height: size.height
                        )
                        .animation(
                            animated ? PlumpyTheme.Animation.smooth : nil,
                            value: progress
                        )
                }
            }
            .frame(height: size.height)
            
            // Подзаголовок
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(PlumpyTheme.Typography.caption1)
                    .foregroundColor(PlumpyTheme.textTertiary)
            }
        }
        .onAppear {
            if animated {
                withAnimation(PlumpyTheme.Animation.slow) {
                    animatedValue = value
                }
            }
        }
        .onChange(of: value) { newValue in
            if animated {
                withAnimation(PlumpyTheme.Animation.smooth) {
                    animatedValue = newValue
                }
            }
        }
    }
    
    private var progress: Double {
        let clampedValue = max(0, min(value, maxValue))
        return maxValue > 0 ? clampedValue / maxValue : 0
    }
}

// MARK: - Circular Progress Bar

struct PlumpyCircularProgressBar: View {
    let value: Double
    let maxValue: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let style: PlumpyProgressBar.PlumpyProgressBarStyle
    let showPercentage: Bool
    let animated: Bool
    
    @State private var animatedValue: Double = 0
    
    init(
        value: Double,
        maxValue: Double = 100,
        size: CGFloat = 100,
        lineWidth: CGFloat = 8,
        style: PlumpyProgressBar.PlumpyProgressBarStyle = .primary,
        showPercentage: Bool = true,
        animated: Bool = true
    ) {
        self.value = value
        self.maxValue = maxValue
        self.size = size
        self.lineWidth = lineWidth
        self.style = style
        self.showPercentage = showPercentage
        self.animated = animated
    }
    
    var body: some View {
        ZStack {
            // Фоновая окружность
            Circle()
                .stroke(
                    PlumpyTheme.surfaceTertiary,
                    lineWidth: lineWidth
                )
                .frame(width: size, height: size)
            
            // Прогресс
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        colors: [
                            style.color,
                            style.color.opacity(0.8),
                            style.color
                        ],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(
                    animated ? PlumpyTheme.Animation.slow : nil,
                    value: progress
                )
            
            // Процент в центре
            if showPercentage {
                VStack(spacing: 2) {
                    Text("\(Int(progress * 100))")
                        .font(.system(size: size * 0.3, weight: .bold, design: .rounded))
                        .foregroundColor(style.color)
                    
                    Text("%")
                        .font(.system(size: size * 0.15, weight: .medium, design: .rounded))
                        .foregroundColor(PlumpyTheme.textSecondary)
                }
            }
        }
        .onAppear {
            if animated {
                withAnimation(PlumpyTheme.Animation.slow) {
                    animatedValue = value
                }
            }
        }
        .onChange(of: value) { newValue in
            if animated {
                withAnimation(PlumpyTheme.Animation.smooth) {
                    animatedValue = newValue
                }
            }
        }
    }
    
    private var progress: Double {
        let clampedValue = max(0, min(value, maxValue))
        return maxValue > 0 ? clampedValue / maxValue : 0
    }
}

// MARK: - Step Progress Bar

struct PlumpyStepProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    let style: PlumpyProgressBar.PlumpyProgressBarStyle
    let showLabels: Bool
    
    init(
        currentStep: Int,
        totalSteps: Int,
        style: PlumpyProgressBar.PlumpyProgressBarStyle = .primary,
        showLabels: Bool = true
    ) {
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.style = style
        self.showLabels = showLabels
    }
    
    var body: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            // Шаги
            HStack(spacing: 0) {
                ForEach(0..<totalSteps, id: \.self) { step in
                    HStack(spacing: 0) {
                        // Круг шага
                        Circle()
                            .fill(stepColor(for: step))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .stroke(
                                        step == currentStep ? style.color : PlumpyTheme.border,
                                        lineWidth: step == currentStep ? 3 : 1
                                    )
                            )
                            .overlay(
                                Group {
                                    if step < currentStep {
                                        Image(systemName: "checkmark")
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(PlumpyTheme.textInverse)
                                    } else {
                                        Text("\(step + 1)")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundColor(stepTextColor(for: step))
                                    }
                                }
                            )
                        
                        // Линия между шагами
                        if step < totalSteps - 1 {
                            Rectangle()
                                .fill(step < currentStep ? style.color : PlumpyTheme.border)
                                .frame(height: 2)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            
            // Подписи шагов
            if showLabels {
                HStack {
                    ForEach(0..<totalSteps, id: \.self) { step in
                        Text("Step \(step + 1)")
                            .font(PlumpyTheme.Typography.caption1)
                            .foregroundColor(stepTextColor(for: step))
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
    
    private func stepColor(for step: Int) -> Color {
        if step < currentStep {
            return style.color
        } else if step == currentStep {
            return style.color.opacity(0.3)
        } else {
            return PlumpyTheme.surfaceTertiary
        }
    }
    
    private func stepTextColor(for step: Int) -> Color {
        if step <= currentStep {
            return PlumpyTheme.textPrimary
        } else {
            return PlumpyTheme.textTertiary
        }
    }
}

#Preview {
    VStack(spacing: PlumpyTheme.Spacing.extraLarge) {
        VStack(spacing: PlumpyTheme.Spacing.large) {
            PlumpyProgressBar(
                value: 75,
                title: "Daily Goal",
                subtitle: "750 / 1000 calories",
                showPercentage: true,
                style: .primary
            )
            
            PlumpyProgressBar(
                value: 60,
                style: .secondary,
                size: .large
            )
            
            PlumpyProgressBar(
                value: 90,
                style: .success,
                size: .small
            )
        }
        
        HStack(spacing: PlumpyTheme.Spacing.large) {
            PlumpyCircularProgressBar(
                value: 75,
                size: 80,
                style: .primary
            )
            
            PlumpyCircularProgressBar(
                value: 60,
                size: 100,
                style: .secondary
            )
        }
        
        PlumpyStepProgressBar(
            currentStep: 2,
            totalSteps: 4,
            style: .primary
        )
    }
    .padding()
    .background(PlumpyTheme.background)
}
