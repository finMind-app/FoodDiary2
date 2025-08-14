//
//  HistoryStatsSettings.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import SwiftUI

struct HistoryStatsSettings: View {
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            PlumpyBackground(style: .primary)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                PlumpyNavigationBar(
                    title: "More",
                    subtitle: "History, Stats & Settings"
                )
                
                // Tab Content
                TabView(selection: $selectedTab) {
                    HistoryView()
                        .tag(0)
                    
                    StatisticsView()
                        .tag(1)
                    
                    SettingsView()
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // Custom Tab Bar
                PlumpyTabBar(
                    selectedTab: $selectedTab,
                    tabs: [
                        PlumpyTabItem(icon: "clock.fill", title: "History", color: PlumpyTheme.primaryAccent),
                        PlumpyTabItem(icon: "chart.bar.fill", title: "Stats", color: PlumpyTheme.secondaryAccent),
                        PlumpyTabItem(icon: "gear", title: "Settings", color: PlumpyTheme.tertiaryAccent)
                    ]
                )
                .padding(.horizontal, PlumpyTheme.Spacing.large)
                .padding(.bottom, PlumpyTheme.Spacing.small)
            }
        }
    }
}

// MARK: - History View

struct HistoryView: View {
    @State private var selectedPeriod: HistoryPeriod = .week
    @State private var searchText = ""
    
    enum HistoryPeriod: String, CaseIterable {
        case week = "week"
        case month = "month"
        case year = "year"
        
        var displayName: String {
            switch self {
            case .week: return "Week"
            case .month: return "Month"
            case .year: return "Year"
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: PlumpyTheme.Spacing.large) {
                // Период
                periodSelector
                
                // Поиск
                searchSection
                
                // Список записей
                historyList
                
                PlumpySpacer(size: .huge)
            }
            .padding(.horizontal, PlumpyTheme.Spacing.large)
            .padding(.top, PlumpyTheme.Spacing.large)
        }
    }
    
    private var periodSelector: some View {
        VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.medium) {
            Text("Period")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
            
            HStack(spacing: PlumpyTheme.Spacing.small) {
                ForEach(HistoryPeriod.allCases, id: \.self) { period in
                    PlumpyChip(
                        title: period.displayName,
                        style: selectedPeriod == period ? .primary : .outline,
                        isSelected: selectedPeriod == period
                    ) {
                        selectedPeriod = period
                    }
                }
            }
        }
        .plumpyCard()
    }
    
    private var searchSection: some View {
        PlumpySearchField(
            text: $searchText,
            placeholder: "Search meals...",
            onSearch: { query in
                // Поиск по записям
            }
        )
    }
    
    private var historyList: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Recent Meals")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Заглушка для списка
            PlumpyEmptyState(
                icon: "clock",
                title: "No history yet",
                subtitle: "Your meal history will appear here once you start tracking",
                actionTitle: "Add First Meal"
            ) {
                // Действие добавления
            }
        }
        .plumpyCard()
    }
}

// MARK: - Statistics View

struct StatisticsView: View {
    @State private var selectedPeriod: StatisticsPeriod = .week
    
    enum StatisticsPeriod: String, CaseIterable {
        case week = "week"
        case month = "month"
        case year = "year"
        
        var displayName: String {
            switch self {
            case .week: return "Week"
            case .month: return "Month"
            case .year: return "Year"
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: PlumpyTheme.Spacing.large) {
                // Период
                periodSelector
                
                // Основная статистика
                mainStatistics
                
                // График калорий
                caloriesChart
                
                // Дополнительная статистика
                additionalStats
                
                PlumpySpacer(size: .huge)
            }
            .padding(.horizontal, PlumpyTheme.Spacing.large)
            .padding(.top, PlumpyTheme.Spacing.large)
        }
    }
    
