//
//  FoodRecognitionViewModel.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import Foundation
import SwiftUI
import PhotosUI

// MARK: - ViewModel для распознавания еды
@MainActor
class FoodRecognitionViewModel: ObservableObject {
    
    // MARK: - Published свойства
    @Published var selectedImage: UIImage?
    @Published var recognitionResult: FoodRecognitionResult?
    @Published var isProcessing = false
    @Published var processingProgress: Double = 0.0
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var showResults = false
    @Published var imageQualityResult: ImageQualityResult?
    
    // MARK: - Сервисы
    private let recognitionService: FoodRecognitionServiceProtocol
    
    // MARK: - Инициализация
    init(recognitionService: FoodRecognitionServiceProtocol = FoodRecognitionService()) {
        self.recognitionService = recognitionService
    }
    
    // MARK: - Публичные методы
    
    /// Выбор изображения из галереи
    func selectImage() {
        // Этот метод теперь вызывается из AddMealView через PhotosPicker
        // Здесь можно добавить дополнительную логику при необходимости
        print("Image selection handled by PhotosPicker")
    }
    
    /// Сделать фото
    func takePhoto() {
        // Этот метод теперь вызывается из AddMealView через ImagePicker
        // Здесь можно добавить дополнительную логику при необходимости
        print("Camera capture handled by ImagePicker")
    }
    
    /// Распознать еду на изображении
    func recognizeFood() async {
        guard let image = selectedImage else {
            showError(message: "Изображение не выбрано")
            return
        }
        
        // Анализируем качество изображения
        imageQualityResult = recognitionService.analyzeImageQuality(image)
        
        guard imageQualityResult?.isSuitable == true else {
            showError(message: "Изображение не подходит для анализа")
            return
        }
        
        do {
            isProcessing = true
            processingProgress = 0.0
            
            // Подписываемся на прогресс обработки
            if let service = recognitionService as? FoodRecognitionService {
                await observeProgress(from: service)
            }
            
            // Выполняем распознавание
            let result = try await recognitionService.recognizeFood(from: image)
            
            recognitionResult = result
            showResults = true
            errorMessage = nil
            
        } catch {
            showError(message: error.localizedDescription)
        }
        
        isProcessing = false
        processingProgress = 0.0
    }
    
    /// Сбросить результаты
    func resetResults() {
        recognitionResult = nil
        selectedImage = nil
        imageQualityResult = nil
        showResults = false
        errorMessage = nil
        processingProgress = 0.0
    }
    
    /// Применить результаты к приему пищи
    func applyResultsToMeal() -> FoodEntry? {
        guard let result = recognitionResult else { return nil }
        
        // Создаем FoodProduct объекты из результатов распознавания
        let products = result.recognizedFoods.map { food in
            FoodProduct(
                name: food.name,
                servingSize: food.estimatedWeight,
                caloriesPerServing: Int(food.calories),
                protein: food.protein,
                carbs: food.carbs,
                fat: food.fat,
                category: food.category
            )
        }
        
        // Создаем запись о приеме пищи на основе результатов распознавания
        let meal = FoodEntry(
            name: generateMealName(from: result),
            date: Date(),
            mealType: .lunch, // По умолчанию обед
            products: products,
            notes: generateMealNotes(from: result)
        )
        
        return meal
    }
    
    /// Получить рекомендации по улучшению качества изображения
    func getImageQualityRecommendations() -> [String] {
        return imageQualityResult?.recommendations ?? []
    }
    
    // MARK: - Приватные методы
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
    
    private func observeProgress(from service: FoodRecognitionService) async {
        // Наблюдаем за прогрессом обработки
        for await progress in service.$processingProgress.values {
            processingProgress = progress
        }
    }
    
    private func loadMockImage() {
        // Создаем моковое изображение для демонстрации
        let size = CGSize(width: 512, height: 512)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        
        // Рисуем простой градиент
        let context = UIGraphicsGetCurrentContext()!
        let colors = [UIColor.systemBlue.cgColor, UIColor.systemGreen.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0, 1])!
        
        context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: size.height), options: [])
        
        // Добавляем текст "FOOD"
        let text = "FOOD"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 48, weight: .bold),
            .foregroundColor: UIColor.white
        ]
        
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: (size.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        text.draw(in: textRect, withAttributes: attributes)
        
        selectedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    private func generateMealName(from result: FoodRecognitionResult) -> String {
        let foodNames = result.recognizedFoods.map { $0.name }
        
        if foodNames.count == 1 {
            return foodNames[0]
        } else if foodNames.count <= 3 {
            return foodNames.joined(separator: " + ")
        } else {
            return "Смешанное блюдо"
        }
    }
    
    private func generateMealNotes(from result: FoodRecognitionResult) -> String {
        var notes: [String] = []
        
        // Добавляем информацию об уверенности
        notes.append("Уверенность: \(result.confidenceText)")
        
        // Добавляем информацию о продуктах
        for food in result.recognizedFoods {
            let confidence = Int(food.confidence * 100)
            notes.append("\(food.name): \(confidence)% уверенность")
        }
        
        // Добавляем информацию о способе приготовления
        let cookingMethods = result.recognizedFoods.compactMap { $0.cookingMethod }
        if !cookingMethods.isEmpty {
            let uniqueMethods = Array(Set(cookingMethods)).map { $0.rawValue }
            notes.append("Способы приготовления: \(uniqueMethods.joined(separator: ", "))")
        }
        
        return notes.joined(separator: "\n")
    }
}

// MARK: - Расширения для удобства

extension FoodRecognitionViewModel {
    
    /// Проверить, можно ли начать распознавание
    var canStartRecognition: Bool {
        selectedImage != nil && !isProcessing
    }
    
    /// Получить текст кнопки распознавания
    var recognitionButtonText: String {
        if isProcessing {
            return "Анализируем..."
        } else if selectedImage != nil {
            return "Распознать еду"
        } else {
            return "Выберите фото"
        }
    }
    
    /// Получить цвет кнопки распознавания
    var recognitionButtonColor: Color {
        if isProcessing {
            return .gray
        } else if selectedImage != nil {
            return .blue
        } else {
            return .gray
        }
    }
    
    /// Получить текст статуса
    var statusText: String {
        if isProcessing {
            return "Анализируем изображение..."
        } else if let result = recognitionResult {
            return "Найдено \(result.recognizedFoods.count) продукта(ов)"
        } else if selectedImage != nil {
            return "Готово к анализу"
        } else {
            return "Выберите изображение еды"
        }
    }
    
    /// Получить цвет статуса
    var statusColor: Color {
        if isProcessing {
            return .blue
        } else if recognitionResult != nil {
            return .green
        } else if selectedImage != nil {
            return .orange
        } else {
            return .gray
        }
    }
}
