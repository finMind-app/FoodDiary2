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
            .veryActive: "Very Active"
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
            .veryActive: "Очень Активный"
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
            .veryActive: "Дуже Активний"
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
            .veryActive: "Muy activo"
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
            .veryActive: "Très actif"
        ]
    }
}
