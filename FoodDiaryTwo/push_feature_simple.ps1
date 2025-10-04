# PowerShell скрипт для пуша в feature ветку с автоматическим запуском CI/CD
# Версия без эмодзи для совместимости с Windows

Write-Host "Пуш в feature ветку с запуском CI/CD..." -ForegroundColor Green

# Переходим в папку скрипта
Set-Location $PSScriptRoot

# Проверяем, что это git репозиторий
if (-not (Test-Path ".git")) {
    Write-Host "ОШИБКА: Папка не является git репозиторием" -ForegroundColor Red
    exit 1
}

# Получаем имя текущей ветки
$CURRENT_BRANCH = git branch --show-current
Write-Host "Текущая ветка: $CURRENT_BRANCH" -ForegroundColor Yellow

# Проверяем, что мы в feature ветке
if (-not $CURRENT_BRANCH.StartsWith("feature/")) {
    Write-Host "ВНИМАНИЕ: Вы не в feature ветке!" -ForegroundColor Yellow
    Write-Host "Рекомендуется работать в ветке feature/your-feature-name" -ForegroundColor Cyan
    $response = Read-Host "Продолжить? (y/N)"
    if ($response -ne "y" -and $response -ne "Y") {
        Write-Host "Операция отменена" -ForegroundColor Red
        exit 1
    }
}

# Проверяем статус git
Write-Host "Проверяем статус репозитория..." -ForegroundColor Blue
$gitStatus = git status --porcelain

if ([string]::IsNullOrEmpty($gitStatus)) {
    Write-Host "Нет изменений для коммита" -ForegroundColor Green
} else {
    Write-Host "Обнаружены изменения:" -ForegroundColor Yellow
    Write-Host $gitStatus -ForegroundColor Gray
    
    # Добавляем все изменения
    Write-Host "Добавляем все изменения..." -ForegroundColor Blue
    git add -A
    
    # Запрашиваем сообщение коммита
    $commitMessage = Read-Host "Введите сообщение коммита"
    if ([string]::IsNullOrEmpty($commitMessage)) {
        $commitMessage = "feat: автоматический коммит $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
    }
    
    # Создаем коммит
    Write-Host "Создаем коммит..." -ForegroundColor Blue
    git commit -m $commitMessage
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Коммит создан успешно" -ForegroundColor Green
    } else {
        Write-Host "Ошибка при создании коммита" -ForegroundColor Red
        exit 1
    }
}

# Получаем изменения с удаленного репозитория
Write-Host "Получаем изменения с удаленного репозитория..." -ForegroundColor Blue
git fetch origin

# Проверяем, существует ли ветка на удаленном репозитории
$remoteBranchExists = $false
try {
    git rev-parse --verify "origin/$CURRENT_BRANCH" 2>$null
    $remoteBranchExists = $true
} catch {
    $remoteBranchExists = $false
}

if ($remoteBranchExists) {
    Write-Host "Ветка $CURRENT_BRANCH существует на удаленном репозитории" -ForegroundColor Yellow
    
    # Проверяем, есть ли различия
    $LOCAL_COMMIT = git rev-parse HEAD
    $REMOTE_COMMIT = git rev-parse "origin/$CURRENT_BRANCH"
    
    if ($LOCAL_COMMIT -ne $REMOTE_COMMIT) {
        Write-Host "Локальная ветка отличается от удаленной" -ForegroundColor Yellow
        Write-Host "Выполняем rebase..." -ForegroundColor Blue
        git rebase "origin/$CURRENT_BRANCH"
        
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Ошибка при rebase. Разрешите конфликты вручную" -ForegroundColor Red
            exit 1
        }
    }
} else {
    Write-Host "Создаем новую ветку на удаленном репозитории" -ForegroundColor Green
}

# Пушим в удаленный репозиторий
Write-Host "Пушим в удаленный репозиторий..." -ForegroundColor Blue
if ($remoteBranchExists) {
    git push origin $CURRENT_BRANCH
} else {
    git push -u origin $CURRENT_BRANCH
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "Пуш выполнен успешно!" -ForegroundColor Green
} else {
    Write-Host "Ошибка при пуше" -ForegroundColor Red
    exit 1
}

# Запускаем CI/CD пайплайн (если настроен)
Write-Host "Запускаем CI/CD пайплайн..." -ForegroundColor Blue

# Проверяем, есть ли GitHub Actions
if (Test-Path ".github/workflows") {
    Write-Host "Обнаружены GitHub Actions workflows" -ForegroundColor Green
    
    # Получаем URL репозитория
    $remoteUrl = git remote get-url origin
    if ($remoteUrl -match "github\.com[:/]([^/]+)/([^/]+?)(?:\.git)?$") {
        $owner = $matches[1]
        $repo = $matches[2]
        $workflowUrl = "https://github.com/$owner/$repo/actions"
        
        Write-Host "Открываем GitHub Actions: $workflowUrl" -ForegroundColor Cyan
        Start-Process $workflowUrl
    }
} else {
    Write-Host "GitHub Actions не настроены" -ForegroundColor Yellow
}

# Проверяем, есть ли другие CI/CD системы
if (Test-Path "azure-pipelines.yml") {
    Write-Host "Обнаружен Azure DevOps pipeline" -ForegroundColor Blue
}

if (Test-Path ".gitlab-ci.yml") {
    Write-Host "Обнаружен GitLab CI" -ForegroundColor Orange
}

if (Test-Path "Jenkinsfile") {
    Write-Host "Обнаружен Jenkins pipeline" -ForegroundColor DarkBlue
}

# Показываем информацию о ветке
Write-Host "`nИнформация о ветке:" -ForegroundColor Cyan
Write-Host "   Ветка: $CURRENT_BRANCH" -ForegroundColor White
Write-Host "   Последний коммит: $(git log -1 --pretty=format:'%h - %s (%cr)')" -ForegroundColor White
Write-Host "   Автор: $(git log -1 --pretty=format:'%an <%ae>')" -ForegroundColor White

Write-Host "`nГотово! Код отправлен в feature ветку и CI/CD запущен" -ForegroundColor Green
Write-Host "Следующие шаги:" -ForegroundColor Cyan
Write-Host "   1. Проверьте статус пайплайна в GitHub Actions" -ForegroundColor White
Write-Host "   2. После успешного прохождения тестов создайте Pull Request" -ForegroundColor White
Write-Host "   3. Проведите code review" -ForegroundColor White
Write-Host "   4. После одобрения выполните merge в main ветку" -ForegroundColor White
