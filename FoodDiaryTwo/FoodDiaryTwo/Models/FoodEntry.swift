//
//  FoodEntry.swift
//  FoodDiaryTwo
//
//  Created by Emil Svetlichnyy on 10.08.2025.
//

import Foundation
import SwiftData

@Model
final class FoodEntry {
    var id: UUID
    var name: String
    var date: Date
    var mealType: MealType
    var products: [FoodProduct]
    var notes: String?
    var totalCalories: Int
    var totalProtein: Double
    var totalCarbs: Double
    var totalFat: Double
    var createdAt: Date
    var updatedAt: Date
    
    init(
        name: String,
        date: Date = Date(),
        mealType: MealType = .breakfast,
        products: [FoodProduct] = [],
        notes: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.date = date
        self.mealType = mealType
        self.products = products
        self.notes = notes
        self.totalCalories = products.reduce(0) { $0 + $1.totalCalories }
        self.totalProtein = products.reduce(0) { $0 + $1.protein }
        self.totalCarbs = products.reduce(0) { $0 + $1.carbs }
        self.totalFat = products.reduce(0) { $0 + $1.fat }
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var displayName: String {
        return name.isEmpty ? mealType.displayName : name
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

enum MealType: String, CaseIterable, Codable {
    case breakfast = "breakfast"
    case lunch = "lunch"
    case dinner = "dinner"
    case snack = "snack"
    
    var displayName: String {
        switch self {
        case .breakfast:
            return "Breakfast"
        case .lunch:
            return "Lunch"
        case .dinner:
            return "Dinner"
        case .snack:
            return "Snack"
        }
    }
    
    var icon: String {
        switch self {
        case .breakfast:
            return "sunrise.fill"
        case .lunch:
            return "sun.max.fill"
        case .dinner:
            return "moon.fill"
        case .snack:
            return "leaf.fill"
        }
    }
}
