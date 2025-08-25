//
//  LocalizationManager.swift
//  FoodDiaryTwo
//
//  Created by Emil Svetlichnyy on 10.08.2025.
//

import Foundation
import SwiftUI

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: Language = .english
    
    private init() {
        // Загружаем сохраненный язык
        if let savedLanguage = UserDefaults.standard.string(forKey: "selectedLanguage"),
           let language = Language(rawValue: savedLanguage) {
            currentLanguage = language
        }
    }
    
    func setLanguage(_ language: Language) {
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "selectedLanguage")
    }
    
    func localizedString(_ key: LocalizationKey) -> String {
        return key.localizedString(for: currentLanguage)
    }
}

enum Language: String, CaseIterable {
    case english = "en"
    case russian = "ru"
    case ukrainian = "uk"
    case spanish = "es"
    case french = "fr"
    
    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .russian:
            return "Русский"
        case .ukrainian:
            return "Українська"
        case .spanish:
            return "Español"
        case .french:
            return "Français"
        }
    }
    
    var flag: String {
        switch self {
        case .english:
            return "🇺🇸"
        case .russian:
            return "🇷🇺"
        case .ukrainian:
            return "🇺🇦"
        case .spanish:
            return "🇪🇸"
        case .french:
            return "🇫🇷"
        }
    }
}

enum LocalizationKey: String, CaseIterable {
    // Общие
    case appName = "app_name"
    case ok = "ok"
    case cancel = "cancel"
    case save = "save"
    case delete = "delete"
    case edit = "edit"
    case add = "add"
    case search = "search"
    case timeLabel = "time_label"
    case items = "items"
    case calUnit = "cal_unit"
    
    // Навигация
    case home = "home"
    case stats = "stats"
    case profile = "profile"
    case settings = "settings"
    case history = "history"
    
    // Дневник питания
    case foodDiary = "food_diary"
    case addMeal = "add_meal"
    case mealName = "meal_name"
    case mealType = "meal_type"
    case mealTime = "meal_time"
    case notes = "notes"
    case totalCaloriesToday = "total_calories_today"
    case todaysMeals = "todays_meals"
    case quickActions = "quick_actions"
    case aiRecommendations = "ai_recommendations"
    case noMealsToday = "no_meals_today"
    case startTrackingHint = "start_tracking_hint"
    case addMealCta = "add_meal_cta"
    
    // Типы приемов пищи
    case breakfast = "breakfast"
    case lunch = "lunch"
    case dinner = "dinner"
    case snack = "snack"
    
    // Продукты
    case products = "products"
    case addProduct = "add_product"
    case productName = "product_name"
    case brand = "brand"
    case servingSize = "serving_size"
    case calories = "calories"
    case protein = "protein"
    case carbs = "carbs"
    case fat = "fat"
    case fiber = "fiber"
    case sugar = "sugar"
    case sodium = "sodium"
    
    // Статистика
    case dailyProgress = "daily_progress"
    case totalCalories = "total_calories"
    case dailyGoal = "daily_goal"
    case remaining = "remaining"
    case progress = "progress"
    case goalLabel = "goal_label"

    // Профиль
    case editProfile = "edit_profile"
    case allTime = "all_time"
    case mealsLabel = "meals_label"
    case avgPerDay = "avg_per_day"
    case achievements = "achievements"
    case unlockedFormat = "unlocked_format" // expects %d/%d
    case editDailyCalories = "edit_daily_calories"
    case runQuestionnaire = "run_questionnaire"
    case profileSummary = "profile_summary"
    case heightLabel = "height_label"
    case weightLabel = "weight_label"
    case bmiLabel = "bmi_label"
    case ageLabel = "age_label"
    case yearsSuffix = "years_suffix"
    case cmUnit = "cm_unit"
    case kgUnit = "kg_unit"
    case profilePhoto = "profile_photo"
    case tapToChangePhoto = "tap_to_change_photo"
    case firstName = "first_name"
    case lastName = "last_name"
    case emailAddress = "email_address"
    case enterFirstName = "enter_first_name"
    case enterLastName = "enter_last_name"
    case enterEmail = "enter_email"

