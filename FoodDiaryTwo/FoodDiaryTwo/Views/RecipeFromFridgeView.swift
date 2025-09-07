//
//  RecipeFromFridgeView.swift
//  FoodDiaryTwo
//
//  Created by AI on 07.09.2025.
//

import SwiftUI

struct RecipeFromFridgeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var i18n = LocalizationManager.shared
    @State private var ingredientsText: String = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var suggestion: RecipeSuggestion?
    private let service = RecipeSuggestionService()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.medium) {
                    TextField(i18n.localizedString(.recipeInputPlaceholder), text: $ingredientsText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)

                    Button(action: { Task { await generate() } }) {
                        if isLoading { ProgressView() } else { Text(i18n.localizedString(.recipeGenerateCta)) }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, PlumpyTheme.Spacing.small)

                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(PlumpyTheme.warning)
                            .font(PlumpyTheme.Typography.caption2)
                    }

                    if let s = suggestion {
                        VStack(alignment: .leading, spacing: PlumpyTheme.Spacing.small) {
                            Text(s.title)
                                .font(PlumpyTheme.Typography.title3)
                                .fontWeight(.bold)
                                .foregroundColor(PlumpyTheme.textPrimary)

                            Text(i18n.localizedString(.ingredientsTitle))
                                .font(PlumpyTheme.Typography.caption1)
                                .foregroundColor(PlumpyTheme.textSecondary)
                                .padding(.top, PlumpyTheme.Spacing.tiny)

                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(s.ingredients, id: \.self) { item in
                                    HStack(alignment: .top, spacing: 8) {
                                        Circle().fill(PlumpyTheme.secondaryAccent).frame(width: 6, height: 6)
                                        Text(item).foregroundColor(PlumpyTheme.textPrimary).font(PlumpyTheme.Typography.caption1)
                                        Spacer()
                                    }
                                }
                            }

                            Text(i18n.localizedString(.stepsTitle))
                                .font(PlumpyTheme.Typography.caption1)
                                .foregroundColor(PlumpyTheme.textSecondary)
                                .padding(.top, PlumpyTheme.Spacing.small)

                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(Array(s.steps.enumerated()), id: \.offset) { idx, step in
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("\(idx + 1).")
                                            .font(PlumpyTheme.Typography.caption1)
                                            .foregroundColor(PlumpyTheme.secondaryAccent)
                                            .frame(width: 18, alignment: .leading)
                                        Text(step)
                                            .foregroundColor(PlumpyTheme.textPrimary)
                                            .font(PlumpyTheme.Typography.caption1)
                                        Spacer()
                                    }
                                }
                            }

                            if !s.nutritionTip.isEmpty {
                                HStack(alignment: .top, spacing: PlumpyTheme.Spacing.small) {
                                    Image(systemName: "heart.fill").foregroundColor(PlumpyTheme.success)
                                    Text(s.nutritionTip)
                                        .font(PlumpyTheme.Typography.caption2)
                                        .foregroundColor(PlumpyTheme.textPrimary)
                                    Spacer()
                                }
                                .padding(PlumpyTheme.Spacing.small)
                                .plumpyCard(cornerRadius: PlumpyTheme.Radius.small, backgroundColor: PlumpyTheme.success.opacity(0.1))
                            }
                        }
                    }
                }
                .padding(PlumpyTheme.Spacing.medium)
            }
            .navigationTitle(i18n.localizedString(.recipeFromFridgeTitle))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(i18n.localizedString(.close)) { dismiss() }
                }
            }
        }
    }

    private func generate() async {
        errorMessage = nil
        suggestion = nil
        let items = ingredientsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !items.isEmpty else {
            errorMessage = i18n.localizedString(.recipeEmptyInputError)
            return
        }
        isLoading = true
        do {
            let s = try await service.generateRecipe(ingredients: items, language: i18n.currentLanguage)
            suggestion = s
        } catch let FoodRecognitionError.apiError(message) {
            if message.contains("429") { errorMessage = i18n.localizedString(.recipeRateLimitError) }
            else { errorMessage = message }
        } catch {
            errorMessage = i18n.localizedString(.recipeApiGenericError)
        }
        isLoading = false
    }
}


