import Foundation

struct SymbolSearchResponse: Codable {
    let count: Int
    let result: [SymbolSearchItem]
}

struct SymbolSearchItem: Codable, Hashable {
    let description: String
    let displaySymbol: String
    let symbol: String
    let type: String?
}
