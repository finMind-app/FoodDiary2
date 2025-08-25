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
    @State private var lastTabSwitchMark = ""
    
    var body: some View {
        ZStack {
            PlumpyBackground(style: .primary)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case 0: HomeView()
                    case 1: HistoryView()
                    case 2: StatisticsView()
                    case 3: ProfileView()
                    default: HomeView()
                    }
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: selectedTab)
                .onChange(of: selectedTab) { _, newValue in
                    PerformanceLogger.end(lastTabSwitchMark)
                    lastTabSwitchMark = "tab_switch_\(newValue)"
                    PerformanceLogger.begin(lastTabSwitchMark)
                }

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
