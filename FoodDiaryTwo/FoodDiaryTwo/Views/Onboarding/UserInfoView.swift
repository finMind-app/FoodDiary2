//
//  UserInfoView.swift
//  FoodDiaryTwo
//
//  Created by AI Assistant
//

import SwiftUI

struct UserInfoView: View {
    @Binding var gender: Gender?
    @Binding var age: Int?
    @Binding var height: Double?
    @Binding var weight: Double?
    
    let onNext: () -> Void
    
    @State private var ageText: String = ""
    @State private var heightText: String = ""
    @State private var weightText: String = ""
    @State private var isVisible = false
    @State private var showSliders = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: PlumpyTheme.Spacing.large) {
                    // Header
                    VStack(spacing: PlumpyTheme.Spacing.medium) {
                        Text(LocalizationManager.shared.localizedString(.onboardingUserInfoTitle))
                            .font(PlumpyTheme.Typography.title1)
                            .fontWeight(.bold)
                            .foregroundColor(PlumpyTheme.textPrimary)
                            .multilineTextAlignment(.center)
                            .opacity(isVisible ? 1 : 0)
                            .offset(y: isVisible ? 0 : 20)
                            .animation(.easeOut(duration: 0.6).delay(0.1), value: isVisible)
                    }
                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                    .padding(.top, PlumpyTheme.Spacing.medium)
            
                // Form Fields
                VStack(spacing: PlumpyTheme.Spacing.medium) {
                // Gender Selection
                VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
                    Text(LocalizationManager.shared.localizedString(.gender))
                        .font(PlumpyTheme.Typography.headline)
                        .foregroundColor(PlumpyTheme.textPrimary)
                    
                    HStack(spacing: PlumpyTheme.Spacing.small) {
                        ForEach(Gender.allCases, id: \.self) { genderOption in
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    gender = genderOption
                                }
                            }) {
                                Text(genderOption.displayName)
                                    .font(PlumpyTheme.Typography.body)
                                    .foregroundColor(gender == genderOption ? .white : PlumpyTheme.textPrimary)
                                    .padding(.horizontal, PlumpyTheme.Spacing.medium)
                                    .padding(.vertical, PlumpyTheme.Spacing.small)
                                    .background(
                                        RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                                            .fill(gender == genderOption ? PlumpyTheme.primary : PlumpyTheme.neutral100)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: isVisible)
                
                // Age Field
                VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
                    UserInfoField(
                        title: LocalizationManager.shared.localizedString(.age),
                        text: $ageText,
                        unit: LocalizationManager.shared.localizedString(.yearsSuffix)
                    ) { value in
                        age = Int(value)
                    }
                    
                    if showSliders {
                        Slider(
                            value: Binding(
                                get: { Double(age ?? 25) },
                                set: { 
                                    age = Int($0)
                                    ageText = String(Int($0))
                                }
                            ),
                            in: 16...100,
                            step: 1
                        )
                        .accentColor(PlumpyTheme.primary)
                        .padding(.top, PlumpyTheme.Spacing.small)
                        .opacity(showSliders ? 1 : 0)
                        .offset(y: showSliders ? 0 : 10)
                        .animation(.easeInOut(duration: 0.5), value: showSliders)
                    }
                }
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.4), value: isVisible)
                
                // Height Field
                VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
                    UserInfoField(
                        title: LocalizationManager.shared.localizedString(.height),
                        text: $heightText,
                        unit: LocalizationManager.shared.localizedString(.cmUnit)
                    ) { value in
                        height = Double(value)
                    }
                    
                    if showSliders {
                        Slider(
                            value: Binding(
                                get: { height ?? 175 },
                                set: { 
                                    height = $0
                                    heightText = String(Int($0))
                                }
                            ),
                            in: 120...250,
                            step: 1
                        )
                        .accentColor(PlumpyTheme.primary)
                        .padding(.top, PlumpyTheme.Spacing.small)
                        .opacity(showSliders ? 1 : 0)
                        .offset(y: showSliders ? 0 : 10)
                        .animation(.easeInOut(duration: 0.5), value: showSliders)
                    }
                }
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.5), value: isVisible)
                
                // Weight Field
                VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
                    UserInfoField(
                        title: LocalizationManager.shared.localizedString(.weight),
                        text: $weightText,
                        unit: LocalizationManager.shared.localizedString(.kgUnit)
                    ) { value in
                        weight = Double(value)
                    }
                    
                    if showSliders {
                        Slider(
                            value: Binding(
                                get: { weight ?? 70 },
                                set: { 
                                    weight = $0
                                    weightText = String(Int($0))
                                }
                            ),
                            in: 30...200,
                            step: 1
                        )
                        .accentColor(PlumpyTheme.primary)
                        .padding(.top, PlumpyTheme.Spacing.small)
                        .opacity(showSliders ? 1 : 0)
                        .offset(y: showSliders ? 0 : 10)
                        .animation(.easeInOut(duration: 0.5), value: showSliders)
                    }
                }
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.6), value: isVisible)
                }
                .padding(.horizontal, PlumpyTheme.Spacing.medium)
                .padding(.bottom, PlumpyTheme.Spacing.large)
            }
            
            // Next Button - прибита снизу
            VStack {
                Divider()
                    .background(PlumpyTheme.border)
                    .opacity(isVisible ? 1 : 0)
                    .animation(.easeOut(duration: 0.3).delay(0.7), value: isVisible)
                
                PlumpyButton(
                    title: LocalizationManager.shared.localizedString(.onboardingContinue),
                    icon: "arrow.right",
                    style: isFormValid ? .primary : .ghost,
                    isEnabled: isFormValid,
                    action: onNext
                )
                .padding(.horizontal, PlumpyTheme.Spacing.medium)
                .padding(.vertical, PlumpyTheme.Spacing.medium)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 20)
                .scaleEffect(isVisible ? 1 : 0.9)
                .animation(.easeOut(duration: 0.6).delay(0.8), value: isVisible)
            }
            .background(PlumpyTheme.background)
        }
        .background(PlumpyTheme.background)
        .onAppear {
            // Initialize text fields with existing values
            if let age = age {
                ageText = String(age)
            }
            if let height = height {
                heightText = String(Int(height))
            }
            if let weight = weight {
                weightText = String(Int(weight))
            }
            
            withAnimation {
                isVisible = true
            }
            
            // Show sliders after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showSliders = true
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        return gender != nil && age != nil && height != nil && weight != nil
    }
}

// MARK: - UserInfoField Component

struct UserInfoField: View {
    let title: String
    @Binding var text: String
    let unit: String
    let onValueChange: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
            HStack {
                TextField(title, text: $text)
                    .textFieldStyle(PlumpyTextFieldStyle())
                    .keyboardType(.numberPad)
                    .onChange(of: text) { newValue in
                        onValueChange(newValue)
                    }
                
                Text(unit)
                    .font(PlumpyTheme.Typography.body)
                    .foregroundColor(PlumpyTheme.textSecondary)
            }
        }
    }
}

#Preview {
    UserInfoView(
        gender: .constant(nil),
        age: .constant(nil),
        height: .constant(nil),
        weight: .constant(nil)
    ) {
        // Preview action
    }
}