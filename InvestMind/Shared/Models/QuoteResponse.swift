//
//  QuoteResponse.swift
//  InvestMind
//
//  Created by Булат Хусаинов on 23.12.2025.
//

import Foundation

struct QuoteResponse: Decodable {
    let c: Double      // current price
    let d: Double      // absolute change
    let dp: Double     // percent change
    let h: Double      // high of day
    let l: Double      // low of day
    let o: Double      // open price
    let pc: Double     // previous close
    let t: TimeInterval
}

struct CandleResponse: Decodable {
    let c: [Double]   // close prices
    let t: [Int]      // timestamps (seconds)
    let s: String     // status: "ok" or "no_data"
}
