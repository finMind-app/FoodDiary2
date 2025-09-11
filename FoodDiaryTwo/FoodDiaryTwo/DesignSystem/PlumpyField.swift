//
//  PlumpyField.swift
//  FoodDiaryTwo
//
//  Created by Plumpy UI Design System
//

import SwiftUI

struct PlumpyField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    let textContentType: UITextContentType?
    let isSecure: Bool
    let icon: String?
    let iconColor: Color
    let errorMessage: String?
    let isRequired: Bool
    
    @FocusState private var isFocused: Bool
    @State private var isEditing = false
    
    init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default,
        textContentType: UITextContentType? = nil,
        isSecure: Bool = false,
        icon: String? = nil,
        iconColor: Color = PlumpyTheme.primary,
        errorMessage: String? = nil,
        isRequired: Bool = false
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.keyboardType = keyboardType
        self.textContentType = textContentType
        self.isSecure = isSecure
        self.icon = icon
        self.iconColor = iconColor
        self.errorMessage = errorMessage
        self.isRequired = isRequired
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
            // Заголовок поля
            HStack(spacing: PlumpyTheme.Spacing.tiny) {
                Text(title)
                    .font(PlumpyTheme.Typography.caption1)
                    .fontWeight(.medium)
                    .foregroundColor(PlumpyTheme.textSecondary)
                
                if isRequired {
                    Text("*")
                        .font(PlumpyTheme.Typography.caption1)
                        .foregroundColor(PlumpyTheme.error)
                }
            }
            
            // Поле ввода
            HStack(spacing: PlumpyTheme.Spacing.medium) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.body)
                        .foregroundColor(iconColor)
                        .frame(width: 20)
                }
                
                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .font(PlumpyTheme.Typography.body)
                .foregroundColor(PlumpyTheme.textPrimary)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .focused($isFocused)
                .onChange(of: isFocused) { _, newValue in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isFocused = newValue
                    }
                }
            }
            .padding(.horizontal, PlumpyTheme.Spacing.medium)
            .padding(.vertical, PlumpyTheme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
            )
            .shadow(
                color: shadowColor,
                radius: PlumpyTheme.Shadow.small.radius,
                x: PlumpyTheme.Shadow.small.x,
                y: PlumpyTheme.Shadow.small.y
            )
            
            // Сообщение об ошибке
            if let errorMessage = errorMessage {
                HStack(spacing: PlumpyTheme.Spacing.tiny) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(PlumpyTheme.error)
                    
                    Text(errorMessage)
                        .font(PlumpyTheme.Typography.caption1)
                        .foregroundColor(PlumpyTheme.error)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(PlumpyTheme.Animation.smooth, value: isEditing)
        .animation(PlumpyTheme.Animation.smooth, value: errorMessage != nil)
    }
    
    // MARK: - Computed Properties
    
    private var backgroundColor: Color {
        if errorMessage != nil {
            return PlumpyTheme.error.opacity(0.06)
        }
        // Unify field background across themes
        return Color(UIColor { tc in
            tc.userInterfaceStyle == .dark ? UIColor(PlumpyTheme.surfaceSecondary) : UIColor(PlumpyTheme.surface)
        })
    }
    
    private var borderColor: Color {
        if errorMessage != nil {
            return PlumpyTheme.error
        }
        return isFocused ? PlumpyTheme.primary : PlumpyTheme.neutral200
    }
    
    private var borderWidth: CGFloat {
        return (isFocused || errorMessage != nil) ? 1.5 : 1
    }
    
    private var shadowColor: Color {
        return isFocused ? PlumpyTheme.primary.opacity(0.08) : PlumpyTheme.shadow.opacity(0.02)
    }
}

// MARK: - Specialized Fields

