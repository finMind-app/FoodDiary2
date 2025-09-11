//
//  FoodRecognitionService.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import Foundation
import SwiftUI
import Vision
import CoreML
import CoreGraphics

// MARK: - Протокол для сервиса распознавания
protocol FoodRecognitionServiceProtocol {
    func recognizeFood(from image: UIImage, language: Language) async throws -> FoodRecognitionResult
    func analyzeImageQuality(_ image: UIImage) -> ImageQualityResult
    func preprocessImage(_ image: UIImage) -> UIImage?
}

// MARK: - Сервис распознавания еды с OpenRouter API
class FoodRecognitionService: FoodRecognitionServiceProtocol, ObservableObject {
    
    // MARK: - Свойства
    @Published var isProcessing = false
    @Published var processingProgress: Double = 0.0
    
    private let imageAnalyzer = ImageQualityAnalyzer()
    private let openRouterAPI = OpenRouterAPIService()
    
    // MARK: - Основной метод распознавания
    func recognizeFood(from image: UIImage, language: Language) async throws -> FoodRecognitionResult {
        print("🔄 FoodRecognitionService: Начинаем обработку изображения")
        print("📐 Размер изображения: \(image.size)")
        
        await MainActor.run { 
            isProcessing = true 
            processingProgress = 0.0
        }
        
        // Анализируем качество изображения
        let qualityResult = analyzeImageQuality(image)
        print("📊 Качество изображения: \(qualityResult.isSuitable ? "подходит" : "не подходит")")
        guard qualityResult.isSuitable else {
            print("❌ Изображение не подходит для анализа")
            throw FoodRecognitionError.imageTooSmall
        }
        
        await MainActor.run { processingProgress = 0.1 }
        
        // Предобработка изображения
        guard let processedImage = preprocessImage(image) else {
            print("❌ Ошибка предобработки изображения")
            throw FoodRecognitionError.processingFailed
        }
        
        print("✅ Изображение предобработано")
        await MainActor.run { processingProgress = 0.2 }
        
        // Конвертируем изображение в base64
        guard let imageData = processedImage.jpegData(compressionQuality: 0.8),
              let base64String = imageData.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("❌ Ошибка конвертации изображения в base64")
            throw FoodRecognitionError.imageConversionFailed
        }
        
        print("✅ Изображение конвертировано в base64, размер данных: \(imageData.count) байт")
        await MainActor.run { processingProgress = 0.3 }
        
        // Отправляем запрос к OpenRouter API
        print("🌐 Отправляем запрос к OpenRouter API...")
        let startTime = Date()
        let result = try await openRouterAPI.analyzeFoodImage(base64String: base64String, language: language)
        let processingTime = Date().timeIntervalSince(startTime)
        
        print("✅ Ответ получен от API за \(processingTime) секунд")
        await MainActor.run { 
            processingProgress = 1.0
            isProcessing = false 
        }
        
        // Создаем результат с реальным временем обработки
        var finalResult = result
        finalResult.processingTime = processingTime
        finalResult.imageSize = image.size
        
        print("🎯 Финальный результат: \(finalResult.name), \(finalResult.calories) калорий")
        return finalResult
    }
    
    // MARK: - Анализ качества изображения
    func analyzeImageQuality(_ image: UIImage) -> ImageQualityResult {
        return imageAnalyzer.analyze(image)
    }
    
    // MARK: - Предобработка изображения
    func preprocessImage(_ image: UIImage) -> UIImage? {
        // Изменение размера изображения для анализа
        let targetSize = CGSize(width: 512, height: 512)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}

// MARK: - Сервис для работы с OpenRouter API
class OpenRouterAPIService {
    private let remoteConfigService = RemoteConfigService()
    private let baseURL = "https://openrouter.ai/api/v1/chat/completions"
    private let model = "qwen/qwen2.5-vl-32b-instruct:free"
    
