import Foundation
import SwiftUI

// MARK: - PortfolioStore

final class PortfolioStore: ObservableObject {

    // Публичные данные для UI
    @Published private(set) var portfolios: [UserPortfolio] = []
    @Published private(set) var isRefreshing = false

    // Текущая валюта — при изменении пересчитываем портфели
    @Published var selectedCurrency: AppCurrency = {
        AppCurrency(rawValue: UserDefaults.standard.string(forKey: "selectedCurrency") ?? "") ?? .usd
    }() {
        didSet {
            UserDefaults.standard.set(selectedCurrency.rawValue, forKey: "selectedCurrency")
            recompute()
        }
    }

    // Актуальные рыночные цены (USD) по тикеру, обновляются через refreshMarketData()
    @Published private(set) var currentRates: [String: Double] = [:]

    private var persisted: [PersistedPortfolio] = []
    private var currentPrices: [String: Double] = [:]
    private var userId: String?

    private let firestoreService = FirestorePortfolioService()

    // Локальный JSON-стор — используется при миграции и как fallback
    private let localStorage = JSONPortfolioStorage()

    // MARK: - Setup / Teardown

    func setup(userId: String) {
        guard self.userId != userId else { return }
        self.userId = userId

        // Загружаем актуальные курсы валют
        refreshExchangeRates()

        // Подписываемся на Firestore; при первом получении данных автоматически мигрируем
        firestoreService.startListening(uid: userId) { [weak self] remotePortfolios in
            guard let self else { return }
            if remotePortfolios.isEmpty {
                self.migrateLocalDataIfNeeded(uid: userId)
            } else {
                self.persisted = remotePortfolios
                self.recompute()
            }
        }
    }

    func tearDown() {
        firestoreService.stopListening()
        userId = nil
        persisted = []
        portfolios = []
        currentPrices = [:]
    }

    // MARK: - Public API (portfolio management)

    func addPortfolio(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let portfolio = PersistedPortfolio(name: trimmed)
        persisted.append(portfolio)
        persist(portfolio)
        recompute()
    }

    func renamePortfolio(id: UUID, newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let i = persisted.firstIndex(where: { $0.id == id }) else { return }
        persisted[i].name = trimmed
        persist(persisted[i])
        recompute()
    }

    func deletePortfolio(id: UUID) {
        persisted.removeAll { $0.id == id }
        guard let uid = userId else { return }
        Task { try? await firestoreService.delete(portfolioId: id, uid: uid) }
        recompute()
    }

    // MARK: - Trading

    func buy(asset: Asset, amount: Double, pricePerShare: Double, portfolioId: UUID) {
        guard amount > 0, pricePerShare >= 0,
              let i = persisted.firstIndex(where: { $0.id == portfolioId }) else { return }

        let txn = PersistedTransaction(
            id: UUID().uuidString,
            ticker: asset.ticker,
            name: asset.name,
            icon: asset.icon,
            type: .buy,
            amount: amount,
            pricePerShareUSD: pricePerShare,
            purchaseDate: Date(),
            exchangeRatesAtTime: currentRates  // курсы на момент покупки
        )

        persisted[i].transactions.append(txn)
        persist(persisted[i])
        recompute()
    }

    func sell(assetTicker: String, amount: Double, pricePerShare: Double, portfolioId: UUID) {
        guard amount > 0, pricePerShare >= 0,
              let i = persisted.firstIndex(where: { $0.id == portfolioId }) else { return }

        let netHeld = netAmount(ticker: assetTicker, in: persisted[i])
        guard netHeld >= amount else { return }

        // Берём мета-данные актива из последней buy-транзакции
        let lastBuy = persisted[i].transactions
            .filter { $0.ticker == assetTicker && $0.type == .buy }
            .max(by: { $0.purchaseDate < $1.purchaseDate })

        let txn = PersistedTransaction(
            id: UUID().uuidString,
            ticker: assetTicker,
            name: lastBuy?.name ?? assetTicker,
            icon: lastBuy?.icon ?? "chart.line.uptrend.xyaxis",
            type: .sell,
            amount: amount,
            pricePerShareUSD: pricePerShare,
            purchaseDate: Date(),
            exchangeRatesAtTime: currentRates  // курсы на момент продажи
        )

        persisted[i].transactions.append(txn)
        persist(persisted[i])
        recompute()
    }

    // MARK: - Queries

