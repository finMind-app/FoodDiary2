//
//  FoodDiaryViewModel.swift
//  FoodDiaryTwo
//
//  Created by Emil Svetlichnyy on 10.08.2025.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
class FoodDiaryViewModel: ObservableObject {
    private let modelContext: ModelContext
    
    @Published var selectedDate: Date = Date()
    @Published var showingAddFoodEntry: Bool = false
    @Published var showingAddProduct: Bool = false
    @Published var searchText: String = ""
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Date Formatting
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // MARK: - Food Entries Management
    
    func getFoodEntriesForDate(_ date: Date) -> [FoodEntry] {
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
    
    func addFoodEntry(_ entry: FoodEntry) {
        modelContext.insert(entry)
        saveContext()
    }
    
    func deleteFoodEntry(_ entry: FoodEntry) {
        modelContext.delete(entry)
        saveContext()
    }
    
    func updateFoodEntry(_ entry: FoodEntry) {
        entry.updatedAt = Date()
        saveContext()
    }
    
    // MARK: - Products Management
    
    func getProducts() -> [FoodProduct] {
        let descriptor = FetchDescriptor<FoodProduct>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching products: \(error)")
            return []
        }
    }
    
    func addProduct(_ product: FoodProduct) {
        modelContext.insert(product)
        saveContext()
    }
    
    func deleteProduct(_ product: FoodProduct) {
        modelContext.delete(product)
        saveContext()
    }
    
    func updateProduct(_ product: FoodProduct) {
        product.updatedAt = Date()
        saveContext()
    }
    
    // MARK: - User Profile Management
    
    func getUserProfile() -> UserProfile? {
        let descriptor = FetchDescriptor<UserProfile>()
        
        do {
            let profiles = try modelContext.fetch(descriptor)
            return profiles.first
        } catch {
            print("Error fetching user profile: \(error)")
            return nil
        }
    }
    
    func createUserProfile(
        name: String,
        age: Int,
        gender: Gender,
        height: Double,
        weight: Double,
        activityLevel: ActivityLevel,
        goal: Goal
    ) {
        let profile = UserProfile(
            name: name,
            age: age,
            gender: gender,
            height: height,
            weight: weight,
            activityLevel: activityLevel,
            goal: goal
        )
        
        modelContext.insert(profile)
        saveContext()
    }
    
    func updateUserProfile(_ profile: UserProfile) {
        profile.updatedAt = Date()
        saveContext()
    }
    
    // MARK: - Calculations
    
    func getTotalCaloriesForDate(_ date: Date) -> Int {
        let entries = getFoodEntriesForDate(date)
        return entries.reduce(0) { $0 + $1.totalCalories }
    }
    
    func getDailyCalorieGoal() -> Int {
        if let profile = getUserProfile() {
            return profile.dailyCalorieGoal
        }
        return 2000 // Default goal
    }
    
    func getCalorieProgress(for date: Date) -> Double {
        let total = getTotalCaloriesForDate(date)
        let goal = getDailyCalorieGoal()
        return goal > 0 ? Double(total) / Double(goal) : 0.0
    }
    
    func getMacroProgress(for date: Date) -> (protein: Double, carbs: Double, fat: Double) {
        let entries = getFoodEntriesForDate(date)
        let totalProtein = entries.reduce(0.0) { $0 + $1.totalProtein }
        let totalCarbs = entries.reduce(0.0) { $0 + $1.totalCarbs }
        let totalFat = entries.reduce(0.0) { $0 + $1.totalFat }
        
        let profile = getUserProfile()
        let proteinGoal = profile?.dailyProteinGoal ?? 150.0
        let carbsGoal = profile?.dailyCarbsGoal ?? 250.0
        let fatGoal = profile?.dailyFatGoal ?? 67.0
        
        return (
            protein: proteinGoal > 0 ? totalProtein / proteinGoal : 0.0,
            carbs: carbsGoal > 0 ? totalCarbs / carbsGoal : 0.0,
            fat: fatGoal > 0 ? totalFat / fatGoal : 0.0
        )
    }
    
    // MARK: - Search
    
    func searchProducts(query: String) -> [FoodProduct] {
        guard !query.isEmpty else { return [] }
        
        let products = getProducts()
        return products.filter { product in
            product.name.localizedCaseInsensitiveContains(query) ||
            (product.brand?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }
    
    // MARK: - History & Suggestions
    
    /// Returns all `FoodEntry` items for the last `days` days including today, sorted by most recent first.
    func getFoodEntriesForLastDays(_ days: Int) -> [FoodEntry] {
        let calendar = Calendar.current
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))!
        let startDate = calendar.date(byAdding: .day, value: -max(0, days - 1), to: calendar.startOfDay(for: Date())) ?? Date()
        
        let descriptor = FetchDescriptor<FoodEntry>(
            predicate: #Predicate<FoodEntry> { entry in
                entry.date >= startDate && entry.date < endOfToday
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching recent food entries: \(error)")
            return []
        }
    }
    
    /// Returns entries from the last 30 days that are similar by time-of-day to the provided `date`.
    /// Similarity is defined as within ±60 minutes from the provided time.
    func getSimilarFoodEntries(for date: Date) -> [FoodEntry] {
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        let descriptor = FetchDescriptor<FoodEntry>(
            predicate: #Predicate<FoodEntry> { entry in
                entry.date >= thirtyDaysAgo
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            let all = try modelContext.fetch(descriptor)
            let targetComponents = calendar.dateComponents([.hour, .minute], from: date)
            let targetMinutes = (targetComponents.hour ?? 0) * 60 + (targetComponents.minute ?? 0)
            
            return all.filter { entry in
                let comps = calendar.dateComponents([.hour, .minute], from: entry.date)
                let minutes = (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
                return abs(minutes - targetMinutes) <= 60
            }
        } catch {
            print("Error fetching similar entries: \(error)")
            return []
        }
    }
    
    /// Very simple heuristic suggestions based on remaining calories for the day.
    func getAIFoodSuggestions(for date: Date) -> [String] {
        let consumed = getTotalCaloriesForDate(date)
        let goal = getDailyCalorieGoal()
        let remaining = max(0, goal - consumed)
        
        if remaining <= 150 {
            return [
                "Light yogurt or cottage cheese",
                "A handful of berries",
                "Cucumber and tomato salad"
            ]
        } else if remaining <= 400 {
            return [
                "Chicken breast with veggies",
                "Omelet with spinach",
                "Greek salad with feta"
            ]
        } else {
            return [
                "Grilled salmon with rice",
                "Turkey wrap with whole grain tortilla",
                "Quinoa bowl with chicken and avocado"
            ]
        }
    }
    
    // MARK: - Private Methods
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
