# PowerShell скрипт для обновления проекта и открытия в Visual Studio
# Работает на Windows без дополнительных зависимостей

Write-Host "🚀 Обновление проекта FoodDiaryTwo..." -ForegroundColor Green

# Переходим в папку скрипта
Set-Location $PSScriptRoot

# Проверяем, что это git репозиторий
if (-not (Test-Path ".git")) {
    Write-Host "❌ Ошибка: Папка не является git репозиторием" -ForegroundColor Red
    exit 1
}

# Сохраняем текущую ветку
$CURRENT_BRANCH = git branch --show-current
Write-Host "📍 Текущая ветка: $CURRENT_BRANCH" -ForegroundColor Yellow

# Получаем изменения с удаленного репозитория
Write-Host "📥 Получаем изменения с удаленного репозитория..." -ForegroundColor Blue
git fetch origin

# Проверяем, есть ли изменения
$LOCAL_COMMIT = git rev-parse HEAD
$REMOTE_COMMIT = git rev-parse "origin/$CURRENT_BRANCH"

if ($LOCAL_COMMIT -eq $REMOTE_COMMIT) {
    Write-Host "✅ Проект уже обновлен до последней версии" -ForegroundColor Green
} else {
    Write-Host "🔄 Обнаружены изменения, обновляем..." -ForegroundColor Yellow
    
    # Сохраняем локальные изменения (если есть)
    if (-not (git diff-index --quiet HEAD --)) {
        Write-Host "💾 Сохраняем локальные изменения..." -ForegroundColor Blue
        git stash push -m "Автоматическое сохранение перед обновлением"
        $STASHED = $true
    }
    
    # Переключаемся на удаленную версию
    git reset --hard "origin/$CURRENT_BRANCH"
    
    # Восстанавливаем локальные изменения (если были)
    if ($STASHED) {
        Write-Host "📤 Восстанавливаем локальные изменения..." -ForegroundColor Blue
        git stash pop
    }
    
    Write-Host "✅ Проект успешно обновлен!" -ForegroundColor Green
}

# Открываем проект в Xcode (если установлен) или в проводнике
Write-Host "🖥️  Открываем проект..." -ForegroundColor Blue

# Пытаемся открыть в Xcode (если установлен)
if (Get-Command "xcodebuild" -ErrorAction SilentlyContinue) {
    Write-Host "📱 Открываем в Xcode..." -ForegroundColor Green
    Start-Process "FoodDiaryTwo.xcodeproj"
} else {
    # Если Xcode не установлен, открываем в проводнике
    Write-Host "📁 Открываем в проводнике..." -ForegroundColor Yellow
    Invoke-Item "."
}

Write-Host "🎉 Готово! Проект открыт" -ForegroundColor Green
