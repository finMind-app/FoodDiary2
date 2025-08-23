//
//  FoodRecognitionResult.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import Foundation
import SwiftUI

// MARK: - Результат распознавания еды
struct FoodRecognitionResult: Identifiable, Codable {
    var id = UUID()
    let confidence: Double // Уверенность в распознавании (0.0 - 1.0)
    let recognizedFoods: [RecognizedFood]
    let totalCalories: Double
    let totalProtein: Double
    let totalFat: Double
    let totalCarbs: Double
    let processingTime: TimeInterval
    let imageSize: CGSize
    
    // Вычисляемые свойства
    var isHighConfidence: Bool { confidence >= 0.7 }
    var isMediumConfidence: Bool { confidence >= 0.4 && confidence < 0.7 }
    var isLowConfidence: Bool { confidence < 0.4 }
    
    var confidenceText: String {
        switch confidence {
        case 0.8...1.0: return "Высокая уверенность"
        case 0.6..<0.8: return "Хорошая уверенность"
        case 0.4..<0.6: return "Средняя уверенность"
        default: return "Низкая уверенность"
        }
    }
}

// MARK: - Распознанная еда
struct RecognizedFood: Identifiable, Codable {
    var id = UUID()
    let name: String
    let confidence: Double
    let estimatedWeight: Double // в граммах
    let calories: Double
    let protein: Double
    let fat: Double
    let carbs: Double
    let category: FoodCategory
    let boundingBox: BoundingBox? // Область на изображении
    
    // Дополнительная информация
    let isProcessed: Bool // Обработанная еда или сырая
    let cookingMethod: CookingMethod?
    let estimatedServingSize: String
    
    var confidenceColor: Color {
        switch confidence {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .orange
        default: return .red
        }
    }
}

// MARK: - Область на изображении (Codable версия CGRect)
struct BoundingBox: Codable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    
    init(x: Double, y: Double, width: Double, height: Double) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
    
    init(from rect: CGRect) {
        self.x = rect.origin.x
        self.y = rect.origin.y
        self.width = rect.size.width
        self.height = rect.size.height
    }
    
    var cgRect: CGRect {
        CGRect(x: x, y: y, width: width, height: height)
    }
}

// MARK: - Категории еды
// Используем FoodCategory из FoodProduct.swift

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

// MARK: - Ошибки распознавания
enum FoodRecognitionError: Error, LocalizedError {
    case imageTooSmall
    case imageTooLarge
    case unsupportedFormat
    case processingFailed
    case networkError
    case noFoodDetected
    case lowConfidence
    
    var errorDescription: String? {
        switch self {
        case .imageTooSmall:
            return "Изображение слишком маленькое для анализа"
        case .imageTooLarge:
            return "Изображение слишком большое для обработки"
        case .unsupportedFormat:
            return "Неподдерживаемый формат изображения"
        case .processingFailed:
            return "Ошибка обработки изображения"
        case .networkError:
            return "Ошибка сети при анализе"
        case .noFoodDetected:
            return "Еда не обнаружена на изображении"
        case .lowConfidence:
            return "Низкая уверенность в распознавании"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .imageTooSmall:
            return "Используйте изображение с разрешением не менее 512x512 пикселей"
        case .imageTooLarge:
            return "Используйте изображение с разрешением не более 2048x2048 пикселей"
        case .unsupportedFormat:
            return "Поддерживаются форматы: JPEG, PNG, HEIC"
        case .processingFailed:
            return "Попробуйте другое изображение или перезапустите приложение"
        case .networkError:
            return "Проверьте подключение к интернету"
        case .noFoodDetected:
            return "Убедитесь, что на изображении есть еда"
        case .lowConfidence:
            return "Попробуйте сделать более четкое фото еды"
        }
    }
}
