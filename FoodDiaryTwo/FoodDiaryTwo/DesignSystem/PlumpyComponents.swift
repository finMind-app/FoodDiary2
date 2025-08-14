//
//  PlumpyComponents.swift
//  FoodDiaryTwo
//
//  Created by Plumpy UI Design System
//

import SwiftUI

// MARK: - Action Icon Button

struct PlumpyActionIconButton: View {
    let systemImageName: String
    let title: String
    let color: Color
    let action: () -> Void
    
    init(
        systemImageName: String,
        title: String,
        color: Color = PlumpyTheme.primaryAccent,
        action: @escaping () -> Void
    ) {
        self.systemImageName = systemImageName
        self.title = title
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            withAnimation(PlumpyTheme.Animation.spring) {
                action()
            }
        }) {
            VStack(spacing: PlumpyTheme.Spacing.small) {
                Image(systemName: systemImageName)
                    .font(.title2)
                    .foregroundColor(PlumpyTheme.textInverse)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(color)
                            .shadow(
                                color: color.opacity(0.3),
                                radius: PlumpyTheme.Shadow.small.radius,
                                x: PlumpyTheme.Shadow.small.x,
                                y: PlumpyTheme.Shadow.small.y
                            )
                    )
                
                Text(title)
                    .font(PlumpyTheme.Typography.caption1)
                    .fontWeight(.medium)
                    .foregroundColor(PlumpyTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(1.0)
        .animation(PlumpyTheme.Animation.spring, value: true)
    }
}

// MARK: - Chip

struct PlumpyChip: View {
    let title: String
    let icon: String?
    let style: PlumpyChipStyle
    let isSelected: Bool
    let action: () -> Void
    
    enum PlumpyChipStyle {
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
        style: PlumpyChipStyle = .primary,
        isSelected: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            withAnimation(PlumpyTheme.Animation.spring) {
                action()
            }
        }) {
            HStack(spacing: PlumpyTheme.Spacing.tiny) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                
                Text(title)
                    .font(PlumpyTheme.Typography.caption1)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? style.foregroundColor : PlumpyTheme.textSecondary)
            .padding(.horizontal, PlumpyTheme.Spacing.medium)
            .padding(.vertical, PlumpyTheme.Spacing.small)
            .background(
                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.round)
                    .fill(isSelected ? style.backgroundColor : PlumpyTheme.surfaceSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: PlumpyTheme.Radius.round)
                            .stroke(
                                isSelected ? style.borderColor : PlumpyTheme.border,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(PlumpyTheme.Animation.spring, value: isSelected)
    }
}

// MARK: - Badge

struct PlumpyBadge: View {
    let text: String
    let style: PlumpyBadgeStyle
    let size: PlumpyBadgeSize
    
    enum PlumpyBadgeStyle {
        case primary
        case secondary
        case accent
        case success
        case warning
        case error
        
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
            }
        }
        
        var foregroundColor: Color {
            return PlumpyTheme.textInverse
        }
    }
    
    enum PlumpyBadgeSize {
        case small
        case medium
        case large
        
        var padding: CGFloat {
            switch self {
            case .small:
                return PlumpyTheme.Spacing.tiny
            case .medium:
                return PlumpyTheme.Spacing.small
            case .large:
                return PlumpyTheme.Spacing.medium
            }
        }
        
        var fontSize: Font {
            switch self {
            case .small:
                return PlumpyTheme.Typography.caption2
            case .medium:
                return PlumpyTheme.Typography.caption1
            case .large:
                return PlumpyTheme.Typography.footnote
            }
        }
    }
    
    init(
        text: String,
        style: PlumpyBadgeStyle = .primary,
        size: PlumpyBadgeSize = .medium
    ) {
        self.text = text
        self.style = style
        self.size = size
    }
    
    var body: some View {
        Text(text)
            .font(size.fontSize)
            .fontWeight(.semibold)
            .foregroundColor(style.foregroundColor)
            .padding(.horizontal, size.padding)
            .padding(.vertical, size.padding / 2)
            .background(
                Capsule()
                    .fill(style.backgroundColor)
                    .shadow(
                        color: style.backgroundColor.opacity(0.3),
                        radius: PlumpyTheme.Shadow.small.radius,
                        x: PlumpyTheme.Shadow.small.x,
                        y: PlumpyTheme.Shadow.small.y
                    )
            )
    }
}

// MARK: - Divider

struct PlumpyDivider: View {
    let style: PlumpyDividerStyle
    let spacing: CGFloat
    
    enum PlumpyDividerStyle {
        case solid
        case dashed
        case dotted
        
        var strokeStyle: StrokeStyle {
            switch self {
            case .solid:
                return StrokeStyle(lineWidth: 1)
            case .dashed:
                return StrokeStyle(lineWidth: 1, dash: [5, 5])
            case .dotted:
                return StrokeStyle(lineWidth: 1, dash: [2, 2])
            }
        }
    }
    
    init(style: PlumpyDividerStyle = .solid, spacing: CGFloat = PlumpyTheme.Spacing.medium) {
        self.style = style
        self.spacing = spacing
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            Rectangle()
                .fill(PlumpyTheme.border)
                .frame(height: 1)
                .overlay(
                    Rectangle()
                        .stroke(PlumpyTheme.border, style: style.strokeStyle)
                )
        }
    }
}

