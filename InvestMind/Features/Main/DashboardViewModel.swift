//
//  DashboardViewModel.swift
//  InvestMind
//
//  Created by Булат Хусаинов on 23.12.2025.
//

import Foundation
import SwiftUI

enum MarketSegment: String, CaseIterable {
    case stocks = "Акции"
    case funds  = "Фонды"
}

final class DashboardViewModel: ObservableObject {

    @Published var selectedSegment: MarketSegment = .stocks
    @Published var stockAssets: [Asset] = []
    @Published var fundAssets:  [Asset] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    var assets: [Asset] {
        selectedSegment == .stocks ? stockAssets : fundAssets
    }

    // MARK: – Stocks

    private let stockSymbols = ["AAPL", "MSFT", "NVDA", "AMZN", "GOOGL", "META", "TSLA", "NFLX", "AMD", "INTC"]

    private let stockMeta: [String: (name: String, icon: String)] = [
        "AAPL":  ("Apple",     "applelogo"),
        "MSFT":  ("Microsoft", "pc"),
        "NVDA":  ("NVIDIA",    "cpu.fill"),
        "AMZN":  ("Amazon",    "cart.fill"),
        "GOOGL": ("Alphabet",  "globe"),
        "META":  ("Meta",      "person.2.fill"),
        "TSLA":  ("Tesla",     "bolt.fill"),
        "NFLX":  ("Netflix",   "film.fill"),
        "AMD":   ("AMD",       "memorychip"),
        "INTC":  ("Intel",     "memorychip")
    ]

    // MARK: – Funds (ETFs)

    private let fundSymbols = ["SPY", "QQQ", "VTI", "IWM", "EFA", "GLD", "VNQ", "XLF", "XLE", "AGG"]

    private let fundMeta: [String: (name: String, icon: String)] = [
        "SPY": ("SPDR S&P 500 ETF",          "chart.bar.fill"),
        "QQQ": ("Invesco Nasdaq-100 ETF",     "chart.line.uptrend.xyaxis"),
        "VTI": ("Vanguard Total Market ETF",  "building.columns.fill"),
        "IWM": ("iShares Russell 2000 ETF",   "dollarsign.circle.fill"),
        "EFA": ("iShares MSCI EAFE ETF",      "globe.europe.africa.fill"),
        "GLD": ("SPDR Gold Shares",           "star.fill"),
        "VNQ": ("Vanguard Real Estate ETF",   "house.fill"),
        "XLF": ("Financial Select SPDR",      "banknote.fill"),
        "XLE": ("Energy Select SPDR",         "flame.fill"),
        "AGG": ("iShares Core Bond ETF",      "shield.fill")
    ]

    // MARK: – Public API

    func loadMarket() {
        switch selectedSegment {
        case .stocks: loadStocks()
        case .funds:  loadFunds()
        }
    }

    func selectSegment(_ segment: MarketSegment) {
        selectedSegment = segment
        switch segment {
        case .stocks where stockAssets.isEmpty: loadStocks()
        case .funds  where fundAssets.isEmpty:  loadFunds()
        default: break
        }
    }

    // MARK: – Private

    private func loadStocks() {
        load(symbols: stockSymbols, meta: stockMeta) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let assets): self.stockAssets = assets
            case .failure(let error): self.errorMessage = error.localizedDescription
            }
        }
    }

    private func loadFunds() {
        load(symbols: fundSymbols, meta: fundMeta) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let assets): self.fundAssets = assets
            case .failure(let error): self.errorMessage = error.localizedDescription
            }
        }
    }

    private func load(
        symbols: [String],
        meta: [String: (name: String, icon: String)],
        completion: @escaping (Result<[Asset], Error>) -> Void
    ) {
        isLoading = true
        errorMessage = nil

        ChartAPI.shared.getQuotes(symbols: symbols) { [weak self] result in
            guard let self else { return }
            self.isLoading = false

            switch result {
            case .success(let quotesBySymbol):
                let newAssets: [Asset] = symbols.compactMap { symbol in
                    guard let quote = quotesBySymbol[symbol] else { return nil }
                    let info = meta[symbol] ?? (symbol, "chart.line.uptrend.xyaxis")
                    return Asset(
                        ticker: symbol,
                        name: info.name,
                        price: quote.c,
                        change: quote.dp >= 0 ? .up(quote.dp) : .down(abs(quote.dp)),
                        icon: info.icon
                    )
                }
                completion(.success(newAssets))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
