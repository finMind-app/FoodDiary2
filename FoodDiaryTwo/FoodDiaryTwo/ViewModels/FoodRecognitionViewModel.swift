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
        guard let image = selectedImage else {
            showError(message: "Изображение не выбрано")
            return
        }
        
        isProcessing = true
        processingProgress = 0.0
        errorMessage = nil
        
        do {
            // Используем новый сервис с OpenRouter API
            let result = try await recognitionService.recognizeFood(from: image)
            
            recognitionResult = result
            isProcessing = false
            processingProgress = 1.0
            
        } catch let error as FoodRecognitionError {
            isProcessing = false
            processingProgress = 0.0
            showError(message: error.localizedDescription)
            
        } catch {
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
