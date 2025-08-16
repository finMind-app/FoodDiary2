//
//  PlumpyCard.swift
//  FoodDiaryTwo
//
//  Created by Plumpy UI Design System
//

import SwiftUI

struct PlumpyCard<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let shadowStyle: PlumpyTheme.ShadowStyle
    let backgroundColor: Color
    let borderColor: Color?
    let borderWidth: CGFloat
    
    init(
        cornerRadius: CGFloat = PlumpyTheme.Radius.medium,
        shadowStyle: PlumpyTheme.ShadowStyle = PlumpyTheme.Shadow.small,
        backgroundColor: Color = PlumpyTheme.surface,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.shadowStyle = shadowStyle
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(.horizontal, PlumpyTheme.Spacing.large)
            .padding(.vertical, PlumpyTheme.Spacing.large)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                Group {
                    if let borderColor = borderColor, borderWidth > 0 {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor, lineWidth: borderWidth)
                    }
                }
            )
            .shadow(
                color: shadowStyle.color.opacity(shadowStyle.opacity),
                radius: shadowStyle.radius,
                x: shadowStyle.x,
                y: shadowStyle.y
            )
    }
}

// MARK: - Card Modifier

struct PlumpyCardModifier: ViewModifier {
    let cornerRadius: CGFloat
    let shadowStyle: PlumpyTheme.ShadowStyle
    let backgroundColor: Color
    let borderColor: Color?
    let borderWidth: CGFloat
    
    init(
        cornerRadius: CGFloat = PlumpyTheme.Radius.medium,
        shadowStyle: PlumpyTheme.ShadowStyle = PlumpyTheme.Shadow.small,
        backgroundColor: Color = PlumpyTheme.surface,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 0
    ) {
        self.cornerRadius = cornerRadius
        self.shadowStyle = shadowStyle
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, PlumpyTheme.Spacing.large)
            .padding(.vertical, PlumpyTheme.Spacing.large)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                Group {
                    if let borderColor = borderColor, borderWidth > 0 {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(borderColor, lineWidth: borderWidth)
                    }
                }
            )
            .shadow(
                color: shadowStyle.color.opacity(shadowStyle.opacity),
                radius: shadowStyle.radius,
                x: shadowStyle.x,
                y: shadowStyle.y
            )
    }
}

// MARK: - View Extensions

extension View {
    func plumpyCard(
        cornerRadius: CGFloat = PlumpyTheme.Radius.medium,
        shadowStyle: PlumpyTheme.ShadowStyle = PlumpyTheme.Shadow.small,
        backgroundColor: Color = PlumpyTheme.surface,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 0
    ) -> some View {
        modifier(PlumpyCardModifier(
            cornerRadius: cornerRadius,
            shadowStyle: shadowStyle,
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            borderWidth: borderWidth
        ))
    }
}

// MARK: - Specialized Cards

struct PlumpyInfoCard: View {
    let title: String
    let subtitle: String?
    let icon: String
    let iconColor: Color
    let action: () -> Void
    
    init(
        title: String,
        subtitle: String? = nil,
        icon: String,
        iconColor: Color = PlumpyTheme.primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: PlumpyTheme.Spacing.medium) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.tiny) {
                    Text(title)
                        .font(PlumpyTheme.Typography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(PlumpyTheme.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(PlumpyTheme.Typography.caption1)
                            .foregroundColor(PlumpyTheme.textSecondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(PlumpyTheme.textTertiary)
            }
            .padding(.horizontal, PlumpyTheme.Spacing.large)
            .padding(.vertical, PlumpyTheme.Spacing.medium)
            .background(PlumpyTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium))
            .overlay(
                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                    .stroke(PlumpyTheme.neutral200, lineWidth: 1)
            )
            .shadow(
                color: PlumpyTheme.shadow.opacity(0.02),
                radius: PlumpyTheme.Shadow.small.radius,
                x: PlumpyTheme.Shadow.small.x,
                y: PlumpyTheme.Shadow.small.y
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PlumpyStatsCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let iconColor: Color
    let trend: PlumpyTrend
    
    enum PlumpyTrend {
        case up
        case down
        case neutral
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return PlumpyTheme.success
            case .down: return PlumpyTheme.error
            case .neutral: return PlumpyTheme.textTertiary
            }
        }
    }
    
    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String,
        iconColor: Color = PlumpyTheme.primary,
        trend: PlumpyTrend = .neutral
    ) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.trend = trend
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.medium) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 24, height: 24)
                
                Spacer()
                
                Image(systemName: trend.icon)
                    .font(.caption)
                    .foregroundColor(trend.color)
            }
            
            VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.tiny) {
                Text(value)
                    .font(PlumpyTheme.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                
                Text(title)
                    .font(PlumpyTheme.Typography.caption1)
                    .foregroundColor(PlumpyTheme.textSecondary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(PlumpyTheme.Typography.caption2)
                        .foregroundColor(PlumpyTheme.textTertiary)
                }
            }
        }
        .padding(.horizontal, PlumpyTheme.Spacing.large)
        .padding(.vertical, PlumpyTheme.Spacing.large)
        .background(PlumpyTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
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

#Preview {
    VStack(spacing: PlumpyTheme.Spacing.large) {
        PlumpyCard {
            VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.medium) {
                Text("Card Title")
                    .font(PlumpyTheme.Typography.title3)
                    .fontWeight(.semibold)
                
                Text("This is a sample card with some content to demonstrate the new design system.")
                    .font(PlumpyTheme.Typography.body)
                    .foregroundColor(PlumpyTheme.textSecondary)
            }
        }
        
        PlumpyInfoCard(
            title: "Personal Information",
            subtitle: "Edit your name, email, and photo",
            icon: "person.circle",
            iconColor: PlumpyTheme.primary
        ) {}
        
        PlumpyStatsCard(
            title: "Total Meals",
            value: "156",
            subtitle: "This month",
            icon: "fork.knife",
            iconColor: PlumpyTheme.primary,
            trend: .up
        )
    }
    .padding()
    .background(PlumpyTheme.background)
}
