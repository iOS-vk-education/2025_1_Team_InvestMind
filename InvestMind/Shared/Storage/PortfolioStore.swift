import Foundation
import SwiftUI

final class PortfolioStore: ObservableObject {
    @Published private(set) var portfolios: [UserPortfolio] = []
    @Published private(set) var isRefreshing = false

    private var persisted: PersistedPortfolios
    private let storage: PortfolioStorage

    init(storage: PortfolioStorage = JSONPortfolioStorage()) {
        self.storage = storage

        if let loaded = storage.load() {
            self.persisted = loaded
        } else {
            self.persisted = PersistedPortfolios(portfolios: [])
            storage.save(persisted: self.persisted)
        }

        self.portfolios = self.persisted.toUserPortfolios()
    }

    func addPortfolio(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        persisted.portfolios.append(
            PersistedPortfolio(id: UUID(), name: trimmed, positions: [])
        )
        persistAndPublish()
    }

    func buy(asset: Asset, amount: Double, pricePerShare: Double, portfolioId: UUID) {
        guard amount > 0, pricePerShare >= 0 else { return }
        guard let pIndex = persisted.portfolios.firstIndex(where: { $0.id == portfolioId }) else { return }

        let snapshot = PersistedAssetSnapshot(
            ticker: asset.ticker,
            name: asset.name,
            icon: asset.icon,
            lastPrice: pricePerShare
        )

        if let posIndex = persisted.portfolios[pIndex].positions.firstIndex(where: { $0.asset.ticker == asset.ticker }) {
            persisted.portfolios[pIndex].positions[posIndex].amount += amount
            persisted.portfolios[pIndex].positions[posIndex].invested += amount * pricePerShare
            persisted.portfolios[pIndex].positions[posIndex].asset = snapshot
        } else {
            persisted.portfolios[pIndex].positions.append(
                PersistedPosition(
                    asset: snapshot,
                    amount: amount,
                    invested: amount * pricePerShare
                )
            )
        }

        persistAndPublish()
    }

    func sell(assetTicker: String, amount: Double, pricePerShare: Double, portfolioId: UUID) {
        guard amount > 0, pricePerShare >= 0 else { return }
        guard let pIndex = persisted.portfolios.firstIndex(where: { $0.id == portfolioId }) else { return }
        guard let posIndex = persisted.portfolios[pIndex].positions.firstIndex(where: { $0.asset.ticker == assetTicker }) else { return }

        var pos = persisted.portfolios[pIndex].positions[posIndex]
        guard pos.amount >= amount else { return }

        let sellRatio = amount / pos.amount
        pos.amount -= amount
        pos.invested -= pos.invested * sellRatio
        pos.asset.lastPrice = pricePerShare

        if pos.amount <= 0.000_001 {
            persisted.portfolios[pIndex].positions.remove(at: posIndex)
        } else {
            persisted.portfolios[pIndex].positions[posIndex] = pos
        }

        persistAndPublish()
    }

    func hasPosition(ticker: String, in portfolioId: UUID) -> Bool {
        guard let p = persisted.portfolios.first(where: { $0.id == portfolioId }) else { return false }
        return p.positions.contains(where: { $0.asset.ticker == ticker && $0.amount > 0 })
    }

    func allPortfoliosMeta() -> [(id: UUID, name: String)] {
        persisted.portfolios.map { ($0.id, $0.name) }
    }

    func positionAmount(ticker: String, in portfolioId: UUID) -> Double {
        guard let p = persisted.portfolios.first(where: { $0.id == portfolioId }) else { return 0 }
        return p.positions.first(where: { $0.asset.ticker == ticker })?.amount ?? 0
    }