    // MARK: - Получение API ключа
    private func getAPIKey() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            remoteConfigService.getAPIKey { apiKey in
                if let apiKey = apiKey {
                    continuation.resume(returning: apiKey)
                } else {
                    continuation.resume(throwing: FoodRecognitionError.apiError("Не удалось получить API ключ"))
                }
            }
        }
    }
    
    func analyzeFoodImage(base64String: String, language: Language) async throws -> FoodRecognitionResult {
        print("🌐 OpenRouterAPIService: Начинаем анализ изображения")
        print("📡 URL: \(baseURL)")
        print("🤖 Модель: \(model)")
        
        // Получаем API ключ асинхронно
        let apiKey = try await getAPIKey()
        
        let url = URL(string: baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Добавляем дополнительные заголовки для OpenRouter
        request.setValue("FoodDiaryTwo/1.0", forHTTPHeaderField: "HTTP-Referer")
        request.setValue("https://fooddiary.app", forHTTPHeaderField: "X-Title")
        
        // Создаем запрос согласно API
        let openRouterRequest = createOpenRouterRequest(base64String: base64String, language: language)
        
        do {
            request.httpBody = try JSONEncoder().encode(openRouterRequest)
            print("📦 Запрос подготовлен, размер: \(request.httpBody?.count ?? 0) байт")
        } catch {
            print("❌ Ошибка кодирования запроса: \(error)")
            throw FoodRecognitionError.processingFailed
        }
        
        print("🚀 Отправляем HTTP запрос...")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Проверяем HTTP статус
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Неверный тип ответа")
            throw FoodRecognitionError.networkError
        }
        
        print("📡 HTTP статус: \(httpResponse.statusCode)")
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Неизвестная ошибка"
            print("❌ HTTP ошибка: \(httpResponse.statusCode) - \(errorMessage)")
            throw FoodRecognitionError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }
        
        print("✅ HTTP ответ успешен, размер данных: \(data.count) байт")
        
        // Парсим ответ
        do {
            let openRouterResponse = try JSONDecoder().decode(OpenRouterResponse.self, from: data)
            
            guard let firstChoice = openRouterResponse.choices.first,
                  let content = firstChoice.message.content.data(using: .utf8) else {
                print("❌ Неверная структура ответа API")
                throw FoodRecognitionError.invalidResponse
            }
            
            print("📄 Контент ответа: \(firstChoice.message.content)")
            
            // Парсим JSON из content
            let foodAnalysis = try JSONDecoder().decode(OpenRouterFoodAnalysis.self, from: content)
            print("✅ JSON успешно распарсен: \(foodAnalysis.name)")
            
            return FoodRecognitionResult(from: foodAnalysis)
            
        } catch {
            print("❌ Ошибка парсинга ответа: \(error)")
            throw FoodRecognitionError.invalidResponse
        }
    }
    
    private func createOpenRouterRequest(base64String: String, language: Language) -> OpenRouterRequest {
        let imageURL = "data:image/jpeg;base64,\(base64String)"
        
        // Instruct model: return JSON with English keys, but dish name/value text in selected language
        let locale = language.rawValue
        let content = [
            OpenRouterContent(
                type: "text",
                text: "Analyze this food photo. Return ONLY JSON with English keys {name, calories, macros:{protein, fat, carbs}}. Write the dish name and any textual values in the user's language (lang=\(locale)) without extra commentary.",
                image_url: nil
            ),
            OpenRouterContent(
                type: "image_url",
                text: nil,
                image_url: OpenRouterImageURL(url: imageURL)
            )
        ]
        
        let message = OpenRouterMessage(role: "user", content: content)
        
        let jsonSchema = OpenRouterJSONSchema(
            name: "meal_analysis_mobile",
            schema: OpenRouterSchema(
                type: "object",
                properties: [
                    "name": OpenRouterProperty(type: "string", properties: nil, items: nil),
                    "calories": OpenRouterProperty(type: "number", properties: nil, items: nil),
                    "macros": OpenRouterProperty(
                        type: "object",
                        properties: [
                            "protein": OpenRouterProperty(type: "number", properties: nil, items: nil),
                            "fat": OpenRouterProperty(type: "number", properties: nil, items: nil),
                            "carbs": OpenRouterProperty(type: "number", properties: nil, items: nil)
                        ],
                        items: nil
                    )
                ],
                required: ["name", "calories", "macros"]
            )
        )
        
        let responseFormat = OpenRouterResponseFormat(
            type: "json_schema",
            json_schema: jsonSchema
        )
        
        return OpenRouterRequest(
            model: model,
            messages: [message],
            max_tokens: 150,
            temperature: 0,
            response_format: responseFormat
        )
    }

    // MARK: - Gemini Recipe Generation
    func generateRecipe(ingredients: [String], language: Language) async throws -> RecipeSuggestion {
        let apiKey = try await getAPIKey()
        let url = URL(string: baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("FoodDiaryTwo/1.0", forHTTPHeaderField: "HTTP-Referer")
        request.setValue("https://fooddiary.app", forHTTPHeaderField: "X-Title")

        let promptLanguageCode = language.rawValue
        let prompt = "Ты шеф-повар. Составь полностью готовый рецепт на выбранном в приложении языке (передать его сюда) с названием блюда и пошаговой инструкцией. Ингредиенты: \(ingredients.joined(separator: ", ")). Язык: \(promptLanguageCode). Верни строго JSON по схеме."

        let content = [
            OpenRouterContent(type: "text", text: prompt, image_url: nil)
        ]
        let message = OpenRouterMessage(role: "user", content: content)

        // JSON schema for structured recipe
        let jsonSchema = OpenRouterJSONSchema(
            name: "recipe_suggestion",
            schema: OpenRouterSchema(
                type: "object",
                properties: [
                    "title": OpenRouterProperty(type: "string", properties: nil, items: nil),
                    "ingredients": OpenRouterProperty(type: "array", properties: nil, items: OpenRouterProperty.ArrayItems(type: "string", properties: nil)),
                    "steps": OpenRouterProperty(type: "array", properties: nil, items: OpenRouterProperty.ArrayItems(type: "string", properties: nil)),
                    "nutritionTip": OpenRouterProperty(type: "string", properties: nil, items: nil)
                ],
                required: ["title", "ingredients", "steps", "nutritionTip"]
            )
        )
        let responseFormat = OpenRouterResponseFormat(type: "json_schema", json_schema: jsonSchema)

        let requestBody = OpenRouterRequest(
            model: "google/gemini-2.0-flash-exp:free",
            messages: [message],
            max_tokens: 500,
            temperature: 0.7,
            response_format: responseFormat
        )
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw FoodRecognitionError.apiError(errorMessage)
        }
        let openRouterResponse = try JSONDecoder().decode(OpenRouterResponse.self, from: data)
        guard let firstChoice = openRouterResponse.choices.first,
              let contentString = firstChoice.message.content.data(using: .utf8) else {
            throw FoodRecognitionError.invalidResponse
        }
        let suggestion = try JSONDecoder().decode(RecipeSuggestion.self, from: contentString)
        return suggestion
    }
}

