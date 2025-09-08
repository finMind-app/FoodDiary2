//
//  RecipeSuggestionService.swift
//  FoodDiaryTwo
//
//  Created by AI on 07.09.2025.
//

import Foundation

final class RecipeSuggestionService {
    private let remoteConfigService = RemoteConfigService()
    private let baseURL = "https://openrouter.ai/api/v1/chat/completions"
    private let primaryModel = "google/gemini-2.0-flash-exp:free"
    private let fallbackModels = [
        "meta-llama/llama-3.3-8b-instruct:free",
        "qwen/qwen3-14b:free"
    ]

    private func getAPIKey() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            remoteConfigService.getAPIKey { apiKey in
                if let apiKey = apiKey {
                    continuation.resume(returning: apiKey)
                } else {
                    continuation.resume(throwing: FoodRecognitionError.apiError("Не удалось получить API ключ"))
                }
            }
        }
    }

    func generateRecipe(ingredients: [String], language: Language) async throws -> RecipeSuggestion {
        let apiKey = try await getAPIKey()
        let maskedKey: String = {
            let prefix = apiKey.prefix(6)
            let suffix = apiKey.suffix(4)
            return "\(prefix)...\(suffix)"
        }()
        print("🔐 RecipeSuggestionService: Using API key: \(maskedKey)")

        // Try primary then fallbacks on 429
        let modelsToTry = [primaryModel] + fallbackModels
        for (index, model) in modelsToTry.enumerated() {
            do {
                let result = try await sendRequest(apiKey: apiKey, model: model, ingredients: ingredients, language: language)
                if index > 0 { print("🔁 Fallback success with model: \(model)") }
                return result
            } catch let FoodRecognitionError.apiError(message) {
                // Detect 429 from either HTTP or OpenRouter error payload
                if message.contains("429") || message.lowercased().contains("rate-limited") {
                    print("⚠️ Rate limited on model: \(model). Trying fallback if available...")
                    continue
                }
                throw error
            } catch {
                throw error
            }
        }
        throw FoodRecognitionError.apiError("All models failed")
    }

    private func sendRequest(apiKey: String, model: String, ingredients: [String], language: Language) async throws -> RecipeSuggestion {
        let url = URL(string: baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("FoodDiaryTwo/1.0", forHTTPHeaderField: "HTTP-Referer")
        request.setValue("https://fooddiary.app", forHTTPHeaderField: "X-Title")

        let prompt = "Ты шеф-повар. Составь полностью готовый рецепт на выбранном в приложении языке (передать его сюда) с названием блюда и пошаговой инструкцией. Ингредиенты: \(ingredients.joined(separator: ", ")). Язык: \(language.rawValue). Верни строго JSON по схеме."

        let message = OpenRouterMessage(
            role: "user",
            content: [OpenRouterContent(type: "text", text: prompt, image_url: nil)]
        )

        let jsonSchema = OpenRouterJSONSchema(
            name: "recipe_suggestion",
            schema: OpenRouterSchema(
                type: "object",
                properties: [
                    "title": OpenRouterProperty(type: "string", properties: nil, items: nil),
                    "ingredients": OpenRouterProperty(type: "array", properties: nil, items: OpenRouterProperty.ArrayItems(type: "string", properties: nil)),
                    "steps": OpenRouterProperty(type: "array", properties: nil, items: OpenRouterProperty.ArrayItems(type: "string", properties: nil)),
                    "nutritionTip": OpenRouterProperty(type: "string", properties: nil, items: nil)
                ],
                required: ["title", "ingredients", "steps", "nutritionTip"]
            )
        )
        let responseFormat = OpenRouterResponseFormat(type: "json_schema", json_schema: jsonSchema)

        let body = OpenRouterRequest(
            model: model,
            messages: [message],
            max_tokens: 1200,
            temperature: 0.7,
            response_format: responseFormat
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let httpBody = try encoder.encode(body)
        request.httpBody = httpBody

        if let bodyString = String(data: httpBody, encoding: .utf8) {
            print("📤 RecipeSuggestionService Request JSON (model=\(model)):\n\(bodyString)")
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 HTTP status: \(httpResponse.statusCode) (model=\(model))")
            if httpResponse.statusCode == 429 {
                throw FoodRecognitionError.apiError("HTTP 429")
            }
        }
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 RecipeSuggestionService Response JSON (model=\(model)):\n\(responseString)")
        }

        // Some providers return 200 with an error payload
        struct OpenRouterErrorResponse: Codable {
            struct ErrorPayload: Codable {
                let code: Int?
                let message: String?
            }
            let error: ErrorPayload?
        }
        if let err = try? JSONDecoder().decode(OpenRouterErrorResponse.self, from: data), let code = err.error?.code, code == 429 {
            throw FoodRecognitionError.apiError("HTTP 429: rate-limited")
        }

        let openRouterResponse = try JSONDecoder().decode(OpenRouterResponse.self, from: data)
        guard let contentString = openRouterResponse.choices.first?.message.content,
              let contentData = contentString.data(using: .utf8) else {
            throw FoodRecognitionError.invalidResponse
        }
        let suggestion = try JSONDecoder().decode(RecipeSuggestion.self, from: contentData)
        return suggestion
    }
}


