//
//  SettingsView.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [UserProfile]
    
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var selectedLanguage = "English"
    @State private var dataExportEnabled = false
    @State private var showingLanguagePicker = false
    
    let languages = ["English", "Русский", "Español", "Français"]
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Notifications
                Section {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Toggle("Notifications", isOn: $notificationsEnabled)
                    }
                    
                    if notificationsEnabled {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            Text("Reminder Time")
                            Spacer()
                            Text("9:00 AM")
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            Text("Calorie Reminders")
                            Spacer()
                            Toggle("", isOn: .constant(true))
                                .labelsHidden()
                        }
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Get reminded about your daily goals and meal tracking")
                }
                
                // MARK: - Appearance
                Section {
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.purple)
                            .frame(width: 24)
                        Toggle("Dark Mode", isOn: $darkModeEnabled)
                    }
                } header: {
                    Text("Appearance")
                }
                
                // MARK: - Language & Region
                Section {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text("Language")
                        Spacer()
                        Text(selectedLanguage)
                            .foregroundColor(.secondary)
                    }
                    .onTapGesture {
                        showingLanguagePicker = true
                    }
                    
                    HStack {
                        Image(systemName: "flag.fill")
                            .foregroundColor(.orange)
                            .frame(width: 24)
                        Text("Region")
                        Spacer()
                        Text("United States")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("Language & Region")
                }
                
                // MARK: - Data Management
                Section {
                    HStack {
                        Image(systemName: "arrow.up.doc.fill")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        Text("Export Data")
                        Spacer()
                        Toggle("", isOn: $dataExportEnabled)
                            .labelsHidden()
                    }
                    
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        Text("Clear All Data")
                        Spacer()
                        Text("")
                    }
                    .foregroundColor(.red)
                } header: {
                    Text("Data Management")
                } footer: {
                    Text("Export your food diary data or reset the app")
                }
                
                // MARK: - About
                Section {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        Text("Terms of Service")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        Text("Privacy Policy")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingLanguagePicker) {
            LanguagePickerView(selectedLanguage: $selectedLanguage, languages: languages)
        }
    }
}

// MARK: - Language Picker View
struct LanguagePickerView: View {
    @Binding var selectedLanguage: String
    let languages: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(languages, id: \.self) { language in
                HStack {
                    Text(language)
                    Spacer()
                    if language == selectedLanguage {
                        Image(systemName: "checkmark")
                            .foregroundColor(.blue)
                    }
                }
                .onTapGesture {
                    selectedLanguage = language
                    dismiss()
                }
            }
            .navigationTitle("Language")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [FoodEntry.self, FoodProduct.self, UserProfile.self], inMemory: true)
}
