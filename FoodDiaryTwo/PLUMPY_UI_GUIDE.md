# Plumpy UI Design System Guide

## Обзор

Plumpy UI - это дружелюбная дизайн-система для iOS приложений, созданная с акцентом на мягкие, округлые формы и приятные, дружелюбные элементы интерфейса.

## Основные принципы

- **Мягкость**: Все элементы имеют закруглённые углы и мягкие тени
- **Дружелюбие**: Тёплая цветовая палитра и приятные анимации
- **Простота**: Минималистичный дизайн с акцентом на удобство использования
- **Консистентность**: Единообразные компоненты по всему приложению

## Цветовая палитра

### Основные цвета
```swift
PlumpyTheme.primary        // Бежевый (#F4E4C1)
PlumpyTheme.secondary      // Мятный (#C8E6C9)
PlumpyTheme.tertiary       // Нежно-голубой (#B3E5FC)
```

### Акцентные цвета
```swift
PlumpyTheme.primaryAccent   // Насыщенный бежевый (#E6D4A3)
PlumpyTheme.secondaryAccent // Насыщенный мятный (#A5D6A7)
PlumpyTheme.tertiaryAccent  // Насыщенный голубой (#81C784)
```

### Фоновые цвета
```swift
PlumpyTheme.background        // Светлый тёплый фон (#FDFCFA)
PlumpyTheme.surface          // Белый (#FFFFFF)
PlumpyTheme.surfaceSecondary // Светло-бежевый (#F8F6F2)
```

### Текстовые цвета
```swift
PlumpyTheme.textPrimary    // Тёмно-серый (#2C2C2C)
PlumpyTheme.textSecondary  // Серый средней насыщенности (#6B6B6B)
PlumpyTheme.textTertiary   // Светло-серый (#9E9E9E)
```

## Типографика

### Заголовки
```swift
PlumpyTheme.Typography.largeTitle  // 34pt, Bold, Rounded
PlumpyTheme.Typography.title1      // 28pt, Bold, Rounded
PlumpyTheme.Typography.title2      // 22pt, Semibold, Rounded
PlumpyTheme.Typography.title3      // 20pt, Semibold, Rounded
```

### Основной текст
```swift
PlumpyTheme.Typography.headline     // 17pt, Semibold, Rounded
PlumpyTheme.Typography.body         // 17pt, Regular, Rounded
PlumpyTheme.Typography.subheadline  // 15pt, Regular, Rounded
```

### Вспомогательный текст
```swift
PlumpyTheme.Typography.footnote     // 13pt, Regular, Rounded
PlumpyTheme.Typography.caption1     // 12pt, Regular, Rounded
PlumpyTheme.Typography.caption2     // 11pt, Regular, Rounded
```

## Отступы и размеры

### Отступы
```swift
PlumpyTheme.Spacing.tiny       // 4pt
PlumpyTheme.Spacing.small      // 8pt
PlumpyTheme.Spacing.medium     // 16pt
PlumpyTheme.Spacing.large      // 24pt
PlumpyTheme.Spacing.extraLarge // 32pt
PlumpyTheme.Spacing.huge       // 48pt
```

### Радиусы скругления
```swift
PlumpyTheme.Radius.small       // 8pt
PlumpyTheme.Radius.medium      // 12pt
PlumpyTheme.Radius.large       // 16pt
PlumpyTheme.Radius.extraLarge  // 24pt
PlumpyTheme.Radius.round       // 50pt
```

## Компоненты

### 1. Кнопки

#### Основная кнопка
```swift
PlumpyButton(
    title: "Добавить",
    icon: "plus",
    style: .primary
) {
    // Действие
}
```

#### Стили кнопок
```swift
PlumpyButtonStyle.primary    // Основной стиль
PlumpyButtonStyle.secondary  // Вторичный стиль
PlumpyButtonStyle.accent     // Акцентный стиль
PlumpyButtonStyle.outline    // Контурный стиль
```

#### Иконочная кнопка
```swift
PlumpyIconButton(
    systemImageName: "heart",
    title: "Like",
    style: .primary
) {
    // Действие
}
```

#### Плавающая кнопка
```swift
PlumpyFloatingButton(icon: "plus") {
    // Действие
}
```

### 2. Карточки

#### Базовая карточка
```swift
PlumpyCard {
    Text("Содержимое карточки")
}
```

#### Модификатор карточки
```swift
Text("Текст")
    .plumpyCard(
        backgroundColor: PlumpyTheme.surfaceSecondary,
        cornerRadius: PlumpyTheme.Radius.large
    )
```

#### Информационная карточка
```swift
PlumpyInfoCard(
    title: "Заголовок",
    subtitle: "Подзаголовок",
    icon: "info.circle",
    action: {
        // Действие
    }
)
```

#### Карточка статистики
```swift
PlumpyStatsCard(
    title: "Калории",
    value: "1,250",
    subtitle: "Сегодня",
    icon: "flame.fill",
    iconColor: PlumpyTheme.warning,
    trend: .up
)
```

### 3. Поля ввода

#### Основное поле
```swift
PlumpyField(
    title: "Email",
    placeholder: "Введите email",
    text: $email,
    icon: "envelope",
    isRequired: true
)
```

#### Поле поиска
```swift
PlumpySearchField(
    text: $searchText,
    placeholder: "Поиск...",
    onSearch: { query in
        // Поиск
    }
)
```

#### Текстовое поле
```swift
PlumpyTextArea(
    title: "Заметки",
    placeholder: "Введите заметки...",
    text: $notes
)
```

### 4. Прогресс-бары

#### Линейный прогресс-бар
```swift
PlumpyProgressBar(
    value: 75,
    maxValue: 100,
    title: "Прогресс",
    showPercentage: true,
    style: .primary
)
```

