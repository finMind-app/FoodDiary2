//
//  ContentView.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            PlumpyBackground(style: .primary)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tag(0)
                    
                    HistoryStatsSettings()
                        .tag(1)
                    
                    ProfileView()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                PlumpyTabBar(
                    selectedTab: $selectedTab,
                    tabs: [
                        PlumpyTabItem(icon: "house.fill", title: "Home", color: PlumpyTheme.primary),
                        PlumpyTabItem(icon: "chart.bar.fill", title: "Stats", color: PlumpyTheme.secondary),
                        PlumpyTabItem(icon: "person.fill", title: "Profile", color: PlumpyTheme.tertiary)
                    ]
                )
                .padding(.horizontal, PlumpyTheme.Spacing.large)
                .padding(.bottom, PlumpyTheme.Spacing.small)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [FoodEntry.self, FoodProduct.self, UserProfile.self], inMemory: true)
}
