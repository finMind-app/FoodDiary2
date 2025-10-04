# FoodDiary - iOS App

## Описание

FoodDiary - это iOS приложение для отслеживания питания, построенное с использованием современного стека технологий и дружелюбной дизайн-системы Plumpy UI.

## Особенности

- 📱 **Современный UI/UX**: Использует дизайн-систему Plumpy UI с мягкими, округлыми формами
- 🍽️ **Отслеживание питания**: Добавление приемов пищи, подсчет калорий
- 📊 **Статистика**: Детальная аналитика потребления калорий
- 🎯 **Цели**: Установка и отслеживание дневных целей по калориям
- 📸 **Фото**: Возможность добавления фотографий блюд
- 🏆 **Достижения**: Система достижений для мотивации
- 🔍 **Поиск**: Быстрый поиск по истории приемов пищи
- 🌍 **Локализация**: Поддержка нескольких языков

## Технологии

- **SwiftUI** - современный фреймворк для создания пользовательских интерфейсов
- **SwiftData** - новая система управления данными от Apple
- **iOS 17+** - поддержка последних версий iOS
- **Xcode 15+** - последняя версия среды разработки

## Дизайн-система Plumpy UI

### Принципы дизайна

Plumpy UI основан на принципах дружелюбия и мягкости:

- **Мягкие формы**: Все элементы имеют закруглённые углы (cornerRadius ≥ 12)
- **Тёплая палитра**: Светлые пастельные оттенки (бежевый, мятный, нежно-голубой)
- **Мягкие тени**: Лёгкие тени для создания глубины
- **Плавные анимации**: Пружинные анимации для интерактивных элементов

### Цветовая схема

```
Основные цвета:
- Primary: #F4E4C1 (Бежевый)
- Secondary: #C8E6C9 (Мятный)
- Tertiary: #B3E5FC (Нежно-голубой)

Акцентные цвета:
- Primary Accent: #E6D4A3 (Насыщенный бежевый)
- Secondary Accent: #A5D6A7 (Насыщенный мятный)
- Tertiary Accent: #81C784 (Насыщенный голубой)
```

### Компоненты

Дизайн-система включает полный набор компонентов:

- **Кнопки**: `PlumpyButton`, `PlumpyIconButton`, `PlumpyFloatingButton`
- **Карточки**: `PlumpyCard`, `PlumpyInfoCard`, `PlumpyStatsCard`
- **Поля ввода**: `PlumpyField`, `PlumpySearchField`, `PlumpyTextArea`
- **Прогресс-бары**: `PlumpyProgressBar`, `PlumpyCircularProgressBar`
- **Навигация**: `PlumpyNavigationBar`, `PlumpyTabBar`
- **Фоны**: `PlumpyBackground` с различными стилями
- **Дополнительные**: `PlumpyChip`, `PlumpyBadge`, `PlumpyLoadingIndicator`

## Структура проекта

```
FoodDiaryTwo/
├── DesignSystem/           # Дизайн-система Plumpy UI
│   ├── PlumpyTheme.swift      # Основная тема (цвета, типографика, отступы)
│   ├── PlumpyButton.swift     # Кнопки
│   ├── PlumpyCard.swift       # Карточки
│   ├── PlumpyField.swift      # Поля ввода
│   ├── PlumpyProgressBar.swift # Прогресс-бары
│   ├── PlumpyNavigationBar.swift # Навигация
│   ├── PlumpyBackground.swift # Фоны
│   └── PlumpyComponents.swift # Дополнительные компоненты
├── Views/                  # Экранные представления
│   ├── HomeView.swift         # Главный экран
│   ├── AddMealView.swift      # Добавление приема пищи
│   ├── HistoryStatsSettings.swift # История, статистика, настройки
│   ├── ProfileView.swift      # Профиль пользователя
│   └── ContentView.swift      # Основной контейнер
├── Models/                 # Модели данных
│   ├── FoodEntry.swift        # Запись о приеме пищи
│   ├── FoodProduct.swift      # Продукт питания
│   └── Item.swift             # Базовый элемент
├── ViewModels/             # Модели представления
├── Localization/           # Локализация
└── Assets.xcassets/        # Ресурсы приложения
```

## Установка и запуск

### Требования

- macOS 14.0+
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Шаги установки

1. Клонируйте репозиторий:
```bash
git clone https://github.com/your-username/FoodDiary.git
cd FoodDiary
```

