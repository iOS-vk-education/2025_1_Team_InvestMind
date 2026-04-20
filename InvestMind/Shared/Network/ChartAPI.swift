//
//  ChartAPI.swift
//  InvestMind
//
//  Created by Булат Хусаинов on 23.12.2025.
//
import Foundation

final class ChartAPI {

    static let shared = ChartAPI()
    private init() {}

    private func completeOnMain<T>(
        _ completion: @escaping (Result<T, Error>) -> Void,
        with result: Result<T, Error>
    ) {
        DispatchQueue.main.async {
            completion(result)
        }
    }

    func fetchHistory(
        symbol: String,
        days: Int,
        completion: @escaping (Result<[Double], Error>) -> Void
    ) {
        let urlString =
        "https://query1.finance.yahoo.com/v8/finance/chart/\(symbol)?range=\(days)d&interval=1d"

        guard let url = URL(string: urlString) else {
            completeOnMain(completion, with: .failure(URLError(.badURL)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                self.completeOnMain(completion, with: .failure(error))
                return
            }

            guard let data else {
                self.completeOnMain(completion, with: .failure(URLError(.badServerResponse)))
                return
            }

            do {
                let response = try JSONDecoder().decode(YahooChartResponse.self, from: data)
                if let err = response.chart.error {
                    let message = (err.code ?? "Yahoo error") + (err.description.map { ": \($0)" } ?? "")
                    let nsError = NSError(
                        domain: "YahooChart",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: message]
                    )
                    self.completeOnMain(completion, with: .failure(nsError))
                    return
                }

                let prices = response.chart.result?.first?
                    .indicators.quote.first?
                    .close
                    .compactMap { $0 } ?? []

                self.completeOnMain(completion, with: .success(prices))
            } catch {
                self.completeOnMain(completion, with: .failure(error))
            }
        }.resume()
    }

    func getQuote(
        symbol: String,
        completion: @escaping (Result<QuoteResponse, Error>) -> Void
    ) {
        let urlString = "https://query1.finance.yahoo.com/v8/finance/chart/\(symbol)?range=1d&interval=1d"

        guard let url = URL(string: urlString) else {
            completeOnMain(completion, with: .failure(URLError(.badURL)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                self.completeOnMain(completion, with: .failure(error))
                return
            }

            guard let data else {
                self.completeOnMain(completion, with: .failure(URLError(.badServerResponse)))
                return
            }

            do {
                let response = try JSONDecoder().decode(YahooChartResponse.self, from: data)

                if let err = response.chart.error {
                    let message = (err.code ?? "Yahoo error") + (err.description.map { ": \($0)" } ?? "")
                    let nsError = NSError(
                        domain: "YahooChart",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: message]
                    )
                    self.completeOnMain(completion, with: .failure(nsError))
                    return
                }

                guard let first = response.chart.result?.first else {
                    self.completeOnMain(completion, with: .failure(URLError(.cannotParseResponse)))
                    return
                }

                let meta = first.meta

                let c = meta.regularMarketPrice
                let pc = meta.chartPreviousClose
                let d = c - pc
                let dp = (pc == 0) ? 0 : (d / pc) * 100

                let o = first.indicators.quote.first?.open?.compactMap { $0 }.first ?? c
                let h = meta.regularMarketDayHigh ?? (first.indicators.quote.first?.high?.compactMap { $0 }.max() ?? c)
                let l = meta.regularMarketDayLow  ?? (first.indicators.quote.first?.low?.compactMap { $0 }.min() ?? c)
                let t = meta.regularMarketTime ?? first.timestamp?.last ?? Date().timeIntervalSince1970

                let quote = QuoteResponse(c: c, d: d, dp: dp, h: h, l: l, o: o, pc: pc, t: t)
                self.completeOnMain(completion, with: .success(quote))
            } catch {
                self.completeOnMain(completion, with: .failure(error))
            }
        }.resume()
    }

    func searchAsset(
        symbol: String,
        completion: @escaping (Result<Asset, Error>) -> Void
    ) {
        let trimmed = symbol.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !trimmed.isEmpty else {
            completeOnMain(completion, with: .failure(URLError(.badURL)))
            return
        }

        getQuote(symbol: trimmed) { result in
            switch result {
            case .success(let quote):
                let asset = Asset(
                    ticker: trimmed,
                    name: trimmed,
                    price: quote.c,
                    change: quote.dp >= 0 ? .up(quote.dp) : .down(abs(quote.dp)),
                    icon: "chart.line.uptrend.xyaxis"
                )
                self.completeOnMain(completion, with: .success(asset))
            case .failure(let error):
                self.completeOnMain(completion, with: .failure(error))
            }
        }
    }
    
    // Функция для получения информации об одном тикере
//    func getQuote(symbol: String, completion: @escaping (Result<[QuoteResponse], Error>) -> Void)
//    {
//        fetchHistory(symbol: symbol, days: 1) {result in
//
//        }
//
//    }
    
//    func fetchQuote(
//        symbol: String,
//        completion: @escaping (Result<QuoteResponse, Error>) -> Void
//    ) {
//        let urlString = "\(baseURL)/quote?symbol=\(symbol)&token=\(apiKey)"
//        guard let url = URL(string: urlString) else { return }
//
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            if let error = error { completion(.failure(error)); return }
//            guard let data = data else { return }
//
//            do {
//                let quote = try JSONDecoder().decode(QuoteResponse.self, from: data)
//                completion(.success(quote))
//            } catch {
//                completion(.failure(error))
//            }
//        }.resume()
//    }
    
    // Функция получения информации о массиве тикеров
    func getQuotes(
        symbols: [String],
        completion: @escaping (Result<[String: QuoteResponse], Error>) -> Void
    ) {
        let group = DispatchGroup()
        var results: [String: QuoteResponse] = [:]
        var firstError: Error?

        let lockQueue = DispatchQueue(label: "ChartAPI.getQuotes.lock")

        for symbol in symbols {
            group.enter()
            getQuote(symbol: symbol) { result in
                lockQueue.sync {
                    switch result {
                    case .success(let quote):
                        results[symbol] = quote
                    case .failure(let error):
                        if firstError == nil { firstError = error }
                    }
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let firstError {
                completion(.failure(firstError))
            } else {
                completion(.success(results))
            }
        }
    }
}