    func hasPosition(ticker: String, in portfolioId: UUID) -> Bool {
        guard let p = persisted.first(where: { $0.id == portfolioId }) else { return false }
        return netAmount(ticker: ticker, in: p) > 0.000_001
    }

    func allPortfoliosMeta() -> [(id: UUID, name: String)] {
        persisted.map { ($0.id, $0.name) }
    }

    func positionAmount(ticker: String, in portfolioId: UUID) -> Double {
        guard let p = persisted.first(where: { $0.id == portfolioId }) else { return 0 }
        return netAmount(ticker: ticker, in: p)
    }

    // MARK: - Market refresh

    func refreshMarketData(completion: ((Error?) -> Void)? = nil) {
        isRefreshing = true
        let tickers = allTickers()
        guard !tickers.isEmpty else {
            recompute()
            isRefreshing = false
            completion?(nil)
            return
        }

        refreshExchangeRates()

        ChartAPI.shared.getQuotes(symbols: tickers) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let quotes):
                for (ticker, quote) in quotes {
                    self.currentPrices[ticker] = quote.c
                }
                self.recompute()
                self.isRefreshing = false
                completion?(nil)
            case .failure(let error):
                self.recompute()
                self.isRefreshing = false
                completion?(error)
            }
        }
    }

    // MARK: - Private helpers

    private func netAmount(ticker: String, in portfolio: PersistedPortfolio) -> Double {
        portfolio.transactions
            .filter { $0.ticker == ticker }
            .reduce(0.0) { acc, txn in
                txn.type == .buy ? acc + txn.amount : acc - txn.amount
            }
    }

    private func allTickers() -> [String] {
        Array(Set(persisted.flatMap { $0.transactions.map(\.ticker) }))
    }

    private func persist(_ portfolio: PersistedPortfolio) {
        guard let uid = userId else { return }
        Task { try? await firestoreService.save(portfolio, uid: uid) }
    }

    private func refreshExchangeRates() {
        ExchangeRateAPI.shared.fetchCurrentRates { [weak self] rates in
            self?.currentRates = rates
            self?.recompute()
        }
    }

    // Пересчитывает UserPortfolio из транзакций с учётом выбранной валюты.
    private func recompute() {
        let currency = selectedCurrency
        let currentRateToDisplay = currency == .usd ? 1.0 : (currentRates[currency.rawValue] ?? 1.0)

        portfolios = persisted.map { p in
            // Группируем транзакции по тикеру
            let grouped = Dictionary(grouping: p.transactions, by: { $0.ticker })

            let assets: [PortfolioAsset] = grouped.compactMap { ticker, txns -> PortfolioAsset? in
                let net = txns.reduce(0.0) { acc, t in t.type == .buy ? acc + t.amount : acc - t.amount }
                guard net > 0.000_001 else { return nil }

                // Рассчитываем вложения в выбранной валюте, используя курс на дату каждой транзакции
                let investedInCurrency: Double
                if currency == .usd {
                    let bought = txns.filter { $0.type == .buy }
                        .reduce(0.0) { $0 + $1.amount * $1.pricePerShareUSD }
                    let sold   = txns.filter { $0.type == .sell }
                        .reduce(0.0) { $0 + $1.amount * $1.pricePerShareUSD }
                    investedInCurrency = max(0, bought - sold)
                } else {
                    // Для каждой транзакции используем курс на момент операции (historicalRate),
                    // а не текущий — это и есть то, что просил тимлид.
                    let key = currency.rawValue
                    let bought = txns.filter { $0.type == .buy }
                        .reduce(0.0) { acc, t in
                            let rate = t.exchangeRatesAtTime[key] ?? currentRateToDisplay
                            return acc + t.amount * t.pricePerShareUSD * rate
                        }
                    let sold = txns.filter { $0.type == .sell }
                        .reduce(0.0) { acc, t in
                            let rate = t.exchangeRatesAtTime[key] ?? currentRateToDisplay
                            return acc + t.amount * t.pricePerShareUSD * rate
                        }
                    investedInCurrency = max(0, bought - sold)
                }

                let priceUSD = currentPrices[ticker]
                    ?? txns.filter { $0.type == .buy }.max(by: { $0.purchaseDate < $1.purchaseDate })?.pricePerShareUSD
                    ?? 0
                // Текущая цена в выбранной валюте — по текущему курсу
                let displayPrice = priceUSD * currentRateToDisplay

                let lastBuy = txns.filter { $0.type == .buy }.max(by: { $0.purchaseDate < $1.purchaseDate })
                let changePercent = investedInCurrency > 0
                    ? (net * displayPrice - investedInCurrency) / investedInCurrency * 100
                    : 0

                let asset = Asset(
                    ticker: ticker,
                    name: lastBuy?.name ?? ticker,
                    price: displayPrice,
                    change: changePercent >= 0 ? .up(changePercent) : .down(abs(changePercent)),
                    icon: lastBuy?.icon ?? "chart.line.uptrend.xyaxis"
                )

                return PortfolioAsset(asset: asset, amount: net, invested: investedInCurrency)
            }

            let totalValue    = assets.reduce(0.0) { $0 + $1.amount * $1.asset.price }
            let totalInvested = assets.reduce(0.0) { $0 + $1.invested }
            let returnPercent = totalInvested > 0
                ? (totalValue - totalInvested) / totalInvested * 100
                : 0

            return UserPortfolio(
                id: p.id,
                name: p.name,
                summary: PortfolioSummary(
                    totalValue: totalValue,
                    invested: totalInvested,
                    totalReturnPercent: returnPercent
                ),
                assets: assets
            )
        }
    }

    // MARK: - Migration (JSON → Firestore)

    private func migrateLocalDataIfNeeded(uid: String) {
        guard let old = localStorage.load(), !old.portfolios.isEmpty else {
            recompute()
            return
        }

        // Конвертируем старые агрегированные позиции в транзакции.
        // Курс на дату миграции — используем текущий (лучшего не знаем).
        let migratedPortfolios: [PersistedPortfolio] = old.portfolios.map { oldP in
            let txns: [PersistedTransaction] = oldP.positions.map { pos in
                PersistedTransaction(
                    id: UUID().uuidString,
                    ticker: pos.asset.ticker,
                    name: pos.asset.name,
                    icon: pos.asset.icon,
                    type: .buy,
                    amount: pos.amount,
                    pricePerShareUSD: pos.amount > 0 ? pos.invested / pos.amount : pos.asset.lastPrice,
                    purchaseDate: Date(),
                    exchangeRatesAtTime: currentRates
                )
            }
            return PersistedPortfolio(id: oldP.id, name: oldP.name, transactions: txns)
        }

        persisted = migratedPortfolios
        recompute()

        Task {
            for portfolio in migratedPortfolios {
                try? await firestoreService.save(portfolio, uid: uid)
            }
        }
    }
}

