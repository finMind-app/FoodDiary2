//
//  FoodDataService.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import Foundation
import UIKit

// MARK: - Центральный сервис для работы с данными о еде
class FoodDataService: ObservableObject {
    
    // MARK: - Синглтон
    static let shared = FoodDataService()
    
    // MARK: - База данных продуктов
    private let foodDatabase: [String: FoodData] = [
        "apple": FoodData(
            name: "Яблоко",
            calories: 52,
            protein: 0.3,
            fat: 0.2,
            carbs: 14,
            category: .fruits,
            isProcessed: false,
            cookingMethod: .raw,
            estimatedServingSize: "1 среднее яблоко (180г)"
        ),
        "banana": FoodData(
            name: "Банан",
            calories: 89,
            protein: 1.1,
            fat: 0.3,
            carbs: 23,
            category: .fruits,
            isProcessed: false,
            cookingMethod: .raw,
            estimatedServingSize: "1 средний банан (120г)"
        ),
        "chicken_breast": FoodData(
            name: "Куриная грудка",
            calories: 165,
            protein: 31,
            fat: 3.6,
            carbs: 0,
            category: .protein,
            isProcessed: true,
            cookingMethod: .grilled,
            estimatedServingSize: "1 грудка (174г)"
        ),
        "rice": FoodData(
            name: "Рис отварной",
            calories: 130,
            protein: 2.7,
            fat: 0.3,
            carbs: 28,
            category: .grains,
            isProcessed: true,
            cookingMethod: .boiled,
            estimatedServingSize: "1 чашка (158г)"
        ),
        "salad": FoodData(
            name: "Салат из овощей",
            calories: 25,
            protein: 1.5,
            fat: 0.2,
            carbs: 5,
            category: .vegetables,
            isProcessed: false,
            cookingMethod: .raw,
            estimatedServingSize: "1 порция (100г)"
        ),
        "pizza": FoodData(
            name: "Пицца",
            calories: 266,
            protein: 11,
            fat: 10,
            carbs: 33,
            category: .other,
            isProcessed: true,
            cookingMethod: .baked,
            estimatedServingSize: "1 ломтик (100г)"
        ),
        "yogurt": FoodData(
            name: "Греческий йогурт",
            calories: 59,
            protein: 10,
            fat: 0.4,
            carbs: 3.6,
            category: .dairy,
            isProcessed: true,
            cookingMethod: .raw,
            estimatedServingSize: "1 стакан (170г)"
        ),
        "oatmeal": FoodData(
            name: "Овсяная каша",
            calories: 150,
            protein: 5.5,
            fat: 3.0,
            carbs: 27,
            category: .grains,
            isProcessed: true,
            cookingMethod: .boiled,
            estimatedServingSize: "1 чашка (234г)"
        )
    ]
    
    // MARK: - Публичные методы
    
    /// Получить все доступные продукты
    func getAllFoods() -> [FoodData] {
        return Array(foodDatabase.values)
    }
    
    /// Найти продукт по названию
    func findFood(by name: String) -> FoodData? {
        let lowercasedName = name.lowercased()
        return foodDatabase.values.first { food in
            food.name.lowercased().contains(lowercasedName) ||
            lowercasedName.contains(food.name.lowercased())
        }
    }
    
    /// Получить случайные продукты для демонстрации
    func getRandomFoods(count: Int = 3) -> [FoodData] {
        let allFoods = Array(foodDatabase.values)
        let shuffled = allFoods.shuffled()
        return Array(shuffled.prefix(min(count, allFoods.count)))
    }
    
    /// Создать тестовый результат распознавания (для демонстрации)
    func createTestRecognitionResult() -> FoodRecognitionResult {
        let randomFood = getRandomFoods(count: 1).first ?? foodDatabase["apple"]!
        
        return FoodRecognitionResult(
            name: randomFood.name,
            calories: randomFood.calories,
            protein: randomFood.protein,
            fat: randomFood.fat,
            carbs: randomFood.carbs,
            processingTime: Double.random(in: 1.5...3.0),
            imageSize: CGSize(width: 512, height: 512)
        )
    }
}

// MARK: - Модели данных
struct FoodData {
    let name: String
    let calories: Double
    let protein: Double
    let fat: Double
    let carbs: Double
    let category: FoodCategory
    let isProcessed: Bool
    let cookingMethod: CookingMethod?
    let estimatedServingSize: String
    
    var estimatedWeight: Double {
        // Извлекаем примерный вес из serving size
        if estimatedServingSize.contains("г") {
            let components = estimatedServingSize.components(separatedBy: CharacterSet.decimalDigits.inverted)
            if let weightString = components.first(where: { !$0.isEmpty }),
               let weight = Double(weightString) {
                return weight
            }
        }
        return 100.0 // По умолчанию 100г
    }
}
