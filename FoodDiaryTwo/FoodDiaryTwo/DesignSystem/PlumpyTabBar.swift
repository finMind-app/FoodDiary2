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
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation(PlumpyTheme.Animation.spring) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: PlumpyTheme.Spacing.tiny) {
                        Image(systemName: tabs[index].icon)
                            .font(.title3)
                            .foregroundColor(selectedTab == index ? tabs[index].color : PlumpyTheme.textTertiary)
                        
                        Text(tabs[index].title)
                            .font(PlumpyTheme.Typography.caption1)
                            .foregroundColor(selectedTab == index ? tabs[index].color : PlumpyTheme.textTertiary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PlumpyTheme.Spacing.medium)
                    .background(
                        Rectangle()
                            .fill(selectedTab == index ? tabs[index].color.opacity(0.1) : Color.clear)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, PlumpyTheme.Spacing.large)
        .padding(.vertical, PlumpyTheme.Spacing.small)
        .background(PlumpyTheme.surface)
        .overlay(
            Rectangle()
                .fill(PlumpyTheme.neutral100)
                .frame(height: 1),
            alignment: .top
        )
        .shadow(
            color: PlumpyTheme.shadow.opacity(0.03),
            radius: PlumpyTheme.Shadow.small.radius,
            x: PlumpyTheme.Shadow.small.x,
            y: PlumpyTheme.Shadow.small.y
        )
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
                PlumpyTabItem(icon: "chart.bar.fill", title: "Stats", color: PlumpyTheme.secondary),
                PlumpyTabItem(icon: "person.fill", title: "Profile", color: PlumpyTheme.tertiary)
            ]
        )
    }
    .background(PlumpyTheme.background)
}
