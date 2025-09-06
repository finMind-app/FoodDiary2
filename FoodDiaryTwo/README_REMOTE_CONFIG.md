# RemoteConfigService - Динамическая загрузка API ключей

## Описание

`RemoteConfigService` - это сервис для динамической загрузки API-ключей из Google Sheets. Он заменяет захардкоженные API-ключи в коде на динамически загружаемые из удаленного источника.

## Основные возможности

- ✅ **Динамическая загрузка**: API-ключ загружается из Google Sheets CSV
- ✅ **Кэширование**: Ключ сохраняется в UserDefaults для офлайн использования
- ✅ **Автоматическое обновление**: Ключ обновляется раз в 24 часа
- ✅ **Асинхронная работа**: Все операции выполняются асинхронно
- ✅ **Обработка ошибок**: Корректная обработка сетевых ошибок и отсутствия интернета

## Использование

### Базовое использование

```swift
let remoteConfigService = RemoteConfigService()

// Получение API ключа асинхронно
remoteConfigService.getAPIKey { apiKey in
    if let apiKey = apiKey {
        print("API ключ получен: \(apiKey)")
        // Используйте ключ для API запросов
    } else {
        print("Не удалось получить API ключ")
    }
}
```

### Принудительное обновление

```swift
// Принудительное обновление API ключа
remoteConfigService.refreshAPIKey { success in
    if success {
        print("API ключ успешно обновлен")
    } else {
        print("Ошибка обновления API ключа")
    }
}
```

### Синхронное получение (только кэш)

```swift
// Получение кэшированного ключа (работает офлайн)
if let apiKey = remoteConfigService.getAPIKeySync() {
    print("Кэшированный API ключ: \(apiKey)")
} else {
    print("Кэшированный ключ не найден")
}
```

## Интеграция с существующим кодом

### До (захардкоженный ключ)

```swift
class OpenRouterAPIService {
    private let apiKey = "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"
    
    func makeRequest() {
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    }
}
```

### После (динамический ключ)

```swift
class OpenRouterAPIService {
    private let remoteConfigService = RemoteConfigService()
    
    func makeRequest() async throws {
        let apiKey = try await getAPIKey()
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    }
    
    private func getAPIKey() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            remoteConfigService.getAPIKey { apiKey in
                if let apiKey = apiKey {
                    continuation.resume(returning: apiKey)
                } else {
                    continuation.resume(throwing: APIError.keyNotFound)
                }
            }
        }
    }
}
```

## Настройка Google Sheets

### Формат CSV файла

CSV файл должен содержать строку с API ключом в следующем формате:

```csv
apiKey,sk-or-v1-your-actual-api-key-here
```

### URL для Google Sheets

```
https://docs.google.com/spreadsheets/d/e/2PACX-1vT-wvWAbmKGId7oTEFhAUGdUWJt1BrexuREA2XqmDWg8CcjXTt1-KuX7zimYYe7vVc4hlme6F0Rk0FI/pub?gid=0&single=true&output=csv
```

## Тестирование

### Использование RemoteConfigTester

```swift
// Быстрый тест
RemoteConfigTester.quickTest()

// Или создание экземпляра для детального тестирования
let tester = RemoteConfigTester()
tester.runFullTest()
```

### Тестовые сценарии

1. **Первый запуск** - загрузка ключа из сети
2. **Офлайн режим** - использование кэшированного ключа
3. **Обновление ключа** - принудительное обновление
4. **Ошибки сети** - обработка сетевых ошибок

## Конфигурация

### Настройка интервала обновления

По умолчанию ключ обновляется каждые 24 часа. Для изменения интервала:

```swift
// В RemoteConfigService.swift
private let updateInterval: TimeInterval = 12 * 60 * 60 // 12 часов
```

### Настройка ключей UserDefaults

```swift
// В RemoteConfigService.swift
private let apiKeyKey = "remote_api_key"           // Ключ для API ключа
private let lastUpdateKey = "last_api_key_update"  // Ключ для времени обновления
```

## Безопасность

- ✅ API ключ не хранится в коде
- ✅ Ключ кэшируется локально в UserDefaults
- ✅ Автоматическое обновление ключа
- ✅ Обработка ошибок сети

## Логирование

Сервис выводит подробные логи для отладки:

```
📱 RemoteConfigService: Используем кэшированный API ключ
🔄 RemoteConfigService: Запускаем фоновое обновление API ключа
🌐 RemoteConfigService: Загружаем API ключ из Google Sheets
✅ RemoteConfigService: API ключ успешно извлечен из CSV
💾 RemoteConfigService: API ключ сохранен в UserDefaults
```

## Обработка ошибок

Сервис обрабатывает следующие типы ошибок:

- ❌ **Сетевые ошибки** - отсутствие интернета
- ❌ **HTTP ошибки** - неправильный статус ответа
- ❌ **Парсинг ошибки** - неправильный формат CSV
- ❌ **Отсутствие ключа** - ключ не найден в CSV

## Производительность

- ⚡ **Быстрый доступ** - кэшированный ключ доступен мгновенно
- ⚡ **Фоновое обновление** - обновление не блокирует UI
- ⚡ **Минимальный трафик** - загрузка только при необходимости
- ⚡ **Офлайн работа** - приложение работает без интернета