    // AddMeal photo actions
    case recognizeCalories = "recognize_calories"
    case photoReady = "photo_ready"
    case pickFromGallery = "pick_from_gallery"
    case takePhoto = "take_photo"
    case photoHint = "photo_hint"

    // Статистика (доп.)
    case statisticsTitle = "statistics_title"
    case nutritionInsights = "nutrition_insights"
    case caloriesOverTime = "calories_over_time"
    case loadingData = "loading_data"
    case noDataForPeriod = "no_data_for_period"
    case monthlyActivity = "monthly_activity"
    case additionalInsights = "additional_insights"
    case unlocked = "unlocked"
    case mostCommonMeal = "most_common_meal"
    case mostCaloricMeal = "most_caloric_meal"
    case bestDay = "best_day"
    case currentStreak = "current_streak"
    case daysInARow = "days_in_a_row"
    case averageDailyCalories = "average_daily_calories"
    case goalAchievement = "goal_achievement"
    case maxLabel = "max_label"
    
    // Профиль пользователя
    case userName = "user_name"
    case age = "age"
    case gender = "gender"
    case height = "height"
    case weight = "weight"
    case activityLevel = "activity_level"
    case goal = "goal"
    
    // Цели
    case loseWeight = "lose_weight"
    case maintainWeight = "maintain_weight"
    case gainWeight = "gain_weight"
    
    // Уровни активности
    case sedentary = "sedentary"
    case light = "light"
    case moderate = "moderate"
    case active = "active"
    case veryActive = "very_active"
    
    func localizedString(for language: Language) -> String {
        switch language {
        case .english:
            return englishStrings[self] ?? rawValue
        case .russian:
            return russianStrings[self] ?? rawValue
        case .ukrainian:
            return ukrainianStrings[self] ?? rawValue
        case .spanish:
            return spanishStrings[self] ?? rawValue
        case .french:
            return frenchStrings[self] ?? rawValue
        }
    }
    
    private var englishStrings: [LocalizationKey: String] {
        [
            .appName: "Food Diary",
            .ok: "OK",
            .cancel: "Cancel",
            .save: "Save",
            .delete: "Delete",
            .edit: "Edit",
            .add: "Add",
            .search: "Search",
            .timeLabel: "Time",
            .items: "items",
            .calUnit: "cal",
            .home: "Home",
            .stats: "Stats",
            .profile: "Profile",
            .settings: "Settings",
            .history: "History",
            .foodDiary: "Food Diary",
            .addMeal: "Add Meal",
            .mealName: "Meal Name",
            .mealType: "Meal Type",
            .mealTime: "Meal Time",
            .notes: "Notes",
            .totalCaloriesToday: "Total calories today",
            .todaysMeals: "Today's Meals",
            .quickActions: "Quick Actions",
            .aiRecommendations: "AI Recommendations",
            .noMealsToday: "No meals yet today",
            .startTrackingHint: "Start tracking your nutrition by adding your first meal",
            .addMealCta: "Add Meal",
            .breakfast: "Breakfast",
            .lunch: "Lunch",
            .dinner: "Dinner",
            .snack: "Snack",
            .products: "Products",
            .addProduct: "Add Product",
            .productName: "Product Name",
            .brand: "Brand",
            .servingSize: "Serving Size",
            .calories: "Calories",
            .protein: "Protein",
            .carbs: "Carbs",
            .fat: "Fat",
            .fiber: "Fiber",
            .sugar: "Sugar",
            .sodium: "Sodium",
            .dailyProgress: "Daily Progress",
            .totalCalories: "Total Calories",
            .dailyGoal: "Daily Goal",
            .remaining: "Remaining",
            .progress: "Progress",
            .goalLabel: "Goal",
            .userName: "Name",
            .age: "Age",
            .gender: "Gender",
            .height: "Height",
            .weight: "Weight",
            .activityLevel: "Activity Level",
            .goal: "Goal",
            .loseWeight: "Lose Weight",
            .maintainWeight: "Maintain Weight",
            .gainWeight: "Gain Weight",
            .sedentary: "Sedentary",
            .light: "Light",
            .moderate: "Moderate",
            .active: "Active",
            .veryActive: "Very Active",
            .editProfile: "Edit Profile",
            .allTime: "All-time",
            .mealsLabel: "Meals",
            .avgPerDay: "Avg/Day",
            .achievements: "Achievements",
            .unlockedFormat: "Unlocked: %d/%d",
            .editDailyCalories: "Edit Daily Calories",
            .runQuestionnaire: "Run Questionnaire",
            .profileSummary: "Profile Summary",
            .heightLabel: "Height",
            .weightLabel: "Weight",
            .bmiLabel: "BMI",
            .ageLabel: "Age",
            .yearsSuffix: "years",
            .cmUnit: "cm",
            .kgUnit: "kg",
            .profilePhoto: "Profile Photo",
            .tapToChangePhoto: "Tap to change photo",
            .firstName: "First Name",
            .lastName: "Last Name",
            .emailAddress: "Email",
            .enterFirstName: "Enter first name",
            .enterLastName: "Enter last name",
            .enterEmail: "Enter email address",
            .recognizeCalories: "Recognize Calories",
            .photoReady: "Photo is ready for analysis",
            .pickFromGallery: "Pick from Gallery",
            .takePhoto: "Take Photo",
            .photoHint: "Photograph food to auto-detect calories and macros",
            .statisticsTitle: "Statistics",
            .nutritionInsights: "Your nutrition insights",
            .caloriesOverTime: "Calories Over Time",
            .loadingData: "Loading data...",
            .noDataForPeriod: "No data for this period",
            .monthlyActivity: "Monthly Activity",
            .additionalInsights: "Additional Insights",
            .unlocked: "Unlocked",
            .mostCommonMeal: "Most Common Meal",
            .mostCaloricMeal: "Most Caloric Meal",
            .bestDay: "Best Day",
            .currentStreak: "Current Streak",
            .daysInARow: "days in a row",
            .averageDailyCalories: "Average Daily Calories",
            .goalAchievement: "Goal Achievement",
            .maxLabel: "Max"
        ]
    }
    
