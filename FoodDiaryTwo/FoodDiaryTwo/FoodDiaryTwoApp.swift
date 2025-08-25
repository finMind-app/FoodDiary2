//
//  FoodDiaryTwoApp.swift
//  FoodDiaryTwo
//
//  Created by Emil Svetlichnyy on 10.08.2025.
//

import SwiftUI
import SwiftData

@main
struct FoodDiaryTwoApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FoodEntry.self,
            FoodProduct.self,
            UserProfile.self,
            AppSettings.self,
            Achievement.self,
        ])
        let persistentConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        let inMemoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            // Try persistent container first
            return try ModelContainer(for: schema, configurations: [persistentConfig])
        } catch {
            // Fallback to in-memory to avoid crash and print a clear log
            print("SwiftData persistent container failed to load: \(error). Falling back to in-memory store.")
            do {
                return try ModelContainer(for: schema, configurations: [inMemoryConfig])
            } catch {
                fatalError("Could not create any ModelContainer (including in-memory): \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainAppView()
        }
        .modelContainer(sharedModelContainer)
    }
}
