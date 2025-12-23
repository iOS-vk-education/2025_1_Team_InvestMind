import SwiftUI

struct AddPortfolioView: View {
    @EnvironmentObject var portfolioStore: PortfolioStore
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Название", text: $name)
                        .textInputAutocapitalization(.sentences)
                }
            }
            .navigationTitle("Новый портфель")
            .scrollContentBackground(.hidden)
            .background(AppColors.backgroundPrimary)
            .preferredColorScheme(.dark)
            .tint(AppColors.accentPrimary)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Создать") {
                        portfolioStore.addPortfolio(name: name)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationBackground(AppColors.backgroundPrimary)
    }
}
