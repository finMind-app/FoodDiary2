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
    // private let recognitionService: FoodRecognitionServiceProtocol
    
    // MARK: - Инициализация
    init() {
        // self.recognitionService = recognitionService
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
        
        // Используем центральный сервис для распознавания
        let result = await FoodDataService.shared.recognizeFoodFromImage(image)
        
        recognitionResult = result
        errorMessage = nil
        
        isProcessing = false
        processingProgress = 0.0
    }
    
    /// Сбросить результаты
    func resetResults() {
        recognitionResult = nil
        selectedImage = nil
        errorMessage = nil
        processingProgress = 0.0
    }
    
    // MARK: - Приватные методы
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}
