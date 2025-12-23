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
    let result: [YahooChartResult]
}

struct YahooChartResult: Decodable {
    let indicators: YahooIndicators
}

struct YahooIndicators: Decodable {
    let quote: [YahooQuote]
}

struct YahooQuote: Decodable {
    let close: [Double?]
}
