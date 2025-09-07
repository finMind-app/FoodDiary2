//
//  RecipeSuggestionViewModel.swift
//  FoodDiaryTwo
//
//  Created by AI on 07.09.2025.
//

import Foundation
import SwiftUI

@MainActor
final class RecipeSuggestionViewModel: ObservableObject {
    @Published var ingredientsInput: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var suggestion: RecipeSuggestion?
    
    private let api: OpenRouterAPIService
    private let i18n = LocalizationManager.shared
    
    init(api: OpenRouterAPIService = OpenRouterAPIService()) {
        self.api = api
    }
    
    func generate() async {
        errorMessage = nil
        suggestion = nil
        let trimmed = ingredientsInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = i18n.localizedString(.recipeEmptyInputError)
            return
        }
        let items = trimmed
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !items.isEmpty else {
            errorMessage = i18n.localizedString(.recipeEmptyInputError)
            return
        }
        isLoading = true
        do {
            let result = try await api.generateRecipe(ingredients: items, language: i18n.currentLanguage)
            suggestion = result
        } catch let error as FoodRecognitionError {
            switch error {
            case .apiError(let message):
                if message.contains("429") { // rate limit
                    errorMessage = i18n.localizedString(.recipeRateLimitError)
                } else {
                    errorMessage = message
                }
            default:
                errorMessage = i18n.localizedString(.recipeModelNoAnswer)
            }
        } catch {
            errorMessage = i18n.localizedString(.recipeApiGenericError)
        }
        isLoading = false
    }
}


