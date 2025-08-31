//
//  FoodRecognitionViewModel.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import Foundation
import SwiftUI

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
        print("Image selection handled by PhotosPicker")
    }
    
    /// Сделать фото
    func takePhoto() {
        // Этот метод теперь вызывается из AddMealView через ImagePicker
        print("Camera capture handled by ImagePicker")
    }
    
    /// Распознать еду на изображении
    func recognizeFood() async {
        print("🔍 Начинаем распознавание еды...")
        print("📸 selectedImage: \(selectedImage != nil ? "установлено" : "не установлено")")
        
        guard let image = selectedImage else {
            print("❌ Изображение не выбрано")
            showError(message: "Изображение не выбрано")
            return
        }
        
        print("✅ Изображение найдено, размер: \(image.size)")
        isProcessing = true
        processingProgress = 0.0
        errorMessage = nil
        
        do {
            print("🚀 Отправляем изображение на сервер...")
            // Используем новый сервис с OpenRouter API
            let result = try await recognitionService.recognizeFood(from: image)
            
            print("✅ Распознавание завершено успешно")
            recognitionResult = result
            isProcessing = false
            processingProgress = 1.0
            
        } catch let error as FoodRecognitionError {
            print("❌ Ошибка распознавания: \(error.localizedDescription)")
            isProcessing = false
            processingProgress = 0.0
            showError(message: error.localizedDescription)
            
        } catch {
            print("❌ Неизвестная ошибка: \(error.localizedDescription)")
            isProcessing = false
            processingProgress = 0.0
            showError(message: "Неизвестная ошибка: \(error.localizedDescription)")
        }
    }
    
    /// Сбросить результаты
    func resetResults() {
        recognitionResult = nil
        selectedImage = nil
        errorMessage = nil
        showError = false
        processingProgress = 0.0
    }
    
    /// Установить изображение
    func setImage(_ image: UIImage) {
        selectedImage = image
        resetResults() // Сбрасываем предыдущие результаты
    }
    
    // MARK: - Приватные методы
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}
