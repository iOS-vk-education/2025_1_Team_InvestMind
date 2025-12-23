import SwiftUI

struct StockSearchView: View {
    @Environment(\.dismiss) private var dismiss

    var onSelect: (Asset) -> Void

    @State private var query: String = ""
    @State private var results: [SymbolSearchItem] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(AppColors.danger)
                        .font(AppTypography.caption())
                        .padding(.horizontal)
                        .padding(.top, 8)
                }

                List {
                    ForEach(results, id: \.self) { item in
                        Button {
                            let asset = Asset(
                                ticker: item.symbol,
                                name: item.description,
                                price: 0,
                                change: .up(0),
                                icon: "chart.line.uptrend.xyaxis"
                            )
                            onSelect(asset)
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.symbol)
                                    .foregroundStyle(AppColors.textPrimary)
                                Text(item.description)
                                    .foregroundStyle(AppColors.textSecondary)
                                    .font(AppTypography.caption())
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .overlay {
                    if isLoading {
                        ProgressView()
                    }
                }
            }
            .navigationTitle("Поиск")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") { dismiss() }
                }
            }
        }
        .searchable(text: $query, prompt: "Тикер или компания")
        .onChange(of: query) { _, newValue in
            search(text: newValue)
        }
    }

    private func search(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 1 else {
            results = []
            errorMessage = nil
            return
        }

        isLoading = true
        errorMessage = nil

        MarketAPI.shared.searchSymbols(query: trimmed) { result in
            isLoading = false
            switch result {
            case .success(let response):
                results = response.result
            case .failure(let error):
                results = []
                errorMessage = error.localizedDescription
            }
        }
    }
}
