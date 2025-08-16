//
//  HomeView.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var localizationManager = LocalizationManager.shared
    
    @State private var selectedDate: Date = Date()
    @State private var showingAddFoodEntry: Bool = false
    @State private var selectedMealType: MealType = .breakfast
    @State private var showingSearch = false
    @State private var showingAchievements = false
    @State private var showingHistory = false
    
    var body: some View {
        ZStack {
            PlumpyBackground(style: .gradient)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                PlumpyNavigationBar(
                    title: "Food Diary",
                    subtitle: nil
                )
                
                ScrollView {
                    VStack(spacing: PlumpyTheme.Spacing.large) {
                        // Заголовок с датой и поиском
                        headerSection
                        
                        // Кольцевая диаграмма калорий
                        calorieRingChart
                        
                        // Быстрые действия
                        quickActionsSection
                        
                        // Список приемов пищи
                        foodEntriesList
                        
                        // История и рекомендации
                        historySection
                        
                        PlumpySpacer(size: .large)
                    }
                    .padding(.horizontal, PlumpyTheme.Spacing.large)
                    .padding(.top, PlumpyTheme.Spacing.large)
                }
            }
        }
        .sheet(isPresented: $showingAddFoodEntry) {
            AddMealView(mealType: selectedMealType)
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func getFoodEntriesForDate(_ date: Date) -> [FoodEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<FoodEntry>(
            predicate: #Predicate<FoodEntry> { entry in
                entry.date >= startOfDay && entry.date < endOfDay
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching food entries: \(error)")
            return []
        }
    }
    
    private func getTotalCaloriesForDate(_ date: Date) -> Int {
        let entries = getFoodEntriesForDate(date)
        return entries.reduce(0) { $0 + $1.totalCalories }
    }
    
    private func getDailyCalorieGoal() -> Int {
        // Default goal, can be enhanced to fetch from user profile
        return 2000
    }
    
    private func getFoodEntriesForLastDays(_ days: Int) -> [FoodEntry] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        let descriptor = FetchDescriptor<FoodEntry>(
            predicate: #Predicate<FoodEntry> { entry in
                entry.date >= startDate
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching recent entries: \(error)")
            return []
        }
    }
    
    private func getSimilarFoodEntries(for date: Date) -> [FoodEntry] {
        // Simple implementation - return recent entries
        return getFoodEntriesForLastDays(7)
    }
    
    private func getAIFoodSuggestions(for date: Date) -> [String] {
        // Simple implementation - return some suggestions
        return [
            "Try adding more vegetables to your meals",
            "Consider having a protein-rich snack",
            "Stay hydrated throughout the day"
        ]
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.tiny) {
                Text(formatDate(selectedDate))
                    .font(PlumpyTheme.Typography.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                
                Text("Total calories today")
                    .font(PlumpyTheme.Typography.caption2)
                    .foregroundColor(PlumpyTheme.textSecondary)
            }
            
            Spacer()
            
            PlumpyButton(
                title: "Today",
                style: .outline,
                action: {
                    withAnimation(PlumpyTheme.Animation.spring) {
                        selectedDate = Date()
                    }
                }
            )
            .frame(maxWidth: 100)
        }
        .plumpyCard()
    }
    
    private var calorieRingChart: some View {
        VStack(spacing: PlumpyTheme.Spacing.large) {
            Text("Daily Progress")
                .font(PlumpyTheme.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
            
            ZStack {
                // Кольцевая диаграмма
                PlumpyCircularProgressBar(
                    value: Double(getTotalCaloriesForDate(selectedDate)),
                    maxValue: Double(getDailyCalorieGoal()),
                    size: 120,
                    lineWidth: 10,
                    style: .primary
                )
            }
            
            PlumpyProgressBar(
                value: Double(getTotalCaloriesForDate(selectedDate)),
                maxValue: Double(getDailyCalorieGoal()),
                title: "Goal: \(getDailyCalorieGoal()) cal",
                showPercentage: true,
                style: .primary
            )
        }
        .plumpyCard()
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.large) {
            Text("Meal Types")
                .font(PlumpyTheme.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: PlumpyTheme.Spacing.medium) {
                ForEach(MealType.allCases, id: \.self) { mealType in
                    Button(action: {
                        selectedMealType = mealType
                        showingAddFoodEntry = true
                    }) {
                        VStack(spacing: PlumpyTheme.Spacing.small) {
                            Image(systemName: mealType.icon)
                                .font(.title2)
                                .foregroundColor(PlumpyTheme.primary)
                            
                            Text(mealType.displayName)
                                .font(PlumpyTheme.Typography.caption1)
                                .fontWeight(.medium)
                                .foregroundColor(PlumpyTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, PlumpyTheme.Spacing.large)
                        .plumpyCard(
                            cornerRadius: PlumpyTheme.Radius.medium,
                            backgroundColor: PlumpyTheme.neutral50
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .plumpyCard()
    }
    
    private var foodEntriesList: some View {
        let entries = getFoodEntriesForDate(selectedDate)
        
        return VStack(spacing: PlumpyTheme.Spacing.large) {
            HStack {
                Text("Today's Meals")
                    .font(PlumpyTheme.Typography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                
                Spacer()
                
                PlumpyBadge(
                    text: "\(entries.count)",
                    style: .primary,
                    size: .medium
                )
            }
            
            if entries.isEmpty {
                PlumpyEmptyState(
                    icon: "fork.knife",
                    title: "No meals yet today",
                    subtitle: "Start tracking your nutrition by adding your first meal",
                    actionTitle: "Add Meal"
                ) {
                    selectedMealType = .breakfast
                    showingAddFoodEntry = true
                }
            } else {
                LazyVStack(spacing: PlumpyTheme.Spacing.medium) {
                    ForEach(entries) { entry in
                        FoodEntryCard(entry: entry)
                    }
                }
            }
        }
        .plumpyCard()
    }
    
    private var historySection: some View {
        let recentEntries = getFoodEntriesForLastDays(7)
        let similarEntries = getSimilarFoodEntries(for: selectedDate)
        
        return VStack(spacing: PlumpyTheme.Spacing.large) {
            Text("History & Recommendations")
                .font(PlumpyTheme.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
            
            if !recentEntries.isEmpty {
                VStack(spacing: PlumpyTheme.Spacing.medium) {
                    Text("A week ago at this time you ate:")
                        .font(PlumpyTheme.Typography.caption1)
                        .foregroundColor(PlumpyTheme.textSecondary)
                    
                    ForEach(similarEntries.prefix(3), id: \.id) { entry in
                        HStack {
                            Image(systemName: entry.mealType.icon)
                                .foregroundColor(PlumpyTheme.primary)
                                .frame(width: 20)
                            
                            Text(entry.displayName)
                                .font(PlumpyTheme.Typography.caption1)
                                .foregroundColor(PlumpyTheme.textPrimary)
                            
                            Spacer()
                            
                            Text("\(entry.totalCalories) cal")
                                .font(PlumpyTheme.Typography.caption1)
                                .foregroundColor(PlumpyTheme.textSecondary)
                        }
                        .padding(PlumpyTheme.Spacing.medium)
                        .plumpyCard(
                            cornerRadius: PlumpyTheme.Radius.small,
                            backgroundColor: PlumpyTheme.neutral50
                        )
                    }
                }
            }
            
            // AI рекомендации
            VStack(spacing: PlumpyTheme.Spacing.medium) {
                Text("AI recommends:")
                    .font(PlumpyTheme.Typography.caption1)
                    .foregroundColor(PlumpyTheme.textSecondary)
                
                let suggestions = getAIFoodSuggestions(for: Date())
                ForEach(suggestions.prefix(3), id: \.self) { suggestion in
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(PlumpyTheme.warning)
                            .frame(width: 20)
                        
                        Text(suggestion)
                            .font(PlumpyTheme.Typography.caption1)
                            .foregroundColor(PlumpyTheme.textPrimary)
                        
                        Spacer()
                    }
                    .padding(PlumpyTheme.Spacing.medium)
                    .plumpyCard(
                        cornerRadius: PlumpyTheme.Radius.small,
                        backgroundColor: PlumpyTheme.warning.opacity(0.1)
                    )
                }
            }
        }
        .plumpyCard()
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: PlumpyTheme.Spacing.small) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(PlumpyTheme.Typography.caption1)
                    .fontWeight(.medium)
                    .foregroundColor(PlumpyTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, PlumpyTheme.Spacing.large)
            .plumpyCard(
                cornerRadius: PlumpyTheme.Radius.medium,
                backgroundColor: PlumpyTheme.neutral50
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FoodEntryCard: View {
    let entry: FoodEntry
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            VStack(spacing: PlumpyTheme.Spacing.large) {
                HStack {
                    HStack(spacing: PlumpyTheme.Spacing.medium) {
                        Image(systemName: entry.mealType.icon)
                            .foregroundColor(PlumpyTheme.primary)
                            .frame(width: 20)
                        
                        VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.tiny) {
                            Text(entry.displayName)
                                .font(PlumpyTheme.Typography.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(PlumpyTheme.textPrimary)
                            
                            Text(entry.formattedTime)
                                .font(PlumpyTheme.Typography.caption1)
                                .foregroundColor(PlumpyTheme.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: PlumpyTheme.Spacing.tiny) {
                        Text("\(entry.totalCalories)")
                            .font(PlumpyTheme.Typography.title3)
                            .fontWeight(.bold)
                            .foregroundColor(PlumpyTheme.primary)
                        
                        Text("calories")
                            .font(PlumpyTheme.Typography.caption2)
                            .foregroundColor(PlumpyTheme.textSecondary)
                    }
                }
                
                if !entry.products.isEmpty {
                    VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.medium) {
                        Text("Products")
                            .font(PlumpyTheme.Typography.caption1)
                            .fontWeight(.medium)
                            .foregroundColor(PlumpyTheme.textSecondary)
                        
                        ForEach(entry.products.prefix(3)) { product in
                            HStack {
                                Text(product.displayName)
                                    .font(PlumpyTheme.Typography.caption1)
                                    .foregroundColor(PlumpyTheme.textPrimary)
                                
                                Spacer()
                                
                                Text("\(product.totalCalories) cal")
                                    .font(PlumpyTheme.Typography.caption1)
                                    .foregroundColor(PlumpyTheme.textSecondary)
                            }
                        }
                        
                        if entry.products.count > 3 {
                            Text("and \(entry.products.count - 3) more...")
                                .font(PlumpyTheme.Typography.caption1)
                                .foregroundColor(PlumpyTheme.textTertiary)
                        }
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .plumpyCard(
            cornerRadius: PlumpyTheme.Radius.medium,
            backgroundColor: PlumpyTheme.neutral50
        )
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [FoodEntry.self, FoodProduct.self, UserProfile.self], inMemory: true)
}
