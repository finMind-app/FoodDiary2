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
                // Tab Content
                TabView(selection: $selectedTab) {
                    HomeView(modelContext: try! ModelContainer(for: FoodEntry.self, FoodProduct.self, UserProfile.self).mainContext)
                        .tag(0)
                    
                    HistoryStatsSettings()
                        .tag(1)
                    
                    ProfileView()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Custom Tab Bar
                PlumpyTabBar(
                    selectedTab: $selectedTab,
                    tabs: [
                        PlumpyTabItem(icon: "house.fill", title: "Home", color: PlumpyTheme.primaryAccent),
                        PlumpyTabItem(icon: "chart.bar.fill", title: "Stats", color: PlumpyTheme.secondaryAccent),
                        PlumpyTabItem(icon: "person.fill", title: "Profile", color: PlumpyTheme.tertiaryAccent)
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
        .modelContainer(for: FoodEntry.self, inMemory: true)
}
