//
//  StockDetailViewModel.swift
//  InvestMind
//
//  Created by Булат Хусаинов on 23.12.2025.
//

import Foundation

enum ChartPeriod: String, CaseIterable, Identifiable {
    case month1 = "1M"
    case month3 = "3M"
    case month6 = "6M"
    case year = "1Y"

    var id: String { rawValue }
}


@MainActor
final class StockDetailViewModel: ObservableObject {

    let asset: Asset

    @Published var price: Double?

    @Published var dayChangeValue: Double?
    @Published var dayChangePercent: Double?

    @Published var yearChangeValue: Double?
    @Published var yearChangePercent: Double?

    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var selectedPeriod: ChartPeriod = .year
    @Published var chartPrices: [Double] = []

    init(asset: Asset) {
        self.asset = asset
    }

    func load() {
        isLoading = true
        errorMessage = nil

        loadQuote()
        loadYearSummary()
        loadChartPrices()
        isLoading = false
    }

    func loadChartPrices() {
        switch selectedPeriod {

        case .month1:
            loadChartHistory(days: 30)

        case .month3:
            loadChartHistory(days: 90)

        case .month6:
            loadChartHistory(days: 180)

        case .year:
            loadChartHistory(days: 365)
        }
    }

    // 1D (Finnhub Quote)

    private func loadQuote() {
        MarketAPI.shared.fetchQuote(symbol: asset.ticker) { [weak self] result in
            guard let self else { return }

            Task { @MainActor in
                switch result {
                case .success(let quote):
                    self.price = quote.c

                    self.dayChangePercent = quote.dp
                    self.dayChangeValue = quote.d

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // 1Y (Yahoo Finance)
    private func loadYearSummary() {
        ChartAPI.shared.fetchHistory(symbol: asset.ticker, days: 365) { [weak self] result in
            guard let self else { return }

            Task { @MainActor in
                switch result {
                case .success(let prices):
                    guard
                        let first = prices.first,
                        let last = prices.last,
                        first != 0
                    else {
                        self.yearChangeValue = nil
                        self.yearChangePercent = nil
                        return
                    }

                    let diff = last - first
                    self.yearChangeValue = diff
                    self.yearChangePercent = diff / first * 100

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func loadChartHistory(days: Int) {
        ChartAPI.shared.fetchHistory(symbol: asset.ticker, days: days) { [weak self] result in
            guard let self else { return }

            Task { @MainActor in
                switch result {
                case .success(let prices):
                    self.chartPrices = prices

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }


}
