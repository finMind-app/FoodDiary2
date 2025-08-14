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
    
    // MARK: - Private Methods
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