    private var russianStrings: [LocalizationKey: String] {
        [
            .appName: "Дневник Питания",
            .ok: "ОК",
            .cancel: "Отмена",
            .save: "Сохранить",
            .delete: "Удалить",
            .edit: "Изменить",
            .add: "Добавить",
            .search: "Поиск",
            .timeLabel: "Время",
            .items: "элементов",
            .calUnit: "ккал",
            .home: "Главная",
            .stats: "Статистика",
            .profile: "Профиль",
            .settings: "Настройки",
            .history: "История",
            .foodDiary: "Дневник Питания",
            .addMeal: "Добавить Прием Пищи",
            .mealName: "Название Приема",
            .mealType: "Тип Приема",
            .mealTime: "Время Приема",
            .notes: "Заметки",
            .totalCaloriesToday: "Всего калорий сегодня",
            .todaysMeals: "Сегодняшние приемы пищи",
            .quickActions: "Быстрые действия",
            .aiRecommendations: "Рекомендации ИИ",
            .noMealsToday: "Сегодня еще нет приемов пищи",
            .startTrackingHint: "Начните вести дневник питания, добавив первый прием",
            .addMealCta: "Добавить прием",
            .breakfast: "Завтрак",
            .lunch: "Обед",
            .dinner: "Ужин",
            .snack: "Перекус",
            .products: "Продукты",
            .addProduct: "Добавить Продукт",
            .productName: "Название Продукта",
            .brand: "Бренд",
            .servingSize: "Размер Порции",
            .calories: "Калории",
            .protein: "Белки",
            .carbs: "Углеводы",
            .fat: "Жиры",
            .fiber: "Клетчатка",
            .sugar: "Сахар",
            .sodium: "Натрий",
            .dailyProgress: "Дневной Прогресс",
            .totalCalories: "Общие Калории",
            .dailyGoal: "Дневная Цель",
            .remaining: "Осталось",
            .progress: "Прогресс",
            .goalLabel: "Цель",
            .userName: "Имя",
            .age: "Возраст",
            .gender: "Пол",
            .height: "Рост",
            .weight: "Вес",
            .activityLevel: "Уровень Активности",
            .goal: "Цель",
            .loseWeight: "Похудеть",
            .maintainWeight: "Поддержать Вес",
            .gainWeight: "Набрать Вес",
            .sedentary: "Сидячий",
            .light: "Легкий",
            .moderate: "Умеренный",
            .active: "Активный",
            .veryActive: "Очень Активный",
            .editProfile: "Редактировать профиль",
            .allTime: "За все время",
            .mealsLabel: "Приемы",
            .avgPerDay: "В ср./день",
            .achievements: "Достижения",
            .unlockedFormat: "Открыто: %d/%d",
            .editDailyCalories: "Редактировать дневные калории",
            .runQuestionnaire: "Пройти анкету",
            .profileSummary: "Сводка профиля",
            .heightLabel: "Рост",
            .weightLabel: "Вес",
            .bmiLabel: "ИМТ",
            .ageLabel: "Возраст",
            .yearsSuffix: "лет",
            .cmUnit: "см",
            .kgUnit: "кг",
            .profilePhoto: "Фото профиля",
            .tapToChangePhoto: "Нажмите, чтобы изменить фото",
            .firstName: "Имя",
            .lastName: "Фамилия",
            .emailAddress: "Email",
            .enterFirstName: "Введите имя",
            .enterLastName: "Введите фамилию",
            .enterEmail: "Введите email",
            .recognizeCalories: "Распознать калории",
            .photoReady: "Фото готово для анализа",
            .pickFromGallery: "Выбрать из галереи",
            .takePhoto: "Сделать фото",
            .photoHint: "Сфотографируйте еду для авто-распознавания калорий и БЖУ",
            .statisticsTitle: "Статистика",
            .nutritionInsights: "Ваши инсайты питания",
            .caloriesOverTime: "Калории со временем",
            .loadingData: "Загрузка данных...",
            .noDataForPeriod: "Нет данных за этот период",
            .monthlyActivity: "Месячная активность",
            .additionalInsights: "Дополнительные сведения",
            .unlocked: "Открыто",
            .mostCommonMeal: "Самый частый прием",
            .mostCaloricMeal: "Самый калорийный прием",
            .bestDay: "Лучший день",
            .currentStreak: "Текущая серия",
            .daysInARow: "дней подряд",
            .averageDailyCalories: "Средние дневные калории",
            .goalAchievement: "Достижение цели",
            .maxLabel: "Макс"
        ]
    }
    
