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
        shadowStyle: PlumpyTheme.ShadowStyle = PlumpyTheme.Shadow.medium,
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
            .padding(.vertical, PlumpyTheme.Spacing.medium)
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
        shadowStyle: PlumpyTheme.ShadowStyle = PlumpyTheme.Shadow.medium,
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
            .padding(.vertical, PlumpyTheme.Spacing.medium)
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

// MARK: - View Extension

extension View {
    func plumpyCard(
        cornerRadius: CGFloat = PlumpyTheme.Radius.medium,
        shadowStyle: PlumpyTheme.ShadowStyle = PlumpyTheme.Shadow.medium,
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
    let action: (() -> Void)?
    
    init(
        title: String,
        subtitle: String? = nil,
        icon: String,
        iconColor: Color = PlumpyTheme.primaryAccent,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: PlumpyTheme.Spacing.medium) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(iconColor.opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.tiny) {
                    Text(title)
                        .font(PlumpyTheme.Typography.headline)
                        .foregroundColor(PlumpyTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(PlumpyTheme.Typography.caption1)
                            .foregroundColor(PlumpyTheme.textSecondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                if action != nil {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(PlumpyTheme.textTertiary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .plumpyCard(
            backgroundColor: PlumpyTheme.surfaceSecondary,
            borderColor: action != nil ? PlumpyTheme.borderLight : nil,
            borderWidth: action != nil ? 1 : 0
        )
    }
}

struct PlumpyStatsCard: View {
    let title: String
    let value: String
    let subtitle: String?
    let icon: String
    let iconColor: Color
    let trend: Trend?
    
    enum Trend {
        case up
        case down
        case neutral
        
        var icon: String {
            switch self {
            case .up:
                return "arrow.up.right"
            case .down:
                return "arrow.down.right"
            case .neutral:
                return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up:
                return PlumpyTheme.success
            case .down:
                return PlumpyTheme.error
            case .neutral:
                return PlumpyTheme.textTertiary
            }
        }
    }
    
    init(
        title: String,
        value: String,
        subtitle: String? = nil,
        icon: String,
        iconColor: Color = PlumpyTheme.primaryAccent,
        trend: Trend? = nil
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
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(iconColor.opacity(0.1))
                    )
                
                Spacer()
                
                if let trend = trend {
                    Image(systemName: trend.icon)
                        .font(.caption)
                        .foregroundColor(trend.color)
                }
            }
            
            VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.tiny) {
                Text(value)
                    .font(PlumpyTheme.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                
                Text(title)
                    .font(PlumpyTheme.Typography.subheadline)
                    .foregroundColor(PlumpyTheme.textSecondary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(PlumpyTheme.Typography.caption1)
                        .foregroundColor(PlumpyTheme.textTertiary)
                }
            }
        }
        .plumpyCard(
            backgroundColor: PlumpyTheme.surfaceSecondary
        )
    }
}

#Preview {
    VStack(spacing: PlumpyTheme.Spacing.large) {
        PlumpyCard {
            Text("Basic Card Content")
                .font(PlumpyTheme.Typography.body)
        }
        
        PlumpyInfoCard(
            title: "Profile Settings",
            subtitle: "Manage your account preferences",
            icon: "person.circle",
            action: {}
        )
        
        PlumpyStatsCard(
            title: "Total Calories",
            value: "1,250",
            subtitle: "Today's intake",
            icon: "flame.fill",
            iconColor: PlumpyTheme.warning,
            trend: .up
        )
        
        Text("Custom Card")
            .font(PlumpyTheme.Typography.headline)
            .plumpyCard(
                cornerRadius: PlumpyTheme.Radius.large,
                backgroundColor: PlumpyTheme.primary.opacity(0.1),
                borderColor: PlumpyTheme.primary,
                borderWidth: 2
            )
    }
    .padding()
    .background(PlumpyTheme.background)
}