// MARK: - Firestore-совместимые модели данных

// Одна транзакция (покупка или продажа).
struct PersistedTransaction: Codable {
    let id: String
    var ticker: String
    var name: String
    var icon: String
    var type: TransactionKind
    var amount: Double
    var pricePerShareUSD: Double
    var purchaseDate: Date
    // Курсы USD → другие валюты на момент операции. Ключ = rawValue AppCurrency.
    var exchangeRatesAtTime: [String: Double]

    enum TransactionKind: String, Codable {
        case buy, sell
    }
}

struct PersistedPortfolio: Codable {
    var id: UUID
    var name: String
    var transactions: [PersistedTransaction]

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.transactions = []
    }

    init(id: UUID, name: String, transactions: [PersistedTransaction]) {
        self.id = id
        self.name = name
        self.transactions = transactions
    }
}

// MARK: - Локальный JSON (только для миграции)

protocol PortfolioStorage {
    func load() -> PersistedPortfoliosLegacy?
    func save(persisted: PersistedPortfoliosLegacy)
}

struct JSONPortfolioStorage: PortfolioStorage {
    private let url: URL

    init(filename: String = "portfolios.json") {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.url = docs.appendingPathComponent(filename)
    }

    func load() -> PersistedPortfoliosLegacy? {
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(PersistedPortfoliosLegacy.self, from: data)
    }

    func save(persisted: PersistedPortfoliosLegacy) {
        guard let data = try? JSONEncoder().encode(persisted) else { return }
        try? data.write(to: url, options: [.atomic])
    }
}

// Старый формат — нужен только для миграции.
struct PersistedPortfoliosLegacy: Codable {
    var portfolios: [PersistedPortfolioLegacy]
}

struct PersistedPortfolioLegacy: Codable {
    let id: UUID
    var name: String
    var positions: [PersistedPositionLegacy]
}

struct PersistedPositionLegacy: Codable {
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
