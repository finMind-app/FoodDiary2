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
    @StateObject private var viewModel: FoodDiaryViewModel
    @StateObject private var localizationManager = LocalizationManager.shared
    
    @Query private var foodEntries: [FoodEntry]
    
    @State private var showingSearch = false
    @State private var showingAchievements = false
    @State private var showingHistory = false
    
    init(modelContext: ModelContext) {
        self._viewModel = StateObject(wrappedValue: FoodDiaryViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        ZStack {
            PlumpyBackground(style: .warmGradient)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Navigation Bar
                PlumpyNavigationBar(
                    title: "Food Diary",
                    subtitle: "Track your nutrition journey"
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
                        
                        PlumpySpacer(size: .huge)
                    }
                    .padding(.horizontal, PlumpyTheme.Spacing.large)
                    .padding(.top, PlumpyTheme.Spacing.large)
                }
            }
        }
        .sheet(isPresented: $viewModel.showingAddFoodEntry) {
            AddMealView()
        }
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.tiny) {
                Text(viewModel.formatDate(viewModel.selectedDate))
                    .font(PlumpyTheme.Typography.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(PlumpyTheme.textPrimary)
                
                Text("Total calories today")
                    .font(PlumpyTheme.Typography.caption1)
                    .foregroundColor(PlumpyTheme.textSecondary)
            }
            
            Spacer()
            
            PlumpyButton(
                title: "Today",
                style: .outline,
                action: {
                    withAnimation(PlumpyTheme.Animation.spring) {
                        viewModel.selectedDate = Date()
                    }
                }
            )
            .frame(maxWidth: 100)
        }
        .plumpyCard()
    }
    
    private var calorieRingChart: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Daily Progress")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
            
            ZStack {
                // Кольцевая диаграмма
                PlumpyCircularProgressBar(
                    value: Double(viewModel.getTotalCaloriesForDate(viewModel.selectedDate)),
                    maxValue: Double(viewModel.getDailyCalorieGoal()),
                    size: 120,
                    lineWidth: 12,
                    style: .primary
                )
                
                // Центральная информация
                VStack(spacing: PlumpyTheme.Spacing.tiny) {
                    Text("\(viewModel.getTotalCaloriesForDate(viewModel.selectedDate))")
                        .font(PlumpyTheme.Typography.title1)
                        .fontWeight(.bold)
                        .foregroundColor(PlumpyTheme.primaryAccent)
                    
                    Text("calories")
                        .font(PlumpyTheme.Typography.caption1)
                        .foregroundColor(PlumpyTheme.textSecondary)
                }
            }
            
            // Прогресс-бар
            PlumpyProgressBar(
                value: Double(viewModel.getTotalCaloriesForDate(viewModel.selectedDate)),
                maxValue: Double(viewModel.getDailyCalorieGoal()),
                title: "Goal: \(viewModel.getDailyCalorieGoal()) calories",
                showPercentage: true,
                style: .primary
            )
        }
        .plumpyCard()
    }
    
    private var quickActionsSection: some View {
        VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("Quick Actions")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
            
            HStack(spacing: PlumpyTheme.Spacing.medium) {
                PlumpyActionIconButton(
                    systemImageName: "plus.circle.fill",
                    title: "Add Meal",
                    color: PlumpyTheme.primaryAccent
                ) {
                    viewModel.showingAddFoodEntry = true
                }
                
                PlumpyActionIconButton(
                    systemImageName: "camera.fill",
                    title: "Photo",
                    color: PlumpyTheme.secondaryAccent
                ) {
                    // Camera action
                }
                
                PlumpyActionIconButton(
                    systemImageName: "chart.bar.fill",
                    title: "Stats",
                    color: PlumpyTheme.tertiaryAccent
                ) {
                    // Stats action
                }
            }
        }
        .plumpyCard()
    }
    
    private var foodEntriesList: some View {
        let entries = viewModel.getFoodEntriesForDate(viewModel.selectedDate)
        
        return VStack(spacing: PlumpyTheme.Spacing.medium) {
            HStack {
                Text("Today's Meals")
                    .font(PlumpyTheme.Typography.headline)
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
                    viewModel.showingAddFoodEntry = true
                }
            } else {
                LazyVStack(spacing: PlumpyTheme.Spacing.small) {
                    ForEach(entries) { entry in
                        FoodEntryCard(entry: entry, viewModel: viewModel)
                    }
                }
            }
        }
        .plumpyCard()
    }
    
    private var historySection: some View {
        let recentEntries = viewModel.getFoodEntriesForLastDays(7)
        let similarEntries = viewModel.getSimilarFoodEntries(for: viewModel.selectedDate)
        
        return VStack(spacing: PlumpyTheme.Spacing.medium) {
            Text("History & Recommendations")
                .font(PlumpyTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(PlumpyTheme.textPrimary)
            
            if !recentEntries.isEmpty {
                VStack(spacing: PlumpyTheme.Spacing.small) {
                    Text("A week ago at this time you ate:")
                        .font(PlumpyTheme.Typography.caption1)
                        .foregroundColor(PlumpyTheme.textSecondary)
                    
                    ForEach(similarEntries.prefix(3), id: \.id) { entry in
                        HStack {
                            Image(systemName: entry.mealType.icon)
                                .foregroundColor(PlumpyTheme.primaryAccent)
                                .frame(width: 20)
                            
                            Text(entry.displayName)
                                .font(PlumpyTheme.Typography.caption1)
                                .foregroundColor(PlumpyTheme.textPrimary)
                            
                            Spacer()
                            
                            Text("\(entry.totalCalories) cal")
                                .font(PlumpyTheme.Typography.caption1)
                                .foregroundColor(PlumpyTheme.textSecondary)
                        }
                        .padding(PlumpyTheme.Spacing.small)
                        .plumpyCard(
                            cornerRadius: PlumpyTheme.Radius.small,
                            backgroundColor: PlumpyTheme.surfaceSecondary
                        )
                    }
                }
            }
            
            // AI рекомендации
            VStack(spacing: PlumpyTheme.Spacing.small) {
                Text("AI recommends:")
                    .font(PlumpyTheme.Typography.caption1)
                    .foregroundColor(PlumpyTheme.textSecondary)
                
                let suggestions = viewModel.getAIFoodSuggestions(for: Date())
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
                    .padding(PlumpyTheme.Spacing.small)
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
            .padding(.vertical, PlumpyTheme.Spacing.medium)
            .plumpyCard(
                cornerRadius: PlumpyTheme.Radius.medium,
                backgroundColor: PlumpyTheme.surfaceSecondary
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FoodEntryCard: View {
    let entry: FoodEntry
    let viewModel: FoodDiaryViewModel
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            VStack(spacing: PlumpyTheme.Spacing.medium) {
                HStack {
                    HStack(spacing: PlumpyTheme.Spacing.small) {
                        Image(systemName: entry.mealType.icon)
                            .foregroundColor(PlumpyTheme.primaryAccent)
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
                            .foregroundColor(PlumpyTheme.primaryAccent)
                        
                        Text("calories")
                            .font(PlumpyTheme.Typography.caption2)
                            .foregroundColor(PlumpyTheme.textSecondary)
                    }
                }
                
                if !entry.products.isEmpty {
                    VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
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
            backgroundColor: PlumpyTheme.surfaceSecondary
        )
    }
}

#Preview {
    HomeView(modelContext: try! ModelContainer(for: FoodEntry.self, FoodProduct.self).mainContext)
}