2. Откройте проект в Xcode:
```bash
open FoodDiaryTwo.xcodeproj
```

3. Выберите симулятор или устройство

4. Нажмите ⌘+R для запуска

## Использование дизайн-системы

### Базовое применение

```swift
import SwiftUI

struct MyView: View {
    var body: some View {
        ZStack {
            // Фон
            PlumpyBackground(style: .primary)
                .ignoresSafeArea()
            
            VStack(spacing: PlumpyTheme.Spacing.large) {
                // Заголовок
                Text("Мой заголовок")
                    .font(PlumpyTheme.Typography.title1)
                    .foregroundColor(PlumpyTheme.textPrimary)
                
                // Кнопка
                PlumpyButton(
                    title: "Действие",
                    icon: "plus",
                    style: .primary
                ) {
                    // Ваше действие
                }
            }
            .padding(PlumpyTheme.Spacing.large)
        }
    }
}
```

### Создание карточки

```swift
PlumpyCard {
    VStack(spacing: PlumpyTheme.Spacing.medium) {
        Text("Содержимое карточки")
            .font(PlumpyTheme.Typography.body)
            .foregroundColor(PlumpyTheme.textPrimary)
    }
}
```

### Использование модификаторов

```swift
Text("Текст с карточкой")
    .plumpyCard(
        backgroundColor: PlumpyTheme.surfaceSecondary,
        cornerRadius: PlumpyTheme.Radius.large
    )
```

## Архитектура

Приложение построено с использованием архитектуры MVVM (Model-View-ViewModel):

- **Model**: `FoodEntry`, `FoodProduct` - модели данных
- **View**: SwiftUI представления
- **ViewModel**: `FoodDiaryViewModel` - бизнес-логика и управление состоянием

## Локализация

Приложение поддерживает несколько языков через `LocalizationManager`:

- Английский (по умолчанию)
- Русский
- Другие языки могут быть легко добавлены

## Тестирование

Для тестирования компонентов дизайн-системы используйте Preview в Xcode:

```swift
#Preview {
    PlumpyButton(title: "Test Button") {}
        .padding()
        .plumpyBackground(style: .primary)
}
```

## Вклад в проект

### Добавление новых компонентов

1. Создайте новый файл в папке `DesignSystem/`
2. Следуйте существующим соглашениям по именованию
3. Добавьте Preview для тестирования
4. Обновите документацию

### Стилизация существующих экранов

1. Замените стандартные SwiftUI компоненты на Plumpy UI
2. Используйте `PlumpyTheme` для цветов, отступов и типографики
3. Применяйте `PlumpyBackground` для фонов
4. Используйте `.plumpyCard()` модификатор для карточек

## 📚 Дополнительная документация

### 🛠️ Скрипты разработки
- [README_SCRIPTS.md](README_SCRIPTS.md) - Полная документация по скриптам
- [QUICK_START_SCRIPTS.md](QUICK_START_SCRIPTS.md) - Быстрый старт со скриптами
- `push_feature.*` - Скрипты для пуша в feature ветки с CI/CD
- `update_and_open.*` - Скрипты для обновления проекта

### 🎨 Дизайн-система
- [PLUMPY_UI_GUIDE.md](PLUMPY_UI_GUIDE.md) - Полное руководство по Plumpy UI
- [DESIGN_SYSTEM_OVERHAUL.md](DESIGN_SYSTEM_OVERHAUL.md) - История переработки дизайна

### 🤖 AI интеграция
- [README_FOOD_RECOGNITION.md](README_FOOD_RECOGNITION.md) - Система распознавания еды
- [README_OPENROUTER_API.md](README_OPENROUTER_API.md) - Интеграция с OpenRouter API

### ⚡ Оптимизация
- [UI_OPTIMIZATION_SUMMARY.md](UI_OPTIMIZATION_SUMMARY.md) - Улучшения производительности

## Лицензия

Этот проект распространяется под лицензией MIT. См. файл `LICENSE` для получения дополнительной информации.

## Поддержка

Если у вас есть вопросы или предложения:

1. Создайте Issue в репозитории
2. Обратитесь к документации дизайн-системы
3. Изучите примеры использования в коде

## Дорожная карта

- [ ] Темная тема
- [ ] Дополнительные анимации
- [ ] Кастомизация цветов
- [ ] Экспорт данных
- [ ] Синхронизация с облаком
- [ ] Виджеты для iOS

---

**FoodDiary** - создано с ❤️ и дизайн-системой **Plumpy UI**
