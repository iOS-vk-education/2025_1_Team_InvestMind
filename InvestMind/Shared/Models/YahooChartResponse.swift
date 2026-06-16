//
//  YahooChartResponse.swift
//  InvestMind
//
//  Created by Булат Хусаинов on 23.12.2025.
//

import Foundation

struct YahooChartResponse: Decodable {
    let chart: YahooChart
}

struct YahooChart: Decodable {
    let result: [YahooChartResult]?
    let error: YahooChartError?
}

struct YahooChartError: Decodable {
    let code: String?
    let description: String?
}

struct YahooChartResult: Decodable {
    let meta: YahooMeta
    let timestamp: [TimeInterval]?
    let indicators: YahooIndicators
}

struct YahooMeta: Decodable {
    let regularMarketPrice: Double
    let chartPreviousClose: Double
    let regularMarketDayHigh: Double?
    let regularMarketDayLow: Double?
    let regularMarketTime: TimeInterval?
}

struct YahooIndicators: Decodable {
    let quote: [YahooQuote]
}

struct YahooQuote: Decodable {
    let open: [Double?]?
    let high: [Double?]?
    let low: [Double?]?
    let close: [Double?]
}