struct PlumpySearchField: View {
    @Binding var text: String
    let placeholder: String
    let onSearch: (String) -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: PlumpyTheme.Spacing.medium) {
            Image(systemName: "magnifyingglass")
                .font(.body)
                .foregroundColor(PlumpyTheme.textSecondary)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .font(PlumpyTheme.Typography.body)
                .foregroundColor(PlumpyTheme.textPrimary)
                .focused($isFocused)
                .onSubmit {
                    onSearch(text)
                }
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.body)
                        .foregroundColor(PlumpyTheme.textTertiary)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, PlumpyTheme.Spacing.medium)
        .padding(.vertical, PlumpyTheme.Spacing.medium)
        .background(
            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                .fill(Color(UIColor { tc in tc.userInterfaceStyle == .dark ? UIColor(PlumpyTheme.surfaceSecondary) : UIColor(PlumpyTheme.neutral50) }))
                .overlay(
                    RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                        .stroke(isFocused ? PlumpyTheme.primary : PlumpyTheme.neutral200, lineWidth: isFocused ? 1.5 : 1)
                )
        )
        .shadow(
            color: isFocused ? PlumpyTheme.primary.opacity(0.1) : PlumpyTheme.shadow.opacity(0.02),
            radius: PlumpyTheme.Shadow.small.radius,
            x: PlumpyTheme.Shadow.small.x,
            y: PlumpyTheme.Shadow.small.y
        )
        .animation(PlumpyTheme.Animation.smooth, value: isFocused)
        .animation(PlumpyTheme.Animation.smooth, value: text.isEmpty)
    }
}

struct PlumpyTextArea: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let minHeight: CGFloat
    let maxHeight: CGFloat
    
    @FocusState private var isFocused: Bool
    
    init(
        title: String,
        placeholder: String,
        text: Binding<String>,
        minHeight: CGFloat = 80,
        maxHeight: CGFloat = 200
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.minHeight = minHeight
        self.maxHeight = maxHeight
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
            Text(title)
                .font(PlumpyTheme.Typography.caption1)
                .fontWeight(.medium)
                .foregroundColor(PlumpyTheme.textSecondary)
            
            TextEditor(text: $text)
                .font(PlumpyTheme.Typography.body)
                .foregroundColor(PlumpyTheme.textPrimary)
                .focused($isFocused)
                .frame(minHeight: minHeight, maxHeight: maxHeight)
                .padding(.horizontal, PlumpyTheme.Spacing.medium)
                .padding(.vertical, PlumpyTheme.Spacing.medium)
                .background(
                    RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                        .fill(Color(UIColor { tc in tc.userInterfaceStyle == .dark ? UIColor(PlumpyTheme.surfaceSecondary) : UIColor(PlumpyTheme.neutral50) }))
                        .overlay(
                            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                                .stroke(isFocused ? PlumpyTheme.primary : PlumpyTheme.neutral200, lineWidth: isFocused ? 1.5 : 1)
                        )
                )
                .shadow(
                    color: isFocused ? PlumpyTheme.primary.opacity(0.1) : PlumpyTheme.shadow.opacity(0.02),
                    radius: PlumpyTheme.Shadow.small.radius,
                    x: PlumpyTheme.Shadow.small.x,
                    y: PlumpyTheme.Shadow.small.y
                )
                .overlay(
                    Group {
                        if text.isEmpty {
                            HStack {
                                Text(placeholder)
                                    .font(PlumpyTheme.Typography.body)
                                    .foregroundColor(PlumpyTheme.textTertiary)
                                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                                    .padding(.vertical, PlumpyTheme.Spacing.medium)
                                Spacer()
                            }
                            .allowsHitTesting(false)
                        }
                    }
                )
        }
        .animation(PlumpyTheme.Animation.smooth, value: isFocused)
    }
}

#Preview {
    VStack(spacing: PlumpyTheme.Spacing.large) {
        PlumpyField(
            title: "Email",
            placeholder: "Enter your email",
            text: .constant(""),
            icon: "envelope",
            isRequired: true
        )
        
        PlumpyField(
            title: "Password",
            placeholder: "Enter your password",
            text: .constant(""),
            isSecure: true,
            icon: "lock",
            iconColor: PlumpyTheme.secondary
        )
        
        PlumpyField(
            title: "Username",
            placeholder: "Enter username",
            text: .constant(""),
            errorMessage: "Username is already taken"
        )
        
        PlumpySearchField(
            text: .constant(""),
            placeholder: "Search meals...",
            onSearch: { _ in }
        )
        
        PlumpyTextArea(
            title: "Notes",
            placeholder: "Add your notes here...",
            text: .constant("")
        )
    }
    .padding()
    .background(PlumpyTheme.background)
}
