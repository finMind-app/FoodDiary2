//
//  SearchProductsView.swift
//  FoodDiaryTwo
//
//  Created by Emil Svetlichnyy on 27.09.2025.
//
import SwiftUI
import SwiftData
import OpenFoodFactsSDK

struct SearchProductsView: View {
    var onSelect: (Product) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var query: String = ""
    @State private var products: [Product] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Введите название продукта", text: $query)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .onChange(of: query) { _ in
                            Task { await searchProducts() }
                        }
                }
                .padding(.horizontal)
                .padding(.top, 10)

                if isLoading {
                    VStack {
                        Spacer()
                        ProgressView("Поиск...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        Spacer()
                    }
                } else if let errorMessage = errorMessage {
                    VStack {
                        Spacer()
                        Text("Ошибка: \(errorMessage)")
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(products, id: \.code) { product in
                                Button {
                                    onSelect(product)
                                    dismiss()
                                } label: {
                                    ProductRowView(product: product)
                                        .padding(.horizontal)
                                        .padding(.vertical, 6)
                                        .background(Color(.systemBackground))
                                        .cornerRadius(16)
                                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Поиск продуктов")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") { dismiss() }
                }
            }
        }
        .onAppear {
            OFFConfig.shared.country = .RUSSIA
            OFFConfig.shared.productsLanguage = .RUSSIAN
            OFFConfig.shared.apiEnv = .production
        }
    }

    private func searchProducts() async {
        let currentQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !currentQuery.isEmpty else {
            await MainActor.run {
                products = []
                isLoading = false
            }
            return
        }

        try? await Task.sleep(nanoseconds: 200_000_000)
        if Task.isCancelled { return }

        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        do {
            let searchResults = try await searchProductsByName(query: currentQuery)
            if Task.isCancelled { return }

            await MainActor.run {
                products = searchResults
                isLoading = false
            }
        } catch {
            if Task.isCancelled { return }
            await MainActor.run {
                errorMessage = error.localizedDescription
                products = []
                isLoading = false
            }
        }
    }

    private func searchProductsByName(query: String) async throws -> [Product] {
        let baseURL = "https://world.openfoodfacts.org"
        let searchPath = "/cgi/search.pl"
        var components = URLComponents(string: baseURL + searchPath)!
        components.queryItems = [
            URLQueryItem(name: "search_terms", value: query),
            URLQueryItem(name: "search_simple", value: "1"),
            URLQueryItem(name: "action", value: "process"),
            URLQueryItem(name: "json", value: "1"),
            URLQueryItem(name: "page_size", value: "30"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "fields", value: "code,product_name,brands,nutriscore_grade,nova_group,nutriments,categories,quantity")
        ]
        guard let url = components.url else { throw URLError(.badURL) }

        var request = URLRequest(url: url)
        request.setValue("OpenFoodFacts-SwiftUI-Search/1.0", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 8.0
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
        return searchResponse.products ?? []
    }
}

struct ProductRowView: View {
    let product: Product

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(product.productName ?? "Неизвестный продукт")
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(.primary)

                if let brands = product.brands, !brands.isEmpty {
                    Text(brands)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                if let nutriments = product.nutriments,
                   let nutriscore = nutriments["nutriscore_grade"] as? String {
                    Text("Nutri-Score: \(nutriscore.uppercased())")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(nutriscoreColor(for: nutriscore))
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func nutriscoreColor(for score: String) -> Color {
        switch score.lowercased() {
        case "a": return .green
        case "b": return Color(.systemGreen)
        case "c": return .yellow
        case "d": return .orange
        case "e": return .red
        default: return .gray
        }
    }
}

struct SearchResponse: Decodable {
    let count: StringOrInt?
    let page: StringOrInt?
    let page_count: StringOrInt?
    let page_size: StringOrInt?
    let products: [Product]? // Делаем опциональным

    enum CodingKeys: String, CodingKey {
        case count
        case page
        case page_count
        case page_size
        case products
    }
}

struct ProductResponse: Decodable {
    let code: String
    let product: Product?
    let status: Int
    let status_verbose: String?
}

enum StringOrInt: Decodable {
    case int(Int)
    case string(String)

    var intValue: Int? {
        switch self {
        case .int(let value): return value
        case .string(let value): return Int(value)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else {
            throw DecodingError.typeMismatch(StringOrInt.self, DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Expected String or Int"
            ))
        }
    }
}
