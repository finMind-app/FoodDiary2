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


