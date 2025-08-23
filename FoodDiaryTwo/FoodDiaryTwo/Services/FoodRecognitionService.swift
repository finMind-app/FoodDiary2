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
    
    private let mockDataGenerator = MockFoodDataGenerator()
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
        
        // Анализ изображения (моковая логика)
        let analysisResult = try await performImageAnalysis(processedImage)
        
        await MainActor.run { processingProgress = 0.7 }
        
        // Генерация результатов
        let result = try await generateRecognitionResult(
            from: analysisResult,
            imageSize: processedImage.size
        )
        
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
        // Имитируем предобработку: изменение размера, нормализация и т.д.
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
    
    private func performImageAnalysis(_ image: UIImage) async throws -> MockImageAnalysisResult {
        // Имитируем задержку анализа
        try await Task.sleep(nanoseconds: UInt64(1.0 * 1_000_000_000)) // 1 сек
        
        // Генерируем моковые результаты анализа
        return mockDataGenerator.generateImageAnalysisResult(for: image)
    }
    
    private func generateRecognitionResult(
        from analysis: MockImageAnalysisResult,
        imageSize: CGSize
    ) async throws -> FoodRecognitionResult {
        
        // Имитируем задержку генерации результатов
        try await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000)) // 0.5 сек
        
        let recognizedFoods = analysis.detectedFoods.map { food in
            RecognizedFood(
                name: food.name,
                confidence: food.confidence,
                estimatedWeight: food.estimatedWeight,
                calories: food.calories,
                protein: food.protein,
                fat: food.fat,
                carbs: food.carbs,
                category: food.category,
                boundingBox: food.boundingBox.map { BoundingBox(from: $0) },
                isProcessed: food.isProcessed,
                cookingMethod: food.cookingMethod,
                estimatedServingSize: food.estimatedServingSize
            )
        }
        
        let totalCalories = recognizedFoods.reduce(0) { $0 + $1.calories }
        let totalProtein = recognizedFoods.reduce(0) { $0 + $1.protein }
        let totalFat = recognizedFoods.reduce(0) { $0 + $1.fat }
        let totalCarbs = recognizedFoods.reduce(0) { $0 + $1.carbs }
        
        return FoodRecognitionResult(
            confidence: analysis.overallConfidence,
            recognizedFoods: recognizedFoods,
            totalCalories: totalCalories,
            totalProtein: totalProtein,
            totalFat: totalFat,
            totalCarbs: totalCarbs,
            processingTime: analysis.processingTime,
            imageSize: imageSize
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

// MARK: - Генератор моковых данных
class MockFoodDataGenerator {
    
    // База данных моковых продуктов
    private let foodDatabase: [String: MockFoodData] = [
        "apple": MockFoodData(
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
        "banana": MockFoodData(
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
        "chicken_breast": MockFoodData(
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
        "rice": MockFoodData(
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
        "salad": MockFoodData(
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
        "pizza": MockFoodData(
            name: "Пицца",
            calories: 266,
            protein: 11,
            fat: 10,
            carbs: 33,
            category: .mixed,
            isProcessed: true,
            cookingMethod: .baked,
            estimatedServingSize: "1 ломтик (100г)"
        ),
        "yogurt": MockFoodData(
            name: "Греческий йогурт",
            calories: 59,
            protein: 10,
            fat: 0.4,
            carbs: 3.6,
            category: .dairy,
            isProcessed: true,
            cookingMethod: .raw,
            estimatedServingSize: "1 стакан (170г)"
        )
    ]
    
    func generateImageAnalysisResult(for image: UIImage) -> MockImageAnalysisResult {
        // Имитируем анализ изображения и определение продуктов
        let detectedFoods = generateDetectedFoods()
        let overallConfidence = calculateOverallConfidence(detectedFoods)
        
        return MockImageAnalysisResult(
            detectedFoods: detectedFoods,
            overallConfidence: overallConfidence,
            processingTime: Double.random(in: 1.5...3.0)
        )
    }
    
    private func generateDetectedFoods() -> [MockDetectedFood] {
        // Случайно выбираем 1-3 продукта
        let numberOfFoods = Int.random(in: 1...3)
        let availableFoods = Array(foodDatabase.values)
        let selectedFoods = availableFoods.shuffled().prefix(numberOfFoods)
        
        return selectedFoods.map { food in
            let confidence = Double.random(in: 0.6...0.95)
            let weightVariation = Double.random(in: 0.8...1.2)
            
            return MockDetectedFood(
                name: food.name,
                confidence: confidence,
                estimatedWeight: food.estimatedWeight * weightVariation,
                calories: food.calories * weightVariation,
                protein: food.protein * weightVariation,
                fat: food.fat * weightVariation,
                carbs: food.carbs * weightVariation,
                category: food.category,
                boundingBox: generateRandomBoundingBox(),
                isProcessed: food.isProcessed,
                cookingMethod: food.cookingMethod,
                estimatedServingSize: food.estimatedServingSize
            )
        }
    }
    
    private func calculateOverallConfidence(_ foods: [MockDetectedFood]) -> Double {
        guard !foods.isEmpty else { return 0.0 }
        let totalConfidence = foods.reduce(0.0) { $0 + $1.confidence }
        return totalConfidence / Double(foods.count)
    }
    
    private func generateRandomBoundingBox() -> CGRect {
        let x = Double.random(in: 0.1...0.7)
        let y = Double.random(in: 0.1...0.7)
        let width = Double.random(in: 0.2...0.4)
        let height = Double.random(in: 0.2...0.4)
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

// MARK: - Моковые модели данных
struct MockImageAnalysisResult {
    let detectedFoods: [MockDetectedFood]
    let overallConfidence: Double
    let processingTime: TimeInterval
}

struct MockDetectedFood {
    let name: String
    let confidence: Double
    let estimatedWeight: Double
    let calories: Double
    let protein: Double
    let fat: Double
    let carbs: Double
    let category: FoodCategory
    let boundingBox: CGRect
    let isProcessed: Bool
    let cookingMethod: CookingMethod?
    let estimatedServingSize: String
}

struct MockFoodData {
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