    private var ukrainianStrings: [LocalizationKey: String] {
        [
            .appName: "Щоденник Харчування",
            .ok: "ОК",
            .cancel: "Скасувати",
            .save: "Зберегти",
            .delete: "Видалити",
            .edit: "Змінити",
            .add: "Додати",
            .search: "Пошук",
            .timeLabel: "Час",
            .items: "елементів",
            .calUnit: "ккал",
            .home: "Головна",
            .stats: "Статистика",
            .profile: "Профіль",
            .settings: "Налаштування",
            .history: "Історія",
            .foodDiary: "Щоденник Харчування",
            .addMeal: "Додати Прийом Їжі",
            .mealName: "Назва Прийому",
            .mealType: "Тип Прийому",
            .mealTime: "Час Прийому",
            .notes: "Нотатки",
            .totalCaloriesToday: "Всього калорій сьогодні",
            .todaysMeals: "Сьогоднішні прийоми їжі",
            .quickActions: "Швидкі дії",
            .aiRecommendations: "Рекомендації ШІ",
            .noMealsToday: "Сьогодні ще немає прийомів їжі",
            .startTrackingHint: "Почніть вести щоденник, додавши перший прийом",
            .addMealCta: "Додати прийом",
            .breakfast: "Сніданок",
            .lunch: "Обід",
            .dinner: "Вечеря",
            .snack: "Перекус",
            .products: "Продукти",
            .addProduct: "Додати Продукт",
            .productName: "Назва Продукту",
            .brand: "Бренд",
            .servingSize: "Розмір Порції",
            .calories: "Калорії",
            .protein: "Білки",
            .carbs: "Вуглеводи",
            .fat: "Жири",
            .fiber: "Клітковина",
            .sugar: "Цукор",
            .sodium: "Натрій",
            .dailyProgress: "Денний Прогрес",
            .totalCalories: "Загальні Калорії",
            .dailyGoal: "Денна Мета",
            .remaining: "Залишилось",
            .progress: "Прогрес",
            .goalLabel: "Мета",
            .userName: "Ім'я",
            .age: "Вік",
            .gender: "Стать",
            .height: "Зріст",
            .weight: "Вага",
            .activityLevel: "Рівень Активності",
            .goal: "Мета",
            .loseWeight: "Схуднути",
            .maintainWeight: "Підтримувати Вагу",
            .gainWeight: "Набрати Вагу",
            .sedentary: "Сидячий",
            .light: "Легкий",
            .moderate: "Помірний",
            .active: "Активний",
            .veryActive: "Дуже Активний",
            .editProfile: "Редагувати профіль",
            .allTime: "За весь час",
            .mealsLabel: "Прийоми",
            .avgPerDay: "Сер./день",
            .achievements: "Досягнення",
            .unlockedFormat: "Відкрито: %d/%d",
            .editDailyCalories: "Редагувати денні калорії",
            .runQuestionnaire: "Пройти анкету",
            .profileSummary: "Підсумок профілю",
            .heightLabel: "Зріст",
            .weightLabel: "Вага",
            .bmiLabel: "ІМТ",
            .ageLabel: "Вік",
            .yearsSuffix: "років",
            .cmUnit: "см",
            .kgUnit: "кг",
            .profilePhoto: "Фото профілю",
            .tapToChangePhoto: "Торкніться, щоб змінити фото",
            .firstName: "Ім'я",
            .lastName: "Прізвище",
            .emailAddress: "Email",
            .enterFirstName: "Введіть ім'я",
            .enterLastName: "Введіть прізвище",
            .enterEmail: "Введіть email",
            .recognizeCalories: "Розпізнати калорії",
            .photoReady: "Фото готове до аналізу",
            .pickFromGallery: "Обрати з галереї",
            .takePhoto: "Зробити фото",
            .photoHint: "Зфотографуйте їжу для авто-розпізнавання калорій та БЖВ",
            .statisticsTitle: "Статистика",
            .nutritionInsights: "Ваші інсайти харчування",
            .caloriesOverTime: "Калорії з часом",
            .loadingData: "Завантаження даних...",
            .noDataForPeriod: "Немає даних за цей період",
            .monthlyActivity: "Місячна активність",
            .additionalInsights: "Додаткові відомості",
            .unlocked: "Відкрито",
            .mostCommonMeal: "Найчастіший прийом",
            .mostCaloricMeal: "Найкалорійніший прийом",
            .bestDay: "Найкращий день",
            .currentStreak: "Поточна серія",
            .daysInARow: "днів поспіль",
            .averageDailyCalories: "Середні денні калорії",
            .goalAchievement: "Досягнення цілі",
            .maxLabel: "Макс"
        ]
    }

