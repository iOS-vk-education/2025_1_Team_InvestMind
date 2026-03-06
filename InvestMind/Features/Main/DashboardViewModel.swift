//
//  DashboardViewModel.swift
//  InvestMind
//
//  Created by Булат Хусаинов on 23.12.2025.
//

import Foundation
import SwiftUI

final class DashboardViewModel: ObservableObject {

    @Published var assets: [Asset] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let symbols = ["AAPL", "MSFT", "NVDA", "AMZN", "GOOGL", "META", "TSLA", "NFLX", "AMD", "INTC"]

    private let meta: [String: (name: String, icon: String)] = [
        "AAPL": ("Apple", "applelogo"),
        "MSFT": ("Microsoft", "pc"),
        "NVDA": ("NVIDIA", "cpu.fill"),
        "AMZN": ("Amazon", "cart.fill"),
        "GOOGL": ("Alphabet", "globe"),
        "META": ("Meta", "person.2.fill"),
        "TSLA": ("Tesla", "bolt.fill"),
        "NFLX": ("Netflix", "film.fill"),
        "AMD": ("AMD", "memorychip"),
        "INTC": ("Intel", "memorychip")
    ]

    func loadMarket() {
        isLoading = true
        errorMessage = nil

        ChartAPI.shared.getQuotes(symbols: symbols) { [weak self] result in
            guard let self else { return }
            self.isLoading = false

            switch result {
            case .success(let quotesBySymbol):
                let newAssets: [Asset] = self.symbols.compactMap { symbol in
                    guard let quote = quotesBySymbol[symbol] else { return nil }
                    let info = self.meta[symbol] ?? (symbol, "chart.line.uptrend.xyaxis")

                    return Asset(
                        ticker: symbol,
                        name: info.name,
                        price: quote.c,
                        change: quote.dp >= 0 ? .up(quote.dp) : .down(abs(quote.dp)),
                        icon: info.icon
                    )
                }

                self.assets = newAssets

            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
