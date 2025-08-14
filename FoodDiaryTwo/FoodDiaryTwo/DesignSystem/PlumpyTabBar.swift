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

#Preview {
    PlumpyTabBar(
        selectedTab: .constant(0),
        tabs: [
            PlumpyTabItem(icon: "house.fill", title: "Home", color: PlumpyTheme.primaryAccent),
            PlumpyTabItem(icon: "chart.bar.fill", title: "Stats", color: PlumpyTheme.secondaryAccent),
            PlumpyTabItem(icon: "person.fill", title: "Profile", color: PlumpyTheme.tertiaryAccent)
        ]
    )
    .padding()
    .background(PlumpyTheme.background)
}
