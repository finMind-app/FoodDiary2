#!/bin/bash

# Скрипт для обновления проекта и открытия в Xcode
# Работает на macOS без дополнительных зависимостей

echo "🚀 Обновление проекта FoodDiaryTwo..."

# Переходим в папку проекта
cd "$(dirname "$0")"

# Проверяем, что это git репозиторий
if [ ! -d ".git" ]; then
    echo "❌ Ошибка: Папка не является git репозиторием"
    exit 1
fi

# Сохраняем текущую ветку
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 Текущая ветка: $CURRENT_BRANCH"

# Получаем изменения с удаленного репозитория
echo "📥 Получаем изменения с удаленного репозитория..."
git fetch origin

# Проверяем, есть ли изменения
LOCAL_COMMIT=$(git rev-parse HEAD)
REMOTE_COMMIT=$(git rev-parse origin/$CURRENT_BRANCH)

if [ "$LOCAL_COMMIT" = "$REMOTE_COMMIT" ]; then
    echo "✅ Проект уже обновлен до последней версии"
else
    echo "🔄 Обнаружены изменения, обновляем..."
    
    # Сохраняем локальные изменения (если есть)
    if ! git diff-index --quiet HEAD --; then
        echo "💾 Сохраняем локальные изменения..."
        git stash push -m "Автоматическое сохранение перед обновлением"
        STASHED=true
    fi
    
    # Переключаемся на удаленную версию
    git reset --hard origin/$CURRENT_BRANCH
    
    # Восстанавливаем локальные изменения (если были)
    if [ "$STASHED" = true ]; then
        echo "📤 Восстанавливаем локальные изменения..."
        git stash pop
    fi
    
    echo "✅ Проект успешно обновлен!"
fi

# Открываем проект в Xcode
echo "🖥️  Открываем проект в Xcode..."
open FoodDiaryTwo.xcodeproj

echo "🎉 Готово! Проект открыт в Xcode"
