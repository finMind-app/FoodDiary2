//
//  PlumpyTheme.swift
//  FoodDiaryTwo
//
//  Created by Plumpy UI Design System
//

import SwiftUI

enum PlumpyTheme {
    
    // MARK: - Colors
    
    // Основная цветовая палитра (современные, гармоничные цвета)
    static let primary = Color(hex: "#6366F1")      // Индиго
    static let secondary = Color(hex: "#10B981")    // Изумрудный
    static let tertiary = Color(hex: "#F59E0B")     // Янтарный
    
    // Акцентные цвета (более насыщенные версии)
    static let primaryAccent = Color(hex: "#4F46E5")   // Насыщенный индиго
    static let secondaryAccent = Color(hex: "#059669") // Насыщенный изумрудный
    static let tertiaryAccent = Color(hex: "#D97706")  // Насыщенный янтарный
    
    // Нейтральные цвета
    static let neutral50 = Color(hex: "#FAFAFA")
    static let neutral100 = Color(hex: "#F5F5F5")
    static let neutral200 = Color(hex: "#E5E5E5")
    static let neutral300 = Color(hex: "#D4D4D4")
    static let neutral400 = Color(hex: "#A3A3A3")
    static let neutral500 = Color(hex: "#737373")
    static let neutral600 = Color(hex: "#525252")
    static let neutral700 = Color(hex: "#404040")
    static let neutral800 = Color(hex: "#262626")
    static let neutral900 = Color(hex: "#171717")
    
    // Фоновые цвета
    static let background = Color(hex: "#FFFFFF")       // Белый
    static let surface = Color(hex: "#FFFFFF")          // Белый
    static let surfaceSecondary = Color(hex: "#FAFAFA") // Светло-серый
    static let surfaceTertiary = Color(hex: "#F5F5F5")  // Очень светлый серый
    
    // Текстовые цвета
    static let textPrimary = Color(hex: "#171717")      // Почти черный
    static let textSecondary = Color(hex: "#525252")    // Средний серый
    static let textTertiary = Color(hex: "#A3A3A3")     // Светло-серый
    static let textInverse = Color(hex: "#FFFFFF")       // Белый для тёмных фонов
    
    // Семантические цвета
    static let success = Color(hex: "#10B981")          // Зелёный
    static let warning = Color(hex: "#F59E0B")          // Оранжевый
    static let error = Color(hex: "#EF4444")            // Красный
    static let info = Color(hex: "#3B82F6")             // Синий
    
    // Границы и разделители
    static let border = Color(hex: "#E5E5E5")           // Светло-серый
    static let borderLight = Color(hex: "#F5F5F5")      // Очень светлый серый
    
    // Тени
    static let shadow = Color(hex: "#000000")            // Чёрный для теней
    
    // MARK: - Typography
    
    enum Typography {
        // Заголовки (более современные размеры)
        static let largeTitle = Font.system(size: 32, weight: .bold, design: .default)
        static let title1 = Font.system(size: 28, weight: .bold, design: .default)
        static let title2 = Font.system(size: 24, weight: .semibold, design: .default)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .default)
        
        // Основной текст
        static let headline = Font.system(size: 17, weight: .semibold, design: .default)
        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let callout = Font.system(size: 16, weight: .regular, design: .default)
        static let subheadline = Font.system(size: 15, weight: .medium, design: .default)
        
        // Вспомогательный текст
        static let footnote = Font.system(size: 13, weight: .regular, design: .default)
        static let caption1 = Font.system(size: 12, weight: .medium, design: .default)
        static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
    }
    
    // MARK: - Spacing (8pt grid system)
    
    enum Spacing {
        static let tiny: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
        static let huge: CGFloat = 48
    }
    
    // MARK: - Radius (современные скругления)
    
    enum Radius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let extraLarge: CGFloat = 16
        static let round: CGFloat = 50
    }
    
    // MARK: - Shadows (современные тени)
    
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
        static let small = ShadowStyle(radius: 2, y: 1, opacity: 0.05)
        static let medium = ShadowStyle(radius: 4, y: 2, opacity: 0.08)
        static let large = ShadowStyle(radius: 8, y: 4, opacity: 0.12)
        static let extraLarge = ShadowStyle(radius: 16, y: 8, opacity: 0.16)
    }
    
    // MARK: - Animation
    
    enum Animation {
        static let quick = SwiftUI.Animation.easeOut(duration: 0.15)
        static let smooth = SwiftUI.Animation.easeInOut(duration: 0.25)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.35)
        static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.8)
        static let bouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.7)
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
