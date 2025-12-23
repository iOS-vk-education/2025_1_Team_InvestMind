//
//  APIConfig.swift
//  InvestMind
//
//  Created by Булат Хусаинов on 23.12.2025.
//

import Foundation

enum APIConfig {

    static let finnhubKey: String = {
        guard let key = Bundle.main.object(
            forInfoDictionaryKey: "FINNHUB_API_KEY"
        ) as? String else {
            fatalError("FINNHUB_API_KEY not found in Info.plist")
        }
        return key
    }()
}
