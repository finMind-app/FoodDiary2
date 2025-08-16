//
//  StatisticsView.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Environment(\.modelContext) private var modelContext
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
        ZStack {
            PlumpyBackground(style: .primary)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                PlumpyNavigationBar(
                    title: "Statistics",
                    subtitle: "Your nutrition insights"
                )
                
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
                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                    .padding(.top, PlumpyTheme.Spacing.medium)
                }
            }
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
                value: String(totalCalories),
                subtitle: "This period",
                icon: "flame.fill",
                iconColor: PlumpyTheme.warning,
                trend: .up
            )
            
            PlumpyStatsCard(
                title: "Meals",
                value: String(totalMeals),
                subtitle: "This period",
                icon: "fork.knife",
                iconColor: PlumpyTheme.primaryAccent,
                trend: .up
            )
            
            PlumpyStatsCard(
                title: "Avg. Daily",
                value: String(averageDailyCalories),
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

    private var totalMeals: Int {
        periodEntries.count
    }
    private var totalCalories: Int {
        periodEntries.reduce(0) { $0 + $1.totalCalories }
    }
    private var averageDailyCalories: Int {
        let days = max(1, uniqueDayCount)
        return totalCalories / days
    }
    private var uniqueDayCount: Int {
        let calendar = Calendar.current
        let days = Set(periodEntries.map { calendar.startOfDay(for: $0.date) })
        return days.count
    }
    private var periodEntries: [FoodEntry] {
        let calendar = Calendar.current
        let startDate: Date
        switch selectedPeriod {
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        }
        let descriptor = FetchDescriptor<FoodEntry>(
            predicate: #Predicate<FoodEntry> { entry in
                entry.date >= startDate
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
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
                    iconColor: PlumpyTheme.warning,
                    action: {}
                )
                
                PlumpyInfoCard(
                    title: "Best Day",
                    subtitle: "Wednesday - 1,450 cal",
                    icon: "star.fill",
                    iconColor: PlumpyTheme.warning,
                    action: {}
                )
                
                PlumpyInfoCard(
                    title: "Streak",
                    subtitle: "7 days in a row",
                    icon: "flame.fill",
                    iconColor: PlumpyTheme.error,
                    action: {}
                )
            }
        }
        .plumpyCard()
    }
}

#Preview {
    StatisticsView()
        .modelContainer(for: [FoodEntry.self, FoodProduct.self, UserProfile.self], inMemory: true)
}