    func refreshMarketData(completion: ((Error?) -> Void)? = nil) {
        isRefreshing = true
        let tickers = Array(Set(
            persisted.portfolios
                .flatMap { $0.positions }
                .map { $0.asset.ticker }
        ))

        guard !tickers.isEmpty else {
            portfolios = persisted.toUserPortfolios()
            isRefreshing = false
            completion?(nil)
            return
        }

        ChartAPI.shared.getQuotes(symbols: tickers) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let quotesByTicker):
                for portfolioIndex in self.persisted.portfolios.indices {
                    for positionIndex in self.persisted.portfolios[portfolioIndex].positions.indices {
                        let ticker = self.persisted.portfolios[portfolioIndex].positions[positionIndex].asset.ticker
                        if let quote = quotesByTicker[ticker] {
                            self.persisted.portfolios[portfolioIndex].positions[positionIndex].asset.lastPrice = quote.c
                        }
                    }
                }

                self.persistAndPublish(quotesByTicker: quotesByTicker)
                self.isRefreshing = false
                completion?(nil)

            case .failure(let error):
                self.portfolios = self.persisted.toUserPortfolios()
                self.isRefreshing = false
                completion?(error)
            }
        }
    }

    private func persistAndPublish(quotesByTicker: [String: QuoteResponse]? = nil) {
        storage.save(persisted: persisted)
        portfolios = persisted.toUserPortfolios(quotesByTicker: quotesByTicker)
    }
}

// MARK: - Persistence

protocol PortfolioStorage {
    func load() -> PersistedPortfolios?
    func save(persisted: PersistedPortfolios)
}

struct JSONPortfolioStorage: PortfolioStorage {
    private let url: URL

    init(filename: String = "portfolios.json") {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.url = docs.appendingPathComponent(filename)
    }

    func load() -> PersistedPortfolios? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(PersistedPortfolios.self, from: data)
    }

    func save(persisted: PersistedPortfolios) {
        guard let data = try? JSONEncoder().encode(persisted) else { return }
        try? data.write(to: url, options: [.atomic])
    }
}

// MARK: - DTOs

struct PersistedPortfolios: Codable {
    var portfolios: [PersistedPortfolio]

    func toUserPortfolios(quotesByTicker: [String: QuoteResponse]? = nil) -> [UserPortfolio] {
        portfolios.map { p in
            let assets: [PortfolioAsset] = p.positions.map { pos in
                let quote = quotesByTicker?[pos.asset.ticker]
                let currentPrice = quote?.c ?? pos.asset.lastPrice
                let currentValue = pos.amount * currentPrice

                let positionReturnPercent: Double
                if pos.invested > 0 {
                    positionReturnPercent = (currentValue - pos.invested) / pos.invested * 100
                } else {
                    positionReturnPercent = 0
                }

                let asset = Asset(
                    ticker: pos.asset.ticker,
                    name: pos.asset.name,
                    price: currentPrice,
                    change: positionReturnPercent >= 0
                        ? .up(positionReturnPercent)
                        : .down(abs(positionReturnPercent)),
                    icon: pos.asset.icon
                )

                return PortfolioAsset(asset: asset, amount: pos.amount, invested: pos.invested)
            }

            let totalValue = assets.map { $0.amount * $0.asset.price }.reduce(0, +)
            let invested = assets.map { $0.invested }.reduce(0, +)

            let totalReturnPercent: Double
            if invested > 0 {
                totalReturnPercent = (totalValue - invested) / invested * 100
            } else {
                totalReturnPercent = 0
            }

            let summary = PortfolioSummary(
                totalValue: totalValue,
                invested: invested,
                totalReturnPercent: totalReturnPercent
            )

            return UserPortfolio(id: p.id, name: p.name, summary: summary, assets: assets)
        }
    }
}

struct PersistedPortfolio: Codable {
    let id: UUID
    var name: String
    var positions: [PersistedPosition]
}

struct PersistedPosition: Codable {
    var asset: PersistedAssetSnapshot
    var amount: Double
    var invested: Double
}

struct PersistedAssetSnapshot: Codable {
    let ticker: String
    let name: String
    let icon: String
    var lastPrice: Double
}
