//
//  LogoAPI.swift
//  InvestMind
//
//  Created by Булат Хусаинов on 28.03.2026.
//

import Foundation

enum LogoAPI {
    static func logoURL(for ticker: String) -> URL? {
        let trimmed = ticker.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !trimmed.isEmpty else { return nil }
        return URL(string: "https://financialmodelingprep.com/image-stock/\(trimmed).png")
    }
}