    private var periodSelector: some View {
        VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.medium) {
            Text("Period")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
            
            HStack(spacing: PlumpyTheme.Spacing.small) {
                ForEach(StatisticsPeriod.allCases, id: \.self) { period in
                    PlumpyChip(
                        title: period.displayName,
                        style: selectedPeriod == period ? .primary : .outline,
                        isSelected: selectedPeriod == period
                    ) {
                        selectedPeriod = period
                    }
                }
            }
        }
        .plumpyCard()
    }
    
    private var mainStatistics: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: PlumpyTheme.Spacing.medium) {
            PlumpyStatsCard(
                title: "Total Calories",
                value: "8,450",
                subtitle: "This period",
                icon: "flame.fill",
                iconColor: PlumpyTheme.warning,
                trend: .up
            )
            
            PlumpyStatsCard(
                title: "Meals",
                value: "42",
                subtitle: "This period",
                icon: "fork.knife",
                iconColor: PlumpyTheme.primaryAccent,
                trend: .up
            )
            
            PlumpyStatsCard(
                title: "Avg. Daily",
                value: "1,208",
                subtitle: "Calories",
                icon: "chart.line.uptrend.xyaxis",
                iconColor: PlumpyTheme.secondaryAccent,
                trend: .neutral
            )
            
            PlumpyStatsCard(
                title: "Goal Met",
                value: "85%",
                subtitle: "Of days",
                icon: "target",
                iconColor: PlumpyTheme.success,
                trend: .up
            )
        }
    }
    
    private var caloriesChart: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Calories Over Time")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Заглушка для графика
            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                .fill(PlumpyTheme.surfaceSecondary)
                .frame(height: 200)
                .overlay(
                    VStack(spacing: PlumpyTheme.Spacing.medium) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 40))
                            .foregroundColor(PlumpyTheme.textTertiary)
                        
                        Text("Chart will appear here")
                            .font(PlumpyTheme.Typography.caption1)
                            .foregroundColor(PlumpyTheme.textTertiary)
                    }
                )
        }
        .plumpyCard()
    }
    
    private var additionalStats: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Additional Insights")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: PlumpyTheme.Spacing.small) {
                PlumpyInfoCard(
                    title: "Most Common Meal",
                    subtitle: "Breakfast - 15 times",
                    icon: "sunrise.fill",
                    iconColor: PlumpyTheme.warning
                )
                
                PlumpyInfoCard(
                    title: "Best Day",
                    subtitle: "Wednesday - 1,450 cal",
                    icon: "star.fill",
                    iconColor: PlumpyTheme.warning
                )
                
                PlumpyInfoCard(
                    title: "Streak",
                    subtitle: "7 days in a row",
                    icon: "flame.fill",
                    iconColor: PlumpyTheme.error
                )
            }
        }
        .plumpyCard()
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var selectedLanguage = "English"
    @State private var dailyGoal = 2000
    
    let languages = ["English", "Русский", "Español", "Français"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: PlumpyTheme.Spacing.large) {
                // Профиль
                profileSection
                
                // Настройки приложения
                appSettingsSection
                
                // Цели
                goalsSection
                
                // О приложении
                aboutSection
                
                PlumpySpacer(size: .huge)
            }
            .padding(.horizontal, PlumpyTheme.Spacing.large)
            .padding(.top, PlumpyTheme.Spacing.large)
        }
    }
    
    private var profileSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Profile")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.Typography.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: PlumpyTheme.Spacing.medium) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(PlumpyTheme.primaryAccent)
                
                VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.tiny) {
                    Text("User Name")
                        .font(PlumpyTheme.Typography.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(PlumpyTheme.textPrimary)
                    
                    Text("user@example.com")
                        .font(PlumpyTheme.Typography.caption1)
                        .foregroundColor(PlumpyTheme.textSecondary)
                }
                
                Spacer()
                
                PlumpyButton(
                    title: "Edit",
                    icon: "pencil",
                    style: .outline
                ) {
                    // Редактирование профиля
                }
                .frame(maxWidth: 80)
            }
        }
        .plumpyCard()
    }
    
    private var appSettingsSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("App Settings")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: PlumpyTheme.Spacing.small) {
                PlumpyInfoCard(
                    title: "Notifications",
                    subtitle: notificationsEnabled ? "Enabled" : "Disabled",
                    icon: "bell.fill",
                    iconColor: notificationsEnabled ? PlumpyTheme.success : PlumpyTheme.textTertiary
                ) {
                    notificationsEnabled.toggle()
                }
                
                PlumpyInfoCard(
                    title: "Dark Mode",
                    subtitle: darkModeEnabled ? "Enabled" : "Disabled",
                    icon: "moon.fill",
                    iconColor: darkModeEnabled ? PlumpyTheme.tertiaryAccent : PlumpyTheme.textTertiary
                ) {
                    darkModeEnabled.toggle()
                }
                
                PlumpyInfoCard(
                    title: "Language",
                    subtitle: selectedLanguage,
                    icon: "globe",
                    iconColor: PlumpyTheme.info
                ) {
                    // Выбор языка
                }
            }
        }
        .plumpyCard()
    }
    
    private var goalsSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Goals")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: PlumpyTheme.Spacing.medium) {
                VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
                    Text("Daily Calorie Goal")
                        .font(PlumpyTheme.Typography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(PlumpyTheme.textSecondary)
                    
                    HStack {
                        Text("\(dailyGoal)")
                            .font(PlumpyTheme.Typography.title2)
                            .fontWeight(.bold)
                            .foregroundColor(PlumpyTheme.primaryAccent)
                        
                        Text("calories")
                            .font(PlumpyTheme.Typography.caption1)
                            .foregroundColor(PlumpyTheme.textSecondary)
                        
                        Spacer()
                        
                        PlumpyButton(
                            title: "Change",
                            icon: "pencil",
                            style: .outline
                        ) {
                            // Изменение цели
                        }
                        .frame(maxWidth: 100)
                    }
                }
                
                PlumpyProgressBar(
                    value: 1250,
                    maxValue: Double(dailyGoal),
                    title: "Today's Progress",
                    showPercentage: true,
                    style: .primary
                )
            }
        }
        .plumpyCard()
    }
    
    private var aboutSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("About")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: PlumpyTheme.Spacing.small) {
                PlumpyInfoCard(
                    title: "Version",
                    subtitle: "1.0.0",
                    icon: "info.circle",
                    iconColor: PlumpyTheme.info
                )
                
                PlumpyInfoCard(
                    title: "Developer",
                    subtitle: "Food Diary Team",
                    icon: "person.2.fill",
                    iconColor: PlumpyTheme.primaryAccent
                )
                
                PlumpyInfoCard(
                    title: "Privacy Policy",
                    subtitle: "Read our privacy policy",
                    icon: "hand.raised.fill",
                    iconColor: PlumpyTheme.secondaryAccent
                ) {
                    // Открытие политики конфиденциальности
                }
                
                PlumpyInfoCard(
                    title: "Terms of Service",
                    subtitle: "Read our terms of service",
                    icon: "doc.text.fill",
                    iconColor: PlumpyTheme.tertiaryAccent
                ) {
                    // Открытие условий использования
                }
            }
        }
        .plumpyCard()
    }
}

#Preview {
    HistoryStatsSettings()
}
