import SwiftUI
import SwiftData
import PhotosUI

struct AddMealView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var type: MealType
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var fat: String = ""
    @State private var carbs: String = ""
    @State private var note: String = ""
    @State private var image: UIImage? = nil
    @State private var isShowingPicker = false

    init(defaultType: MealType?) { _type = State(initialValue: defaultType ?? .other) }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Тип", selection: $type) { ForEach(MealType.allCases) { Text($0.title).tag($0) } }
                Section("Калории и БЖУ") {
                    TextField("Калории", text: $calories).keyboardType(.decimalPad)
                    TextField("Белки (г)", text: $protein).keyboardType(.decimalPad)
                    TextField("Жиры (г)", text: $fat).keyboardType(.decimalPad)
                    TextField("Углеводы (г)", text: $carbs).keyboardType(.decimalPad)
                }
                Section("Фото и заметка") {
                    if let image { Image(uiImage: image).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 16)).padding(.vertical, 4) }
                    Button("Добавить фото") { isShowingPicker = true }
                    TextField("Текст", text: $note, axis: .vertical).lineLimit(3...6)
                }
                Section("AI-заглушка") {
                    Button { calories = "350"; protein = "20"; fat = "15"; carbs = "30" } label: { Label("Определить по фото (заглушка)", systemImage: "wand.and.rays") }
                }
            }
            .navigationTitle("Добавить приём")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { Button("Отмена") { dismiss() } }
                ToolbarItem(placement: .topBarTrailing) { Button("Сохранить", action: save) }
            }
            .sheet(isPresented: $isShowingPicker) { ImagePicker(image: $image) }
        }
    }

    private func save() {
        let c = Double(calories) ?? 0
        let p = Double(protein) ?? 0
        let f = Double(fat) ?? 0
        let cb = Double(carbs) ?? 0
        let photoData = image.flatMap { $0.jpegData(compressionQuality: 0.7) }
        let meal = Meal(date: Date(), type: type, calories: c, protein: p, fat: f, carbs: cb, note: note, photoData: photoData)
        modelContext.insert(meal)
        dismiss()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(); config.filter = .images
        let picker = PHPickerViewController(configuration: config); picker.delegate = context.coordinator; return picker
    }
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    func makeCoordinator() -> Coord { Coord(self) }
    final class Coord: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker; init(_ parent: ImagePicker) { self.parent = parent }
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else { return }
            provider.loadObject(ofClass: UIImage.self) { object, _ in DispatchQueue.main.async { self.parent.image = object as? UIImage } }
        }
    }
}


