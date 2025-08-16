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
    let size: PlumpyButtonSize
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void
    
    enum PlumpyButtonSize {
        case small
        case medium
        case large
        
        var padding: EdgeInsets {
            switch self {
            case .small:
                return EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
            case .medium:
                return EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
            case .large:
                return EdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
            }
        }
        
        var fontSize: Font {
            switch self {
            case .small:
                return PlumpyTheme.Typography.caption1
            case .medium:
                return PlumpyTheme.Typography.body
            case .large:
                return PlumpyTheme.Typography.headline
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small:
                return 14
            case .medium:
                return 16
            case .large:
                return 18
            }
        }
    }
    
    enum PlumpyButtonStyle {
        case primary
        case secondary
        case accent
        case success
        case warning
        case error
        case outline
        case ghost
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return PlumpyTheme.primary
            case .secondary:
                return PlumpyTheme.secondary
            case .accent:
                return PlumpyTheme.tertiary
            case .success:
                return PlumpyTheme.success
            case .warning:
                return PlumpyTheme.warning
            case .error:
                return PlumpyTheme.error
            case .outline, .ghost:
                return Color.clear
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .secondary, .accent, .success, .warning, .error:
                return PlumpyTheme.textInverse
            case .outline:
                return PlumpyTheme.primary
            case .ghost:
                return PlumpyTheme.textPrimary
            }
        }
        
        var borderColor: Color {
            switch self {
            case .outline:
                return PlumpyTheme.primary
            case .ghost:
                return Color.clear
            default:
                return Color.clear
            }
        }
        
        var borderWidth: CGFloat {
            switch self {
            case .outline:
                return 1.5
            default:
                return 0
            }
        }
    }
    
    init(
        title: String,
        icon: String? = nil,
        style: PlumpyButtonStyle = .primary,
        size: PlumpyButtonSize = .medium,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
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
                        .font(.system(size: size.iconSize))
                }
                
                Text(title)
                    .font(size.fontSize)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isEnabled ? style.foregroundColor : PlumpyTheme.textTertiary)
            .padding(size.padding)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                    .fill(isEnabled ? style.backgroundColor : PlumpyTheme.neutral200)
                    .overlay(
                        RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                            .stroke(style.borderColor, lineWidth: style.borderWidth)
                    )
            )
            .shadow(
                color: isEnabled && style != .ghost ? style.backgroundColor.opacity(0.2) : Color.clear,
                radius: PlumpyTheme.Shadow.small.radius,
                x: PlumpyTheme.Shadow.small.x,
                y: PlumpyTheme.Shadow.small.y
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
        case ghost
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return PlumpyTheme.primary
            case .secondary:
                return PlumpyTheme.secondary
            case .accent:
                return PlumpyTheme.tertiary
            case .outline, .ghost:
                return Color.clear
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .secondary, .accent:
                return PlumpyTheme.textInverse
            case .outline:
                return PlumpyTheme.primary
            case .ghost:
                return PlumpyTheme.textPrimary
            }
        }
        
        var borderColor: Color {
            switch self {
            case .outline:
                return PlumpyTheme.primary
            default:
                return Color.clear
            }
        }
    }
    
    init(
        systemImageName: String,
        title: String,
        style: PlumpyButtonStyle = .primary,
        size: CGFloat = 44,
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
                    RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                        .fill(style.backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                                .stroke(style.borderColor, lineWidth: style == .outline ? 1.5 : 0)
                        )
                )
                .shadow(
                    color: style.backgroundColor.opacity(0.2),
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
                .font(.title2)
                .foregroundColor(PlumpyTheme.textInverse)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(PlumpyTheme.primary)
                        .shadow(
                            color: PlumpyTheme.primary.opacity(0.3),
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
        PlumpyButton(title: "Ghost Button", icon: "settings", style: .ghost) {}
        PlumpyButton(title: "Loading Button", isLoading: true) {}
        PlumpyButton(title: "Disabled Button", isEnabled: false) {}
        
        HStack(spacing: PlumpyTheme.Spacing.medium) {
            PlumpyIconButton(systemImageName: "plus", title: "Add") {}
            PlumpyIconButton(systemImageName: "heart", title: "Like", style: .secondary) {}
            PlumpyIconButton(systemImageName: "star", title: "Favorite", style: .accent) {}
            PlumpyIconButton(systemImageName: "settings", title: "Settings", style: .ghost) {}
        }
        
        PlumpyFloatingButton(icon: "plus") {}
    }
    .padding()
    .background(PlumpyTheme.background)
}
