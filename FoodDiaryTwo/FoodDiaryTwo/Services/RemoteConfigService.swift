//
//  RemoteConfigService.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import Foundation

// MARK: - Протокол для сервиса удаленной конфигурации
protocol RemoteConfigServiceProtocol {
    func getAPIKey(completion: @escaping (String?) -> Void)
    func refreshAPIKey(completion: @escaping (Bool) -> Void)
}

// MARK: - Сервис удаленной конфигурации
class RemoteConfigService: RemoteConfigServiceProtocol, ObservableObject {
    
    // MARK: - Свойства
    private let csvURL = "https://docs.google.com/spreadsheets/d/e/2PACX-1vT-wvWAbmKGId7oTEFhAUGdUWJt1BrexuREA2XqmDWg8CcjXTt1-KuX7zimYYe7vVc4hlme6F0Rk0FI/pub?gid=0&single=true&output=csv"
    private let apiKeyKey = "remote_api_key"
    private let lastUpdateKey = "last_api_key_update"
    private let updateInterval: TimeInterval = 24 * 60 * 60 // 24 часа в секундах
    
    // MARK: - Получение API ключа
    func getAPIKey(completion: @escaping (String?) -> Void) {
        // Сначала проверяем кэшированный ключ
        if let cachedKey = getCachedAPIKey() {
            print("📱 RemoteConfigService: Используем кэшированный API ключ")
            completion(cachedKey)
            
            // Проверяем, нужно ли обновить ключ
            if shouldUpdateAPIKey() {
                print("🔄 RemoteConfigService: Запускаем фоновое обновление API ключа")
                refreshAPIKey { success in
                    if success {
                        print("✅ RemoteConfigService: API ключ успешно обновлен в фоне")
                    } else {
                        print("⚠️ RemoteConfigService: Не удалось обновить API ключ в фоне")
                    }
                }
            }
            return
        }
        
        // Если нет кэшированного ключа, пытаемся загрузить
        print("🌐 RemoteConfigService: Загружаем API ключ из Google Sheets")
        loadAPIKeyFromRemote { [weak self] apiKey in
            if let apiKey = apiKey {
                self?.cacheAPIKey(apiKey)
                completion(apiKey)
            } else {
                print("❌ RemoteConfigService: Не удалось загрузить API ключ")
                completion(nil)
            }
        }
    }
    
    // MARK: - Принудительное обновление API ключа
    func refreshAPIKey(completion: @escaping (Bool) -> Void) {
        print("🔄 RemoteConfigService: Принудительное обновление API ключа")
        loadAPIKeyFromRemote { [weak self] apiKey in
            if let apiKey = apiKey {
                self?.cacheAPIKey(apiKey)
                print("✅ RemoteConfigService: API ключ успешно обновлен")
                completion(true)
            } else {
                print("❌ RemoteConfigService: Ошибка обновления API ключа")
                completion(false)
            }
        }
    }
    
    // MARK: - Загрузка API ключа из Google Sheets
    private func loadAPIKeyFromRemote(completion: @escaping (String?) -> Void) {
        guard let url = URL(string: csvURL) else {
            print("❌ RemoteConfigService: Неверный URL для загрузки CSV")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ RemoteConfigService: Ошибка сети: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    print("❌ RemoteConfigService: HTTP ошибка: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                    completion(nil)
                    return
                }
                
                guard let data = data,
                      let csvString = String(data: data, encoding: .utf8) else {
                    print("❌ RemoteConfigService: Ошибка декодирования CSV данных")
                    completion(nil)
                    return
                }
                
                let apiKey = self.parseAPIKeyFromCSV(csvString)
                if let apiKey = apiKey {
                    print("✅ RemoteConfigService: API ключ успешно извлечен из CSV")
                } else {
                    print("❌ RemoteConfigService: API ключ не найден в CSV")
                }
                completion(apiKey)
            }
        }
        
        task.resume()
    }
    
    // MARK: - Парсинг API ключа из CSV
    private func parseAPIKeyFromCSV(_ csvString: String) -> String? {
        let lines = csvString.components(separatedBy: .newlines)
        
        for line in lines {
            let columns = line.components(separatedBy: ",")
            
            // Ищем строку с apiKey
            if columns.count >= 2 && columns[0].trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "apikey" {
                let apiKey = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
                if !apiKey.isEmpty {
                    return apiKey
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Кэширование API ключа
    private func cacheAPIKey(_ apiKey: String) {
        UserDefaults.standard.set(apiKey, forKey: apiKeyKey)
        UserDefaults.standard.set(Date(), forKey: lastUpdateKey)
        print("💾 RemoteConfigService: API ключ сохранен в UserDefaults")
    }
    
    // MARK: - Получение кэшированного API ключа
    private func getCachedAPIKey() -> String? {
        return UserDefaults.standard.string(forKey: apiKeyKey)
    }
    
    // MARK: - Проверка необходимости обновления
    private func shouldUpdateAPIKey() -> Bool {
        guard let lastUpdate = UserDefaults.standard.object(forKey: lastUpdateKey) as? Date else {
            return true // Если нет информации о последнем обновлении, обновляем
        }
        
        let timeSinceLastUpdate = Date().timeIntervalSince(lastUpdate)
        return timeSinceLastUpdate >= updateInterval
    }
}

// MARK: - Расширение для удобства использования
extension RemoteConfigService {
    
    /// Синхронное получение API ключа (использует кэш)
    func getAPIKeySync() -> String? {
        return getCachedAPIKey()
    }
    
    /// Проверка доступности сети
    private func isNetworkAvailable() -> Bool {
        // Простая проверка доступности сети
        // В реальном приложении можно использовать более сложную логику
        return true
    }
}
