@echo off
setlocal enableextensions enabledelayedexpansion

echo Пуш в feature ветку с запуском CI/CD...

cd /d "%~dp0"

rem Проверяем, что это git репозиторий
if not exist ".git" (
    echo ОШИБКА: Папка не является git репозиторием
    pause
    exit /b 1
)

rem Получаем имя текущей ветки
for /f "tokens=*" %%i in ('git branch --show-current 2^>nul') do set CURRENT_BRANCH=%%i
echo Текущая ветка: !CURRENT_BRANCH!

rem Проверяем, что мы в feature ветке
echo !CURRENT_BRANCH! | findstr /b "feature/" >nul
if errorlevel 1 (
    echo ВНИМАНИЕ: Вы не в feature ветке!
    echo Рекомендуется работать в ветке feature/your-feature-name
    set /p response="Продолжить? (y/N): "
    if /i not "!response!"=="y" (
        echo Операция отменена
        pause
        exit /b 1
    )
)

rem Проверяем статус git
echo Проверяем статус репозитория...
git status --porcelain > temp_status.txt
set /p git_status=<temp_status.txt
del temp_status.txt

if "!git_status!"=="" (
    echo Нет изменений для коммита
) else (
    echo Обнаружены изменения:
    git status --short
    
    rem Добавляем все изменения
    echo Добавляем все изменения...
    git add -A
    
    rem Запрашиваем сообщение коммита
    set /p commit_message="Введите сообщение коммита: "
    if "!commit_message!"=="" (
        for /f "tokens=1-3 delims=/ " %%a in ('date /t') do set mydate=%%c-%%a-%%b
        for /f "tokens=1-2 delims=: " %%a in ('time /t') do set mytime=%%a:%%b
        set commit_message=feat: автоматический коммит !mydate! !mytime!
    )
    
    rem Создаем коммит
    echo Создаем коммит...
    git commit -m "!commit_message!"
    
    if errorlevel 1 (
        echo Ошибка при создании коммита
        pause
        exit /b 1
    ) else (
        echo Коммит создан успешно
    )
)

rem Получаем изменения с удаленного репозитория
echo Получаем изменения с удаленного репозитория...
git fetch origin

rem Проверяем, существует ли ветка на удаленном репозитории
git rev-parse --verify "origin/!CURRENT_BRANCH!" >nul 2>&1
if errorlevel 1 (
    echo Создаем новую ветку на удаленном репозитории
    set remote_branch_exists=false
) else (
    echo Ветка !CURRENT_BRANCH! существует на удаленном репозитории
    set remote_branch_exists=true
    
    rem Проверяем, есть ли различия
    for /f "tokens=*" %%i in ('git rev-parse HEAD 2^>nul') do set LOCAL_COMMIT=%%i
    for /f "tokens=*" %%i in ('git rev-parse "origin/!CURRENT_BRANCH!" 2^>nul') do set REMOTE_COMMIT=%%i
    
    if not "!LOCAL_COMMIT!"=="!REMOTE_COMMIT!" (
        echo Локальная ветка отличается от удаленной
        echo Выполняем rebase...
        git rebase "origin/!CURRENT_BRANCH!"
        
        if errorlevel 1 (
            echo Ошибка при rebase. Разрешите конфликты вручную
            pause
            exit /b 1
        )
    )
)

rem Пушим в удаленный репозиторий
echo Пушим в удаленный репозиторий...
if "!remote_branch_exists!"=="true" (
    git push origin !CURRENT_BRANCH!
) else (
    git push -u origin !CURRENT_BRANCH!
)

if errorlevel 1 (
    echo Ошибка при пуше
    pause
    exit /b 1
) else (
    echo Пуш выполнен успешно!
)

rem Запускаем CI/CD пайплайн (если настроен)
echo Запускаем CI/CD пайплайн...

rem Проверяем, есть ли GitHub Actions
if exist ".github\workflows" (
    echo Обнаружены GitHub Actions workflows
    
    rem Получаем URL репозитория
    for /f "tokens=*" %%i in ('git remote get-url origin 2^>nul') do set remote_url=%%i
    
    rem Извлекаем owner и repo из URL
    echo !remote_url! | findstr "github.com" >nul
    if not errorlevel 1 (
        for /f "tokens=3,4 delims=/" %%a in ("!remote_url!") do (
            set owner=%%a
            set repo=%%b
        )
        set repo=!repo:.git=!
        set workflow_url=https://github.com/!owner!/!repo!/actions
        
        echo Открываем GitHub Actions: !workflow_url!
        start "" "!workflow_url!"
    )
) else (
    echo GitHub Actions не настроены
)

rem Проверяем, есть ли другие CI/CD системы
if exist "azure-pipelines.yml" (
    echo Обнаружен Azure DevOps pipeline
)

if exist ".gitlab-ci.yml" (
    echo Обнаружен GitLab CI
)

if exist "Jenkinsfile" (
    echo Обнаружен Jenkins pipeline
)

rem Показываем информацию о ветке
echo.
echo Информация о ветке:
echo    Ветка: !CURRENT_BRANCH!
for /f "tokens=*" %%i in ('git log -1 --pretty=format:"%%h - %%s (%%cr)" 2^>nul') do echo    Последний коммит: %%i
for /f "tokens=*" %%i in ('git log -1 --pretty=format:"%%an ^<%%ae^>" 2^>nul') do echo    Автор: %%i

echo.
echo Готово! Код отправлен в feature ветку и CI/CD запущен
echo Следующие шаги:
echo    1. Проверьте статус пайплайна в GitHub Actions
echo    2. После успешного прохождения тестов создайте Pull Request
echo    3. Проведите code review
echo    4. После одобрения выполните merge в main ветку

pause
endlocal
