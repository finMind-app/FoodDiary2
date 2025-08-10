import SwiftUI
import SwiftData

struct DaySummary {
    let calories: Double
    let protein: Double
    let fat: Double
    let carbs: Double
}

func summarize(meals: [Meal]) -> DaySummary {
    DaySummary(
        calories: meals.reduce(0) { $0 + $1.calories },
        protein: meals.reduce(0) { $0 + $1.protein },
        fat: meals.reduce(0) { $0 + $1.fat },
        carbs: meals.reduce(0) { $0 + $1.carbs }
    )
}

struct PlumpyCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }
    var body: some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
    }
}

struct PlumpyCircularProgress: View {
    var progress: Double
    var lineWidth: CGFloat = 16
    var goalExceeded: Bool
    var body: some View {
        ZStack {
            Circle().stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(goalExceeded ? Color.red : Color.green, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.6), value: progress)
        }
    }
}

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Meal.date) private var allMeals: [Meal]
    @Query private var profiles: [UserProfile]
    @State private var showAddMeal = false
    @State private var quickType: MealType? = nil
    @State private var showProfile = false

    var body: some View {
        let profile = profiles.first
        let todayMeals = allMeals.filter { Calendar.current.isDateInToday($0.date) }
        let summary = summarize(meals: todayMeals)
        let goal = max(1, profile?.dailyCalories ?? 2000)
        let progress = summary.calories / goal
        let goalExceeded = progress > 1.001 || progress < 0.2

        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ZStack {
                        PlumpyCircularProgress(progress: progress, lineWidth: 20, goalExceeded: goalExceeded)
                            .frame(width: 220, height: 220)
                        VStack(spacing: 4) {
                            Text("\(Int(summary.calories)) / \(Int(goal))")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                            Text("ккал сегодня").foregroundStyle(.secondary)
                        }
                    }

                    PlumpyCard {
                        HStack(spacing: 16) {
                            macroBox("Белки", value: summary.protein, target: profile?.proteinTarget)
                            macroBox("Жиры", value: summary.fat, target: profile?.fatTarget)
                            macroBox("Углев.", value: summary.carbs, target: profile?.carbTarget)
                        }
                    }
                    .onTapGesture { showProfile = true }

                    PlumpyCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Быстрые действия").font(.headline)
                            let grid: [MealType] = [.breakfast, .lunch, .dinner, .snack, .afternoonSnack]
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                                ForEach(grid) { t in
                                    Button { quickType = t; showAddMeal = true } label: {
                                        VStack { Image(systemName: t.systemImage).font(.title2); Text(t.title).font(.caption2) }
                                            .frame(maxWidth: .infinity)
                                            .padding(8)
                                            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.accentColor.opacity(0.12)))
                                    }.buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    PlumpyCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Сегодня").font(.headline)
                            if todayMeals.isEmpty {
                                Text("Нет записей. Добавьте приём пищи.").foregroundStyle(.secondary)
                            } else {
                                ForEach(todayMeals) { m in
                                    HStack {
                                        Image(systemName: m.type.systemImage)
                                        VStack(alignment: .leading) {
                                            Text(m.type.title).font(.subheadline.bold())
                                            Text("\(Int(m.calories)) ккал • Б \(Int(m.protein)) Ж \(Int(m.fat)) У \(Int(m.carbs))")
                                                .font(.caption).foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text(m.date, style: .time).foregroundStyle(.secondary).font(.caption)
                                    }.padding(.vertical, 6)
                                }
                            }
                        }
                    }
                }.padding(16)
            }
            .navigationTitle("Food Diary")
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button { quickType = nil; showAddMeal = true } label: { Image(systemName: "plus.circle.fill").font(.title2) } } }
            .sheet(isPresented: $showAddMeal) { AddMealView(defaultType: quickType) }
            .sheet(isPresented: $showProfile) { ProfileView() }
        }
    }

    @ViewBuilder
    private func macroBox(_ title: String, value: Double, target: Double?) -> some View {
        let t = target ?? 0
        let color: Color = (t > 0 && value > t * 1.05) ? .red : .green
        VStack { Text(title).font(.caption).foregroundStyle(.secondary); Text("\(Int(value)) / \(Int(t))").font(.headline).foregroundStyle(color) }
            .frame(maxWidth: .infinity)
    }
}


