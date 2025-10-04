# 📱 Скрипты для работы с проектом FoodDiaryTwo

Этот репозиторий содержит скрипты для автоматического обновления проекта и пуша в feature ветки с запуском CI/CD.

## 🚀 Быстрый старт

### 📥 Обновление проекта

#### Для macOS:
```bash
# Сделать скрипт исполняемым
chmod +x update_and_open.sh

# Запустить скрипт
./update_and_open.sh
```

#### Для Windows:
```powershell
# Запустить PowerShell скрипт
.\update_and_open.ps1
```

### 🚀 Пуш в feature ветку с CI/CD

#### Для macOS/Linux:
```bash
# Сделать скрипт исполняемым
chmod +x push_feature.sh

# Запустить скрипт
./push_feature.sh
```

#### Для Windows PowerShell:
```powershell
# Запустить PowerShell скрипт
.\push_feature.ps1

# Или простую версию без эмодзи (если проблемы с кодировкой)
.\push_feature_simple.ps1
```

#### Для Windows Command Prompt:
```cmd
# Запустить batch скрипт
push_feature.bat

# Или простую версию без эмодзи (если проблемы с кодировкой)
push_feature_simple.bat
```

## 📋 Что делают скрипты

### 📥 Скрипты обновления (update_and_open.*)
1. **🔍 Проверяют** git репозиторий
2. **📥 Получают** изменения с удаленного репозитория
3. **💾 Сохраняют** локальные изменения (если есть)
4. **🔄 Обновляют** проект до последней версии
5. **📤 Восстанавливают** локальные изменения
6. **🖥️ Открывают** проект в Xcode

### 🚀 Скрипты пуша в feature ветку (push_feature.*)
1. **🔍 Проверяют** git репозиторий и текущую ветку
2. **⚠️ Предупреждают** если не в feature ветке
3. **📝 Анализируют** изменения в репозитории
4. **📦 Добавляют** все изменения в staging area
5. **💬 Запрашивают** сообщение коммита
6. **💾 Создают** коммит с изменениями
7. **📥 Получают** изменения с удаленного репозитория
8. **🔄 Выполняют** rebase если необходимо
9. **🚀 Пушат** изменения в удаленную ветку
10. **🔄 Запускают** CI/CD пайплайн автоматически
11. **🔗 Открывают** GitHub Actions в браузере
12. **📊 Показывают** информацию о ветке и коммите

## 🛠️ Требования

- **Git** установлен и настроен
- **Xcode** (для macOS)
- **PowerShell** (для Windows)

## 📁 Структура файлов

```
FoodDiaryTwo/
├── update_and_open.sh      # Скрипт обновления для macOS/Linux
├── update_and_open.ps1     # Скрипт обновления для Windows PowerShell
├── push_feature.sh         # Скрипт пуша в feature для macOS/Linux
├── push_feature.ps1        # Скрипт пуша в feature для Windows PowerShell
├── push_feature.bat        # Скрипт пуша в feature для Windows CMD
├── push_feature_simple.ps1 # Простая версия PowerShell без эмодзи
├── push_feature_simple.bat # Простая версия CMD без эмодзи
├── README_SCRIPTS.md       # Этот файл
└── FoodDiaryTwo.xcodeproj  # Проект Xcode
```

## 🔧 Настройка

### Автоматический запуск (macOS):
1. Откройте **Automator**
2. Создайте новое **Quick Action**
3. Добавьте действие **Run Shell Script**
4. Вставьте путь к скрипту: `/path/to/FoodDiaryTwo/update_and_open.sh`
5. Сохраните как **Quick Action**

### Создание алиасов (macOS):
Добавьте в `~/.zshrc` или `~/.bash_profile`:
```bash
alias update-fooddiary="cd /path/to/FoodDiaryTwo && ./update_and_open.sh"
alias push-feature="cd /path/to/FoodDiaryTwo && ./push_feature.sh"
```

## 💡 Примеры использования

### 🔄 Типичный workflow разработки:

1. **Обновление проекта**:
   ```bash
   ./update_and_open.sh
   ```

2. **Создание feature ветки**:
   ```bash
   git checkout -b feature/new-feature
   ```

3. **Разработка и коммиты**:
   ```bash
   # Вносите изменения в код
   git add .
   git commit -m "feat: добавить новую функцию"
   ```

4. **Пуш в feature ветку с CI/CD**:
   ```bash
   ./push_feature.sh
   ```

5. **Создание Pull Request**:
   - Скрипт автоматически откроет GitHub Actions
   - После успешного прохождения тестов создайте PR
   - Проведите code review
   - Выполните merge в main ветку

### 🚀 Автоматизация с CI/CD:

Скрипты `push_feature.*` автоматически:
- ✅ Проверяют, что вы в feature ветке
- ✅ Добавляют все изменения
- ✅ Создают коммит с вашим сообщением
- ✅ Синхронизируются с удаленным репозиторием
- ✅ Пушат изменения
- ✅ Запускают CI/CD пайплайн
- ✅ Открывают GitHub Actions в браузере

## ⚠️ Важные замечания

### 📥 Скрипты обновления:
- **Локальные изменения** автоматически сохраняются в git stash
- **Несохраненные изменения** в Xcode могут быть потеряны
- **Всегда коммитьте** важные изменения перед запуском скрипта

### 🚀 Скрипты пуша в feature:
- **Feature ветки**: Рекомендуется работать в ветках `feature/your-feature-name`
- **Коммиты**: Всегда пишите осмысленные сообщения коммитов
- **Rebase**: Скрипт автоматически выполняет rebase при необходимости
- **CI/CD**: Убедитесь, что настроены GitHub Actions или другие CI/CD системы
- **Конфликты**: При конфликтах rebase разрешите их вручную

## 🆘 Устранение проблем

### Ошибка "Permission denied":
```bash
chmod +x update_and_open.sh
chmod +x push_feature.sh
```

### Ошибка "git command not found":
Установите Git с [git-scm.com](https://git-scm.com)

### Ошибка "xcodebuild command not found":
Установите Xcode из App Store

### Ошибка "You are not in a feature branch":
```bash
# Создайте feature ветку
git checkout -b feature/your-feature-name

# Или переключитесь на существующую
git checkout feature/existing-feature
```

### Ошибка "Rebase conflicts":
```bash
# Разрешите конфликты вручную
git status
# Отредактируйте файлы с конфликтами
git add .
git rebase --continue
```

### Ошибка "Push failed":
- Проверьте подключение к интернету
- Убедитесь, что у вас есть права на запись в репозиторий
- Проверьте, что удаленная ветка существует

### Проблемы с кодировкой в Windows:
Если видите символы типа "ЁЯЪА" или "╨Я╤Г╨И", используйте простые версии скриптов:
```cmd
# Вместо push_feature.bat используйте:
push_feature_simple.bat

# Вместо push_feature.ps1 используйте:
.\push_feature_simple.ps1
```

### Ошибка "Execution Policy" в PowerShell:
```powershell
# Разрешите выполнение скриптов
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Или запустите скрипт напрямую
powershell -ExecutionPolicy Bypass -File push_feature_simple.ps1
```

## 📞 Поддержка

При возникновении проблем:
1. Проверьте, что Git настроен правильно
2. Убедитесь, что у вас есть доступ к удаленному репозиторию
3. Проверьте права доступа к файлам

---

**🎯 Цель**: Упростить процесс разработки с автоматическим обновлением проекта, пушем в feature ветки и запуском CI/CD пайплайнов!