    private var spanishStrings: [LocalizationKey: String] {
        [
            .appName: "Diario de Comida",
            .ok: "OK",
            .cancel: "Cancelar",
            .save: "Guardar",
            .delete: "Eliminar",
            .edit: "Editar",
            .add: "Añadir",
            .search: "Buscar",
            .timeLabel: "Hora",
            .items: "elementos",
            .calUnit: "kcal",
            .home: "Inicio",
            .stats: "Estadísticas",
            .profile: "Perfil",
            .settings: "Ajustes",
            .history: "Historial",
            .foodDiary: "Diario de Comida",
            .addMeal: "Añadir comida",
            .mealName: "Nombre de la comida",
            .mealType: "Tipo de comida",
            .mealTime: "Hora de la comida",
            .notes: "Notas",
            .totalCaloriesToday: "Calorías totales hoy",
            .todaysMeals: "Comidas de hoy",
            .quickActions: "Acciones rápidas",
            .aiRecommendations: "Recomendaciones IA",
            .noMealsToday: "Aún no hay comidas hoy",
            .startTrackingHint: "Empieza a registrar tu alimentación añadiendo tu primera comida",
            .addMealCta: "Añadir comida",
            .breakfast: "Desayuno",
            .lunch: "Almuerzo",
            .dinner: "Cena",
            .snack: "Snack",
            .products: "Productos",
            .addProduct: "Añadir producto",
            .productName: "Nombre del producto",
            .brand: "Marca",
            .servingSize: "Tamaño de porción",
            .calories: "Calorías",
            .protein: "Proteínas",
            .carbs: "Carbohidratos",
            .fat: "Grasas",
            .fiber: "Fibra",
            .sugar: "Azúcar",
            .sodium: "Sodio",
            .dailyProgress: "Progreso diario",
            .totalCalories: "Calorías totales",
            .dailyGoal: "Meta diaria",
            .remaining: "Restante",
            .progress: "Progreso",
            .goalLabel: "Meta",
            .userName: "Nombre",
            .age: "Edad",
            .gender: "Género",
            .height: "Altura",
            .weight: "Peso",
            .activityLevel: "Nivel de actividad",
            .goal: "Objetivo",
            .loseWeight: "Perder peso",
            .maintainWeight: "Mantener peso",
            .gainWeight: "Ganar peso",
            .sedentary: "Sedentario",
            .light: "Ligero",
            .moderate: "Moderado",
            .active: "Activo",
            .veryActive: "Muy activo",
            .editProfile: "Editar perfil",
            .allTime: "Todo el tiempo",
            .mealsLabel: "Comidas",
            .avgPerDay: "Prom./día",
            .achievements: "Logros",
            .unlockedFormat: "Desbloqueados: %d/%d",
            .editDailyCalories: "Editar calorías diarias",
            .runQuestionnaire: "Realizar cuestionario",
            .profileSummary: "Resumen del perfil",
            .heightLabel: "Altura",
            .weightLabel: "Peso",
            .bmiLabel: "IMC",
            .ageLabel: "Edad",
            .yearsSuffix: "años",
            .cmUnit: "cm",
            .kgUnit: "kg",
            .profilePhoto: "Foto de perfil",
            .tapToChangePhoto: "Toca para cambiar la foto",
            .firstName: "Nombre",
            .lastName: "Apellido",
            .emailAddress: "Email",
            .enterFirstName: "Introduce el nombre",
            .enterLastName: "Introduce el apellido",
            .enterEmail: "Introduce el email",
            .recognizeCalories: "Reconocer calorías",
            .photoReady: "La foto está lista para analizar",
            .pickFromGallery: "Elegir de la galería",
            .takePhoto: "Tomar foto",
            .photoHint: "Fotografía la comida para detectar calorías y macros",
            .statisticsTitle: "Estadísticas",
            .nutritionInsights: "Tus insights de nutrición",
            .caloriesOverTime: "Calorías en el tiempo",
            .loadingData: "Cargando datos...",
            .noDataForPeriod: "No hay datos para este período",
            .monthlyActivity: "Actividad mensual",
            .additionalInsights: "Insights adicionales",
            .unlocked: "Desbloqueado",
            .mostCommonMeal: "Comida más común",
            .mostCaloricMeal: "Comida más calórica",
            .bestDay: "Mejor día",
            .currentStreak: "Racha actual",
            .daysInARow: "días seguidos",
            .averageDailyCalories: "Calorías diarias promedio",
            .goalAchievement: "Logro de la meta",
            .maxLabel: "Máx"
        ]
    }

