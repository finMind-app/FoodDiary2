//
//  FoodProduct.swift
//  FoodDiaryTwo
//
//  Created by Emil Svetlichnyy on 10.08.2025.
//

import Foundation
import SwiftData

@Model
final class FoodProduct {
    var id: UUID
    var name: String
    var brand: String?
    var barcode: String?
    var servingSize: Double
    var servingUnit: String
    var caloriesPerServing: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    var fiber: Double
    var sugar: Double
    var sodium: Double
    var category: FoodCategory
    var isFavorite: Bool
    var createdAt: Date
    var updatedAt: Date
    
    init(
        name: String,
        brand: String? = nil,
        barcode: String? = nil,
        servingSize: Double = 100.0,
        servingUnit: String = "g",
        caloriesPerServing: Int = 0,
        protein: Double = 0.0,
        carbs: Double = 0.0,
        fat: Double = 0.0,
        fiber: Double = 0.0,
        sugar: Double = 0.0,
        sodium: Double = 0.0,
        category: FoodCategory = .other,
        isFavorite: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.brand = brand
        self.barcode = barcode
        self.servingSize = servingSize
        self.servingUnit = servingUnit
        self.caloriesPerServing = caloriesPerServing
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
        self.category = category
        self.isFavorite = isFavorite
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    var displayName: String {
        if let brand = brand, !brand.isEmpty {
            return "\(name) (\(brand))"
        }
        return name
    }
    
    var totalCalories: Int {
        return caloriesPerServing
    }
    
    var nutritionSummary: String {
        return "\(protein)g protein, \(carbs)g carbs, \(fat)g fat"
    }
}

enum FoodCategory: String, CaseIterable, Codable {
    case fruits = "fruits"
    case vegetables = "vegetables"
    case grains = "grains"
    case protein = "protein"
    case dairy = "dairy"
    case fats = "fats"
    case beverages = "beverages"
    case snacks = "snacks"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .fruits:
            return "Fruits"
        case .vegetables:
            return "Vegetables"
        case .grains:
            return "Grains"
        case .protein:
            return "Protein"
        case .dairy:
            return "Dairy"
        case .fats:
            return "Fats"
        case .beverages:
            return "Beverages"
        case .snacks:
            return "Snacks"
        case .other:
            return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .fruits:
            return "leaf.fill"
        case .vegetables:
            return "carrot.fill"
        case .grains:
            return "wheat"
        case .protein:
            return "fish.fill"
        case .dairy:
            return "drop.fill"
        case .fats:
            return "drop.triangle.fill"
        case .beverages:
            return "cup.and.saucer.fill"
        case .snacks:
            return "birthday.cake.fill"
        case .other:
            return "questionmark.circle.fill"
        }
    }
}

// MARK: - Способы приготовления
enum CookingMethod: String, CaseIterable, Codable {
    case raw = "Сырое"
    case boiled = "Вареное"
    case fried = "Жареное"
    case grilled = "Жаренное на гриле"
    case baked = "Запеченное"
    case steamed = "На пару"
    case roasted = "Тушеное"
    case unknown = "Неизвестно"
    
    var icon: String {
        switch self {
        case .raw: return "🥗"
        case .boiled: return "🍲"
        case .fried: return "🍳"
        case .grilled: return "🔥"
        case .baked: return "🥧"
        case .steamed: return "♨️"
        case .roasted: return "🍖"
        case .unknown: return "❓"
        }
    }
}
