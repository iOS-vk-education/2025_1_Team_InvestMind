import SwiftUI

struct BuyStockView: View {
    @EnvironmentObject var portfolioStore: PortfolioStore
    @Environment(\.dismiss) private var dismiss

    let asset: Asset
    let pricePerShare: Double

    @State private var selectedPortfolioId: UUID?
    @State private var amountText: String = ""

    private var portfolios: [(id: UUID, name: String)] {
        portfolioStore.allPortfoliosMeta()
    }

    private var amount: Double? {
        Double(amountText.replacingOccurrences(of: ",", with: "."))
    }

    private var totalPrice: Double? {
        guard let amount, amount > 0 else { return nil }
        return amount * pricePerShare
    }

    private var portfolioSelection: Binding<UUID?> {
        Binding<UUID?>(
            get: { selectedPortfolioId ?? portfolios.first?.id },
            set: { selectedPortfolioId = $0 }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Портфель", selection: portfolioSelection) {
                        ForEach(portfolios, id: \.id) { item in
                            Text(item.name).tag(Optional(item.id))
                        }
                    }
                }

                Section {
                    TextField("Количество", text: $amountText)
                        .keyboardType(.decimalPad)

                    HStack {
                        Text("Цена за 1")
                        Spacer()
                        Text(String(format: "$%.2f", pricePerShare))
                    }

                    HStack {
                        Text("Итого")
                        Spacer()
                        if let totalPrice {
                            Text(String(format: "$%.2f", totalPrice))
                        } else {
                            Text("-")
                        }
                    }
                }
            }
            .navigationTitle("Купить \(asset.ticker)")
            .scrollContentBackground(.hidden)
            .background(AppColors.backgroundPrimary)
            .preferredColorScheme(.dark)
            .tint(AppColors.accentPrimary)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Купить") {
                        guard let amount, amount > 0 else { return }
                        let portfolioId = selectedPortfolioId ?? portfolios.first?.id
                        guard let portfolioId else { return }

                        portfolioStore.buy(asset: asset, amount: amount, pricePerShare: pricePerShare, portfolioId: portfolioId)
                        dismiss()
                    }
                    .disabled(portfolios.isEmpty || totalPrice == nil)
                }
            }
        }
        .presentationBackground(AppColors.backgroundPrimary)
    }
}
