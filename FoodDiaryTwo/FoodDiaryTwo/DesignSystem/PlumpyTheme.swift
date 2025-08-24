//
//  PlumpyTheme.swift
//  FoodDiaryTwo
//
//  Created by Plumpy UI Design System
//

import SwiftUI

enum PlumpyTheme {
    
    // MARK: - Colors
    
    // Основная цветовая палитра
    static let primary = Color(hex: "#6366F1")      // Индиго
    static let secondary = Color(hex: "#10B981")    // Изумрудный
    static let tertiary = Color(hex: "#F59E0B")     // Янтарный
    
    // Акцентные цвета
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
    
    // Фоновые цвета (адаптивные)
    static var background: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#0F0F0F") : UIColor(hex: "#FFFFFF")
        })
    }
    
    static var surface: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#1A1A1A") : UIColor(hex: "#FFFFFF")
        })
    }
    
    static var surfaceSecondary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#262626") : UIColor(hex: "#FAFAFA")
        })
    }
    
    static var surfaceTertiary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#404040") : UIColor(hex: "#F5F5F5")
        })
    }
    
    // Текстовые цвета (адаптивные)
    static var textPrimary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#FFFFFF") : UIColor(hex: "#171717")
        })
    }
    
    static var textSecondary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#A3A3A3") : UIColor(hex: "#525252")
        })
    }
    
    static var textTertiary: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#737373") : UIColor(hex: "#A3A3A3")
        })
    }
    
    static var textInverse: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#171717") : UIColor(hex: "#FFFFFF")
        })
    }
    
    // Семантические цвета
    static let success = Color(hex: "#10B981")          // Зелёный
    static let warning = Color(hex: "#F59E0B")          // Оранжевый
    static let error = Color(hex: "#EF4444")            // Красный
    static let info = Color(hex: "#3B82F6")             // Синий
    
    // Границы и разделители (адаптивные)
    static var border: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#404040") : UIColor(hex: "#E5E5E5")
        })
    }
    
    static var borderLight: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(hex: "#525252") : UIColor(hex: "#F5F5F5")
        })
    }
    
    // Тени
    static let shadow = Color(hex: "#000000")            // Чёрный для теней
    
    // MARK: - Typography
    
    enum Typography {
        // Заголовки
        static let largeTitle = Font.system(size: 32, weight: .bold, design: .default)
        static let title1 = Font.system(size: 28, weight: .bold, design: .default)
        static let title2 = Font.system(size: 24, weight: .semibold, design: .default)
        static let title3 = Font.system(size: 18, weight: .semibold, design: .default)

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
        static let small: CGFloat = 6
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let extraLarge: CGFloat = 16
        static let round: CGFloat = 50
    }
    
    // MARK: - Shadows 
    
    enum Shadow {
        case small, medium, large
        
        var radius: CGFloat {
            switch self {
            case .small: return 2
            case .medium: return 4
            case .large: return 8
            }
        }
        
        var x: CGFloat {
            switch self {
            case .small: return 0
            case .medium: return 0
            case .large: return 0
            }
        }
        
        var y: CGFloat {
            switch self {
            case .small: return 1
            case .medium: return 2
            case .large: return 4
            }
        }
        
        var opacity: Double {
            switch self {
            case .small: return 0.1
            case .medium: return 0.15
            case .large: return 0.2
            }
        }
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

// MARK: - UIColor Extension for Hex Support

extension UIColor {
    convenience init(hex: String) {
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
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            alpha: Double(a) / 255
        )
    }
}
