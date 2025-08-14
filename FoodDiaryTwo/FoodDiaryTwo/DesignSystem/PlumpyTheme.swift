//
//  PlumpyTheme.swift
//  FoodDiaryTwo
//
//  Created by Plumpy UI Design System
//

import SwiftUI

enum PlumpyTheme {
    
    // MARK: - Colors
    
    // Основные цвета (светлые пастельные оттенки)
    static let primary = Color(hex: "#F4E4C1")      // Бежевый
    static let secondary = Color(hex: "#C8E6C9")    // Мятный
    static let tertiary = Color(hex: "#B3E5FC")     // Нежно-голубой
    
    // Акцентные цвета (более насыщенные версии)
    static let primaryAccent = Color(hex: "#E6D4A3")   // Насыщенный бежевый
    static let secondaryAccent = Color(hex: "#A5D6A7") // Насыщенный мятный
    static let tertiaryAccent = Color(hex: "#81C784")  // Насыщенный голубой
    
    // Фоновые цвета
    static let background = Color(hex: "#FDFCFA")       // Светлый тёплый фон
    static let surface = Color(hex: "#FFFFFF")          // Белый
    static let surfaceSecondary = Color(hex: "#F8F6F2") // Светло-бежевый
    static let surfaceTertiary = Color(hex: "#F0EDE6")  // Бежевый с серым
    
    // Текстовые цвета
    static let textPrimary = Color(hex: "#2C2C2C")      // Тёмно-серый
    static let textSecondary = Color(hex: "#6B6B6B")    // Серый средней насыщенности
    static let textTertiary = Color(hex: "#9E9E9E")     // Светло-серый
    static let textInverse = Color(hex: "#FFFFFF")       // Белый для тёмных фонов
    
    // Специальные цвета
    static let success = Color(hex: "#81C784")          // Зелёный
    static let warning = Color(hex: "#FFB74D")          // Оранжевый
    static let error = Color(hex: "#E57373")            // Красный
    static let info = Color(hex: "#64B5F6")             // Синий
    
    // Границы и разделители
    static let border = Color(hex: "#E0E0E0")           // Светло-серый
    static let borderLight = Color(hex: "#F0F0F0")      // Очень светлый серый
    
    // Тени
    static let shadow = Color(hex: "#000000")            // Чёрный для теней
    
    // MARK: - Typography
    
    enum Typography {
        // Заголовки
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
        
        // Основной текст
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 17, weight: .regular, design: .rounded)
        static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
        
        // Вспомогательный текст
        static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
        static let caption1 = Font.system(size: 12, weight: .regular, design: .rounded)
        static let caption2 = Font.system(size: 11, weight: .regular, design: .rounded)
    }
    
    // MARK: - Spacing
    
    enum Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
        static let huge: CGFloat = 48
    }
    
    // MARK: - Radius
    
    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
        static let round: CGFloat = 50
    }
    
    // MARK: - Shadows
    
    struct ShadowStyle {
        let color: Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
        let opacity: Double
        
        init(
            color: Color = PlumpyTheme.shadow,
            radius: CGFloat,
            x: CGFloat = 0,
            y: CGFloat,
            opacity: Double = 1.0
        ) {
            self.color = color
            self.radius = radius
            self.x = x
            self.y = y
            self.opacity = opacity
        }
    }
    
    enum Shadow {
        static let small = ShadowStyle(radius: 4, y: 2, opacity: 0.08)
        static let medium = ShadowStyle(radius: 8, y: 4, opacity: 0.12)
        static let large = ShadowStyle(radius: 16, y: 8, opacity: 0.16)
        static let extraLarge = ShadowStyle(radius: 24, y: 12, opacity: 0.20)
    }
    
    // MARK: - Animation
    
    enum Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let bouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6)
    }
}

// MARK: - Color Extensions

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
