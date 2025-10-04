#!/bin/bash

# Bash скрипт для пуша в feature ветку с автоматическим запуском CI/CD
# Работает на macOS/Linux без дополнительных зависимостей

echo "🚀 Пуш в feature ветку с запуском CI/CD..."

# Переходим в папку скрипта
cd "$(dirname "$0")"

# Проверяем, что это git репозиторий
if [ ! -d ".git" ]; then
    echo "❌ Ошибка: Папка не является git репозиторием"
    exit 1
fi

# Получаем имя текущей ветки
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 Текущая ветка: $CURRENT_BRANCH"

# Проверяем, что мы в feature ветке
if [[ ! "$CURRENT_BRANCH" =~ ^feature/ ]]; then
    echo "⚠️  Внимание: Вы не в feature ветке!"
    echo "💡 Рекомендуется работать в ветке feature/your-feature-name"
    read -p "Продолжить? (y/N): " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "❌ Операция отменена"
        exit 1
    fi
fi

# Проверяем статус git
echo "🔍 Проверяем статус репозитория..."
git_status=$(git status --porcelain)

if [ -z "$git_status" ]; then
    echo "✅ Нет изменений для коммита"
else
    echo "📝 Обнаружены изменения:"
    echo "$git_status"
    
    # Добавляем все изменения
    echo "📦 Добавляем все изменения..."
    git add -A
    
    # Запрашиваем сообщение коммита
    read -p "💬 Введите сообщение коммита: " commit_message
    if [ -z "$commit_message" ]; then
        commit_message="feat: автоматический коммит $(date '+%Y-%m-%d %H:%M')"
    fi
    
    # Создаем коммит
    echo "💾 Создаем коммит..."
    git commit -m "$commit_message"
    
    if [ $? -eq 0 ]; then
        echo "✅ Коммит создан успешно"
    else
        echo "❌ Ошибка при создании коммита"
        exit 1
    fi
fi

# Получаем изменения с удаленного репозитория
echo "📥 Получаем изменения с удаленного репозитория..."
git fetch origin

# Проверяем, существует ли ветка на удаленном репозитории
if git rev-parse --verify "origin/$CURRENT_BRANCH" >/dev/null 2>&1; then
    echo "🔄 Ветка $CURRENT_BRANCH существует на удаленном репозитории"
    
    # Проверяем, есть ли различия
    LOCAL_COMMIT=$(git rev-parse HEAD)
    REMOTE_COMMIT=$(git rev-parse "origin/$CURRENT_BRANCH")
    
    if [ "$LOCAL_COMMIT" != "$REMOTE_COMMIT" ]; then
        echo "⚠️  Локальная ветка отличается от удаленной"
        echo "🔄 Выполняем rebase..."
        git rebase "origin/$CURRENT_BRANCH"
        
        if [ $? -ne 0 ]; then
            echo "❌ Ошибка при rebase. Разрешите конфликты вручную"
            exit 1
        fi
    fi
else
    echo "🆕 Создаем новую ветку на удаленном репозитории"
fi

# Пушим в удаленный репозиторий
echo "🚀 Пушим в удаленный репозиторий..."
if git rev-parse --verify "origin/$CURRENT_BRANCH" >/dev/null 2>&1; then
    git push origin "$CURRENT_BRANCH"
else
    git push -u origin "$CURRENT_BRANCH"
fi

if [ $? -eq 0 ]; then
    echo "✅ Пуш выполнен успешно!"
else
    echo "❌ Ошибка при пуше"
    exit 1
fi

# Запускаем CI/CD пайплайн (если настроен)
echo "🔄 Запускаем CI/CD пайплайн..."

# Проверяем, есть ли GitHub Actions
if [ -d ".github/workflows" ]; then
    echo "📋 Обнаружены GitHub Actions workflows"
    
    # Получаем URL репозитория
    remote_url=$(git remote get-url origin)
    if [[ "$remote_url" =~ github\.com[:/]([^/]+)/([^/]+?)(?:\.git)?$ ]]; then
        owner="${BASH_REMATCH[1]}"
        repo="${BASH_REMATCH[2]}"
        workflow_url="https://github.com/$owner/$repo/actions"
        
        echo "🔗 Открываем GitHub Actions: $workflow_url"
        if command -v open >/dev/null 2>&1; then
            open "$workflow_url"
        elif command -v xdg-open >/dev/null 2>&1; then
            xdg-open "$workflow_url"
        else
            echo "💡 Откройте в браузере: $workflow_url"
        fi
    fi
else
    echo "⚠️  GitHub Actions не настроены"
fi

# Проверяем, есть ли другие CI/CD системы
if [ -f "azure-pipelines.yml" ]; then
    echo "🔵 Обнаружен Azure DevOps pipeline"
fi

if [ -f ".gitlab-ci.yml" ]; then
    echo "🦊 Обнаружен GitLab CI"
fi

if [ -f "Jenkinsfile" ]; then
    echo "🔧 Обнаружен Jenkins pipeline"
fi

# Показываем информацию о ветке
echo ""
echo "📊 Информация о ветке:"
echo "   Ветка: $CURRENT_BRANCH"
echo "   Последний коммит: $(git log -1 --pretty=format:'%h - %s (%cr)')"
echo "   Автор: $(git log -1 --pretty=format:'%an <%ae>')"

echo ""
echo "🎉 Готово! Код отправлен в feature ветку и CI/CD запущен"
echo "💡 Следующие шаги:"
echo "   1. Проверьте статус пайплайна в GitHub Actions"
echo "   2. После успешного прохождения тестов создайте Pull Request"
echo "   3. Проведите code review"
echo "   4. После одобрения выполните merge в main ветку"
