//
//  PlumpyNavigationBar.swift
//  FoodDiaryTwo
//
//  Created by Plumpy UI Design System
//

import SwiftUI

struct PlumpyNavigationBar: View {
    let title: String
    let subtitle: String?
    let leftButton: PlumpyNavigationButton?
    let rightButton: PlumpyNavigationButton?
    let backgroundColor: Color
    let showBorder: Bool
    
    init(
        title: String,
        subtitle: String? = nil,
        leftButton: PlumpyNavigationButton? = nil,
        rightButton: PlumpyNavigationButton? = nil,
        backgroundColor: Color = PlumpyTheme.surface,
        showBorder: Bool = true
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leftButton = leftButton
        self.rightButton = rightButton
        self.backgroundColor = backgroundColor
        self.showBorder = showBorder
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: PlumpyTheme.Spacing.medium) {
                // Левая кнопка
                if let leftButton = leftButton {
                    leftButton
                        .frame(width: 44, height: 44)
                } else {
                    Spacer()
                        .frame(width: 44, height: 44)
                }
                
                // Заголовок
                VStack(spacing: PlumpyTheme.Spacing.tiny) {
                    Text(title)
                        .font(PlumpyTheme.Typography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(PlumpyTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(PlumpyTheme.Typography.caption1)
                            .foregroundColor(PlumpyTheme.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Правая кнопка
                if let rightButton = rightButton {
                    rightButton
                        .frame(width: 44, height: 44)
                } else {
                    Spacer()
                        .frame(width: 44, height: 44)
                }
            }
            .padding(.horizontal, PlumpyTheme.Spacing.large)
            .padding(.vertical, PlumpyTheme.Spacing.medium)
            .background(
                Rectangle()
                    .fill(backgroundColor)
                    .shadow(
                        color: PlumpyTheme.shadow.opacity(0.1),
                        radius: PlumpyTheme.Shadow.medium.radius,
                        x: PlumpyTheme.Shadow.medium.x,
                        y: PlumpyTheme.Shadow.medium.y
                    )
            )
            
            // Нижняя граница
            if showBorder {
                Rectangle()
                    .fill(PlumpyTheme.border)
                    .frame(height: 1)
            }
        }
    }
}

// MARK: - Navigation Button

struct PlumpyNavigationButton: View {
    let icon: String
    let title: String
    let style: PlumpyNavigationButtonStyle
    let action: () -> Void
    
    enum PlumpyNavigationButtonStyle {
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
        icon: String,
        title: String,
        style: PlumpyNavigationButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            withAnimation(PlumpyTheme.Animation.spring) {
                action()
            }
        }) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(style.foregroundColor)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(style.backgroundColor)
                        .overlay(
                            Circle()
                                .stroke(style.borderColor, lineWidth: style == .outline ? 2 : 0)
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

// MARK: - Tab Bar

struct PlumpyTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [PlumpyTabItem]
    let backgroundColor: Color
    let showBorder: Bool
    
    init(
        selectedTab: Binding<Int>,
        tabs: [PlumpyTabItem],
        backgroundColor: Color = PlumpyTheme.surface,
        showBorder: Bool = true
    ) {
        self._selectedTab = selectedTab
        self.tabs = tabs
        self.backgroundColor = backgroundColor
        self.showBorder = showBorder
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Верхняя граница
            if showBorder {
                Rectangle()
                    .fill(PlumpyTheme.border)
                    .frame(height: 1)
            }
            
            HStack(spacing: 0) {
                ForEach(0..<tabs.count, id: \.self) { index in
                    Button(action: {
                        withAnimation(PlumpyTheme.Animation.spring) {
                            selectedTab = index
                        }
                    }) {
                        VStack(spacing: PlumpyTheme.Spacing.tiny) {
                            Image(systemName: tabs[index].icon)
                                .font(.title2)
                                .foregroundColor(selectedTab == index ? tabs[index].color : PlumpyTheme.textTertiary)
                            
                            Text(tabs[index].title)
                                .font(PlumpyTheme.Typography.caption1)
                                .foregroundColor(selectedTab == index ? tabs[index].color : PlumpyTheme.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, PlumpyTheme.Spacing.medium)
                        .background(
                            Group {
                                if selectedTab == index {
                                    RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                                        .fill(tabs[index].color.opacity(0.15))
                                }
                            }
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, PlumpyTheme.Spacing.medium)
            .padding(.vertical, PlumpyTheme.Spacing.small)
            .background(
                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.large)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: PlumpyTheme.Radius.large)
                            .stroke(Color.black.opacity(0.05), lineWidth: 1)
                    )
            )
            .shadow(
                color: PlumpyTheme.shadow.opacity(0.1),
                radius: PlumpyTheme.Shadow.large.radius,
                x: PlumpyTheme.Shadow.large.x,
                y: PlumpyTheme.Shadow.large.y
            )
        }
    }
}

struct PlumpyTabItem {
    let icon: String
    let title: String
    let color: Color
    
    init(icon: String, title: String, color: Color) {
        self.icon = icon
        self.title = title
        self.color = color
    }
}

// MARK: - Breadcrumb Navigation

struct PlumpyBreadcrumb: View {
    let items: [PlumpyBreadcrumbItem]
    let onItemTap: (Int) -> Void
    
    init(items: [PlumpyBreadcrumbItem], onItemTap: @escaping (Int) -> Void) {
        self.items = items
        self.onItemTap = onItemTap
    }
    
    var body: some View {
        HStack(spacing: PlumpyTheme.Spacing.small) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(spacing: PlumpyTheme.Spacing.tiny) {
                    Button(action: {
                        onItemTap(index)
                    }) {
                        Text(item.title)
                            .font(PlumpyTheme.Typography.caption1)
                            .foregroundColor(index == items.count - 1 ? PlumpyTheme.textPrimary : PlumpyTheme.textSecondary)
                            .fontWeight(index == items.count - 1 ? .semibold : .regular)
                    }
                    
                    if index < items.count - 1 {
                        Image(systemName: "chevron.right")
                            .font(.caption2)
                            .foregroundColor(PlumpyTheme.textTertiary)
                    }
                }
            }
        }
        .padding(.horizontal, PlumpyTheme.Spacing.medium)
        .padding(.vertical, PlumpyTheme.Spacing.small)
        .background(
            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                .fill(PlumpyTheme.surfaceSecondary)
        )
    }
}

