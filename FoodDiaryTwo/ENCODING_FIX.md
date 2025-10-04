# 🔧 Решение проблемы с кодировкой в Windows

## ❌ Проблема

При запуске скриптов в Windows Command Prompt вы видите символы типа:
```
ЁЯЪА ╨Я╤Г╨И ╨▓ feature ╨▓╨╡╤В╨║╤Г ╤Б ╨╖╨░╨┐╤Г╤Б╨║╨╛╨╝ CI/CD...
тЭМ ╨Ю╤И╨╕╨▒╨║╨░: ╨Я╨░╨┐╨║╨░ ╨╜╨╡ ╤П╨▓╨╗╤П╨╡╤В╤Б╤П git ╤А╨╡╨┐╨╛╨╖╨╕╤В╨╛╤А╨╕╨╡╨╝
```

## ✅ Решение

Используйте **простые версии скриптов** без эмодзи:

### Для Windows Command Prompt:
```cmd
push_feature_simple.bat
```

### Для Windows PowerShell:
```powershell
.\push_feature_simple.ps1
```

## 🔍 Причина проблемы

- Windows Command Prompt не поддерживает эмодзи и Unicode символы
- PowerShell может отображать эмодзи, но не всегда корректно
- Простые версии используют только ASCII символы

## 📋 Доступные версии скриптов

### С эмодзи (красивые, но могут не работать в CMD):
- `push_feature.ps1` - PowerShell с эмодзи
- `push_feature.bat` - CMD с эмодзи
- `push_feature.sh` - Bash с эмодзи (macOS/Linux)

### Без эмодзи (совместимые со всеми системами):
- `push_feature_simple.ps1` - PowerShell без эмодзи
- `push_feature_simple.bat` - CMD без эмодзи

## 🚀 Рекомендации

1. **Для Windows CMD**: Используйте `push_feature_simple.bat`
2. **Для Windows PowerShell**: Попробуйте сначала `push_feature.ps1`, если не работает - `push_feature_simple.ps1`
3. **Для macOS/Linux**: Используйте `push_feature.sh`

## 💡 Дополнительные решения

### Если PowerShell не запускается:
```powershell
# Разрешите выполнение скриптов
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Или запустите напрямую
powershell -ExecutionPolicy Bypass -File push_feature_simple.ps1
```

### Если все еще проблемы:
1. Убедитесь, что Git установлен и настроен
2. Проверьте, что вы в папке проекта
3. Убедитесь, что папка является git репозиторием

---

**🎯 Теперь скрипты работают на всех системах!**
