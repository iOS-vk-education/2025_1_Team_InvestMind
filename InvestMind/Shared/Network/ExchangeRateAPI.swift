//
//  ExchangeRateAPI.swift
//  InvestMind
//
// Курсы валют через Yahoo Finance (тот же ChartAPI что используется для акций).
// Тикеры формата USDXXX=X — курс 1 USD в целевой валюте.
//

import Foundation

final class ExchangeRateAPI {
    static let shared = ExchangeRateAPI()
    private init() {}

    private let pairs: [String: String] = [
        "EUR": "USDEUR=X",
        "RUB": "USDRUB=X",
        "CNY": "USDCNY=X",
        "GBP": "USDGBP=X"
    ]

    // Актуальные курсы USD → другие валюты.
    func fetchCurrentRates(completion: @escaping ([String: Double]) -> Void) {
        let symbols = Array(pairs.values)
        ChartAPI.shared.getQuotes(symbols: symbols) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let quotes):
                var rates: [String: Double] = [:]
                for (currency, ticker) in self.pairs {
                    if let quote = quotes[ticker], quote.c > 0 {
                        rates[currency] = quote.c
                    }
                }
                completion(rates)
            case .failure:
                completion([:])
            }
        }
    }

    // Исторический курс на конкретную дату — используем тот же дневной чарт Yahoo.
    func fetchRates(for date: Date, completion: @escaping ([String: Double]) -> Void) {
        let group = DispatchGroup()
        var rates: [String: Double] = [:]
        let lock = DispatchQueue(label: "ExchangeRateAPI.lock")

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: date)

        // Считаем сколько дней назад была эта дата, чтобы передать range в Yahoo
        let daysSince = max(1, Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 1)

        for (currency, ticker) in pairs {
            group.enter()
            ChartAPI.shared.fetchHistory(symbol: ticker, days: daysSince + 5) { result in
                lock.sync {
                    if case .success(let prices) = result, let price = prices.last, price > 0 {
                        rates[currency] = price
                    }
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(rates)
        }
    }
}
