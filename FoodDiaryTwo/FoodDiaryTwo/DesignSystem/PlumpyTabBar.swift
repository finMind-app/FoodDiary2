//
//  PlumpyTabBar.swift
//  FoodDiaryTwo
//
//  Created by Plumpy UI Design System
//

import SwiftUI

struct PlumpyTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [PlumpyTabItem]
    
    var body: some View {
        HStack(spacing: PlumpyTheme.Spacing.medium) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    PerformanceLogger.begin("tab_button_\(index)")
                    withAnimation(PlumpyTheme.Animation.spring) {
                        selectedTab = index
                    }
                    PerformanceLogger.end("tab_button_\(index)")
                }) {
                    VStack(spacing: 2) {
                        Image(systemName: tabs[index].icon)
                            .font(.system(size: 16))
                            .foregroundColor(selectedTab == index ? tabs[index].color : PlumpyTheme.textTertiary)
                        
                        Text(tabs[index].title)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(selectedTab == index ? tabs[index].color : PlumpyTheme.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
                    .background(
                        RoundedRectangle(cornerRadius: PlumpyTheme.Radius.extraLarge)
                            .fill(selectedTab == index ? tabs[index].color.opacity(0.15) : Color.clear)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(selectedTab == index ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: selectedTab)
            }
        }
        .padding(.horizontal, PlumpyTheme.Spacing.medium)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.extraLarge)
                .fill(PlumpyTheme.surface)
                .shadow(
                    color: PlumpyTheme.shadow.opacity(0.06),
                    radius: PlumpyTheme.Shadow.medium.radius,
                    x: PlumpyTheme.Shadow.medium.x,
                    y: PlumpyTheme.Shadow.medium.y
                )
        )
        .padding(.horizontal, PlumpyTheme.Spacing.large)
        .padding(.bottom, 0)
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

#Preview {
    VStack {
        Spacer()
        
        PlumpyTabBar(
            selectedTab: .constant(0),
            tabs: [
                PlumpyTabItem(icon: "house.fill", title: "Home", color: PlumpyTheme.primary),
                PlumpyTabItem(icon: "chart.bar.fill", title: LocalizationManager.shared.localizedString(.stats), color: PlumpyTheme.secondary),
                PlumpyTabItem(icon: "person.fill", title: LocalizationManager.shared.localizedString(.profile), color: PlumpyTheme.tertiary)
            ]
        )
    }
    .background(PlumpyTheme.background)
}
