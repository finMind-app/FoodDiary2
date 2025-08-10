//
//  ContentView.swift
//  FoodDiaryTwo
//
//  Created by Emil Svetlichnyy on 10.08.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View { MainTabView() }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView().tabItem { Label("Главная", systemImage: "house.fill") }
            HistoryView().tabItem { Label("История", systemImage: "clock.fill") }
            StatsView().tabItem { Label("Статистика", systemImage: "chart.bar.fill") }
            SettingsView().tabItem { Label("Настройки", systemImage: "gearshape.fill") }
        }
    }
}

