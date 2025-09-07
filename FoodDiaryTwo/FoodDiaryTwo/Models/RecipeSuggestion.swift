//
//  RecipeSuggestion.swift
//  FoodDiaryTwo
//
//  Created by AI on 07.09.2025.
//

import Foundation

struct RecipeSuggestion: Codable, Equatable {
    let title: String
    let ingredients: [String]
    let steps: [String]
    let nutritionTip: String
}

// MARK: - OpenRouter recipe response wiring
struct OpenRouterRecipeSchema: Codable {
    let name: String
    let schema: OpenRouterRecipeSchemaBody
}

struct OpenRouterRecipeSchemaBody: Codable {
    let type: String
    let properties: [String: OpenRouterRecipeProperty]
    let required: [String]
}

struct OpenRouterRecipeProperty: Codable {
    let type: String
    let items: OpenRouterRecipeProperty?
}


