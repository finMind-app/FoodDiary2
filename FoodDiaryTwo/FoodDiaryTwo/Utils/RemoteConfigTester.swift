//
//  RemoteConfigTester.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import Foundation

// MARK: - Тестер для RemoteConfigService
class RemoteConfigTester {
    
    private let remoteConfigService = RemoteConfigService()
    
    // MARK: - Тестирование загрузки API ключа
    func testAPIKeyLoading() {
        print("🧪 RemoteConfigTester: Начинаем тестирование загрузки API ключа")
        
        remoteConfigService.getAPIKey { apiKey in
            if let apiKey = apiKey {
                print("✅ RemoteConfigTester: API ключ успешно получен")
                print("🔑 Ключ: \(String(apiKey.prefix(20)))...")
            } else {
                print("❌ RemoteConfigTester: Не удалось получить API ключ")
            }
        }
    }
    
    // MARK: - Тестирование принудительного обновления
    func testAPIKeyRefresh() {
        print("🧪 RemoteConfigTester: Начинаем тестирование принудительного обновления")
        
        remoteConfigService.refreshAPIKey { success in
            if success {
                print("✅ RemoteConfigTester: API ключ успешно обновлен")
            } else {
                print("❌ RemoteConfigTester: Ошибка обновления API ключа")
            }
        }
    }
    
    // MARK: - Тестирование синхронного получения
    func testSyncAPIKey() {
        print("🧪 RemoteConfigTester: Тестируем синхронное получение API ключа")
        
        if let apiKey = remoteConfigService.getAPIKeySync() {
            print("✅ RemoteConfigTester: Синхронный API ключ получен")
            print("🔑 Ключ: \(String(apiKey.prefix(20)))...")
        } else {
            print("❌ RemoteConfigTester: Синхронный API ключ не найден")
        }
    }
    
    // MARK: - Полное тестирование
    func runFullTest() {
        print("🚀 RemoteConfigTester: Запускаем полное тестирование")
        print(String(repeating: "=", count: 50))
        
        // Тест 1: Синхронное получение (может быть пустым при первом запуске)
        testSyncAPIKey()
        
        // Тест 2: Асинхронное получение
        testAPIKeyLoading()
        
        // Тест 3: Принудительное обновление
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.testAPIKeyRefresh()
        }
        
        // Тест 4: Повторное синхронное получение (должно работать после кэширования)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.testSyncAPIKey()
        }
    }
}

// MARK: - Расширение для удобства тестирования
extension RemoteConfigTester {
    
    /// Быстрый тест для проверки работы сервиса
    static func quickTest() {
        let tester = RemoteConfigTester()
        tester.runFullTest()
    }
}
