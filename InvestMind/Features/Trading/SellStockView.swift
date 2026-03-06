import SwiftUI

struct SellStockView: View {
    @EnvironmentObject var portfolioStore: PortfolioStore
    @Environment(\.dismiss) private var dismiss

    let asset: Asset
    let pricePerShare: Double

    @State private var selectedPortfolioId: UUID?
    @State private var amountText: String = ""

    private var portfolios: [(id: UUID, name: String)] {
        portfolioStore.allPortfoliosMeta()
    }

    private var selectedIdResolved: UUID? {
        selectedPortfolioId ?? portfolios.first?.id
    }

    private var availableAmount: Double {
        guard let id = selectedIdResolved else { return 0 }
        return portfolioStore.positionAmount(ticker: asset.ticker, in: id)
    }

    private var amount: Double? {
        Double(amountText.replacingOccurrences(of: ",", with: "."))
    }

    private var canSell: Bool {
        guard let amount, amount > 0 else { return false }
        return availableAmount >= amount
    }

    private var totalPrice: Double? {
        guard let amount, amount > 0 else { return nil }
        return amount * pricePerShare
    }

    private var portfolioSelection: Binding<UUID?> {
        Binding<UUID?>(
            get: { selectedPortfolioId ?? portfolios.first?.id },
            set: {
                selectedPortfolioId = $0
                amountText = ""
            }
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
                    HStack {
                        Text("Доступно")
                        Spacer()
                        Text(String(format: "%.4g", availableAmount))
                    }

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

                    if selectedIdResolved != nil && availableAmount <= 0 {
                        Text("В этом портфеле нет этой акции")
                            .foregroundStyle(AppColors.textSecondary)
                            .font(AppTypography.caption())
                    }
                }
            }
            .navigationTitle("Продать \(asset.ticker)")
            .scrollContentBackground(.hidden)
            .background(AppColors.backgroundPrimary)
            .preferredColorScheme(.dark)
            .tint(AppColors.accentPrimary)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Продать") {
                        guard canSell else { return }
                        guard let amount else { return }
                        guard let portfolioId = selectedIdResolved else { return }

                        portfolioStore.sell(assetTicker: asset.ticker, amount: amount, pricePerShare: pricePerShare, portfolioId: portfolioId)
                        dismiss()
                    }
                    .disabled(portfolios.isEmpty || !canSell)
                }
            }
        }
        .presentationBackground(AppColors.backgroundPrimary)
    }
}
