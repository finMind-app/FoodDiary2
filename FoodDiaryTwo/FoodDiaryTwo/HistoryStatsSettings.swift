import SwiftUI
import SwiftData

struct HistoryView: View {
    @State private var selection: Int = 0
    @Query(sort: \Meal.date, order: .reverse) private var meals: [Meal]
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Период", selection: $selection) {
                    Text("День").tag(0)
                    Text("Неделя").tag(1)
                    Text("Месяц").tag(2)
                }.pickerStyle(.segmented).padding()
                List {
                    ForEach(filtered(meals: meals)) { m in
                        NavigationLink(value: m) {
                            HStack {
                                Image(systemName: m.type.systemImage)
                                VStack(alignment: .leading) {
                                    Text(m.type.title).font(.subheadline.bold())
                                    Text("\(Int(m.calories)) ккал • Б \(Int(m.protein)) Ж \(Int(m.fat)) У \(Int(m.carbs))")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(m.date, style: .date).foregroundStyle(.secondary).font(.caption)
                            }
                        }
                    }
                }
                .navigationDestination(for: Meal.self) { m in MealDetailView(meal: m) }
            }
            .navigationTitle("История")
        }
    }

    private func filtered(meals: [Meal]) -> [Meal] {
        let cal = Calendar.current
        switch selection {
        case 0: return meals.filter { cal.isDateInToday($0.date) }
        case 1:
            if let week = cal.dateInterval(of: .weekOfYear, for: Date()) { return meals.filter { week.contains($0.date) } }
        default:
            if let month = cal.dateInterval(of: .month, for: Date()) { return meals.filter { month.contains($0.date) } }
        }
        return meals
    }
}

struct MealDetailView: View {
    let meal: Meal
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let data = meal.photoData, let ui = UIImage(data: data) {
                    Image(uiImage: ui).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 16))
                }
                PlumpyCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(meal.type.title).font(.title2.bold())
                        Text(meal.date.formatted(date: .abbreviated, time: .shortened)).foregroundStyle(.secondary)
                        Divider()
                        Text("\(Int(meal.calories)) ккал")
                        Text("Б/Ж/У: \(Int(meal.protein))/\(Int(meal.fat))/\(Int(meal.carbs)) г")
                        if !meal.note.isEmpty { Text(meal.note) }
                    }
                }.padding(.horizontal, 16)
            }.padding(.vertical, 16)
        }.navigationTitle("Детали")
    }
}

struct StatsView: View {
    @State private var selection: Int = 0
    @Query(sort: \Meal.date) private var meals: [Meal]
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Picker("Период", selection: $selection) {
                    Text("День").tag(0)
                    Text("Неделя").tag(1)
                    Text("Месяц").tag(2)
                }.pickerStyle(.segmented).padding(.horizontal)
                PlumpyCard { VStack(alignment: .leading, spacing: 8) { Text("Калории").font(.headline); SimpleBar(values: values(for: .calories)).frame(height: 120) } }.padding(.horizontal)
                PlumpyCard { VStack(alignment: .leading, spacing: 8) { Text("БЖУ").font(.headline); SimpleBar(values: values(for: .protein), color: .blue).frame(height: 80); SimpleBar(values: values(for: .fat), color: .orange).frame(height: 80); SimpleBar(values: values(for: .carbs), color: .green).frame(height: 80) } }.padding(.horizontal)
                Spacer()
            }.navigationTitle("Статистика")
        }
    }
    enum Metric { case calories, protein, fat, carbs }
    private func values(for metric: Metric) -> [Double] {
        let cal = Calendar.current
        let days = (0..<7).compactMap { cal.date(byAdding: .day, value: -$0, to: Date()) }.reversed()
        return days.map { day in
            let dayMeals = meals.filter { cal.isDate($0.date, inSameDayAs: day) }
            let s = summarize(meals: dayMeals)
            switch metric { case .calories: return s.calories; case .protein: return s.protein; case .fat: return s.fat; case .carbs: return s.carbs }
        }
    }
}

struct SimpleBar: View {
    var values: [Double]
    var color: Color = .accentColor
    var body: some View {
        GeometryReader { geo in
            let maxV = max(values.max() ?? 1, 1)
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(values.enumerated()), id: \.offset) { _, v in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(color.opacity(0.8))
                        .frame(width: (geo.size.width - 6 * 8) / 7, height: max(4, geo.size.height * CGFloat(v / maxV)))
                }
            }
        }
    }
}

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("app.language") private var language: String = "ru"
    @AppStorage("app.theme") private var theme: String = "system"
    @AppStorage("units.mass") private var unitsMass: String = "g"
    @State private var showDeleteAlert = false
    var body: some View {
        NavigationStack {
            Form {
                Section("Интерфейс") {
                    Picker("Язык", selection: $language) { Text("Русский").tag("ru"); Text("English").tag("en") }
                    Picker("Тема", selection: $theme) { Text("Светлая").tag("light"); Text("Тёмная").tag("dark"); Text("Системная").tag("system") }
                }
                Section("Единицы") { Picker("Масса", selection: $unitsMass) { Text("Граммы").tag("g"); Text("Унции").tag("oz") } }
                Section("Поддержка") { Link("Написать разработчику", destination: URL(string: "mailto:developer@example.com")!) }
                Section { Button(role: .destructive) { showDeleteAlert = true } label: { Text("Удалить все данные") } }
            }
            .navigationTitle("Настройки")
            .alert("Точно удалить все данные?", isPresented: $showDeleteAlert) {
                Button("Отмена", role: .cancel) {}
                Button("Удалить", role: .destructive) { deleteAll() }
            } message: { Text("Это действие необратимо.") }
        }
    }
    private func deleteAll() { try? modelContext.delete(model: Meal.self); try? modelContext.delete(model: UserProfile.self) }
}