// MARK: - Анализатор качества изображения
class ImageQualityAnalyzer {
    
    func analyze(_ image: UIImage) -> ImageQualityResult {
        let size = image.size
        let megapixels = (size.width * size.height) / 1_000_000
        
        let isSuitable = megapixels >= 0.25 && megapixels <= 4.0 // 0.25MP - 4MP
        let quality = calculateQualityScore(size: size, megapixels: megapixels)
        
        return ImageQualityResult(
            isSuitable: isSuitable,
            megapixels: megapixels,
            quality: quality,
            recommendations: generateRecommendations(megapixels: megapixels)
        )
    }
    
    private func calculateQualityScore(size: CGSize, megapixels: Double) -> Double {
        var score = 0.0
        
        // Размер
        if megapixels >= 1.0 { score += 0.4 }
        else if megapixels >= 0.5 { score += 0.3 }
        else if megapixels >= 0.25 { score += 0.2 }
        
        // Соотношение сторон
        let aspectRatio = size.width / size.height
        if aspectRatio >= 0.8 && aspectRatio <= 1.2 { score += 0.3 } // Квадрат
        else if aspectRatio >= 0.6 && aspectRatio <= 1.7 { score += 0.2 } // Портрет/ландшафт
        
        // Разрешение
        if size.width >= 512 && size.height >= 512 { score += 0.3 }
        else if size.width >= 256 && size.height >= 256 { score += 0.2 }
        
        return min(score, 1.0)
    }
    
    private func generateRecommendations(megapixels: Double) -> [String] {
        var recommendations: [String] = []
        
        if megapixels < 0.5 {
            recommendations.append("Используйте изображение с разрешением не менее 0.5MP")
        }
        
        if megapixels > 3.0 {
            recommendations.append("Изображение слишком большое, используйте меньшее разрешение")
        }
        
        if recommendations.isEmpty {
            recommendations.append("Изображение подходит для анализа")
        }
        
        return recommendations
    }
}

// MARK: - Результат анализа качества изображения
struct ImageQualityResult {
    let isSuitable: Bool
    let megapixels: Double
    let quality: Double
    let recommendations: [String]
}