    private var frenchStrings: [LocalizationKey: String] {
        [
            .appName: "Journal Alimentaire",
            .ok: "OK",
            .cancel: "Annuler",
            .save: "Enregistrer",
            .delete: "Supprimer",
            .edit: "Modifier",
            .add: "Ajouter",
            .search: "Rechercher",
            .timeLabel: "Heure",
            .items: "éléments",
            .calUnit: "kcal",
            .home: "Accueil",
            .stats: "Stats",
            .profile: "Profil",
            .settings: "Réglages",
            .history: "Historique",
            .foodDiary: "Journal alimentaire",
            .addMeal: "Ajouter un repas",
            .mealName: "Nom du repas",
            .mealType: "Type de repas",
            .mealTime: "Heure du repas",
            .notes: "Notes",
            .totalCaloriesToday: "Calories totales aujourd'hui",
            .todaysMeals: "Repas du jour",
            .quickActions: "Actions rapides",
            .aiRecommendations: "Recommandations IA",
            .noMealsToday: "Aucun repas aujourd'hui",
            .startTrackingHint: "Commencez à suivre votre alimentation en ajoutant un premier repas",
            .addMealCta: "Ajouter un repas",
            .breakfast: "Petit-déjeuner",
            .lunch: "Déjeuner",
            .dinner: "Dîner",
            .snack: "Snack",
            .products: "Produits",
            .addProduct: "Ajouter un produit",
            .productName: "Nom du produit",
            .brand: "Marque",
            .servingSize: "Taille de portion",
            .calories: "Calories",
            .protein: "Protéines",
            .carbs: "Glucides",
            .fat: "Lipides",
            .fiber: "Fibres",
            .sugar: "Sucre",
            .sodium: "Sodium",
            .dailyProgress: "Progression quotidienne",
            .totalCalories: "Calories totales",
            .dailyGoal: "Objectif quotidien",
            .remaining: "Restant",
            .progress: "Progression",
            .goalLabel: "Objectif",
            .userName: "Nom",
            .age: "Âge",
            .gender: "Sexe",
            .height: "Taille",
            .weight: "Poids",
            .activityLevel: "Niveau d'activité",
            .goal: "Objectif",
            .loseWeight: "Perdre du poids",
            .maintainWeight: "Maintenir le poids",
            .gainWeight: "Prendre du poids",
            .sedentary: "Sédentaire",
            .light: "Léger",
            .moderate: "Modéré",
            .active: "Actif",
            .veryActive: "Très actif",
            .editProfile: "Modifier le profil",
            .allTime: "Tout temps",
            .mealsLabel: "Repas",
            .avgPerDay: "Moy./jour",
            .achievements: "Succès",
            .unlockedFormat: "Déverrouillés : %d/%d",
            .editDailyCalories: "Modifier calories quotidiennes",
            .runQuestionnaire: "Remplir le questionnaire",
            .profileSummary: "Résumé du profil",
            .heightLabel: "Taille",
            .weightLabel: "Poids",
            .bmiLabel: "IMC",
            .ageLabel: "Âge",
            .yearsSuffix: "ans",
            .cmUnit: "cm",
            .kgUnit: "kg",
            .profilePhoto: "Photo de profil",
            .tapToChangePhoto: "Touchez pour changer la photo",
            .firstName: "Prénom",
            .lastName: "Nom",
            .emailAddress: "Email",
            .enterFirstName: "Entrez le prénom",
            .enterLastName: "Entrez le nom",
            .enterEmail: "Entrez l'email",
            .recognizeCalories: "Reconnaître les calories",
            .photoReady: "La photo est prête pour l'analyse",
            .pickFromGallery: "Choisir depuis la galerie",
            .takePhoto: "Prendre une photo",
            .photoHint: "Photographiez la nourriture pour détecter calories et macros",
            .statisticsTitle: "Statistiques",
            .nutritionInsights: "Vos analyses nutritionnelles",
            .caloriesOverTime: "Calories dans le temps",
            .loadingData: "Chargement des données...",
            .noDataForPeriod: "Aucune donnée pour cette période",
            .monthlyActivity: "Activité mensuelle",
            .additionalInsights: "Analyses supplémentaires",
            .unlocked: "Déverrouillé",
            .mostCommonMeal: "Repas le plus fréquent",
            .mostCaloricMeal: "Repas le plus calorique",
            .bestDay: "Meilleure journée",
            .currentStreak: "Série actuelle",
            .daysInARow: "jours d'affilée",
            .averageDailyCalories: "Calories quotidiennes moyennes",
            .goalAchievement: "Atteinte de l'objectif",
            .maxLabel: "Max"
        ]
    }
}
