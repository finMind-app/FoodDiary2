#!/usr/bin/env swift

// Простой скрипт для тестирования RemoteConfigService
// Запуск: swift test_remote_config.swift

import Foundation

// Имитация RemoteConfigService для тестирования
class TestRemoteConfigService {
    private let csvURL = "https://docs.google.com/spreadsheets/d/e/2PACX-1vT-wvWAbmKGId7oTEFhAUGdUWJt1BrexuREA2XqmDWg8CcjXTt1-KuX7zimYYe7vVc4hlme6F0Rk0FI/pub?gid=0&single=true&output=csv"
    
    func testCSVDownload() {
        print("🧪 Тестируем загрузку CSV из Google Sheets...")
        
        guard let url = URL(string: csvURL) else {
            print("❌ Неверный URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Ошибка сети: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                print("❌ HTTP ошибка: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                return
            }
            
            guard let data = data,
                  let csvString = String(data: data, encoding: .utf8) else {
                print("❌ Ошибка декодирования CSV")
                return
            }
            
            print("✅ CSV успешно загружен")
            print("📄 Содержимое CSV:")
            print(csvString)
            
            // Парсим API ключ
            let apiKey = self.parseAPIKeyFromCSV(csvString)
            if let apiKey = apiKey {
                print("🔑 API ключ найден: \(String(apiKey.prefix(20)))...")
            } else {
                print("❌ API ключ не найден в CSV")
            }
        }
        
        task.resume()
    }
    
    private func parseAPIKeyFromCSV(_ csvString: String) -> String? {
        let lines = csvString.components(separatedBy: .newlines)
        
        for line in lines {
            let columns = line.components(separatedBy: ",")
            
            if columns.count >= 2 && columns[0].trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "apikey" {
                let apiKey = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
                if !apiKey.isEmpty {
                    return apiKey
                }
            }
        }
        
        return nil
    }
}

// Запуск теста
print("🚀 Запуск теста RemoteConfigService")
print("=" * 50)

let tester = TestRemoteConfigService()
tester.testCSVDownload()

// Ждем завершения асинхронной задачи
RunLoop.main.run(until: Date().addingTimeInterval(10))
