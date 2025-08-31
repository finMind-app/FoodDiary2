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
    let name: String
    let calories: Double
    let protein: Double
    let fat: Double
    let carbs: Double
    var processingTime: TimeInterval
    var imageSize: CGSize
    
    // Инициализатор из ответа OpenRouter API
    init(from openRouterResponse: OpenRouterFoodAnalysis) {
        self.name = openRouterResponse.название
        self.calories = openRouterResponse.калории
        self.protein = openRouterResponse.бжу.белки
        self.fat = openRouterResponse.бжу.жиры
        self.carbs = openRouterResponse.бжу.углеводы
        self.processingTime = 2.0 // Примерное время обработки
        self.imageSize = CGSize(width: 512, height: 512) // Стандартный размер
    }
    
    // Стандартный инициализатор
    init(name: String, calories: Double, protein: Double, fat: Double, carbs: Double, processingTime: TimeInterval, imageSize: CGSize) {
        self.name = name
        self.calories = calories
        self.protein = protein
        self.fat = fat
        self.carbs = carbs
        self.processingTime = processingTime
        self.imageSize = imageSize
    }
}

// MARK: - Структуры для парсинга ответа OpenRouter API
struct OpenRouterFoodAnalysis: Codable {
    let название: String
    let калории: Double
    let бжу: БЖУ
}

struct БЖУ: Codable {
    let белки: Double
    let жиры: Double
    let углеводы: Double
}

// MARK: - Структуры для запроса к OpenRouter API
struct OpenRouterRequest: Codable {
    let model: String
    let messages: [OpenRouterMessage]
    let max_tokens: Int
    let temperature: Double
    let response_format: OpenRouterResponseFormat
}

struct OpenRouterMessage: Codable {
    let role: String
    let content: [OpenRouterContent]
}

struct OpenRouterContent: Codable {
    let type: String
    let text: String?
    let image_url: OpenRouterImageURL?
}

struct OpenRouterImageURL: Codable {
    let url: String
}

struct OpenRouterResponseFormat: Codable {
    let type: String
    let json_schema: OpenRouterJSONSchema
}

struct OpenRouterJSONSchema: Codable {
    let name: String
    let schema: OpenRouterSchema
}

struct OpenRouterSchema: Codable {
    let type: String
    let properties: [String: OpenRouterProperty]
    let required: [String]
}

struct OpenRouterProperty: Codable {
    let type: String
    let properties: [String: OpenRouterProperty]?
}

// MARK: - Ответ от OpenRouter API
struct OpenRouterResponse: Codable {
    let id: String
    let choices: [OpenRouterChoice]
    let usage: OpenRouterUsage
}

struct OpenRouterChoice: Codable {
    let message: OpenRouterResponseMessage
    let finish_reason: String
}

struct OpenRouterResponseMessage: Codable {
    let content: String
}

struct OpenRouterUsage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
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
    case apiError(String)
    case invalidResponse
    case imageConversionFailed
    
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
        case .apiError(let message):
            return "Ошибка API: \(message)"
        case .invalidResponse:
            return "Неверный ответ от сервера"
        case .imageConversionFailed:
            return "Ошибка конвертации изображения"
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
        case .apiError:
            return "Попробуйте еще раз через несколько секунд"
        case .invalidResponse:
            return "Попробуйте другое изображение"
        case .imageConversionFailed:
            return "Попробуйте другое изображение"
        }
    }
}
