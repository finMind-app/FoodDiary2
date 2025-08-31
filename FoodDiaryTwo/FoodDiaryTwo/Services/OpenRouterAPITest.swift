//
//  OpenRouterAPITest.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import Foundation
import UIKit

// MARK: - Тестовый класс для проверки OpenRouter API
class OpenRouterAPITest {
    
    static func testAPI() async {
        print("🧪 Начинаем тест OpenRouter API...")
        
        let apiService = OpenRouterAPIService()
        
        // Создаем тестовое изображение (1x1 пиксель)
        let testImage = createTestImage()
        
        do {
            // Конвертируем в base64
            guard let imageData = testImage.jpegData(compressionQuality: 0.8),
                  let base64String = imageData.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                print("❌ Ошибка конвертации изображения в base64")
                return
            }
            
            print("📤 Отправляем запрос к API...")
            let result = try await apiService.analyzeFoodImage(base64String: base64String)
            
            print("✅ API тест успешен!")
            print("📊 Результат:")
            print("   - Название: \(result.name)")
            print("   - Калории: \(result.calories)")
            print("   - Белки: \(result.protein)g")
            print("   - Жиры: \(result.fat)g")
            print("   - Углеводы: \(result.carbs)g")
            print("   - Время обработки: \(result.processingTime) сек")
            
        } catch {
            print("❌ Ошибка API теста: \(error)")
            if let recognitionError = error as? FoodRecognitionError {
                print("   - Описание: \(recognitionError.localizedDescription)")
                print("   - Рекомендация: \(recognitionError.recoverySuggestion ?? "Нет рекомендаций")")
            }
        }
    }
    
    private static func createTestImage() -> UIImage {
        let size = CGSize(width: 512, height: 512)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        
        // Рисуем простой градиент
        let context = UIGraphicsGetCurrentContext()!
        let colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0, 1])!
        
        context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: size.height), options: [])
        
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
}
