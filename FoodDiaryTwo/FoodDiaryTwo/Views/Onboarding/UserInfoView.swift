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
                                ForEach(Array(Gender.allCases.enumerated()), id: \.element) { index, genderOption in
                                    GenderButton(
                                        gender: genderOption,
                                        isSelected: gender == genderOption,
                                        onTap: {
                                            withAnimation(PlumpyTheme.Animation.smooth) {
                                                gender = genderOption
                                            }
                                        }
                                    )
                                    .opacity(isVisible ? 1 : 0)
                                    .offset(x: isVisible ? 0 : -20)
                                    .animation(.easeOut(duration: 0.5).delay(0.3 + Double(index) * 0.1), value: isVisible)
                                }
                            }
                        }
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 20)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: isVisible)

                        // Age Input
                        VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
                            Text(LocalizationManager.shared.localizedString(.ageLabel))
                                .font(PlumpyTheme.Typography.headline)
                                .foregroundColor(PlumpyTheme.textPrimary)

                            UserInfoField(
                                title: LocalizationManager.shared.localizedString(.ageLabel),
                                icon: "calendar",
                                placeholder: "25",
                                text: $ageText,
                                keyboardType: .numberPad,
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

                        // Height Input
                        VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
                            Text(LocalizationManager.shared.localizedString(.heightLabel))
                                .font(PlumpyTheme.Typography.headline)
                                .foregroundColor(PlumpyTheme.textPrimary)

                            UserInfoField(
                                title: LocalizationManager.shared.localizedString(.heightLabel),
                                icon: "ruler",
                                placeholder: "175",
                                text: $heightText,
                                keyboardType: .decimalPad,
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

                        // Weight Input
                        VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
                            Text(LocalizationManager.shared.localizedString(.weightLabel))
                                .font(PlumpyTheme.Typography.headline)
                                .foregroundColor(PlumpyTheme.textPrimary)

                            UserInfoField(
                                title: LocalizationManager.shared.localizedString(.weightLabel),
                                icon: "scalemass",
                                placeholder: "70",
                                text: $weightText,
                                keyboardType: .decimalPad,
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

                // Start animations
                withAnimation {
                    isVisible = true
                }

                // Show sliders after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSliders = true
                    }
                }
            }
        }

        var isFormValid: Bool {
            return gender != nil &&
            age != nil &&
            height != nil &&
            weight != nil &&
            age! >= 16 && age! <= 100 &&
            height! >= 120 && height! <= 250 &&
            weight! >= 30 && weight! <= 200
        }
    }

    struct GenderButton: View {
        let gender: Gender
        let isSelected: Bool
        let onTap: () -> Void

        var body: some View {
            Button(action: onTap) {
                HStack(spacing: PlumpyTheme.Spacing.small) {
                    Image(systemName: gender == .male ? "person.fill" : "person.fill")
                        .font(.title3)
                        .foregroundColor(isSelected ? PlumpyTheme.textInverse : PlumpyTheme.textPrimary)

                    Text(gender.displayName)
                        .font(PlumpyTheme.Typography.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? PlumpyTheme.textInverse : PlumpyTheme.textPrimary)
                }
                .padding(.horizontal, PlumpyTheme.Spacing.medium)
                .padding(.vertical, PlumpyTheme.Spacing.small)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                        .fill(isSelected ? PlumpyTheme.primary : PlumpyTheme.surfaceSecondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                                .stroke(
                                    isSelected ? PlumpyTheme.primary : PlumpyTheme.border,
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
            .animation(PlumpyTheme.Animation.smooth, value: isSelected)
        }
    }

    struct UserInfoField: View {
        let title: String
        let icon: String
        let placeholder: String
        @Binding var text: String
        let keyboardType: UIKeyboardType
        let unit: String
        let onValueChanged: (String) -> Void

        var body: some View {
            HStack(spacing: PlumpyTheme.Spacing.medium) {
                // Icon
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(PlumpyTheme.primary)
                    .frame(width: 24, height: 24)

                // Text Field
                TextField(placeholder, text: $text)
                    .font(PlumpyTheme.Typography.body)
                    .keyboardType(keyboardType)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onChange(of: text) { _, newValue in
                        onValueChanged(newValue)
                    }

                // Unit
                Text(unit)
                    .font(PlumpyTheme.Typography.caption1)
                    .foregroundColor(PlumpyTheme.textSecondary)
                    .frame(minWidth: 30)
            }
            .padding(PlumpyTheme.Spacing.medium)
            .background(
                RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                    .fill(PlumpyTheme.surfaceSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: PlumpyTheme.Radius.medium)
                            .stroke(PlumpyTheme.border, lineWidth: 1)
                    )
            )
        }
    }
}
