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
    
    // Автоматические запросы для обновления UI
    @Query private var allFoodEntries: [FoodEntry]
    
    // Фильтрованные записи для выбранной даты
    private var foodEntriesForSelectedDate: [FoodEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return allFoodEntries.filter { entry in
            entry.date >= startOfDay && entry.date < endOfDay
        }.sorted { $0.date > $1.date }
    }
    
    // Общее количество калорий за выбранную дату
    private var totalCaloriesForSelectedDate: Int {
        foodEntriesForSelectedDate.reduce(0) { $0 + $1.totalCalories }
    }
    
    // Записи за последние 7 дней
    private var recentFoodEntries: [FoodEntry] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        return allFoodEntries.filter { entry in
            entry.date >= startDate
        }.sorted { $0.date > $1.date }
    }
    
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
                        
                        // Рекомендации
                        recommendationsSection
                        
                        PlumpySpacer(size: .large)
                    }
                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                    .padding(.top, PlumpyTheme.Spacing.medium)
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
            
            VStack(alignment: .trailing, spacing: PlumpyTheme.Spacing.tiny) {
                Text("\(totalCaloriesForSelectedDate)")
                    .font(PlumpyTheme.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(PlumpyTheme.primary)
                
                Text("calories")
                    .font(PlumpyTheme.Typography.caption2)
                    .foregroundColor(PlumpyTheme.textSecondary)
            }
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
                    value: Double(totalCaloriesForSelectedDate),
                    maxValue: Double(DailyGoalsService.shared.getDailyCalorieGoal(from: modelContext)),
                    size: 120,
                    lineWidth: 10,
                    style: .primary
                )
            }
            
            PlumpyProgressBar(
                value: Double(totalCaloriesForSelectedDate),
                maxValue: Double(DailyGoalsService.shared.getDailyCalorieGoal(from: modelContext)),
                title: "Goal: \(DailyGoalsService.shared.getDailyCalorieGoal(from: modelContext)) cal",
                showPercentage: true,
                style: .primary
            )
        }
        .plumpyCard()
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Quick Actions")
                .font(PlumpyTheme.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Кнопки для быстрого добавления разных типов приемов пищи
            VStack(spacing: PlumpyTheme.Spacing.small) {
                Text("Quick Add")
                    .font(PlumpyTheme.Typography.caption1)
                    .fontWeight(.medium)
                    .foregroundColor(PlumpyTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: PlumpyTheme.Spacing.small), count: 2), spacing: PlumpyTheme.Spacing.small) {
                    PlumpyButton(title: "Breakfast", icon: "sunrise.fill", style: .outline, size: .small) {
                        selectedMealType = .breakfast
                        showingAddFoodEntry = true
                    }
                    
                    PlumpyButton(title: "Lunch", icon: "sun.max.fill", style: .outline, size: .small) {
                        selectedMealType = .lunch
                        showingAddFoodEntry = true
                    }
                    
                    PlumpyButton(title: "Dinner", icon: "moon.fill", style: .outline, size: .small) {
                        selectedMealType = .dinner
                        showingAddFoodEntry = true
                    }
                    
                    PlumpyButton(title: "Snack", icon: "leaf.fill", style: .outline, size: .small) {
                        selectedMealType = .snack
                        showingAddFoodEntry = true
                    }
                }
                
                // Кнопка для фото и распознавания
                PlumpyButton(title: "📸 Photo Recognition", icon: "camera.fill", style: .primary, size: .medium) {
                    selectedMealType = .snack // По умолчанию для фото
                    showingAddFoodEntry = true
                }
                .frame(maxWidth: .infinity)
            }
        }
        .plumpyCard()
    }
    
    private var foodEntriesList: some View {
        return VStack(spacing: PlumpyTheme.Spacing.large) {
            HStack {
                Text("Today's Meals")
                    .font(PlumpyTheme.Typography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                
                Spacer()
                
                PlumpyBadge(
                    text: "\(foodEntriesForSelectedDate.count)",
                    style: .primary,
                    size: .medium
                )
            }
            
            if foodEntriesForSelectedDate.isEmpty {
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
                    ForEach(foodEntriesForSelectedDate) { entry in
                        FoodEntryCard(entry: entry)
                    }
                }
            }
        }
        .plumpyCard()
    }
    
    private var recommendationsSection: some View {
        return VStack(spacing: PlumpyTheme.Spacing.large) {
            Text("AI Recommendations")
                .font(PlumpyTheme.Typography.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
            
            // AI рекомендации
            VStack(spacing: PlumpyTheme.Spacing.medium) {
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
            HStack(spacing: PlumpyTheme.Spacing.medium) {
                // Фотография или иконка
                if let imageData = entry.photoData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium))
                        .shadow(
                            color: PlumpyTheme.shadow.opacity(0.1),
                            radius: 3,
                            x: 0,
                            y: 1
                        )
                } else {
                    Image(systemName: entry.mealType.icon)
                        .foregroundColor(PlumpyTheme.primary)
                        .frame(width: 50, height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                                .fill(PlumpyTheme.primary.opacity(0.1))
                        )
                }
                
                VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.tiny) {
                    Text(entry.displayName)
                        .font(PlumpyTheme.Typography.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(PlumpyTheme.textPrimary)
                    
                    Text(entry.formattedTime)
                        .font(PlumpyTheme.Typography.caption1)
                        .foregroundColor(PlumpyTheme.textSecondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: PlumpyTheme.Spacing.tiny) {
                    Text("\(entry.totalCalories)")
                        .font(PlumpyTheme.Typography.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(PlumpyTheme.primary)
                    
                    Text("cal")
                        .font(PlumpyTheme.Typography.caption2)
                        .foregroundColor(PlumpyTheme.textSecondary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .plumpyCard(
            cornerRadius: PlumpyTheme.Radius.medium,
            backgroundColor: PlumpyTheme.neutral50
        )
        .sheet(isPresented: $showingDetail) {
            FoodEntryDetailView(foodEntry: entry)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [FoodEntry.self, FoodProduct.self, UserProfile.self], inMemory: true)
}
