//
//  MarketAPI.swift
//  InvestMind
//
//  Created by Булат Хусаинов on 23.12.2025.
//

import Foundation

final class MarketAPI {
    static let shared = MarketAPI()
    private init() {}

    private let baseURL = "https://finnhub.io/api/v1"

    private var apiKey: String {
        guard let key = Bundle.main.infoDictionary?["FINNHUB_API_KEY"] as? String, !key.isEmpty else {
            fatalError("FINNHUB_API_KEY not found in Info.plist")
        }
        return key
    }

    func fetchQuote(
        symbol: String,
        completion: @escaping (Result<QuoteResponse, Error>) -> Void
    ) {
        let urlString = "\(baseURL)/quote?symbol=\(symbol)&token=\(apiKey)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }

            do {
                let quote = try JSONDecoder().decode(QuoteResponse.self, from: data)
                completion(.success(quote))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // Свечи
    func fetchCandles(
        symbol: String,
        resolution: String = "D",
        from: Int,
        to: Int,
        completion: @escaping (Result<CandleResponse, Error>) -> Void
    ) {
        let urlString = "\(baseURL)/stock/candle?symbol=\(symbol)&resolution=\(resolution)&from=\(from)&to=\(to)&token=\(apiKey)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error { completion(.failure(error)); return }
            guard let data = data else { return }

            do {
                let candles = try JSONDecoder().decode(CandleResponse.self, from: data)
                completion(.success(candles))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // Несколько котировок параллельно
    func fetchQuotes(
        symbols: [String],
        completion: @escaping (Result<[String: QuoteResponse], Error>) -> Void
    ) {
        let group = DispatchGroup()
        var results: [String: QuoteResponse] = [:]
        var firstError: Error?

        for symbol in symbols {
            group.enter()
            fetchQuote(symbol: symbol) { result in
                switch result {
                case .success(let quote):
                    results[symbol] = quote
                case .failure(let error):
                    if firstError == nil { firstError = error }
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let firstError { completion(.failure(firstError)) }
            else { completion(.success(results)) }
        }
    }
}