#### Круговой прогресс-бар
```swift
PlumpyCircularProgressBar(
    value: 75,
    maxValue: 100,
    size: 100,
    style: .primary
)
```

#### Пошаговый прогресс-бар
```swift
PlumpyStepProgressBar(
    currentStep: 2,
    totalSteps: 4,
    style: .primary
)
```

### 5. Навигация

#### Навигационная панель
```swift
PlumpyNavigationBar(
    title: "Заголовок",
    subtitle: "Подзаголовок",
    leftButton: PlumpyNavigationButton(
        icon: "chevron.left",
        title: "Назад",
        style: .outline
    ) {
        // Действие
    },
    rightButton: PlumpyNavigationButton(
        icon: "plus",
        title: "Добавить",
        style: .primary
    ) {
        // Действие
    }
)
```

#### Табы
```swift
PlumpyTabBar(
    selectedTab: $selectedTab,
    tabs: [
        PlumpyTabItem(icon: "house.fill", title: "Главная", color: PlumpyTheme.primaryAccent),
        PlumpyTabItem(icon: "chart.bar.fill", title: "Статистика", color: PlumpyTheme.secondaryAccent)
    ]
)
```

### 6. Фоны

#### Основной фон
```swift
PlumpyBackground(style: .primary)
    .ignoresSafeArea()
```

#### Градиентный фон
```swift
PlumpyBackground(style: .warmGradient)
    .ignoresSafeArea()
```

#### Модификатор фона
```swift
Text("Текст")
    .plumpyBackground(style: .primaryGradient)
```

### 7. Дополнительные компоненты

#### Чипы
```swift
PlumpyChip(
    title: "Выбран",
    style: .primary,
    isSelected: true
) {
    // Действие
}
```

#### Бейджи
```swift
PlumpyBadge(
    text: "Новое",
    style: .primary,
    size: .medium
)
```

#### Индикаторы загрузки
```swift
PlumpyLoadingIndicator(style: .spinner)
PlumpyLoadingIndicator(style: .dots)
PlumpyLoadingIndicator(style: .pulse)
```

#### Пустое состояние
```swift
PlumpyEmptyState(
    icon: "tray",
    title: "Нет данных",
    subtitle: "Добавьте первый элемент",
    actionTitle: "Добавить"
) {
    // Действие
}
```

## Анимации

### Типы анимаций
```swift
PlumpyTheme.Animation.quick   // 0.2s
PlumpyTheme.Animation.smooth  // 0.3s
PlumpyTheme.Animation.slow    // 0.5s
PlumpyTheme.Animation.spring  // Пружинная анимация
PlumpyTheme.Animation.bouncy  // Прыгучая анимация
```

### Использование
```swift
withAnimation(PlumpyTheme.Animation.spring) {
    // Изменения состояния
}
```

## Тени

### Стили теней
```swift
PlumpyTheme.Shadow.small      // Маленькая тень
PlumpyTheme.Shadow.medium     // Средняя тень
PlumpyTheme.Shadow.large      // Большая тень
PlumpyTheme.Shadow.extraLarge // Очень большая тень
```

### Применение
```swift
.shadow(
    color: PlumpyTheme.Shadow.medium.color.opacity(PlumpyTheme.Shadow.medium.opacity),
    radius: PlumpyTheme.Shadow.medium.radius,
    x: PlumpyTheme.Shadow.medium.x,
    y: PlumpyTheme.Shadow.medium.y
)
```

## Лучшие практики

### 1. Консистентность
- Используйте одинаковые отступы и радиусы скругления
- Придерживайтесь единой цветовой схемы
- Используйте стандартные компоненты вместо кастомных

### 2. Иерархия
- Используйте правильную типографику для заголовков и текста
- Применяйте соответствующие цвета для акцентов
- Соблюдайте логическую структуру отступов

### 3. Доступность
- Обеспечивайте достаточный контраст текста
- Используйте крупные клик-таргеты (минимум 44pt)
- Добавляйте accessibility labels для интерактивных элементов

### 4. Производительность
- Используйте LazyVGrid для больших списков
- Применяйте анимации умеренно
- Оптимизируйте тени и градиенты

## Примеры использования

### Простой экран
```swift
struct SimpleView: View {
    var body: some View {
        ZStack {
            PlumpyBackground(style: .primary)
                .ignoresSafeArea()
            
            VStack(spacing: PlumpyTheme.Spacing.large) {
                Text("Заголовок")
                    .font(PlumpyTheme.Typography.title1)
                    .foregroundColor(PlumpyTheme.textPrimary)
                
                PlumpyButton(
                    title: "Действие",
                    icon: "plus",
                    style: .primary
                ) {
                    // Действие
                }
            }
            .padding(PlumpyTheme.Spacing.large)
        }
    }
}
```

### Список с карточками
```swift
struct ListView: View {
    let items = ["Элемент 1", "Элемент 2", "Элемент 3"]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: PlumpyTheme.Spacing.medium) {
                ForEach(items, id: \.self) { item in
                    PlumpyCard {
                        HStack {
                            Text(item)
                                .font(PlumpyTheme.Typography.body)
                                .foregroundColor(PlumpyTheme.textPrimary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(PlumpyTheme.textTertiary)
                        }
                    }
                }
            }
            .padding(PlumpyTheme.Spacing.large)
        }
        .plumpyBackground(style: .primary)
    }
}
```

## Заключение

Plumpy UI предоставляет полный набор компонентов для создания дружелюбных и привлекательных iOS приложений. Следуйте этому руководству для обеспечения консистентности и качества пользовательского интерфейса.

Для получения дополнительной информации обратитесь к исходному коду компонентов в папке `DesignSystem/`.
