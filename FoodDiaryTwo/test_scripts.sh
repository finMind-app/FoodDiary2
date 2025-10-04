#!/bin/bash

# Тестовый скрипт для проверки работы push_feature скриптов
# Запускается в режиме "dry-run" без реального пуша

echo "🧪 Тестирование скриптов push_feature..."

# Переходим в папку проекта
cd "$(dirname "$0")"

# Проверяем наличие скриптов
echo "🔍 Проверяем наличие скриптов..."

if [ -f "push_feature.sh" ]; then
    echo "✅ push_feature.sh найден"
    chmod +x push_feature.sh
else
    echo "❌ push_feature.sh не найден"
fi

if [ -f "push_feature.ps1" ]; then
    echo "✅ push_feature.ps1 найден"
else
    echo "❌ push_feature.ps1 не найден"
fi

if [ -f "push_feature.bat" ]; then
    echo "✅ push_feature.bat найден"
else
    echo "❌ push_feature.bat не найден"
fi

# Проверяем git репозиторий
echo ""
echo "🔍 Проверяем git репозиторий..."

if [ -d ".git" ]; then
    echo "✅ Git репозиторий обнаружен"
    
    # Получаем текущую ветку
    CURRENT_BRANCH=$(git branch --show-current)
    echo "📍 Текущая ветка: $CURRENT_BRANCH"
    
    # Проверяем статус
    git_status=$(git status --porcelain)
    if [ -z "$git_status" ]; then
        echo "✅ Репозиторий чистый"
    else
        echo "📝 Обнаружены изменения:"
        echo "$git_status"
    fi
    
    # Проверяем удаленный репозиторий
    if git remote get-url origin >/dev/null 2>&1; then
        REMOTE_URL=$(git remote get-url origin)
        echo "🌐 Удаленный репозиторий: $REMOTE_URL"
    else
        echo "⚠️  Удаленный репозиторий не настроен"
    fi
    
else
    echo "❌ Git репозиторий не обнаружен"
fi

# Проверяем CI/CD системы
echo ""
echo "🔍 Проверяем CI/CD системы..."

if [ -d ".github/workflows" ]; then
    echo "✅ GitHub Actions обнаружены"
    ls -la .github/workflows/
else
    echo "⚠️  GitHub Actions не настроены"
fi

if [ -f "azure-pipelines.yml" ]; then
    echo "✅ Azure DevOps pipeline обнаружен"
fi

if [ -f ".gitlab-ci.yml" ]; then
    echo "✅ GitLab CI обнаружен"
fi

if [ -f "Jenkinsfile" ]; then
    echo "✅ Jenkins pipeline обнаружен"
fi

# Проверяем права доступа
echo ""
echo "🔍 Проверяем права доступа..."

if [ -x "push_feature.sh" ]; then
    echo "✅ push_feature.sh исполняемый"
else
    echo "⚠️  push_feature.sh не исполняемый"
fi

# Итоговый отчет
echo ""
echo "📊 Итоговый отчет:"
echo "=================="

if [ -f "push_feature.sh" ] && [ -x "push_feature.sh" ] && [ -d ".git" ]; then
    echo "✅ Все готово для использования push_feature.sh"
    echo "💡 Запустите: ./push_feature.sh"
else
    echo "⚠️  Требуется настройка:"
    if [ ! -f "push_feature.sh" ]; then
        echo "   - Скрипт push_feature.sh не найден"
    fi
    if [ ! -x "push_feature.sh" ]; then
        echo "   - Скрипт не исполняемый (chmod +x push_feature.sh)"
    fi
    if [ ! -d ".git" ]; then
        echo "   - Git репозиторий не инициализирован"
    fi
fi

echo ""
echo "🎉 Тестирование завершено!"
