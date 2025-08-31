//
//  FoodRecognitionTest.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import Foundation
import UIKit

// MARK: - Тестовый класс для проверки системы распознавания
class FoodRecognitionTest {
    
    static func testSimplifiedModel() {
        print("🧪 Тестируем упрощенную модель...")
        
        // Создаем тестовый результат
        let testResult = FoodRecognitionResult(
            name: "Тестовое блюдо",
            calories: 250,
            protein: 15.5,
            fat: 8.2,
            carbs: 30.1,
            processingTime: 1.5,
            imageSize: CGSize(width: 512, height: 512)
        )
        
        print("✅ Тестовая модель создана:")
        print("   - Название: \(testResult.name)")
        print("   - Калории: \(testResult.calories)")
        print("   - Белки: \(testResult.protein)g")
        print("   - Жиры: \(testResult.fat)g")
        print("   - Углеводы: \(testResult.carbs)g")
        print("   - Время обработки: \(testResult.processingTime) сек")
        
        // Тестируем парсинг JSON
        testJSONParsing()
    }
    
    private static func testJSONParsing() {
        print("\n📋 Тестируем парсинг JSON...")
        
        let jsonString = """
        {
            "название": "Куриная грудка с рисом",
            "калории": 295,
            "бжу": {
                "белки": 33.7,
                "жиры": 3.9,
                "углеводы": 28
            }
        }
        """
        
        do {
            let jsonData = jsonString.data(using: .utf8)!
            let foodAnalysis = try JSONDecoder().decode(OpenRouterFoodAnalysis.self, from: jsonData)
            
            print("✅ JSON успешно распарсен:")
            print("   - Название: \(foodAnalysis.название)")
            print("   - Калории: \(foodAnalysis.калории)")
            print("   - Белки: \(foodAnalysis.бжу.белки)")
            print("   - Жиры: \(foodAnalysis.бжу.жиры)")
            print("   - Углеводы: \(foodAnalysis.бжу.углеводы)")
            
            // Создаем результат из API ответа
            let result = FoodRecognitionResult(from: foodAnalysis)
            print("✅ Результат создан из API ответа:")
            print("   - Название: \(result.name)")
            print("   - Калории: \(result.calories)")
            
        } catch {
            print("❌ Ошибка парсинга JSON: \(error)")
        }
    }
    
    static func runAllTests() {
        print("🚀 Запускаем все тесты системы распознавания...")
        print("=" * 50)
        
        testSimplifiedModel()
        
        print("\n" + "=" * 50)
        print("✅ Все тесты завершены!")
    }
}
