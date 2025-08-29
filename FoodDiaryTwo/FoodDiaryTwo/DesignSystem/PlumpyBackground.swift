//
//  PlumpyBackground.swift
//  FoodDiaryTwo
//
//  Created by Plumpy UI Design System
//

import SwiftUI

struct PlumpyBackground: View {
    let style: PlumpyBackgroundStyle
    
    enum PlumpyBackgroundStyle {
        case primary
        case secondary
        case gradient
        case pattern
        case minimal
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return PlumpyTheme.background
            case .secondary:
                return PlumpyTheme.neutral50
            case .gradient:
                return PlumpyTheme.background
            case .pattern:
                return PlumpyTheme.background
            case .minimal:
                return PlumpyTheme.background
            }
        }
        
        var gradient: LinearGradient? {
            switch self {
            case .gradient:
                return LinearGradient(
                    colors: [
                        PlumpyTheme.primary.opacity(0.05),
                        PlumpyTheme.secondary.opacity(0.03),
                        PlumpyTheme.background
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            default:
                return nil
            }
        }
    }
    
    init(style: PlumpyBackgroundStyle = .primary) {
        self.style = style
    }
    
    var body: some View {
        ZStack {
            // Основной фон
            if let gradient = style.gradient {
                gradient
            } else {
                style.backgroundColor
            }
            
            // Паттерн (только для pattern стиля)
            if style == .pattern {
                patternOverlay
            }
        }
    }
    
    private var patternOverlay: some View {
        Canvas { context, size in
            // Минималистичный точечный паттерн
            let dotSize: CGFloat = 2
            let spacing: CGFloat = 24
            
            for x in stride(from: 0, through: size.width, by: spacing) {
                for y in stride(from: 0, through: size.height, by: spacing) {
                    let rect = CGRect(
                        x: x - dotSize / 2,
                        y: y - dotSize / 2,
                        width: dotSize,
                        height: dotSize
                    )
                    
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(PlumpyTheme.neutral300.opacity(0.3))
                    )
                }
            }
        }
    }
}

// MARK: - View Extension

extension View {
    func plumpyBackground(style: PlumpyBackground.PlumpyBackgroundStyle = .primary) -> some View {
        background(PlumpyBackground(style: style))
    }
}

#Preview {
    VStack(spacing: PlumpyTheme.Spacing.large) {
        Text("Primary Background")
            .overlay(Text(LocalizationManager.shared.localizedString(.primaryBackground)).opacity(0))
            .font(PlumpyTheme.Typography.title2)
            .frame(maxWidth: .infinity)
            .padding()
            .plumpyBackground(style: .primary)
        
        Text(LocalizationManager.shared.localizedString(.secondaryBackground))
            .font(PlumpyTheme.Typography.title2)
            .frame(maxWidth: .infinity)
            .padding()
            .plumpyBackground(style: .secondary)
        
        Text(LocalizationManager.shared.localizedString(.gradientBackground))
            .font(PlumpyTheme.Typography.title2)
            .frame(maxWidth: .infinity)
            .padding()
            .plumpyBackground(style: .gradient)
        
        Text(LocalizationManager.shared.localizedString(.patternBackground))
            .font(PlumpyTheme.Typography.title2)
            .frame(maxWidth: .infinity)
            .padding()
            .plumpyBackground(style: .pattern)
        
        Text(LocalizationManager.shared.localizedString(.minimalBackground))
            .font(PlumpyTheme.Typography.title2)
            .frame(maxWidth: .infinity)
            .padding()
            .plumpyBackground(style: .minimal)
    }
    .padding()
}