// MARK: - Spacer

struct PlumpySpacer: View {
    let size: PlumpySpacerSize
    
    enum PlumpySpacerSize {
        case tiny
        case small
        case medium
        case large
        case extraLarge
        case huge
        
        var height: CGFloat {
            switch self {
            case .tiny:
                return PlumpyTheme.Spacing.tiny
            case .small:
                return PlumpyTheme.Spacing.small
            case .medium:
                return PlumpyTheme.Spacing.medium
            case .large:
                return PlumpyTheme.Spacing.large
            case .extraLarge:
                return PlumpyTheme.Spacing.extraLarge
            case .huge:
                return PlumpyTheme.Spacing.huge
            }
        }
    }
    
    init(size: PlumpySpacerSize = .medium) {
        self.size = size
    }
    
    var body: some View {
        Spacer()
            .frame(height: size.height)
    }
}

// MARK: - Loading Indicator

struct PlumpyLoadingIndicator: View {
    let style: PlumpyLoadingIndicatorStyle
    let size: CGFloat
    let color: Color
    
    enum PlumpyLoadingIndicatorStyle {
        case spinner
        case dots
        case pulse
    }
    
    init(
        style: PlumpyLoadingIndicatorStyle = .spinner,
        size: CGFloat = 40,
        color: Color = PlumpyTheme.primaryAccent
    ) {
        self.style = style
        self.size = size
        self.color = color
    }
    
    var body: some View {
        Group {
            switch style {
            case .spinner:
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: color))
                    .scaleEffect(size / 40)
                
            case .dots:
                HStack(spacing: PlumpyTheme.Spacing.tiny) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(color)
                            .frame(width: size / 6, height: size / 6)
                            .scaleEffect(1.0)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                value: true
                            )
                    }
                }
                
            case .pulse:
                Circle()
                    .fill(color)
                    .frame(width: size, height: size)
                    .scaleEffect(1.0)
                    .animation(
                        Animation.easeInOut(duration: 1.0)
                            .repeatForever(autoreverses: true),
                        value: true
                    )
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Empty State

struct PlumpyEmptyState: View {
    let icon: String
    let title: String
    let subtitle: String?
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        subtitle: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: PlumpyTheme.Spacing.large) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(PlumpyTheme.textTertiary)
            
            VStack(spacing: PlumpyTheme.Spacing.small) {
                Text(title)
                    .font(PlumpyTheme.Typography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                    .multilineTextAlignment(.center)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(PlumpyTheme.Typography.body)
                        .foregroundColor(PlumpyTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }
            
            if let actionTitle = actionTitle, let action = action {
                PlumpyButton(
                    title: actionTitle,
                    icon: "plus",
                    style: .primary,
                    action: action
                )
                .frame(maxWidth: 200)
            }
        }
        .padding(PlumpyTheme.Spacing.extraLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: PlumpyTheme.Spacing.extraLarge) {
            // Action Icon Buttons
            HStack(spacing: PlumpyTheme.Spacing.large) {
                PlumpyActionIconButton(
                    systemImageName: "plus",
                    title: "Add",
                    color: PlumpyTheme.primaryAccent
                ) {}
                
                PlumpyActionIconButton(
                    systemImageName: "heart",
                    title: "Like",
                    color: PlumpyTheme.secondaryAccent
                ) {}
                
                PlumpyActionIconButton(
                    systemImageName: "star",
                    title: "Favorite",
                    color: PlumpyTheme.tertiaryAccent
                ) {}
            }
            
            // Chips
            VStack(spacing: PlumpyTheme.Spacing.medium) {
                Text("Chips")
                    .font(PlumpyTheme.Typography.headline)
                
                HStack(spacing: PlumpyTheme.Spacing.small) {
                    PlumpyChip(title: "Primary", style: .primary, isSelected: true) {}
                    PlumpyChip(title: "Secondary", style: .secondary) {}
                    PlumpyChip(title: "Outline", style: .outline) {}
                }
            }
            
            // Badges
            VStack(spacing: PlumpyTheme.Spacing.medium) {
                Text("Badges")
                    .font(PlumpyTheme.Typography.headline)
                
                HStack(spacing: PlumpyTheme.Spacing.medium) {
                    PlumpyBadge(text: "New", style: .primary, size: .small)
                    PlumpyBadge(text: "Popular", style: .secondary, size: .medium)
                    PlumpyBadge(text: "Hot", style: .warning, size: .large)
                }
            }
            
            // Loading Indicators
            VStack(spacing: PlumpyTheme.Spacing.medium) {
                Text("Loading Indicators")
                    .font(PlumpyTheme.Typography.headline)
                
                HStack(spacing: PlumpyTheme.Spacing.large) {
                    PlumpyLoadingIndicator(style: .spinner)
                    PlumpyLoadingIndicator(style: .dots)
                    PlumpyLoadingIndicator(style: .pulse)
                }
            }
            
            // Empty State
            PlumpyEmptyState(
                icon: "tray",
                title: "No meals yet",
                subtitle: "Start by adding your first meal to track your nutrition journey",
                actionTitle: "Add Meal"
            ) {}
        }
        .padding()
    }
    .plumpyBackground(style: .primary)
}
