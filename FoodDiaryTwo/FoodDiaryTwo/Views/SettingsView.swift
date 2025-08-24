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
    @Query private var appSettings: [AppSettings]
    
    @State private var settingsManager: AppSettingsManager?
    @State private var showingLanguagePicker = false
    @State private var showingTimePicker = false
    @State private var showingClearDataAlert = false
    @State private var showingExportSheet = false
    @State private var exportData: String?
    
    let languages = ["English", "Русский", "Español", "Français"]
    let regions = ["United States", "Russia", "Spain", "France", "Germany", "United Kingdom"]
    
    init(modelContext: ModelContext) {
        self.settingsManager = AppSettingsManager(modelContext: modelContext)
    }
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - Notifications
                Section {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Toggle("Notifications", isOn: Binding(
                            get: { settingsManager?.settings?.notificationsEnabled ?? true },
                            set: { newValue in
                                settingsManager?.updateNotificationSettings(
                                    enabled: newValue,
                                    time: settingsManager?.settings?.reminderTime ?? Date(),
                                    calorieReminders: settingsManager?.settings?.calorieRemindersEnabled ?? true
                                )
                            }
                        ))
                    }
                    
                    if settingsManager?.settings?.notificationsEnabled == true {
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            Text("Reminder Time")
                            Spacer()
                            Text(settingsManager?.settings?.reminderTimeString ?? "9:00 AM")
                                .foregroundColor(.secondary)
                        }
                        .onTapGesture {
                            showingTimePicker = true
                        }
                        
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            Text("Calorie Reminders")
                            Spacer()
                            Toggle("", isOn: Binding(
                                get: { settingsManager?.settings?.calorieRemindersEnabled ?? true },
                                set: { newValue in
                                    settingsManager?.updateNotificationSettings(
                                        enabled: settingsManager?.settings?.notificationsEnabled ?? true,
                                        time: settingsManager?.settings?.reminderTime ?? Date(),
                                        calorieReminders: newValue
                                    )
                                }
                            ))
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
                        Toggle("Dark Mode", isOn: Binding(
                            get: { settingsManager?.settings?.darkModeEnabled ?? false },
                            set: { newValue in
                                settingsManager?.updateAppearanceSettings(darkMode: newValue)
                            }
                        ))
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
                        Text(settingsManager?.settings?.selectedLanguage ?? "English")
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
                        Text(settingsManager?.settings?.region ?? "United States")
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
                        Toggle("", isOn: Binding(
                            get: { settingsManager?.settings?.dataExportEnabled ?? false },
                            set: { newValue in
                                settingsManager?.updateDataExportSettings(enabled: newValue)
                            }
                        ))
                        .labelsHidden()
                    }
                    .onTapGesture {
                        exportData = settingsManager?.exportData()
                        showingExportSheet = true
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
                    .onTapGesture {
                        showingClearDataAlert = true
                    }
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
                        Text(settingsManager?.settings?.appVersion ?? "1.0.0")
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
            LanguagePickerView(
                selectedLanguage: Binding(
                    get: { settingsManager?.settings?.selectedLanguage ?? "English" },
                    set: { newValue in
                        settingsManager?.updateLanguageSettings(
                            language: newValue,
                            region: settingsManager?.settings?.region ?? "United States"
                        )
                    }
                ),
                languages: languages
            )
        }
        .sheet(isPresented: $showingTimePicker) {
            TimePickerView(
                selectedTime: Binding(
                    get: { settingsManager?.settings?.reminderTime ?? Date() },
                    set: { newValue in
                        settingsManager?.updateNotificationSettings(
                            enabled: settingsManager?.settings?.notificationsEnabled ?? true,
                            time: newValue,
                            calorieReminders: settingsManager?.settings?.calorieRemindersEnabled ?? true
                        )
                    }
                )
            )
        }
        .alert("Clear All Data", isPresented: $showingClearDataAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                settingsManager?.clearAllData()
            }
        } message: {
            Text("This will permanently delete all your food diary data. This action cannot be undone.")
        }
        .sheet(isPresented: $showingExportSheet) {
            if let exportData = exportData {
                ExportDataView(data: exportData)
            }
        }
        .onAppear {
            // Инициализируем settingsManager с правильным modelContext
            if settingsManager == nil {
                settingsManager = AppSettingsManager(modelContext: modelContext)
            }
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

// MARK: - Time Picker View
struct TimePickerView: View {
    @Binding var selectedTime: Date
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Reminder Time",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()
                
                Spacer()
            }
            .navigationTitle("Reminder Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Export Data View
struct ExportDataView: View {
    let data: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    Text(data)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button("Share") {
                    let activityVC = UIActivityViewController(
                        activityItems: [data],
                        applicationActivities: nil
                    )
                    
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController?.present(activityVC, animated: true)
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("Export Data")
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
    SettingsView(modelContext: try! ModelContainer(for: AppSettings.self, FoodEntry.self, FoodProduct.self, UserProfile.self).mainContext)
        .modelContainer(for: [AppSettings.self, FoodEntry.self, FoodProduct.self, UserProfile.self], inMemory: true)
}
