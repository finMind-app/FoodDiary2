//
//  PlumpyButton.swift
//  FoodDiaryTwo
//
//  Created by Plumpy UI Design System
//

import SwiftUI

struct PlumpyButton: View {
    let title: String
    let icon: String?
    let style: PlumpyButtonStyle
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void
    
    enum PlumpyButtonStyle {
        case primary
        case secondary
        case accent
        case success
        case warning
        case error
        case outline
        
        var backgroundColor: Color {
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
            case .outline:
                return Color.clear
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .secondary, .accent, .success, .warning, .error:
                return PlumpyTheme.textInverse
            case .outline:
                return PlumpyTheme.primaryAccent
            }
        }
        
        var borderColor: Color {
            switch self {
            case .outline:
                return PlumpyTheme.primaryAccent
            default:
                return Color.clear
            }
        }
    }
    
    init(
        title: String,
        icon: String? = nil,
        style: PlumpyButtonStyle = .primary,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if isEnabled && !isLoading {
                withAnimation(PlumpyTheme.Animation.spring) {
                    action()
                }
            }
        }) {
            HStack(spacing: PlumpyTheme.Spacing.small) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: style.foregroundColor))
                        .scaleEffect(0.8)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(PlumpyTheme.Typography.subheadline)
                }
                
                Text(title)
                    .font(PlumpyTheme.Typography.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isEnabled ? style.foregroundColor : PlumpyTheme.textTertiary)
            .padding(.horizontal, PlumpyTheme.Spacing.medium)
            .padding(.vertical, PlumpyTheme.Spacing.small)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                    .fill(isEnabled ? style.backgroundColor : PlumpyTheme.surfaceTertiary)
                    .overlay(
                        RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                            .stroke(style.borderColor, lineWidth: style == .outline ? 2 : 0)
                    )
            )
            .shadow(
                color: isEnabled ? style.backgroundColor.opacity(0.3) : Color.clear,
                radius: PlumpyTheme.Shadow.medium.radius,
                x: PlumpyTheme.Shadow.medium.x,
                y: PlumpyTheme.Shadow.medium.y
            )
        }
        .disabled(!isEnabled || isLoading)
        .scaleEffect(isEnabled && !isLoading ? 1.0 : 0.98)
        .animation(PlumpyTheme.Animation.spring, value: isEnabled)
        .animation(PlumpyTheme.Animation.spring, value: isLoading)
    }
}

// MARK: - Button Variants

struct PlumpyIconButton: View {
    let systemImageName: String
    let title: String
    let style: PlumpyButtonStyle
    let size: CGFloat
    let action: () -> Void
    
    enum PlumpyButtonStyle {
        case primary
        case secondary
        case accent
        case outline
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return PlumpyTheme.primaryAccent
            case .secondary:
                return PlumpyTheme.secondaryAccent
            case .accent:
                return PlumpyTheme.tertiaryAccent
            case .outline:
                return Color.clear
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .secondary, .accent:
                return PlumpyTheme.textInverse
            case .outline:
                return PlumpyTheme.primaryAccent
            }
        }
    }
    
    init(
        systemImageName: String,
        title: String,
        style: PlumpyButtonStyle = .primary,
        size: CGFloat = 36,
        action: @escaping () -> Void
    ) {
        self.systemImageName = systemImageName
        self.title = title
        self.style = style
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            withAnimation(PlumpyTheme.Animation.spring) {
                action()
            }
        }) {
            Image(systemName: systemImageName)
                .font(.title3)
                .foregroundColor(style.foregroundColor)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(style.backgroundColor)
                        .overlay(
                            Circle()
                                .stroke(style == .outline ? PlumpyTheme.primaryAccent : Color.clear, lineWidth: 2)
                        )
                )
                .shadow(
                    color: style.backgroundColor.opacity(0.3),
                    radius: PlumpyTheme.Shadow.small.radius,
                    x: PlumpyTheme.Shadow.small.x,
                    y: PlumpyTheme.Shadow.small.y
                )
        }
        .accessibilityLabel(title)
        .scaleEffect(1.0)
        .animation(PlumpyTheme.Animation.spring, value: true)
    }
}

// MARK: - Floating Action Button

struct PlumpyFloatingButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(PlumpyTheme.Animation.bouncy) {
                action()
            }
        }) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(PlumpyTheme.textInverse)
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(PlumpyTheme.primaryAccent)
                        .shadow(
                            color: PlumpyTheme.primaryAccent.opacity(0.4),
                            radius: PlumpyTheme.Shadow.large.radius,
                            x: PlumpyTheme.Shadow.large.x,
                            y: PlumpyTheme.Shadow.large.y
                        )
                )
        }
        .scaleEffect(1.0)
        .animation(PlumpyTheme.Animation.spring, value: true)
    }
}

#Preview {
    VStack(spacing: PlumpyTheme.Spacing.large) {
        PlumpyButton(title: "Primary Button", icon: "plus") {}
        PlumpyButton(title: "Secondary Button", icon: "heart", style: .secondary) {}
        PlumpyButton(title: "Accent Button", icon: "star", style: .accent) {}
        PlumpyButton(title: "Outline Button", icon: "arrow.right", style: .outline) {}
        PlumpyButton(title: "Loading Button", isLoading: true) {}
        PlumpyButton(title: "Disabled Button", isEnabled: false) {}
        
        HStack(spacing: PlumpyTheme.Spacing.medium) {
            PlumpyIconButton(systemImageName: "plus", title: "Add") {}
            PlumpyIconButton(systemImageName: "heart", title: "Like", style: .secondary) {}
            PlumpyIconButton(systemImageName: "star", title: "Favorite", style: .accent) {}
        }
        
        PlumpyFloatingButton(icon: "plus") {}
    }
    .padding()
    .background(PlumpyTheme.background)
}
