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
                    
                    HistoryView()
                        .tag(1)
                    
                    StatisticsView()
                        .tag(2)
                    
                    ProfileView()
                        .tag(3)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
                
                PlumpyTabBar(
                    selectedTab: $selectedTab,
                    tabs: [
                        PlumpyTabItem(icon: "house.fill", title: "Home", color: PlumpyTheme.primary),
                        PlumpyTabItem(icon: "clock.fill", title: "History", color: PlumpyTheme.primaryAccent),
                        PlumpyTabItem(icon: "chart.bar.fill", title: "Stats", color: PlumpyTheme.secondaryAccent),
                        PlumpyTabItem(icon: "person.fill", title: "Profile", color: PlumpyTheme.tertiary)
                    ]
                )
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [FoodEntry.self, FoodProduct.self, UserProfile.self], inMemory: true)
}
