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
    func recognizeFood(from image: UIImage) async throws -> FoodRecognitionResult
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
    func recognizeFood(from image: UIImage) async throws -> FoodRecognitionResult {
        await MainActor.run { 
            isProcessing = true 
            processingProgress = 0.0
        }
        
        // Анализируем качество изображения
        let qualityResult = analyzeImageQuality(image)
        guard qualityResult.isSuitable else {
            throw FoodRecognitionError.imageTooSmall
        }
        
        await MainActor.run { processingProgress = 0.1 }
        
        // Предобработка изображения
        guard let processedImage = preprocessImage(image) else {
            throw FoodRecognitionError.processingFailed
        }
        
        await MainActor.run { processingProgress = 0.2 }
        
        // Конвертируем изображение в base64
        guard let imageData = processedImage.jpegData(compressionQuality: 0.8),
              let base64String = imageData.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw FoodRecognitionError.imageConversionFailed
        }
        
        await MainActor.run { processingProgress = 0.3 }
        
        // Отправляем запрос к OpenRouter API
        let startTime = Date()
        let result = try await openRouterAPI.analyzeFoodImage(base64String: base64String)
        let processingTime = Date().timeIntervalSince(startTime)
        
        await MainActor.run { 
            processingProgress = 1.0
            isProcessing = false 
        }
        
        // Создаем результат с реальным временем обработки
        var finalResult = result
        finalResult.processingTime = processingTime
        finalResult.imageSize = image.size
        
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
    private let apiKey = "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"
    private let baseURL = "https://openrouter.ai/api/v1/chat/completions"
    private let model = "qwen/qwen2.5-vl-32b-instruct:free"
    
    func analyzeFoodImage(base64String: String) async throws -> FoodRecognitionResult {
        let url = URL(string: baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Создаем запрос согласно API
        let openRouterRequest = createOpenRouterRequest(base64String: base64String)
        
        do {
            request.httpBody = try JSONEncoder().encode(openRouterRequest)
        } catch {
            throw FoodRecognitionError.processingFailed
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Проверяем HTTP статус
        guard let httpResponse = response as? HTTPURLResponse else {
            throw FoodRecognitionError.networkError
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Неизвестная ошибка"
            throw FoodRecognitionError.apiError("HTTP \(httpResponse.statusCode): \(errorMessage)")
        }
        
        // Парсим ответ
        do {
            let openRouterResponse = try JSONDecoder().decode(OpenRouterResponse.self, from: data)
            
            guard let firstChoice = openRouterResponse.choices.first,
                  let content = firstChoice.message.content.data(using: .utf8) else {
                throw FoodRecognitionError.invalidResponse
            }
            
            // Парсим JSON из content
            let foodAnalysis = try JSONDecoder().decode(OpenRouterFoodAnalysis.self, from: content)
            
            return FoodRecognitionResult(from: foodAnalysis)
            
        } catch {
            print("Ошибка парсинга ответа: \(error)")
            throw FoodRecognitionError.invalidResponse
        }
    }
    
    private func createOpenRouterRequest(base64String: String) -> OpenRouterRequest {
        let imageURL = "data:image/jpeg;base64,\(base64String)"
        
        let content = [
            OpenRouterContent(
                type: "text",
                text: "Проанализируй это фото блюда. Выведи только: название блюда, примерное количество калорий и БЖУ (белки, жиры, углеводы).",
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
                    "название": OpenRouterProperty(type: "string", properties: nil),
                    "калории": OpenRouterProperty(type: "number", properties: nil),
                    "бжу": OpenRouterProperty(
                        type: "object",
                        properties: [
                            "белки": OpenRouterProperty(type: "number", properties: nil),
                            "жиры": OpenRouterProperty(type: "number", properties: nil),
                            "углеводы": OpenRouterProperty(type: "number", properties: nil)
                        ]
                    )
                ],
                required: ["название", "калории", "бжу"]
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


