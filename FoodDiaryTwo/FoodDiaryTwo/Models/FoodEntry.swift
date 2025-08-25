//
//  FoodEntry.swift
//  FoodDiaryTwo
//
//  Created by Emil Svetlichnyy on 10.08.2025.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class FoodEntry {
    var id: UUID
    var name: String
    var date: Date
    var mealType: MealType
    var products: [FoodProduct]
    var notes: String?
    var photoData: Data?
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
        notes: String? = nil,
        photoData: Data? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.date = date
        self.mealType = mealType
        self.products = products
        self.notes = notes
        self.photoData = photoData
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
        return FoodEntryFormatters.shared.timeFormatter.string(from: date)
    }
    
    var formattedDate: String {
        return FoodEntryFormatters.shared.dateFormatter.string(from: date)
    }
}

final class FoodEntryFormatters {
    static let shared = FoodEntryFormatters()
    let timeFormatter: DateFormatter
    let dateFormatter: DateFormatter
    private init() {
        let tf = DateFormatter()
        tf.timeStyle = .short
        timeFormatter = tf
        let df = DateFormatter()
        df.dateStyle = .medium
        dateFormatter = df
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
    
    var color: Color {
        switch self {
        case .breakfast:
            return Color(hex: "#F59E0B") // Янтарный
        case .lunch:
            return Color(hex: "#10B981") // Изумрудный
        case .dinner:
            return Color(hex: "#6366F1") // Индиго
        case .snack:
            return Color(hex: "#EC4899") // Розовый
        }
    }
    
    var gradient: Gradient {
        switch self {
        case .breakfast:
            return Gradient(colors: [
                Color(hex: "#F59E0B"),
                Color(hex: "#F97316")
            ])
        case .lunch:
            return Gradient(colors: [
                Color(hex: "#10B981"),
                Color(hex: "#059669")
            ])
        case .dinner:
            return Gradient(colors: [
                Color(hex: "#6366F1"),
                Color(hex: "#4F46E5")
            ])
        case .snack:
            return Gradient(colors: [
                Color(hex: "#EC4899"),
                Color(hex: "#DB2777")
            ])
        }
    }
}
