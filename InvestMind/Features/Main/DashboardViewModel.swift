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
    case crypto = "Криптовалюта"
}

final class DashboardViewModel: ObservableObject {

    @Published var selectedSegment: MarketSegment = .stocks
    @Published var stockAssets: [Asset] = []
    @Published var fundAssets:  [Asset] = []
    @Published var cryptoAssets: [Asset] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    var assets: [Asset] {
        switch selectedSegment {
        case .stocks:
            return stockAssets
        case .funds:
            return fundAssets
        case .crypto:
            return cryptoAssets
        }
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
    
    private let cryptoSymbols = [
        "BTC-USD",
        "ETH-USD",
        "SOL-USD",
        "BNB-USD",
        "XRP-USD",
        "ADA-USD",
        "DOGE-USD",
        "AVAX-USD",
        "TON11419-USD",
        "LINK-USD"
    ]
    
    private let cryptoMeta: [String: (name: String, icon: String)] = [
        "BTC-USD": ("Bitcoin", "bitcoinsign.circle.fill"),
        "ETH-USD": ("Ethereum", "chart.line.uptrend.xyaxis"),
        "SOL-USD": ("Solana", "chart.line.uptrend.xyaxis"),
        "BNB-USD": ("BNB", "chart.line.uptrend.xyaxis"),
        "XRP-USD": ("XRP", "chart.line.uptrend.xyaxis"),
        "ADA-USD": ("Cardano", "chart.line.uptrend.xyaxis"),
        "DOGE-USD": ("Dogecoin", "chart.line.uptrend.xyaxis"),
        "AVAX-USD": ("Avalanche", "chart.line.uptrend.xyaxis"),
        "TON11419-USD": ("Toncoin", "chart.line.uptrend.xyaxis"),
        "LINK-USD": ("Chainlink", "chart.line.uptrend.xyaxis")
    ]

    func loadMarket() {
        switch selectedSegment {
        case .stocks:
            loadStocks()
        case .funds:
            loadFunds()
        case .crypto:
            loadCrypto()
        }
    }

    func selectSegment(_ segment: MarketSegment) {
        selectedSegment = segment
        switch segment {
        case .stocks where stockAssets.isEmpty:
            loadStocks()
        case .funds where fundAssets.isEmpty:
            loadFunds()
        case .crypto where cryptoAssets.isEmpty:
            loadCrypto()
        default:
            break
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
    
    private func loadCrypto() {
        load(symbols: cryptoSymbols, meta: cryptoMeta) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let assets):
                self.cryptoAssets = assets
            case .failure(let error):
                self.errorMessage = error.localizedDescription
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
