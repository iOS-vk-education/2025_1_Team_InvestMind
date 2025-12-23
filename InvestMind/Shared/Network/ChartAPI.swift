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

    func fetchHistory(
        symbol: String,
        days: Int,
        completion: @escaping (Result<[Double], Error>) -> Void
    ) {
        let urlString =
        "https://query1.finance.yahoo.com/v8/finance/chart/\(symbol)?range=\(days)d&interval=1d"

        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error {
                completion(.failure(error))
                return
            }

            guard let data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                let response = try JSONDecoder().decode(YahooChartResponse.self, from: data)

                let prices = response.chart.result.first?
                    .indicators.quote.first?
                    .close
                    .compactMap { $0 } ?? []

                completion(.success(prices))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

