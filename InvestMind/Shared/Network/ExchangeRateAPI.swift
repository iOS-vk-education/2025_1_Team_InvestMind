//
//  ExchangeRateAPI.swift
//  InvestMind
//
// Использует бесплатный API frankfurter.app (без ключа).
// Возвращает курс 1 USD → другие валюты.
//

import Foundation

private struct FrankfurterResponse: Codable {
    let rates: [String: Double]
}

final class ExchangeRateAPI {
    static let shared = ExchangeRateAPI()
    private init() {}

    private let supported = AppCurrency.allCases
        .filter { $0 != .usd }
        .map(\.rawValue)
        .joined(separator: ",")

    // Актуальные курсы USD → остальные валюты.
    func fetchCurrentRates(completion: @escaping ([String: Double]) -> Void) {
        fetch(dateString: "latest", completion: completion)
    }

    // Исторические курсы на конкретную дату (для расчёта вложений по курсу на момент покупки).
    func fetchRates(for date: Date, completion: @escaping ([String: Double]) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        fetch(dateString: formatter.string(from: date), completion: completion)
    }

    private func fetch(dateString: String, completion: @escaping ([String: Double]) -> Void) {
        guard let url = URL(string: "https://api.frankfurter.app/\(dateString)?from=USD&to=\(supported)") else {
            completion([:])
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            let rates: [String: Double]
            if let data,
               let response = try? JSONDecoder().decode(FrankfurterResponse.self, from: data) {
                rates = response.rates
            } else {
                rates = [:]
            }
            DispatchQueue.main.async { completion(rates) }
        }.resume()
    }
}
