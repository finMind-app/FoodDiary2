//
//  SettingsView.swift
//  FoodDiaryTwo
//
//  Created by user on 31.07.2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject private var i18n: LocalizationManager
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
                        Toggle(i18n.localizedString(.notifications), isOn: Binding(
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
                            Text(i18n.localizedString(.reminderTime))
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
                            Text(i18n.localizedString(.calorieReminders))
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
                    Text(i18n.localizedString(.notifications))
                } footer: {
                    Text(i18n.localizedString(.getRemindedAboutGoals))
                }
                
                // MARK: - Appearance
                Section {
                    HStack {
                        Image(systemName: "moon.fill")
                            .foregroundColor(.purple)
                            .frame(width: 24)
                        Toggle(i18n.localizedString(.darkMode), isOn: Binding(
                            get: { settingsManager?.settings?.darkModeEnabled ?? false },
                            set: { newValue in
                                settingsManager?.updateAppearanceSettings(darkMode: newValue)
                            }
                        ))
                    }
                } header: {
                    Text(i18n.localizedString(.appearance))
                }
                
                // MARK: - Language & Region
                Section {
                    HStack {
                        Image(systemName: "globe")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text(i18n.localizedString(.language))
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
                        Text(i18n.localizedString(.region))
                        Spacer()
                        Text(settingsManager?.settings?.region ?? "United States")
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text(i18n.localizedString(.languageRegion))
                }
                
                // MARK: - Data Management
                Section {
                    HStack {
                        Image(systemName: "arrow.up.doc.fill")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        Text(i18n.localizedString(.exportDataTitle))
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
                        Text(i18n.localizedString(.clearAllData))
                        Spacer()
                        Text("")
                    }
                    .foregroundColor(.red)
                    .onTapGesture {
                        showingClearDataAlert = true
                    }
                } header: {
                    Text(i18n.localizedString(.dataManagement))
                } footer: {
                    Text(i18n.localizedString(.exportYourDataOrResetApp))
                }
                
                // MARK: - About
                Section {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text(i18n.localizedString(.version))
                        Spacer()
                        Text(settingsManager?.settings?.appVersion ?? "1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        Text(i18n.localizedString(.termsOfService))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        Text(i18n.localizedString(.privacyPolicy))
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text(i18n.localizedString(.about))
                }
            }
            .navigationTitle(i18n.localizedString(.settings))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(i18n.localizedString(.ok)) {
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
                        let lang: Language
                        switch newValue {
                        case "Русский": lang = .russian
                        case "Español": lang = .spanish
                        case "Français": lang = .french
                        default: lang = .english
                        }
                        i18n.setLanguage(lang)
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
        .alert(i18n.localizedString(.clearAllDataAlertTitle), isPresented: $showingClearDataAlert) {
            Button(i18n.localizedString(.cancel), role: .cancel) { }
            Button(i18n.localizedString(.clearAll), role: .destructive) {
                settingsManager?.clearAllData()
            }
        } message: {
            Text(i18n.localizedString(.clearAllDataAlertMessage))
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
            .navigationTitle(LocalizationManager.shared.localizedString(.language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizationManager.shared.localizedString(.done)) {
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
                    LocalizationManager.shared.localizedString(.reminderTime),
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()
                
                Spacer()
            }
            .navigationTitle(LocalizationManager.shared.localizedString(.reminderTime))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(LocalizationManager.shared.localizedString(.cancel)) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizationManager.shared.localizedString(.done)) {
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
                
                Button(LocalizationManager.shared.localizedString(.share)) {
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
            .navigationTitle(LocalizationManager.shared.localizedString(.exportDataTitle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizationManager.shared.localizedString(.done)) {
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