struct PlumpyBreadcrumbItem {
    let title: String
    let action: (() -> Void)?
    
    init(title: String, action: (() -> Void)? = nil) {
        self.title = title
        self.action = action
    }
}

#Preview {
    VStack(spacing: PlumpyTheme.Spacing.extraLarge) {
        PlumpyNavigationBar(
            title: "Home",
            subtitle: "Welcome back!",
            leftButton: PlumpyNavigationButton(
                icon: "chevron.left",
                title: "Back",
                style: .outline
            ) {},
            rightButton: PlumpyNavigationButton(
                icon: "plus",
                title: "Add",
                style: .primary
            ) {}
        )
        
        PlumpyTabBar(
            selectedTab: .constant(0),
            tabs: [
                PlumpyTabItem(icon: "house.fill", title: "Home", color: PlumpyTheme.primaryAccent),
                PlumpyTabItem(icon: "chart.bar.fill", title: "Stats", color: PlumpyTheme.secondaryAccent),
                PlumpyTabItem(icon: "gear", title: "Settings", color: PlumpyTheme.tertiaryAccent)
            ]
        )
        
        PlumpyBreadcrumb(
            items: [
                PlumpyBreadcrumbItem(title: "Home"),
                PlumpyBreadcrumbItem(title: "Meals"),
                PlumpyBreadcrumbItem(title: "Add Meal")
            ],
            onItemTap: { _ in }
        )
    }
    .padding()
    .background(PlumpyTheme.background)
}
