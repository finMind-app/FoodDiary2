import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]

    @State private var name: String = ""
    @State private var sex: Sex = .male
    @State private var weight: String = "70"
    @State private var height: String = "175"
    @State private var activity: ActivityLevel = .medium
    @State private var goal: Goal = .maintain

    var body: some View {
        NavigationStack {
            Form {
                Section("Персональные данные") {
                    TextField("Имя", text: $name)
                    Picker("Пол", selection: $sex) {
                        Text("Муж").tag(Sex.male)
                        Text("Жен").tag(Sex.female)
                    }
                    TextField("Вес (кг)", text: $weight).keyboardType(.decimalPad)
                    TextField("Рост (см)", text: $height).keyboardType(.decimalPad)
                    Picker("Активность", selection: $activity) {
                        ForEach(ActivityLevel.allCases) { Text($0.title).tag($0) }
                    }
                    Picker("Цель", selection: $goal) {
                        ForEach(Goal.allCases) { Text($0.title).tag($0) }
                    }
                }
                Section("Рекомендации") {
                    if let p = profiles.first {
                        Text("Калории: \(Int(p.dailyCalories))")
                        Text("Б/Ж/У: \(Int(p.proteinTarget))/\(Int(p.fatTarget))/\(Int(p.carbTarget)) г")
                    } else {
                        Text("Пока нет данных")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Профиль")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Закрыть") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) { Button("Сохранить", action: save) }
            }
            .onAppear(perform: load)
        }
    }

    private func load() {
        if let p = profiles.first {
            name = p.name
            sex = p.sex
            weight = String(Int(p.weightKg))
            height = String(Int(p.heightCm))
            activity = p.activity
            goal = p.goal
        }
    }

    private func save() {
        let w = Double(weight) ?? 70
        let h = Double(height) ?? 175
        let profile = profiles.first ?? UserProfile()
        profile.name = name
        profile.sexRaw = sex.rawValue
        profile.weightKg = w
        profile.heightCm = h
        profile.activityRaw = activity.rawValue
        profile.goalRaw = goal.rawValue
        profile.recalculateTargets()
        if profiles.first == nil { modelContext.insert(profile) }
        dismiss()
    }
}


