//
//  StockDetailViewModel.swift
//  InvestMind
//
//  Created by Булат Хусаинов on 23.12.2025.
//

import Foundation
import SwiftUI


enum ChartPeriod: String, CaseIterable, Identifiable {
    case month1 = "1M"
    case month3 = "3M"
    case month6 = "6M"
    case year = "1Y"

    var id: String { rawValue }
}

// MARK: - Аналитика и рекомендации

enum Recommendation: String {
    case strongBuy = "Покупать"
    case buy = "Покупать "
    case hold = "Держать"
    case sell = "Продавать "
    case strongSell = "Продавать"
    
    var color: Color {
        switch self {
        case .strongBuy: return .green
        case .buy: return .green.opacity(0.9)
        case .hold: return .yellow
        case .sell: return .orange
        case .strongSell: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .strongBuy: return "arrow.up.circle.fill"
        case .buy: return "arrow.up.circle"
        case .hold: return "hand.raised.circle"
        case .sell: return "arrow.down.circle"
        case .strongSell: return "arrow.down.circle.fill"
        }
    }
}


@MainActor
final class StockDetailViewModel: ObservableObject {

    let asset: Asset

    @Published var price: Double?
    
    @Published var recommendation: Recommendation?
    @Published var growthPotential: Double? // перспектива роста в %


    @Published var dayChangeValue: Double?
    @Published var dayChangePercent: Double?
    
    @Published var month1ChangeValue: Double?
    @Published var month1ChangePercent: Double?
    
    @Published var month3ChangeValue: Double?
    @Published var month3ChangePercent: Double?

    @Published var month6ChangeValue: Double?
    @Published var month6ChangePercent: Double?

    @Published var yearChangeValue: Double?
    @Published var yearChangePercent: Double?

    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var selectedPeriod: ChartPeriod = .year
    @Published var chartPrices: [Double] = []

    /// Годовой ряд дневных цен только для технического анализа.
    /// Не зависит от выбранного на графике периода, поэтому прогноз стабилен.
    private var analysisPrices: [Double] = []

    init(asset: Asset) {
        self.asset = asset
    }

    func load() {
        isLoading = true
        errorMessage = nil

        loadQuote()
        loadMonth1Summary()
        loadMonth3Summary()
        loadMonth6Summary()
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
        ChartAPI.shared.getQuote(symbol: asset.ticker) { [weak self] result in
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

                    // Полный годовой ряд — основа технического анализа.
                    self.analysisPrices = prices
                    self.analyzeStockPerformance()

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func loadMonth1Summary() {
        ChartAPI.shared.fetchHistory(symbol: asset.ticker, days: 30) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case .success(let prices):
                    guard let first = prices.first, let last = prices.last, first != 0 else {
                        self.month1ChangeValue = nil
                        self.month1ChangePercent = nil
                        return
                    }
                    let diff = last - first
                    self.month1ChangeValue = diff
                    self.month1ChangePercent = diff / first * 100
                case .failure:
                    break
                }
            }
        }
    }
    
    private func loadMonth3Summary() {
        ChartAPI.shared.fetchHistory(symbol: asset.ticker, days: 90) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case .success(let prices):
                    guard let first = prices.first, let last = prices.last, first != 0 else {
                        self.month3ChangeValue = nil
                        self.month3ChangePercent = nil
                        return
                    }
                    let diff = last - first
                    self.month3ChangeValue = diff
                    self.month3ChangePercent = diff / first * 100
                case .failure:
                    break
                }
            }
        }
    }

    private func loadMonth6Summary() {
        ChartAPI.shared.fetchHistory(symbol: asset.ticker, days: 180) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case .success(let prices):
                    guard let first = prices.first, let last = prices.last, first != 0 else {
                        self.month6ChangeValue = nil
                        self.month6ChangePercent = nil
                        return
                    }
                    let diff = last - first
                    self.month6ChangeValue = diff
                    self.month6ChangePercent = diff / first * 100
                case .failure:
                    break
                }
            }
        }
    }
    // MARK: - Технический анализ

    /// Считает рекомендацию по году дневных цен через TechnicalAnalysis.
    /// Прогноз стабилен и не зависит от выбранного на графике периода.
    func analyzeStockPerformance() {
        guard let result = TechnicalAnalysis.analyze(prices: analysisPrices) else {
            recommendation = nil
            growthPotential = nil
            return
        }
        recommendation = result.recommendation
        growthPotential = result.growthPotential
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
