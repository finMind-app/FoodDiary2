//
//  PlumpyBackground.swift
//  FoodDiaryTwo
//
//  Created by Plumpy UI Design System
//

import SwiftUI

struct PlumpyBackground: View {
    let style: PlumpyBackgroundStyle
    let opacity: Double
    
    enum PlumpyBackgroundStyle {
        case solid(Color)
        case gradient(LinearGradient)
        case radial(RadialGradient)
        case angular(AngularGradient)
        case pattern(PlumpyPatternStyle)
        
        static let primary = PlumpyBackgroundStyle.solid(PlumpyTheme.background)
        static let surface = PlumpyBackgroundStyle.solid(PlumpyTheme.surface)
        static let primaryGradient = PlumpyBackgroundStyle.gradient(
            LinearGradient(
                colors: [
                    PlumpyTheme.primary.opacity(0.1),
                    PlumpyTheme.primary.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        static let secondaryGradient = PlumpyBackgroundStyle.gradient(
            LinearGradient(
                colors: [
                    PlumpyTheme.secondary.opacity(0.1),
                    PlumpyTheme.secondary.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        static let warmGradient = PlumpyBackgroundStyle.gradient(
            LinearGradient(
                colors: [
                    PlumpyTheme.primary.opacity(0.15),
                    PlumpyTheme.secondary.opacity(0.1),
                    PlumpyTheme.tertiary.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    enum PlumpyPatternStyle {
        case dots
        case lines
        case waves
        case grid
        
        var view: some View {
            switch self {
            case .dots:
                return AnyView(
                    Canvas { context, size in
                        let dotSize: CGFloat = 4
                        let spacing: CGFloat = 20
                        
                        for x in stride(from: 0, to: size.width, by: spacing) {
                            for y in stride(from: 0, to: size.height, by: spacing) {
                                let rect = CGRect(
                                    x: x - dotSize/2,
                                    y: y - dotSize/2,
                                    width: dotSize,
                                    height: dotSize
                                )
                                context.fill(
                                    Path(ellipseIn: rect),
                                    with: .color(PlumpyTheme.primary.opacity(0.1))
                                )
                            }
                        }
                    }
                )
            case .lines:
                return AnyView(
                    Canvas { context, size in
                        let lineWidth: CGFloat = 1
                        let spacing: CGFloat = 30
                        
                        for x in stride(from: 0, to: size.width, by: spacing) {
                            let path = Path { path in
                                path.move(to: CGPoint(x: x, y: 0))
                                path.addLine(to: CGPoint(x: x, y: size.height))
                            }
                            context.stroke(
                                path,
                                with: .color(PlumpyTheme.primary.opacity(0.05)),
                                lineWidth: lineWidth
                            )
                        }
                        
                        for y in stride(from: 0, to: size.height, by: spacing) {
                            let path = Path { path in
                                path.move(to: CGPoint(x: 0, y: y))
                                path.addLine(to: CGPoint(x: size.width, y: y))
                            }
                            context.stroke(
                                path,
                                with: .color(PlumpyTheme.primary.opacity(0.05)),
                                lineWidth: lineWidth
                            )
                        }
                    }
                )
            case .waves:
                return AnyView(
                    Canvas { context, size in
                        let waveHeight: CGFloat = 20
                        let waveWidth: CGFloat = size.width / 3
                        
                        for i in 0...2 {
                            let path = Path { path in
                                path.move(to: CGPoint(x: 0, y: size.height))
                                
                                for x in stride(from: 0, to: size.width, by: 1) {
                                    let y = size.height - waveHeight * sin((x + CGFloat(i) * waveWidth) / waveWidth * 2 * .pi)
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                                
                                path.addLine(to: CGPoint(x: size.width, y: size.height))
                                path.closeSubpath()
                            }
                            
                            context.fill(
                                path,
                                with: .color(PlumpyTheme.primary.opacity(0.05))
                            )
                        }
                    }
                )
            case .grid:
                return AnyView(
                    Canvas { context, size in
                        let gridSize: CGFloat = 40
                        
                        for x in stride(from: 0, to: size.width, by: gridSize) {
                            for y in stride(from: 0, to: size.height, by: gridSize) {
                                let rect = CGRect(x: x, y: y, width: gridSize, height: gridSize)
                                context.stroke(
                                    Path(rect),
                                    with: .color(PlumpyTheme.primary.opacity(0.03)),
                                    lineWidth: 0.5
                                )
                            }
                        }
                    }
                )
            }
        }
    }
    
    init(
        style: PlumpyBackgroundStyle = .primary,
        opacity: Double = 1.0
    ) {
        self.style = style
        self.opacity = opacity
    }
    
    var body: some View {
        ZStack {
            switch style {
            case .solid(let color):
                Rectangle()
                    .fill(color)
                
            case .gradient(let gradient):
                Rectangle()
                    .fill(gradient)
                
            case .radial(let gradient):
                Rectangle()
                    .fill(gradient)
                
            case .angular(let gradient):
                Rectangle()
                    .fill(gradient)
                
            case .pattern(let patternStyle):
                Rectangle()
                    .fill(PlumpyTheme.background)
                    .overlay(patternStyle.view)
            }
        }
        .opacity(opacity)
        .ignoresSafeArea()
    }
}

// MARK: - Background Modifier

struct PlumpyBackgroundModifier: ViewModifier {
    let style: PlumpyBackground.PlumpyBackgroundStyle
    let opacity: Double
    
    init(
        style: PlumpyBackground.PlumpyBackgroundStyle = .primary,
        opacity: Double = 1.0
    ) {
        self.style = style
        self.opacity = opacity
    }
    
    func body(content: Content) -> some View {
        ZStack {
            PlumpyBackground(style: style, opacity: opacity)
            content
        }
    }
}

// MARK: - View Extension

extension View {
    func plumpyBackground(
        style: PlumpyBackground.PlumpyBackgroundStyle = .primary,
        opacity: Double = 1.0
    ) -> some View {
        modifier(PlumpyBackgroundModifier(style: style, opacity: opacity))
    }
}

// MARK: - Specialized Backgrounds

struct PlumpyCardBackground: View {
    let style: PlumpyCardBackgroundStyle
    
    enum PlumpyCardBackgroundStyle {
        case primary
        case secondary
        case accent
        case success
        case warning
        case error
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return PlumpyTheme.surface
            case .secondary:
                return PlumpyTheme.surfaceSecondary
            case .accent:
                return PlumpyTheme.tertiary.opacity(0.1)
            case .success:
                return PlumpyTheme.success.opacity(0.1)
            case .warning:
                return PlumpyTheme.warning.opacity(0.1)
            case .error:
                return PlumpyTheme.error.opacity(0.1)
            }
        }
        
        var borderColor: Color {
            switch self {
            case .primary:
                return PlumpyTheme.border
            case .secondary:
                return PlumpyTheme.borderLight
            case .accent:
                return PlumpyTheme.tertiary.opacity(0.3)
            case .success:
                return PlumpyTheme.success.opacity(0.3)
            case .warning:
                return PlumpyTheme.warning.opacity(0.3)
            case .error:
                return PlumpyTheme.error.opacity(0.3)
            }
        }
    }
    
    init(style: PlumpyCardBackgroundStyle = .primary) {
        self.style = style
    }
    
    var body: some View {
        Rectangle()
            .fill(style.backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                    .stroke(style.borderColor, lineWidth: 1)
            )
    }
}

struct PlumpyGlassBackground: View {
    let blurRadius: CGFloat
    let opacity: Double
    
    init(blurRadius: CGFloat = 20, opacity: Double = 0.1) {
        self.blurRadius = blurRadius
        self.opacity = opacity
    }
    
    var body: some View {
        Rectangle()
            .fill(.ultraThinMaterial)
            .blur(radius: blurRadius)
            .opacity(opacity)
    }
}

#Preview {
    VStack(spacing: PlumpyTheme.Spacing.extraLarge) {
        VStack(spacing: PlumpyTheme.Spacing.large) {
            Text("Primary Background")
                .font(PlumpyTheme.Typography.title2)
                .plumpyBackground(style: .primary)
            
            Text("Primary Gradient")
                .font(PlumpyTheme.Typography.title2)
                .plumpyBackground(style: .primaryGradient)
            
            Text("Warm Gradient")
                .font(PlumpyTheme.Typography.title2)
                .plumpyBackground(style: .warmGradient)
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        
        VStack(spacing: PlumpyTheme.Spacing.large) {
            Text("Dots Pattern")
                .font(PlumpyTheme.Typography.title2)
                .plumpyBackground(style: .pattern(.dots))
            
            Text("Lines Pattern")
                .font(PlumpyTheme.Typography.title2)
                .plumpyBackground(style: .pattern(.lines))
            
            Text("Waves Pattern")
                .font(PlumpyTheme.Typography.title2)
                .plumpyBackground(style: .pattern(.waves))
            
            Text("Grid Pattern")
                .font(PlumpyTheme.Typography.title2)
                .plumpyBackground(style: .pattern(.grid))
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        
        HStack(spacing: PlumpyTheme.Spacing.large) {
            VStack {
                Text("Primary")
                    .font(PlumpyTheme.Typography.caption1)
                PlumpyCardBackground(style: .primary)
                    .frame(width: 60, height: 40)
            }
            
            VStack {
                Text("Success")
                    .font(PlumpyTheme.Typography.caption1)
                PlumpyCardBackground(style: .success)
                    .frame(width: 60, height: 40)
            }
            
            VStack {
                Text("Warning")
                    .font(PlumpyTheme.Typography.caption1)
                PlumpyCardBackground(style: .warning)
                    .frame(width: 60, height: 40)
            }
        }
    }
    .padding()
    .plumpyBackground(style: .primary)
}
