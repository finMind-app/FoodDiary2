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

// MARK: - Сервис распознавания еды
class FoodRecognitionService: FoodRecognitionServiceProtocol, ObservableObject {
    
    // MARK: - Свойства
    @Published var isProcessing = false
    @Published var processingProgress: Double = 0.0
    
    private let imageAnalyzer = ImageQualityAnalyzer()
    
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
        
        // Имитируем прогресс обработки
        await simulateProcessingProgress()
        
        // Предобработка изображения
        guard let processedImage = preprocessImage(image) else {
            throw FoodRecognitionError.processingFailed
        }
        
        await MainActor.run { processingProgress = 0.3 }
        
        // Используем центральный сервис для распознавания
        let result = await FoodDataService.shared.recognizeFoodFromImage(processedImage)
        
        await MainActor.run { 
            processingProgress = 1.0
            isProcessing = false 
        }
        
        return result
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
    
    // MARK: - Приватные методы
    
    private func simulateProcessingProgress() async {
        let steps = [0.1, 0.2, 0.25]
        for step in steps {
            try? await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000)) // 0.5 сек
            await MainActor.run { processingProgress = step }
        }
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


