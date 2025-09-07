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
    case meals = "meals"
    case less = "less"
    case more = "more"
    
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
    case thisPeriod = "this_period"
    case avgDailyShort = "avg_daily_short"
    case caloriesShortUnit = "calories_short_unit"
    case goalMet = "goal_met"
    case ofDays = "of_days"
    case noneLabel = "none_label"

    // Calorie goal editor
    case dailyCaloriesTitle = "daily_calories_title"
    case setDailyCalorieTarget = "set_daily_calorie_target"
    case exampleCalories = "example_calories"

    // Onboarding
    case close = "close"
    case skip = "skip"
    case next = "next"
    case tellUsAboutYou = "tell_us_about_you"
    case years = "years"
    case heightCm = "height_cm"
    case weightKg = "weight_kg"
    case recommendedDailyCalories = "recommended_daily_calories"
    case recommendedLabel = "recommended_label"
    case customOptional = "custom_optional"
    case summaryTitle = "summary_title"
    case questionnaireTitle = "questionnaire_title"

    // Recognition result
    case analysisResults = "analysis_results"
    case processingTimeSec = "processing_time_sec"
    case generalInfo = "general_info"
    case recognizedProductsTitle = "recognized_products_title"
    case applyToMeal = "apply_to_meal"
    case tryAgain = "try_again"
    case confidenceLabel = "confidence_label"
    case caloriesShort = "calories_short"
    case proteinShort = "protein_short"
    case fatShort = "fat_short"
    case carbsShort = "carbs_short"
    
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
    // Gender labels
    case maleLabel = "male_label"
    case femaleLabel = "female_label"
    case otherLabel = "other_label"
    
    // Settings
    case notifications = "notifications"
    case reminderTime = "reminder_time"
    case calorieReminders = "calorie_reminders"
    case getRemindedAboutGoals = "get_reminded_about_goals"
    case appearance = "appearance"
    case darkMode = "dark_mode"
    case language = "language"
    case region = "region"
    case languageRegion = "language_region"
    case dataManagement = "data_management"
    case exportDataTitle = "export_data_title"
    case exportYourDataOrResetApp = "export_your_data_or_reset_app"
    case clearAllData = "clear_all_data"
    case clearAll = "clear_all"
    case clearAllDataAlertTitle = "clear_all_data_alert_title"
    case clearAllDataAlertMessage = "clear_all_data_alert_message"
    case version = "version"
    case termsOfService = "terms_of_service"
    case privacyPolicy = "privacy_policy"
    case about = "about"
    case done = "done"
    case share = "share"
    
    // History/Calendar
    case week = "week"
    case month = "month"
    case year = "year"
    case custom = "custom"
    case selectDate = "select_date"
    
    // Additional
    case trackJourney = "track_journey"
    case basicInformation = "basic_information"

    // Design system / demo
    case stepLabel = "step_label"
    case primaryBackground = "primary_background"
    case secondaryBackground = "secondary_background"
    case gradientBackground = "gradient_background"
    case patternBackground = "pattern_background"
    case minimalBackground = "minimal_background"
    case chips = "chips"
    case badges = "badges"
    case loadingIndicators = "loading_indicators"
    case cardTitle = "card_title"
    case cardSampleText = "card_sample_text"

    // Recipe feature
    case recipeFromFridgeTitle = "recipe_from_fridge_title"
    case recipeInputPlaceholder = "recipe_input_placeholder"
    case recipeGenerateCta = "recipe_generate_cta"
    case ingredientsTitle = "ingredients_title"
    case stepsTitle = "steps_title"
    case recipeEmptyInputError = "recipe_empty_input_error"
    case recipeModelNoAnswer = "recipe_model_no_answer"
    case recipeRateLimitError = "recipe_rate_limit_error"
    case recipeApiGenericError = "recipe_api_generic_error"

    // Achievements (titles and details)
    case achFirstMealTitle = "ach_first_meal_title"
    case achFirstMealDetail = "ach_first_meal_detail"
    case achFiveMealsTitle = "ach_five_meals_title"
    case achFiveMealsDetail = "ach_five_meals_detail"
    case achTwentyMealsTitle = "ach_twenty_meals_title"
    case achTwentyMealsDetail = "ach_twenty_meals_detail"
    case achHundredMealsTitle = "ach_hundred_meals_title"
    case achHundredMealsDetail = "ach_hundred_meals_detail"
    case achPhotoEntryTitle = "ach_photo_entry_title"
    case achPhotoEntryDetail = "ach_photo_entry_detail"
    case achHealthySnacksTitle = "ach_healthy_snacks_title"
    case achHealthySnacksDetail = "ach_healthy_snacks_detail"
    case achBreakfastEarlyTitle = "ach_breakfast_early_title"
    case achBreakfastEarlyDetail = "ach_breakfast_early_detail"
    case achDinnerLateTitle = "ach_dinner_late_title"
    case achDinnerLateDetail = "ach_dinner_late_detail"
    case achStreak3Title = "ach_streak3_title"
    case achStreak3Detail = "ach_streak3_detail"
    case achStreak7Title = "ach_streak7_title"
    case achStreak7Detail = "ach_streak7_detail"
    case achGoalDayTitle = "ach_goal_day_title"
    case achGoalDayDetail = "ach_goal_day_detail"
    case achGoalWeek4Title = "ach_goal_week4_title"
    case achGoalWeek4Detail = "ach_goal_week4_detail"
    case achProtein100Title = "ach_protein100_title"
    case achProtein100Detail = "ach_protein100_detail"
    case achVeggieDayTitle = "ach_veggie_day_title"
    case achVeggieDayDetail = "ach_veggie_day_detail"
    case achWeek30MealsTitle = "ach_week30_meals_title"
    case achWeek30MealsDetail = "ach_week30_meals_detail"
    case achMonth100MealsTitle = "ach_month100_meals_title"
    case achMonth100MealsDetail = "ach_month100_meals_detail"

    // Recommendations / forecasts
    case recStartBreakfast = "rec_start_breakfast"
    case recAddMoreFood = "rec_add_more_food"
    case recReducePortions = "rec_reduce_portions"
    case recGreatProgress = "rec_great_progress"
    case recAddProtein = "rec_add_protein"
    case recAddCarbs = "rec_add_carbs"
    case recAddFats = "rec_add_fats"
    case recForecastMorning = "rec_forecast_morning"
    case recForecastGoodStart = "rec_forecast_good_start"
    case recForecastExcellent = "rec_forecast_excellent"
    case recForecastHalfDay = "rec_forecast_halfday"
    case recForecastGood = "rec_forecast_good"
    case recForecastGoalReached = "rec_forecast_goal_reached"
    case recForecastEvening = "rec_forecast_evening"
    case recForecastGreatDay = "rec_forecast_great_day"
    case recForecastOverLimit = "rec_forecast_over_limit"
    
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
            .meals: "Meals",
            .less: "Less",
            .more: "More",
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
            .maxLabel: "Max",
            .thisPeriod: "This period",
            .avgDailyShort: "Avg. Daily",
            .caloriesShortUnit: "cal",
            .goalMet: "Goal Met",
            .ofDays: "Of days",
            .noneLabel: "None",
            // Settings
            .notifications: "Notifications",
            .reminderTime: "Reminder Time",
            .calorieReminders: "Calorie Reminders",
            .getRemindedAboutGoals: "Get reminded about your daily goals and meal tracking",
            .appearance: "Appearance",
            .darkMode: "Dark Mode",
            .language: "Language",
            .region: "Region",
            .languageRegion: "Language & Region",
            .dataManagement: "Data Management",
            .exportDataTitle: "Export Data",
            .exportYourDataOrResetApp: "Export your food diary data or reset the app",
            .clearAllData: "Clear All Data",
            .clearAll: "Clear All",
            .clearAllDataAlertTitle: "Clear All Data",
            .clearAllDataAlertMessage: "This will permanently delete all your food diary data. This action cannot be undone.",
            .version: "Version",
            .termsOfService: "Terms of Service",
            .privacyPolicy: "Privacy Policy",
            .about: "About",
            .done: "Done",
            .share: "Share",
            .maleLabel: "Male",
            .femaleLabel: "Female",
            .otherLabel: "Other",
            // History/Calendar
            .week: "Week",
            .month: "Month",
            .year: "Year",
            .custom: "Custom",
            .selectDate: "Select Date",
            // Additional
            .trackJourney: "Track your nutrition journey",
            .basicInformation: "Basic Information",
            .stepLabel: "Step",
            .primaryBackground: "Primary Background",
            .secondaryBackground: "Secondary Background",
            .gradientBackground: "Gradient Background",
            .patternBackground: "Pattern Background",
            .minimalBackground: "Minimal Background",
            .chips: "Chips",
            .badges: "Badges",
            .loadingIndicators: "Loading Indicators",
            .cardTitle: "Card Title",
            .cardSampleText: "This is a sample card with some content to demonstrate the new design system."
            ,
            // Recipe feature
            .recipeFromFridgeTitle: "What to cook from my fridge",
            .recipeInputPlaceholder: "Enter ingredients, comma-separated (e.g., chicken, rice, tomato)",
            .recipeGenerateCta: "Generate Recipe",
            .ingredientsTitle: "Ingredients",
            .stepsTitle: "Steps",
            .recipeEmptyInputError: "Please enter at least one ingredient",
            .recipeModelNoAnswer: "The model didn't return an answer. Try again.",
            .recipeRateLimitError: "Rate limit reached. Please try later.",
            .recipeApiGenericError: "Something went wrong. Please try again.",
            // Achievements
            .achFirstMealTitle: "First Meal",
            .achFirstMealDetail: "Log your very first meal.",
            .achFiveMealsTitle: "Getting Started",
            .achFiveMealsDetail: "Log 5 meals in total.",
            .achTwentyMealsTitle: "Meal Enthusiast",
            .achTwentyMealsDetail: "Log 20 meals in total.",
            .achHundredMealsTitle: "Meal Master",
            .achHundredMealsDetail: "Log 100 meals in total.",
            .achPhotoEntryTitle: "Photo Pro",
            .achPhotoEntryDetail: "Attach a photo to a meal.",
            .achHealthySnacksTitle: "Snack Smart",
            .achHealthySnacksDetail: "Log 10 snacks.",
            .achBreakfastEarlyTitle: "Early Bird",
            .achBreakfastEarlyDetail: "Log a breakfast before 8 AM.",
            .achDinnerLateTitle: "Night Owl",
            .achDinnerLateDetail: "Log a dinner after 9 PM.",
            .achStreak3Title: "3-Day Streak",
            .achStreak3Detail: "Log meals 3 days in a row.",
            .achStreak7Title: "7-Day Streak",
            .achStreak7Detail: "Log meals 7 days in a row.",
            .achGoalDayTitle: "On Target",
            .achGoalDayDetail: "Hit your daily calorie goal.",
            .achGoalWeek4Title: "Consistency",
            .achGoalWeek4Detail: "Hit your goal on 4 days in a week.",
            .achProtein100Title: "Protein Punch",
            .achProtein100Detail: "Reach 100g protein in a day.",
            .achVeggieDayTitle: "Veggie Day",
            .achVeggieDayDetail: "Log 5 different products in a day.",
            .achWeek30MealsTitle: "Busy Week",
            .achWeek30MealsDetail: "Log 30 meals in a week.",
            .achMonth100MealsTitle: "Power Logger",
            .achMonth100MealsDetail: "Log 100 meals in a month.",
            // Recommendations / forecast
            .recStartBreakfast: "Start the day with breakfast! Recommended 400–600 kcal",
            .recAddMoreFood: "Add more food. Remaining %d kcal",
            .recReducePortions: "Consider reducing portions. Over by %d kcal",
            .recGreatProgress: "Great progress! %d kcal remaining to goal",
            .recAddProtein: "Add more protein: meat, fish, eggs, cottage cheese",
            .recAddCarbs: "Add complex carbs: grains, bread, vegetables",
            .recAddFats: "Add healthy fats: nuts, avocado, olive oil",
            .recForecastMorning: "You have %d kcal for the day. Start with a nutritious breakfast!",
            .recForecastGoodStart: "Good start! %d kcal remaining. Plan lunch and dinner",
            .recForecastExcellent: "Excellent progress! Keep it up",
            .recForecastHalfDay: "Half the day passed. %d kcal remaining. Plan dinner",
            .recForecastGood: "Nice! %d kcal remaining to the goal",
            .recForecastGoalReached: "Goal reached! You can have a light snack",
            .recForecastEvening: "Day is ending. %d kcal remaining. Light dinner",
            .recForecastGreatDay: "Great day! You reached your goal",
            .recForecastOverLimit: "Over the limit. Start fresh tomorrow"
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
            .meals: "Приемы",
            .less: "Меньше",
            .more: "Больше",
            .mostCommonMeal: "Самый частый прием",
            .mostCaloricMeal: "Самый калорийный прием",
            .bestDay: "Лучший день",
            .currentStreak: "Текущая серия",
            .daysInARow: "дней подряд",
            .averageDailyCalories: "Средние дневные калории",
            .goalAchievement: "Достижение цели",
            .maxLabel: "Макс",
            .thisPeriod: "Этот период",
            .avgDailyShort: "Ср. в день",
            .caloriesShortUnit: "ккал",
            .goalMet: "Достигнуто",
            .ofDays: "Дней",
            .noneLabel: "Нет",
            // Settings
            .notifications: "Уведомления",
            .reminderTime: "Время напоминания",
            .calorieReminders: "Напоминания о калориях",
            .getRemindedAboutGoals: "Получайте напоминания о целях и ведении дневника",
            .appearance: "Оформление",
            .darkMode: "Темная тема",
            .language: "Язык",
            .region: "Регион",
            .languageRegion: "Язык и регион",
            .dataManagement: "Управление данными",
            .exportDataTitle: "Экспорт данных",
            .exportYourDataOrResetApp: "Экспортируйте данные или сбросьте приложение",
            .clearAllData: "Удалить все данные",
            .clearAll: "Удалить всё",
            .clearAllDataAlertTitle: "Удалить все данные",
            .clearAllDataAlertMessage: "Это навсегда удалит все данные дневника. Действие нельзя отменить.",
            .version: "Версия",
            .termsOfService: "Условия использования",
            .privacyPolicy: "Политика конфиденциальности",
            .about: "О приложении",
            .done: "Готово",
            .share: "Поделиться",
            .maleLabel: "Мужской",
            .femaleLabel: "Женский",
            .otherLabel: "Другое",
            // History/Calendar
            .week: "Неделя",
            .month: "Месяц",
            .year: "Год",
            .custom: "Произвольно",
            .selectDate: "Выберите дату",
            // Additional
            .trackJourney: "Ведите свой путь питания",
            .basicInformation: "Основная информация",
            // Achievements
            .achFirstMealTitle: "Первый прием",
            .achFirstMealDetail: "Добавьте свой самый первый прием пищи.",
            .achFiveMealsTitle: "Начало положено",
            .achFiveMealsDetail: "Добавьте всего 5 приемов пищи.",
            .achTwentyMealsTitle: "Любитель приемов",
            .achTwentyMealsDetail: "Добавьте 20 приемов пищи.",
            .achHundredMealsTitle: "Мастер приемов",
            .achHundredMealsDetail: "Добавьте 100 приемов пищи.",
            .achPhotoEntryTitle: "Фото-про",
            .achPhotoEntryDetail: "Прикрепите фото к приему питания.",
            .achHealthySnacksTitle: "Умный перекус",
            .achHealthySnacksDetail: "Добавьте 10 перекусов.",
            .achBreakfastEarlyTitle: "Ранняя пташка",
            .achBreakfastEarlyDetail: "Добавьте завтрак до 8 утра.",
            .achDinnerLateTitle: "Ночная сова",
            .achDinnerLateDetail: "Добавьте ужин после 21:00.",
            .achStreak3Title: "Серия 3 дня",
            .achStreak3Detail: "Добавляйте приемы 3 дня подряд.",
            .achStreak7Title: "Серия 7 дней",
            .achStreak7Detail: "Добавляйте приемы 7 дней подряд.",
            .achGoalDayTitle: "В цель",
            .achGoalDayDetail: "Достигните дневной цели по калориям.",
            .achGoalWeek4Title: "Последовательность",
            .achGoalWeek4Detail: "Достигайте цели 4 дня на неделе.",
            .achProtein100Title: "Белковый удар",
            .achProtein100Detail: "Достигните 100 г белка за день.",
            .achVeggieDayTitle: "Овощной день",
            .achVeggieDayDetail: "Добавьте 5 разных продуктов за день.",
            .achWeek30MealsTitle: "Загруженная неделя",
            .achWeek30MealsDetail: "Добавьте 30 приемов за неделю.",
            .achMonth100MealsTitle: "Супер-логгер",
            .achMonth100MealsDetail: "Добавьте 100 приемов за месяц.",
            // Recommendations / forecast
            .recStartBreakfast: "Начните день с завтрака! Рекомендуется 400–600 ккал",
            .recAddMoreFood: "Добавьте больше еды. Осталось %d ккал",
            .recReducePortions: "Попробуйте уменьшить порции. Превышение на %d ккал",
            .recGreatProgress: "Отличный прогресс! Осталось %d ккал до цели",
            .recAddProtein: "Добавьте больше белка: мясо, рыба, яйца, творог",
            .recAddCarbs: "Добавьте сложные углеводы: крупы, хлеб, овощи",
            .recAddFats: "Добавьте полезные жиры: орехи, авокадо, оливковое масло",
            .recForecastMorning: "У вас есть %d ккал на весь день. Начните с питательного завтрака!",
            .recForecastGoodStart: "Хорошее начало! Осталось %d ккал. Планируйте обед и ужин",
            .recForecastExcellent: "Отличный прогресс! Продолжайте",
            .recForecastHalfDay: "Половина дня прошла. Осталось %d ккал. Планируйте ужин",
            .recForecastGood: "Хорошо! Осталось %d ккал до цели",
            .recForecastGoalReached: "Цель достигнута! Можно легкий перекус",
            .recForecastEvening: "День подходит к концу. Осталось %d ккал. Легкий ужин",
            .recForecastGreatDay: "Отличный день! Вы достигли цели",
            .recForecastOverLimit: "Превышение нормы. Завтра начните заново"
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
            .meals: "Прийоми",
            .less: "Менше",
            .more: "Більше",
            .mostCommonMeal: "Найчастіший прийом",
            .mostCaloricMeal: "Найкалорійніший прийом",
            .bestDay: "Найкращий день",
            .currentStreak: "Поточна серія",
            .daysInARow: "днів поспіль",
            .averageDailyCalories: "Середні денні калорії",
            .goalAchievement: "Досягнення цілі",
            .maxLabel: "Макс",
            .thisPeriod: "Цей період",
            .avgDailyShort: "Сер. за день",
            .caloriesShortUnit: "ккал",
            .goalMet: "Досягнуто",
            .ofDays: "Днів",
            .noneLabel: "Немає",
            // Settings
            .notifications: "Сповіщення",
            .reminderTime: "Час нагадування",
            .calorieReminders: "Нагадування про калорії",
            .getRemindedAboutGoals: "Отримуйте нагадування про цілі та ведення щоденника",
            .appearance: "Оформлення",
            .darkMode: "Темна тема",
            .language: "Мова",
            .region: "Регіон",
            .languageRegion: "Мова та регіон",
            .dataManagement: "Керування даними",
            .exportDataTitle: "Експорт даних",
            .exportYourDataOrResetApp: "Експортуйте дані або скиньте застосунок",
            .clearAllData: "Видалити всі дані",
            .clearAll: "Видалити все",
            .clearAllDataAlertTitle: "Видалити всі дані",
            .clearAllDataAlertMessage: "Це назавжди видалить усі дані щоденника. Дію не можна скасувати.",
            .version: "Версія",
            .termsOfService: "Умови користування",
            .privacyPolicy: "Політика конфіденційності",
            .about: "Про застосунок",
            .done: "Готово",
            .share: "Поділитися",
            // History/Calendar
            .week: "Тиждень",
            .month: "Місяць",
            .year: "Рік",
            .custom: "Користувацький",
            .selectDate: "Виберіть дату",
            // Additional
            .trackJourney: "Ведіть свій шлях харчування",
            .basicInformation: "Базова інформація"
            ,
            .stepLabel: "Крок",
            .primaryBackground: "Основний фон",
            .secondaryBackground: "Вторинний фон",
            .gradientBackground: "Градієнтний фон",
            .patternBackground: "Візерунковий фон",
            .minimalBackground: "Мінімальний фон",
            .chips: "Чіпси",
            .badges: "Бейджі",
            .loadingIndicators: "Індикатори завантаження",
            .cardTitle: "Заголовок картки",
            .cardSampleText: "Зразок картки з текстом для демонстрації дизайн-системи."
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
            .meals: "Comidas",
            .less: "Menos",
            .more: "Más",
            .mostCommonMeal: "Comida más común",
            .mostCaloricMeal: "Comida más calórica",
            .bestDay: "Mejor día",
            .currentStreak: "Racha actual",
            .daysInARow: "días seguidos",
            .averageDailyCalories: "Calorías diarias promedio",
            .goalAchievement: "Logro de la meta",
            .maxLabel: "Máx",
            .thisPeriod: "Este período",
            .avgDailyShort: "Prom. diario",
            .caloriesShortUnit: "kcal",
            .goalMet: "Meta lograda",
            .ofDays: "De días",
            .noneLabel: "Ninguno",
            // Settings
            .notifications: "Notificaciones",
            .reminderTime: "Hora de recordatorio",
            .calorieReminders: "Recordatorios de calorías",
            .getRemindedAboutGoals: "Recibe recordatorios de tus metas y registro de comidas",
            .appearance: "Apariencia",
            .darkMode: "Modo oscuro",
            .language: "Idioma",
            .region: "Región",
            .languageRegion: "Idioma y región",
            .dataManagement: "Gestión de datos",
            .exportDataTitle: "Exportar datos",
            .exportYourDataOrResetApp: "Exporta tus datos o reinicia la app",
            .clearAllData: "Borrar todos los datos",
            .clearAll: "Borrar todo",
            .clearAllDataAlertTitle: "Borrar todos los datos",
            .clearAllDataAlertMessage: "Esto eliminará permanentemente tus datos. Esta acción no se puede deshacer.",
            .version: "Versión",
            .termsOfService: "Términos de servicio",
            .privacyPolicy: "Política de privacidad",
            .about: "Acerca de",
            .done: "Listo",
            .share: "Compartir",
            // History/Calendar
            .week: "Semana",
            .month: "Mes",
            .year: "Año",
            .custom: "Personalizado",
            .selectDate: "Seleccionar fecha",
            // Additional
            .trackJourney: "Sigue tu camino de nutrición",
            .basicInformation: "Información básica"
            ,
            .stepLabel: "Paso",
            .primaryBackground: "Fondo primario",
            .secondaryBackground: "Fondo secundario",
            .gradientBackground: "Fondo degradado",
            .patternBackground: "Fondo con patrón",
            .minimalBackground: "Fondo minimalista",
            .chips: "Chips",
            .badges: "Insignias",
            .loadingIndicators: "Indicadores de carga",
            .cardTitle: "Título de la tarjeta",
            .cardSampleText: "Tarjeta de ejemplo con contenido para demostrar el sistema de diseño."
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
            .meals: "Repas",
            .less: "Moins",
            .more: "Plus",
            .mostCommonMeal: "Repas le plus fréquent",
            .mostCaloricMeal: "Repas le plus calorique",
            .bestDay: "Meilleure journée",
            .currentStreak: "Série actuelle",
            .daysInARow: "jours d'affilée",
            .averageDailyCalories: "Calories quotidiennes moyennes",
            .goalAchievement: "Atteinte de l'objectif",
            .maxLabel: "Max",
            .thisPeriod: "Cette période",
            .avgDailyShort: "Moy. quotidien",
            .caloriesShortUnit: "kcal",
            .goalMet: "Objectif atteint",
            .ofDays: "Des jours",
            .noneLabel: "Aucun",
            // Settings
            .notifications: "Notifications",
            .reminderTime: "Heure de rappel",
            .calorieReminders: "Rappels de calories",
            .getRemindedAboutGoals: "Recevez des rappels sur vos objectifs et suivi",
            .appearance: "Apparence",
            .darkMode: "Mode sombre",
            .language: "Langue",
            .region: "Région",
            .languageRegion: "Langue et région",
            .dataManagement: "Gestion des données",
            .exportDataTitle: "Exporter les données",
            .exportYourDataOrResetApp: "Exportez vos données ou réinitialisez l'app",
            .clearAllData: "Supprimer toutes les données",
            .clearAll: "Tout supprimer",
            .clearAllDataAlertTitle: "Supprimer toutes les données",
            .clearAllDataAlertMessage: "Cela supprimera définitivement vos données. Action irréversible.",
            .version: "Version",
            .termsOfService: "Conditions d'utilisation",
            .privacyPolicy: "Politique de confidentialité",
            .about: "À propos",
            .done: "Terminé",
            .share: "Partager",
            // History/Calendar
            .week: "Semaine",
            .month: "Mois",
            .year: "An",
            .custom: "Personnalisé",
            .selectDate: "Sélectionner la date",
            // Additional
            .trackJourney: "Suivez votre parcours nutritionnel",
            .basicInformation: "Informations de base"
            ,
            .stepLabel: "Étape",
            .primaryBackground: "Arrière-plan principal",
            .secondaryBackground: "Arrière-plan secondaire",
            .gradientBackground: "Arrière-plan dégradé",
            .patternBackground: "Arrière-plan à motif",
            .minimalBackground: "Arrière-plan minimal",
            .chips: "Puce",
            .badges: "Badges",
            .loadingIndicators: "Indicateurs de chargement",
            .cardTitle: "Titre de la carte",
            .cardSampleText: "Exemple de carte avec du contenu pour démontrer le système de conception."
        ]
    }
}
